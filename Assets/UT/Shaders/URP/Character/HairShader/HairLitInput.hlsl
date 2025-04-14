#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"

#if UT_RENDERING
#include "Assets/UT/Shaders/URP/Character/CharacterInput.hlsl"
#endif
CBUFFER_START(UnityPerMaterial)

float4 _BaseMap_ST;

half _NormalScale;
half _Surface;
half _Cutoff;
half _Dither;

half3 _LightColor1;
half _LightStrength1;
half _LightExponent1;
half _LightPosition1;

half3 _LightColor2;
half _LightStrength2;
half _LightExponent2;
half _LightPosition2;

half3 _HairRootColor;
half3 _HairMiddleColor;
half3 _HairTipColor;
half _HairMiddleRadius;
half _HairTipRadius;
half _HairGradualTranstion;


half _ScatterIntensity;
half _ScatterResult;
half _Noise;
half _NoiseTiling;
half _Metallic;
half _Roughness;
half _HairColorGradualChange;
half _Shadow;
half _SelfShadow;
half4 _MainColor;

#if UT_RENDERING
	half _FogMode;
	half _FogIntensity;
#endif

CBUFFER_END

TEXTURE2D(_BaseMap);       SAMPLER(sampler_BaseMap);   float4 _BaseMap_TexelSize;  float4 _BaseMap_MipInfo;
TEXTURE2D(_NormalMap);       SAMPLER(sampler_NormalMap);  
TEXTURE2D(_HairNosieMap);       SAMPLER(sampler_HairNosieMap);  

#define smp _Linear_Repeat
SAMPLER(smp);


half4 SampleAlbedoAlpha(float2 uv, TEXTURE2D_PARAM(albedoAlphaMap, sampler_albedoAlphaMap))
{
    return half4(SAMPLE_TEXTURE2D(albedoAlphaMap, sampler_albedoAlphaMap, uv));
}

half Alpha(half albedoAlpha, half4 color, half cutoff)
{
    half alpha = albedoAlpha * color.a;
    alpha = AlphaDiscard(alpha, cutoff);
    return alpha;
}

#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
