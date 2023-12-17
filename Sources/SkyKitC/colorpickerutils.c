//
//  colorPickerUtils.c
//  
//
//  Created by Adélaïde Sky on 04/07/2023.
//

#include "colorpickerutils.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define PI_SQUARED M_PI*M_PI
#define ONE_POINT_FIVE_PI M_PI_2*3

/*
 * this is an implementation of 2 ways to approximate
 * cosine. the first was discovered in the 7th Century by
 * an indian mathematician and astronomer called Bhaskara
 * the first. when the passed in angle is over M_PI_2,
 * it instead calls a formula thought of by me (Snoolie
 * K). Perhaps someone else thought of this before me,
 * but I haven't seen anyone else come up with this...
 * this is accurate enough for us and is faster
 * than calling libc's cos(), at least according to
 * the speedtests on my x86_64 mac.
 * Also, we only ever call this in calcPos() and only
 * theoretically need to support a range of 0 to M_PI*2.
*/
#define M_PI_10 M_PI/10 /* PLEASE compile with compiler optimizations to save a div... */

__attribute__((always_inline)) static double cosBhaskaraAndSnoolie(double angle) {
  if (angle > M_PI_2) {
    /*
     * Bhaskara's formula seems to only approximate the range (-M_PI_2,M_PI_2)
     * So, if we are larger, we use another formula I thought of.
     * Perhaps someone else thought of this before me, but I haven't
     * seen anyone else come up with this cosine approximation...
     * unlike bhaskara's it *does* have some inaccuracy but tbh we
     * shouldn't need to worry about the margin of error in this
     * context since it's small enough to not matter. I'm not a
     * mathematician however so this probably isn't perfect, if
     * someone more knowledgable than me could tweak it a bit to
     * be faster or more accurate that would be great :P.
    */
    double b = (angle - ONE_POINT_FIVE_PI);
    double preWarp = (b * (fabs(b) - M_PI));
    return preWarp * (-M_PI_10 - (fabs(preWarp) * 0.03693172));
  }
  double angleSquared = angle*angle;
  return (PI_SQUARED - (4 * angleSquared)) / (PI_SQUARED + angleSquared);
}


/* same thing but for sin. this is only called in wave() */
__attribute__((always_inline)) static double sinBhaskara(double angle) {
  return (16 * angle * (M_PI - angle)) / (5 * PI_SQUARED - (4 * angle * (M_PI - angle)));
}

/*
 * This is Snoolie K's (me) atan approximation
 * It's based off this approximation:
 * y=M_PI_4*x - x*(fabs(x) - 1)*(0.2447 + 0.0663*fabs(x));
 * The problem with that is it's only accurate for a -1,1 range
 * Due to this, I have modified this to handle those scenarios.
 * According to my speedtest on my x86_64 mac, this seems
 * more than 2 times faster than libc's built in atan()
 * function. I'm not a mathematician, so this can
 * probably be improved, but did the best I could and
 * this should work in the app for now :3.
*/
double atanSnoolie(double angle) {
 /* find formula to use */
 if (angle > 2.038) {
  if (angle > 4.0) {
   return 1.43; /* cap at 1.43 */
  }
  return (0.16 * angle) + 0.789;
 } else if (angle < -1.735) {
  if (angle < -3.506) {
   return -1.35; /* cap at -1.35 */
  }
  return (0.16 * angle) - 0.789;
 } else {
  /* main formula */
  return M_PI_4 * angle - angle * (fabs(angle) - 1) * (0.2447 - (0.00722 * fabs(angle)));
 }
}

/*
 * This function is only ever called in SKColorWheel at the moment
 * It is called with HSB values which will always be 0.0-1.0
*/

xy calcPos(double h, double s, double height, double width) {
    double doublePi = M_PI*2;
    double hDPi = h*doublePi;
    
    double y2 = height/2;
    double x2 = width/2;
    
    double cosHDPi = cosBhaskaraAndSnoolie(hDPi);
    /* Calculate sin from the cos, not sure if this is faster idk */
    double sinHDPi = sqrt(1 - (cosHDPi * cosHDPi));
    if (hDPi > M_PI) {
        sinHDPi *= -1;
    }
    
    double w;
    
    double lim = atanSnoolie(height/width)/doublePi;
    
    if ( (h >= lim && h <= 0.5-lim) || (h >= 0.5+lim && h <= 1-lim) ) {
        w = fabs(y2 * s / sinHDPi);
    } else {
        w = fabs(x2 * s / cosHDPi);
    }
    
    xy answer = {
        .x = ( x2 + w * cosHDPi ),
        .y = y2 + w * sinHDPi };
    
    return answer;
}

double calcAngle(double x, double y, double x0, double y0) {
    if (x == x0) {
        if (y0 > y) {
            return 0.75;
        } else {
            return 0.25;
        }
    } else {
        double doublePi = M_PI*2;
        if (x > x0) {
            if (y0 >= y) {
                return 1+( atanSnoolie( (y-y0) / (x-x0) ) / doublePi);
            } else {
                return atanSnoolie( (y-y0) / (x-x0) ) / doublePi;
            }
        } else if (x < x0) {
            return 0.5-(atanSnoolie( (y0-y) / (x-x0) ) / doublePi );
        } else {
            return 0;
        }
    }
}

double calcR(double x,
             double y,
             double width,
             double height,
             double angle) {
    double doublePi = M_PI*2;
    double lim = atanSnoolie(height/width)/doublePi;
    
    if ( (angle >= lim && angle <= 0.5-lim) || (angle >= 0.5+lim && angle <= 1-lim) ) {
        double y0 = height/2;
        return fabs((y-y0)/(height-y0));
    } else {
        double x0 = width/2;
        return fabs((x-x0)/(width-x0));
    }
}

char* rgbToHexString(double r, double g, double b) {
    char* hexString = malloc(7 * sizeof(char));
    
    int redValue = (int)(r * 255);
    int greenValue = (int)(g * 255);
    int blueValue = (int)(b * 255);
    
    sprintf(hexString, "%02x%02x%02x", redValue, greenValue, blueValue);
    
    return hexString;
}
void freeHex(char *array) {
    free(array);
}


xy *wave(unsigned int width, double frequency, double strength, double midHeight) {
    xy *array = malloc((width + 1) * sizeof(xy));
    int x;

    double waveLength = width / frequency;
    for (x = 0; x <= width; x = x + 1) {
        double relativeX = x / waveLength;
        double sine = sinBhaskara(relativeX);
        
        double y = strength * sine + midHeight;
        
        xy answer = { .x = x, .y = y };
        array[x] = answer;
    }
    return array;
}

void freeWave(xy *array) {
    free(array);
}
