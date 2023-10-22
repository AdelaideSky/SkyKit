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
