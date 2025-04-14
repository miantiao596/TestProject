#ifndef UT_CLOTH_DYEING_LIT_INPUT_INCLUDED
#define UT_CLOTH_DYEING_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"

#if UT_RENDERING
#include "../CharacterInput.hlsl"
#endif

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
half _Surface;
half _Cutoff;
half _FogMode;
half _FogIntensity;
float4 _MainTex_ST;
half4 _Color;
half _BumpScale;
half _OcclusionStrength;
half _Roughness;
half _Metallic;
half4 _EmissionColor;
half _EmissionStrength;

// Custom: Four masks
half4 _Mask1Color;
float4 _Mask1DetailNormalMap_ST;
half _Mask1DetailNormalStrength;
half _Mask1Roughness;
half _Mask1Metallic;
half4 _Mask2Color;
float4 _Mask2DetailNormalMap_ST;
half _Mask2DetailNormalStrength;
half _Mask2Roughness;
half _Mask2Metallic;
half4 _Mask3Color;
float4 _Mask3DetailNormalMap_ST;
half _Mask3DetailNormalStrength;
half _Mask3Roughness;
half _Mask3Metallic;
CBUFFER_END

float4 _MainTex_TexelSize;
float4 _MainTex_MipInfo;
TEXTURE2D(_MainTex);
TEXTURE2D(_BumpMap);
TEXTURE2D(_OMREMap);
#define smp _Linear_Repeat
SAMPLER(smp);

// Custom: Four masks
TEXTURE2D(_Mask);
TEXTURE2D(_Mask1DetailNormalMap);   SAMPLER(sampler_Mask1DetailNormalMap);
TEXTURE2D(_Mask2DetailNormalMap);   SAMPLER(sampler_Mask2DetailNormalMap);
TEXTURE2D(_Mask3DetailNormalMap);   SAMPLER(sampler_Mask3DetailNormalMap);

half Alpha(half albedoAlpha, half4 color, half cutoff)
{
    half alpha = albedoAlpha * color.a;
    alpha = AlphaDiscard(alpha, cutoff);
    return alpha;
}

half4 SampleAlbedoAlpha(float2 uv, TEXTURE2D_PARAM(albedoAlphaMap, sampler_albedoAlphaMap))
{
    return half4(SAMPLE_TEXTURE2D(albedoAlphaMap, sampler_albedoAlphaMap, uv));
}

half3 SampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = half(1.0))
{
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
    return UnpackNormalScale(n, scale);
}

half3 ApplyDetailNormal(half3 normalTS, float2 detailUv, Texture2D normalMap, SamplerState sampler_normalMap, half detailMask, half detailNormalStrength)
{
    half3 detailNormalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(normalMap, sampler_normalMap, detailUv), detailNormalStrength);

    // With UNITY_NO_DXT5nm unpacked vector is not normalized for BlendNormalRNM
    // For visual consistency we going to do in all cases
    detailNormalTS = normalize(detailNormalTS);

    return lerp(normalTS, BlendNormalRNM(normalTS, detailNormalTS), detailMask);
}

inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    // 1. Init
    outSurfaceData.specular = half3(0, 0, 0);
    outSurfaceData.clearCoatMask = half(0.0);
    outSurfaceData.clearCoatSmoothness = half(0.0);

    // 2. Sample
    half4 baseCol = SAMPLE_TEXTURE2D(_MainTex, smp, uv * _MainTex_ST.xy + _MainTex_ST.zw);
    half4 omreCol = SAMPLE_TEXTURE2D(_OMREMap, smp, uv * _MainTex_ST.xy + _MainTex_ST.zw);
    
    // 3. Color
    outSurfaceData.alpha = Alpha(baseCol.a, _Color, _Cutoff);
    #ifdef _ENABLE_DETAIL_OPTION
    half4 maskCol = SAMPLE_TEXTURE2D(_Mask, smp, uv * _MainTex_ST.xy + _MainTex_ST.zw);
    outSurfaceData.albedo = _Mask3Color.rgb * maskCol.b;
    // Mask Color Solution: Different blocks replace others' colors
    outSurfaceData.albedo = lerp(outSurfaceData.albedo, maskCol.g * _Mask2Color.rgb, maskCol.g);
    outSurfaceData.albedo = lerp(outSurfaceData.albedo, maskCol.r * _Mask1Color.rgb, maskCol.r);
    outSurfaceData.albedo = lerp(outSurfaceData.albedo, maskCol.a * _Color.rgb * baseCol.rgb, maskCol.a);
    #else
    outSurfaceData.albedo = baseCol.rgb * _Color.rgb;
    #endif
    outSurfaceData.albedo = AlphaModulate(outSurfaceData.albedo, outSurfaceData.alpha);

    // 4. metallic
    // Metallic Solution: support Metallic map
    #if defined (_ENABLE_DETAIL_OPTION) && !defined (_ENABLE_GLOBAL_METALLIC_ROUGHNESS)
    outSurfaceData.metallic = omreCol.g * _Metallic * maskCol.a;
    outSurfaceData.metallic = lerp(outSurfaceData.metallic, _Mask1Metallic, maskCol.r);
    outSurfaceData.metallic = lerp(outSurfaceData.metallic, _Mask2Metallic, maskCol.g);
    outSurfaceData.metallic = lerp(outSurfaceData.metallic, _Mask3Metallic, maskCol.b);
    #else
    outSurfaceData.metallic = omreCol.g * _Metallic;
    #endif

    // 5. roughness
    // Roughness Solution: support Roughness map
    half roughness = 1.0;
    #if defined (_ENABLE_DETAIL_OPTION) && !defined (_ENABLE_GLOBAL_METALLIC_ROUGHNESS)
    roughness = omreCol.b * _Roughness * maskCol.a;
    roughness = lerp(roughness, _Mask1Roughness, maskCol.r);
    roughness = lerp(roughness, _Mask2Roughness, maskCol.g);
    roughness = lerp(roughness, _Mask3Roughness, maskCol.b);
    #else
    roughness = omreCol.b * _Roughness;
    #endif
    outSurfaceData.smoothness = 1.0 - roughness;

    // 6. normal
    outSurfaceData.normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, smp, uv * _MainTex_ST.xy + _MainTex_ST.zw), _BumpScale);
    #ifdef _ENABLE_DETAIL_OPTION
    // Detail Normal Solution: Urp-like Mask Detail normal
    outSurfaceData.normalTS = ApplyDetailNormal(outSurfaceData.normalTS, uv * _Mask1DetailNormalMap_ST.xy + _Mask1DetailNormalMap_ST.zw,
        _Mask1DetailNormalMap, sampler_Mask1DetailNormalMap,maskCol.r, _Mask1DetailNormalStrength);
    outSurfaceData.normalTS = ApplyDetailNormal(outSurfaceData.normalTS, uv * _Mask2DetailNormalMap_ST.xy + _Mask2DetailNormalMap_ST.zw,
        _Mask2DetailNormalMap, sampler_Mask2DetailNormalMap,maskCol.g, _Mask2DetailNormalStrength);
    outSurfaceData.normalTS = ApplyDetailNormal(outSurfaceData.normalTS, uv * _Mask3DetailNormalMap_ST.xy + _Mask3DetailNormalMap_ST.zw,
        _Mask3DetailNormalMap, sampler_Mask3DetailNormalMap,maskCol.b, _Mask3DetailNormalStrength);
    #endif

    // 7. extra
    outSurfaceData.occlusion = LerpWhiteTo(omreCol.r, _OcclusionStrength);
    outSurfaceData.emission = omreCol.a * (outSurfaceData.albedo + _EmissionColor.rgb) * _EmissionStrength;
}


#endif //UT_CLOTH_DYEING_LIT_INPUT_INCLUDED
