#ifndef SOLARSIM_FBM_INCLUDED
#define SOLARSIM_FBM_INCLUDED

#include "Noise.hlsl"

// Standard FBM — lacunarity 2, gain 0.5, decorrelated per-octave offsets
float fbm(float3 p, int octaves)
{
    float  v = 0.0;
    float  a = 0.5;
    float3 shift = float3(100.0, 100.0, 100.0);
    for (int i = 0; i < octaves; i++)
    {
        v += a * snoise(p);
        p  = p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// Domain-warped FBM (Inigo Quilez style: fbm(p + k*q) where q = vec(fbm,fbm,fbm))
float fbmWarp(float3 p, float warpStrength, int octaves)
{
    float3 q = float3(
        fbm(p + float3(0.00, 0.00, 0.00), octaves),
        fbm(p + float3(5.20, 1.30, 2.80), octaves),
        fbm(p + float3(1.70, 9.20, 3.10), octaves)
    );
    return fbm(p + warpStrength * q, octaves);
}

#endif
