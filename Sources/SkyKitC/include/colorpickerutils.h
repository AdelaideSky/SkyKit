//
//  colorPickerUtils.h
//  
//
//  Created by Adélaïde Sky on 04/07/2023.
//

#ifndef colorpickerutils_h
#define colorpickerutils_h

#include <stdio.h>

typedef struct {
    double x;
    double y;
} xy;

xy calcPos(double h, double s, double height, double width);
double calcAngle(double x, double y, double x0, double y0);
double calcR(double x, double y, double width, double height, double angle);
char* doubleToHexString(double value);
char* rgbToHexString(double r, double g, double b);
xy *wave(double width, double height, double frequency, double strength, double midHeight);
#endif /* colorpickerutils_h */
