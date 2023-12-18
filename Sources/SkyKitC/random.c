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
        /* 
         * here, we are generating a RGBA color
         * with R 255, G 255, B 255, and a random
         * A (I mean the function is called
         * randomAlpha, what did you expect,
         * a random red?). Counting the A value,
         * it is a 32 bit color, and only the last
         * 8 bits of the color we're generating.
         * So basically, last 8 bits of rand(),
         * but set all other bits.
        */
        array[i] = 0xFFFFFF00 | rand();
    }
    return array;
}
