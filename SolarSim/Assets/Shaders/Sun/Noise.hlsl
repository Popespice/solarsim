#ifndef SOLARSIM_NOISE_INCLUDED
#define SOLARSIM_NOISE_INCLUDED

// 3D Simplex Noise — Stefan Gustavson / Ashima Arts (MIT)
// Texture-free, WebGL2/HLSL port. Returns [-1, 1].

float3 _Mod289f3(float3 x) { return x - floor(x / 289.0) * 289.0; }
float4 _Mod289f4(float4 x) { return x - floor(x / 289.0) * 289.0; }
float4 _Permute(float4 x)  { return _Mod289f4((x * 34.0 + 1.0) * x); }
float4 _TaylorInvSqrt(float4 r) { return 1.79284291400159 - r * 0.85373472095314; }

float snoise(float3 v)
{
    const float2 C = float2(1.0 / 6.0, 1.0 / 3.0);
    const float4 D = float4(0.0, 0.5, 1.0, 2.0);

    float3 i  = floor(v + dot(v, C.yyy));
    float3 x0 = v - i + dot(i, C.xxx);

    float3 g  = step(x0.yzx, x0.xyz);
    float3 l  = 1.0 - g;
    float3 i1 = min(g.xyz, l.zxy);
    float3 i2 = max(g.xyz, l.zxy);

    float3 x1 = x0 - i1 + C.xxx;
    float3 x2 = x0 - i2 + C.yyy;
    float3 x3 = x0 - D.yyy;

    i = _Mod289f3(i);
    float4 p = _Permute(_Permute(_Permute(
        i.z + float4(0.0, i1.z, i2.z, 1.0))
      + i.y + float4(0.0, i1.y, i2.y, 1.0))
      + i.x + float4(0.0, i1.x, i2.x, 1.0));

    float  n_ = 1.0 / 7.0;
    float3 ns = n_ * D.wyz - D.xzx;

    float4 j  = p - 49.0 * floor(p * ns.z * ns.z);
    float4 x_ = floor(j * ns.z);
    float4 y_ = floor(j - 7.0 * x_);

    float4 xs = x_ * ns.x + ns.yyyy;
    float4 ys = y_ * ns.x + ns.yyyy;
    float4 h  = 1.0 - abs(xs) - abs(ys);

    float4 b0 = float4(xs.xy, ys.xy);
    float4 b1 = float4(xs.zw, ys.zw);

    float4 s0 = floor(b0) * 2.0 + 1.0;
    float4 s1 = floor(b1) * 2.0 + 1.0;
    float4 sh = -step(h, (float4)0.0);

    float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    float3 g0 = float3(a0.xy, h.x);
    float3 g1 = float3(a0.zw, h.y);
    float3 g2 = float3(a1.xy, h.z);
    float3 g3 = float3(a1.zw, h.w);

    float4 norm = _TaylorInvSqrt(float4(dot(g0,g0), dot(g1,g1), dot(g2,g2), dot(g3,g3)));
    g0 *= norm.x; g1 *= norm.y; g2 *= norm.z; g3 *= norm.w;

    float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m * m, float4(dot(g0,x0), dot(g1,x1), dot(g2,x2), dot(g3,x3)));
}

#endif
