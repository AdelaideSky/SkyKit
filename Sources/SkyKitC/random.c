//
//  random.c
//  
//
//  Created by Adélaïde Sky on 04/06/2023.
//

#include "random.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int *randomAlpha(int n) {
    int *array = malloc(n * sizeof(int));
    int i;
    srand(time(NULL));
    for (i = 0; i < n; i++)
    {
        array[i] = (255 << 24) | (255 << 16) | (255 << 8) | rand() % 256;
    }
    return array;
}
//
//struct RandomPoints {
//    float diameter;
//    float offsetX;
//    float offsetY;
//};

RandomPoints randomizeIn(float width, float height) {
    RandomPoints result;
    
    static int seeded = 0;
    if (!seeded) {
        srand(time(NULL));
        seeded = 1;
    }
    
    float decision = (width+height) / 4;
    
    result.diameter = ((float)rand() / RAND_MAX) * (decision * 0.5) + (decision * 0.25);
    result.offsetX = ((float)rand() / RAND_MAX) * width - (width * 0.5);
    result.offsetY = ((float)rand() / RAND_MAX) * height - (height * 0.5);
    
    return result;
}
