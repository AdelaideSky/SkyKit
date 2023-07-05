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

xy calcPos(double h, double s, double height, double width) {
    double doublePi = M_PI*2;
    double hDPi = h*doublePi;
    
    double y2 = height/2;
    
    double sinHDPi = sin(hDPi);
    
    double w = (height-y2)*s;
    
    double lim = atan(height/width)/doublePi;
    
    if ( (h >= lim && h <= 0.5-lim) || (h >= 0.5+lim && h <= 1-lim) ) {
        w = fabs(height * s * 0.5 / sinHDPi);
    } else {
        w = fabs(width * s * 0.5 / cos(hDPi));
    }
    
    xy answer = {
        .x = ( ( width / 2 ) + w * cos( h * doublePi ) ),
        .y = y2 + w * sinHDPi };
    
    return answer;
}

double calcAngle(double x, double y, double x0, double y0) {
    double doublePi = M_PI*2;

    if (x == x0) {
        if (y0 > y) {
            return 0.75;
        } else {
            return 0.25;
        }
    } else {
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

char* doubleToHexString(double value) {
    int intValue = (int)(value * 255);
    char* hexString = malloc(3 * sizeof(char));
    
    sprintf(hexString, "%02x", intValue);
    
    return hexString;
}

char* rgbToHexString(double r, double g, double b) {
    char* hexString = malloc(7 * sizeof(char));
    
    char* red = doubleToHexString(r);
    char* green = doubleToHexString(g);
    char* blue = doubleToHexString(b);
    
    sprintf(hexString, "%s%s%s", red, green, blue);
    
    free(red);
    free(green);
    free(blue);
    
    return hexString;
}
void freeHex(char *array) {
    free(array);
}


xy *wave(double width, double height, double frequency, double strength, double midHeight) {
    xy *array = malloc((width + 1) * sizeof(xy));
    int x;

    double waveLength = width / frequency;
    for (x = 0; x <= width; x = x + 1) {
        double relativeX = x / waveLength;
        double sine = sin(relativeX);
        
        double y = strength * sine + midHeight;
        
        xy answer = { .x = x, .y = y };
        array[x] = answer;
    }
    return array;
}

void freeWave(xy *array) {
    free(array);
}
