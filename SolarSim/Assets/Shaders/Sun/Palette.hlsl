#ifndef SOLARSIM_PALETTE_INCLUDED
#define SOLARSIM_PALETTE_INCLUDED

// IQ cosine palette: a + b * cos(2π(c*t + d))
half3 CosPalette(float t, half3 a, half3 b, half3 c, half3 d)
{
    return a + b * cos(6.28318530718 * (c * t + d));
}

// H-alpha palette: deep red -> orange -> yellow-white at t=1
half3 HaPalette(float t)
{
    return CosPalette(t,
        half3(0.50, 0.20, 0.05),
        half3(0.50, 0.35, 0.15),
        half3(1.00, 1.00, 1.00),
        half3(0.00, 0.15, 0.25));
}

// 171Å EUV: blue-gold corona
half3 UV171Palette(float t)
{
    return CosPalette(t,
        half3(0.30, 0.25, 0.10),
        half3(0.40, 0.30, 0.15),
        half3(0.80, 0.90, 1.00),
        half3(0.10, 0.25, 0.40));
}

// 304Å EUV: deep red/pink chromosphere
half3 UV304Palette(float t)
{
    return CosPalette(t,
        half3(0.60, 0.10, 0.10),
        half3(0.40, 0.20, 0.15),
        half3(1.00, 0.80, 0.90),
        half3(0.00, 0.10, 0.20));
}

// White light: neutral grayscale
half3 WhiteLightPalette(float t)
{
    float v = lerp(0.05, 1.0, t);
    return half3(v, v, v);
}

// Quadratic limb darkening: mu = dot(N, V)
float LimbDarkening(float mu, float a, float b)
{
    float ommu = 1.0 - saturate(mu);
    return 1.0 - a * ommu - b * ommu * ommu;
}

// Chromospheric rim glow
half3 RimGlow(float mu, float intensity)
{
    float rim = pow(saturate(1.0 - mu), 3.0);
    return rim * intensity * half3(1.0, 0.4, 0.15);
}

#endif
