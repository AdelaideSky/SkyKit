//
//  Noise_Header.h
//  Egretta
//
//  Created by Adélaïde Sky on 22/11/2023.
//
#include <metal_stdlib>
using namespace metal;

#ifndef Noise_Header_h
#define Noise_Header_h

class Random {
private:
    thread float seed;
    unsigned TausStep(const unsigned z, const int s1, const int s2, const int s3, const unsigned M);

public:
    thread Random(const unsigned seed1, const unsigned seed2 = 1, const unsigned seed3 = 1);

    thread float rand();
};

#endif /* Noise_Header_h */
