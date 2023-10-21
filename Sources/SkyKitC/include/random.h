//
//  random.h
//  
//
//  Created by Adélaïde Sky on 04/06/2023.
//

#ifndef random_h
#define random_h

#include <stdio.h>
int *randomAlpha(int n);
typedef struct {
    float diameter;
    float offsetX;
    float offsetY;
} RandomPoints;
RandomPoints randomizeIn(float width, float height);
#endif /* random_h */
