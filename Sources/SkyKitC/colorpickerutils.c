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

/*
 * this is an implementation of a way to approximate
 * cosine that was discovered in the 7th Century by an
 * indian mathematician and astronomer called Bhaskara
 * the first. it's accurate enough for us and is faster
 * than calling libc's cos(), at least according to
 * the speedtests on my (Snoolie K)'s x86_64 mac.
*/
__attribute__((always_inline)) static double cosBhaskara(double angle) {
  double doublePi = M_PI*2;
  double angleSquared = angle*angle;
  return (doublePi - (4 * angleSquared)) / (doublePi + angleSquared);
}

/* same thing but for sin */
__attribute__((always_inline)) static double sinBhaskara(double angle) {
  double doublePi = M_PI*2;
  return (16 * angle * (M_PI - angle)) / (5 * doublePi - (4 * angle * (M_PI - angle)));
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
    
    double cosHDPi = cosBhaskara(hDPi);
    /* Calculate sin from the cos, not sure if this is faster idk */
    double sinHDPi = sqrt(1 - (cosHDPi * cosHDPi));
    if (hDPi > M_PI) {
        sinHDPi *= -1;
    }
    
    double w;
    
    double lim = atan(height/width)/doublePi;
    
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
                return 1+( atan( (y-y0) / (x-x0) ) / doublePi);
            } else {
                return atan( (y-y0) / (x-x0) ) / doublePi;
            }
        } else if (x < x0) {
            return 0.5-(atan( (y0-y) / (x-x0) ) / doublePi );
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
    double lim = atan(height/width)/doublePi;
    
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
