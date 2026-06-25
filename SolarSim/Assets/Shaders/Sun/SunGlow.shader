// SunGlow — M0 placeholder: flat HDR emissive sphere.
// Proves the HDR -> Bloom pipeline. Replaced by SunSurface (M1) once noise is wired up.
Shader "SolarSim/SunGlow"
{
    Properties
    {
        _EmissiveColor     ("Emissive Color",     Color)  = (1, 0.45, 0.1, 1)
        _EmissiveIntensity ("Emissive Intensity", Float)  = 3.5
    }

    SubShader
    {
        Tags
        {
            "RenderType"     = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue"          = "Geometry"
        }
        LOD 100
        Cull Back
        ZWrite On

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex   Vert
            #pragma fragment Frag
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _EmissiveColor;
                float _EmissiveIntensity;
            CBUFFER_END

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 Frag(Varyings IN) : SV_Target
            {
                // Values > 1.0 in HDR space feed the Bloom effect
                return half4(_EmissiveColor.rgb * _EmissiveIntensity, 1.0);
            }
            ENDHLSL
        }
    }
}
