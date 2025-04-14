#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Extension/48SurfaceDataExtension.hlsl"
#include "Math.hlsl"

#if defined(_DETAIL_MULX2) || defined(_DETAIL_SCALED)
#define _DETAIL
#endif

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _DetailAlbedoMap_ST;
    half4 _BaseColor;
    half4 _SpecColor;
    half4 _EmissionColor;
    half _Cutoff;
    half _Smoothness;
    half _Metallic;
    half _BumpScale;
    half _Parallax;
    half _OcclusionStrength;
    half _ClearCoatMask;
    half _ClearCoatSmoothness;
    half _DetailAlbedoMapScale;
    half _DetailNormalMapScale;
    half _Surface;

    //=============================================================================//
    //=================================48Add Start=================================//
    float3 _DoubleSidedConstants;

    float _AlphaControlMin;
    float _AlphaControlMax;

    float4 _ThreadMap_ST;
    half _ThreadAOScale;
    half _ThreadNormalScale;
    half _ThreadSmoothnessScale;

    half _FuzzScale;
    half _FuzzIntensity;

    half _Anisotropy;

    half4 _GradualColor;
    half _GradualStart;
    half _GradualEnd;

    half _SequinDensity;
    half _SequinRandomSeed;
    half _SequinScaleMin;
    half _SequinScaleMax;
    half4 _SequinColor0;
    half4 _SequinColor1;
    half4 _SequinColor2;
    half _SequinBrightness;

    half4 _UVLayer1;
    half4 _UVLayer2;
    half4 _UVLayer3;
    float4 _BaseMapLayer1_ST;
    float4 _BumpMapLayer1_ST;
    float4 _BaseMapLayer2_ST;
    float4 _BumpMapLayer2_ST;
    float4 _BaseMapLayer3_ST;
    float4 _BumpMapLayer3_ST;
    half4 _BaseColoLayer1;
    half4 _BaseColoLayer2;
    half4 _BaseColoLayer3;
    float _MetallicLayer1;
    float _SmoothnessLayer1;
    float _MetallicLayer2;
    float _SmoothnessLayer2;
    float _MetallicLayer3;
    float _SmoothnessLayer3;
    half _BumpScaleLayer1;
    half _BumpScaleLayer2;
    half _BumpScaleLayer3;
    half _BumpAlphaBlendLayer1;
    half _BumpAlphaBlendLayer2;
    half _BumpAlphaBlendLayer3;
    half _UseMapAlphaLayer1;
    half _UseMapAlphaLayer2;
    half _UseMapAlphaLayer3;

    float4 _SpecCubeMap_HDR;
    float _SpecCubeMapIntensity;

    float4 _SHAr;
    float4 _SHAg;
    float4 _SHAb;
    float4 _SHBr;
    float4 _SHBg;
    float4 _SHBb;
    float4 _SHC;

    float _BillBoardScale;
    float4 _FabricSpecColor;

    float _IridescenceIntensity;
    float _IridescenceThickness;

    float _ShellAmount;
    float _FurLength;
    float4 _FurPatternMap_ST;

    float _FurPatternMapControlMin;
    float _FurPatternMapControlMax;

    float _SmoothnessAMultiplier;
    float _SmoothnessBMultiplier;
    float _SmoothnessLobeMix;

    float _Transmittance;
    float _ThicknessMin;
    float _ThicknessMax;

    float3 _AOColor;

    float4 _HighlightMap_ST;
    float4 _HighlightMap_TexelSize;
    float _HighlightUVMirror;
    float _HighlightUVRotate;
    float _HighlightIntensity;
    //==================================48Add End==================================//
    //=============================================================================//

CBUFFER_END

// NOTE: Do not ifdef the properties for dots instancing, but ifdef the actual usage.
// Otherwise you might break CPU-side as property constant-buffer offsets change per variant.
// NOTE: Dots instancing is orthogonal to the constant buffer above.
#ifdef UNITY_DOTS_INSTANCING_ENABLED

UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _SpecColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float , _Cutoff)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _Metallic)
    UNITY_DOTS_INSTANCED_PROP(float , _BumpScale)
    UNITY_DOTS_INSTANCED_PROP(float , _Parallax)
    UNITY_DOTS_INSTANCED_PROP(float , _OcclusionStrength)
    UNITY_DOTS_INSTANCED_PROP(float , _ClearCoatMask)
    UNITY_DOTS_INSTANCED_PROP(float , _ClearCoatSmoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailAlbedoMapScale)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailNormalMapScale)
    UNITY_DOTS_INSTANCED_PROP(float , _Surface)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

// Here, we want to avoid overriding a property like e.g. _BaseColor with something like this:
// #define _BaseColor UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _BaseColor0)
//
// It would be simpler, but it can cause the compiler to regenerate the property loading code for each use of _BaseColor.
//
// To avoid this, the property loads are cached in some static values at the beginning of the shader.
// The properties such as _BaseColor are then overridden so that it expand directly to the static value like this:
// #define _BaseColor unity_DOTS_Sampled_BaseColor
//
// This simple fix happened to improve GPU performances by ~10% on Meta Quest 2 with URP on some scenes.
static float4 unity_DOTS_Sampled_BaseColor;
static float4 unity_DOTS_Sampled_SpecColor;
static float4 unity_DOTS_Sampled_EmissionColor;
static float  unity_DOTS_Sampled_Cutoff;
static float  unity_DOTS_Sampled_Smoothness;
static float  unity_DOTS_Sampled_Metallic;
static float  unity_DOTS_Sampled_BumpScale;
static float  unity_DOTS_Sampled_Parallax;
static float  unity_DOTS_Sampled_OcclusionStrength;
static float  unity_DOTS_Sampled_ClearCoatMask;
static float  unity_DOTS_Sampled_ClearCoatSmoothness;
static float  unity_DOTS_Sampled_DetailAlbedoMapScale;
static float  unity_DOTS_Sampled_DetailNormalMapScale;
static float  unity_DOTS_Sampled_Surface;

void SetupDOTSLitMaterialPropertyCaches()
{
    unity_DOTS_Sampled_BaseColor            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _BaseColor);
    unity_DOTS_Sampled_SpecColor            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _SpecColor);
    unity_DOTS_Sampled_EmissionColor        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _EmissionColor);
    unity_DOTS_Sampled_Cutoff               = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _Cutoff);
    unity_DOTS_Sampled_Smoothness           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _Smoothness);
    unity_DOTS_Sampled_Metallic             = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _Metallic);
    unity_DOTS_Sampled_BumpScale            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _BumpScale);
    unity_DOTS_Sampled_Parallax             = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _Parallax);
    unity_DOTS_Sampled_OcclusionStrength    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _OcclusionStrength);
    unity_DOTS_Sampled_ClearCoatMask        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _ClearCoatMask);
    unity_DOTS_Sampled_ClearCoatSmoothness  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _ClearCoatSmoothness);
    unity_DOTS_Sampled_DetailAlbedoMapScale = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailAlbedoMapScale);
    unity_DOTS_Sampled_DetailNormalMapScale = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailNormalMapScale);
    unity_DOTS_Sampled_Surface              = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _Surface);
}

#undef UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES
#define UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES() SetupDOTSLitMaterialPropertyCaches()

#define _BaseColor              unity_DOTS_Sampled_BaseColor
#define _SpecColor              unity_DOTS_Sampled_SpecColor
#define _EmissionColor          unity_DOTS_Sampled_EmissionColor
#define _Cutoff                 unity_DOTS_Sampled_Cutoff
#define _Smoothness             unity_DOTS_Sampled_Smoothness
#define _Metallic               unity_DOTS_Sampled_Metallic
#define _BumpScale              unity_DOTS_Sampled_BumpScale
#define _Parallax               unity_DOTS_Sampled_Parallax
#define _OcclusionStrength      unity_DOTS_Sampled_OcclusionStrength
#define _ClearCoatMask          unity_DOTS_Sampled_ClearCoatMask
#define _ClearCoatSmoothness    unity_DOTS_Sampled_ClearCoatSmoothness
#define _DetailAlbedoMapScale   unity_DOTS_Sampled_DetailAlbedoMapScale
#define _DetailNormalMapScale   unity_DOTS_Sampled_DetailNormalMapScale
#define _Surface                unity_DOTS_Sampled_Surface

#endif

TEXTURE2D(_ParallaxMap);
SAMPLER(sampler_ParallaxMap);
TEXTURE2D(_OcclusionMap);
SAMPLER(sampler_OcclusionMap);
TEXTURE2D(_DetailMask);
SAMPLER(sampler_DetailMask);
TEXTURE2D(_DetailAlbedoMap);
SAMPLER(sampler_DetailAlbedoMap);
TEXTURE2D(_DetailNormalMap);
SAMPLER(sampler_DetailNormalMap);
TEXTURE2D(_MetallicGlossMap);
SAMPLER(sampler_MetallicGlossMap);
TEXTURE2D(_SpecGlossMap);
SAMPLER(sampler_SpecGlossMap);
TEXTURE2D(_ClearCoatMap);
SAMPLER(sampler_ClearCoatMap);

//=============================================================================//
//=================================48Add Start=================================//
TEXTURE2D(_FuzzMap);
SAMPLER(sampler_FuzzMap);
TEXTURE2D(_ThreadMap);
SAMPLER(sampler_ThreadMap);

TEXTURE2D(_BaseMapLayer1);
SAMPLER(sampler_BaseMapLayer1);
TEXTURE2D(_BumpMapLayer1);
SAMPLER(sampler_BumpMapLayer1);

TEXTURE2D(_BaseMapLayer2);
SAMPLER(sampler_BaseMapLayer2);
TEXTURE2D(_BumpMapLayer2);
SAMPLER(sampler_BumpMapLayer2);

TEXTURE2D(_BaseMapLayer3);
SAMPLER(sampler_BaseMapLayer3);
TEXTURE2D(_BumpMapLayer3);
SAMPLER(sampler_BumpMapLayer3);

TEXTURECUBE(_SpecCubeMap);
SAMPLER(sampler_SpecCubeMap);

TEXTURE2D(_MatCapMap);
SAMPLER(sampler_MatCapMap);

TEXTURE2D(_FurPatternMap);
SAMPLER(sampler_FurPatternMap);

TEXTURE2D(_ControlMap);
SAMPLER(sampler_ControlMap);

TEXTURE2D(_ThicknessMap);
SAMPLER(sampler_ThicknessMap);

TEXTURE2D(_HighlightMap);
SAMPLER(sampler_HighlightMap);

// TEXTURE2D(_FGDMap);
// SAMPLER(sampler_FGDMap);
//==================================48Add End==================================//
//=============================================================================//

#ifdef _SPECULAR_SETUP
#define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_SpecGlossMap, sampler_SpecGlossMap, uv)
#else
#define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MetallicGlossMap, uv)
#endif

half4 SampleMetallicSpecGloss(float2 uv, half albedoAlpha)
{
    half4 specGloss;

    #ifdef _METALLICSPECGLOSSMAP
    specGloss = half4(SAMPLE_METALLICSPECULAR(uv));
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        specGloss.a = albedoAlpha * _Smoothness;
    #else
    specGloss.a *= _Smoothness;
    #endif
    //=============================================================================//
    //=================================48Add Start=================================//
    #elif _COTNROLMAP_SMO
    half4 controlMap = SAMPLE_TEXTURE2D(_ControlMap, sampler_ControlMap, uv);
    specGloss.r=controlMap.g*_Metallic;//Metallic
    #ifdef _OCCLUSIONMAP
    specGloss.b=LerpWhiteTo(controlMap.b, _OcclusionStrength);//AO
    #else
    specGloss.b=1;
    #endif
    #ifdef _CHARACTER
    specGloss.a=controlMap.r;
    #else
    specGloss.a=controlMap.r*_Smoothness;//Smoothness
    #endif
    //==================================48Add End==================================//
    //=============================================================================//
    #else // _METALLICSPECGLOSSMAP
    #if _SPECULAR_SETUP
        specGloss.rgb = _SpecColor.rgb;
    #else
    specGloss.rgb = _Metallic.rrr;
    #endif

    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        specGloss.a = albedoAlpha * _Smoothness;
    #else
    specGloss.a = _Smoothness;
    #endif
    #endif

    return specGloss;
}

half SampleOcclusion(float2 uv)
{
    #ifdef _OCCLUSIONMAP
        half occ = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
        return LerpWhiteTo(occ, _OcclusionStrength);
    #else
    return half(1.0);
    #endif
}


// Returns clear coat parameters
// .x/.r == mask
// .y/.g == smoothness
half2 SampleClearCoat(float2 uv)
{
    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    half2 clearCoatMaskSmoothness = half2(_ClearCoatMask, _ClearCoatSmoothness);

    #if defined(_CLEARCOATMAP)
    clearCoatMaskSmoothness *= SAMPLE_TEXTURE2D(_ClearCoatMap, sampler_ClearCoatMap, uv).rg;
    #endif

    return clearCoatMaskSmoothness;
    #else
    return half2(0.0, 1.0);
    #endif  // _CLEARCOAT
}

void ApplyPerPixelDisplacement(half3 viewDirTS, inout float2 uv)
{
    #if defined(_PARALLAXMAP)
    uv += ParallaxMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), viewDirTS, _Parallax, uv);
    #endif
}

// Used for scaling detail albedo. Main features:
// - Depending if detailAlbedo brightens or darkens, scale magnifies effect.
// - No effect is applied if detailAlbedo is 0.5.
half3 ScaleDetailAlbedo(half3 detailAlbedo, half scale)
{
    // detailAlbedo = detailAlbedo * 2.0h - 1.0h;
    // detailAlbedo *= _DetailAlbedoMapScale;
    // detailAlbedo = detailAlbedo * 0.5h + 0.5h;
    // return detailAlbedo * 2.0f;

    // A bit more optimized
    return half(2.0) * detailAlbedo * scale - scale + half(1.0);
}

half3 ApplyDetailAlbedo(float2 detailUv, half3 albedo, half detailMask)
{
    #if defined(_DETAIL)
    half3 detailAlbedo = SAMPLE_TEXTURE2D(_DetailAlbedoMap, sampler_DetailAlbedoMap, detailUv).rgb;

    // In order to have same performance as builtin, we do scaling only if scale is not 1.0 (Scaled version has 6 additional instructions)
    #if defined(_DETAIL_SCALED)
    detailAlbedo = ScaleDetailAlbedo(detailAlbedo, _DetailAlbedoMapScale);
    #else
    detailAlbedo = half(2.0) * detailAlbedo;
    #endif

    return albedo * LerpWhiteTo(detailAlbedo, detailMask);
    #else
    return albedo;
    #endif
}

half3 ApplyDetailNormal(float2 detailUv, half3 normalTS, half detailMask)
{
    #if defined(_DETAIL)
    #if BUMP_SCALE_NOT_SUPPORTED
    half3 detailNormalTS = UnpackNormal(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUv));
    #else
    half3 detailNormalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUv), _DetailNormalMapScale);
    #endif

    // With UNITY_NO_DXT5nm unpacked vector is not normalized for BlendNormalRNM
    // For visual consistancy we going to do in all cases
    detailNormalTS = normalize(detailNormalTS);

    return lerp(normalTS, BlendNormalRNM(normalTS, detailNormalTS), detailMask); // todo: detailMask should lerp the angle of the quaternion rotation, not the normals
    #else
    return normalTS;
    #endif
}

//=============================================================================//
//=================================48Add Start=================================//
half2 SampleUV(half2 uv, half4 tilingOffset, half ratio, half rotate)
{
    half angle = rotate * 180;
    uv = uv - float2(0.5, 0.5);
    uv.y = uv.y * ratio;
    uv = (uv + tilingOffset.zw) / tilingOffset.xy;
    uv = float2(uv.x * cos(radians(angle)) - uv.y * sin(radians(angle)),
                uv.y * cos(radians(angle)) + uv.x * sin(radians(angle)));
    uv += float2(0.5, 0.5);
    return uv;
}

half2 MirrorUV(half2 uv, half4 tilingOffset, half ratio, half mirror, half rotate)
{
    tilingOffset.zw*=0.5;
    half2 uv1 = SampleUV(uv, tilingOffset, ratio, rotate);
    half2 uv2 = SampleUV(half2(1 - uv.x, uv.y), tilingOffset, ratio, rotate);
    uv = lerp(uv2, uv1, step(uv.x, 0.5));
    return mirror == 1 ? uv : uv1;
}

//替换镜面反射
void ReplaceSpecCube()
{
    #ifdef _CUSTOMSPECCUBEMAP
        _SpecCubeMap_HDR.x*=_SpecCubeMapIntensity;
        unity_SpecCube0=_SpecCubeMap;
        samplerunity_SpecCube0=sampler_SpecCubeMap;
        unity_SpecCube0_HDR=_SpecCubeMap_HDR;
    #ifdef _REFLECTION_PROBE_BLENDING
            unity_SpecCube1=_SpecCubeMap;
            samplerunity_SpecCube1=sampler_SpecCubeMap;
            unity_SpecCube1_HDR=_SpecCubeMap_HDR;
    #endif
    #endif
}

//双面渲染，法线修正
void ApplyDoubleSidedFlipOrMirror(half faceSign, half3 doubleSidedConstants, inout half3 normalTS)
{
    normalTS = faceSign > 0 ? normalTS : normalTS * doubleSidedConstants;
}

//=====编织贴图
half ThreadSmoothness(half smoothness, half threadSmoothness, half scale)
{
    return saturate(smoothness + lerp(0.0h, (-1.0h + threadSmoothness * 2.0h), scale));
}

half ThreadAO(half occlusion, half threadAO, half scale)
{
    return occlusion * lerp(1.0h, threadAO, scale);
}

half3 ThreadNormal(half4 threadAG, half3 normalTS, half scale)
{
    half3 threadNormal = UnpackNormalAG(threadAG, scale);

    return BlendNormalRNM(normalTS, threadNormal);
}

// threadRemap:
// x - ThreadAOScale
// y - ThreadNormalScale
// z - ThreadSmoothnessScale

void ApplyThreadMapping(real2 uv, half3 threadRemap, inout SurfaceData surfaceData)
{
    half4 thread = SAMPLE_TEXTURE2D(_ThreadMap, sampler_ThreadMap, uv);

    half occlusion = ThreadAO(surfaceData.occlusion, thread.r, threadRemap.x);
    surfaceData.albedo *= occlusion;
    surfaceData.smoothness = ThreadSmoothness(surfaceData.smoothness, thread.b, threadRemap.z);
    surfaceData.normalTS = ThreadNormal(thread, surfaceData.normalTS, threadRemap.y);
    surfaceData.occlusion = occlusion;
}

float4 VoronoiHash(float4 p, float seed)
{
    float4 a = float4(dot(p.xy, float2(127.1, 311.7)),
                      dot(p.xy, float2(269.5, 183.3)),
                      dot(p.zw, float2(127.1, 311.7)),
                      dot(p.zw, float2(269.5, 183.3)));

    return frac(sin(a * seed) * 43758.5453);
}

half4 UVCenterRandom(half4 sudokuOffset, float2 floorUV, half seed, out half4 random)
{
    half4 offsetUV = half4(floorUV + sudokuOffset.xy, floorUV + sudokuOffset.zw);
    random = VoronoiHash(offsetUV, seed) * 0.5;
    half4 center = random + offsetUV;
    return center;
}

half Sequin(half4 sudokuOffset, float2 floorUV, half2 originalUV, half seed, out half4 random)
{
    half4 center = UVCenterRandom(sudokuOffset, floorUV, seed, random);

    half circle1 = distance(originalUV, center.xy) < lerp(_SequinScaleMin, _SequinScaleMax, random.x) ? 1 : 0;
    half circle2 = distance(originalUV, center.zw) < lerp(_SequinScaleMin, _SequinScaleMax, random.z) ? 1 : 0;
    random.xy *= circle1;
    random.zw *= circle2;
    return circle1 + circle2;
}

half4 lerp3(half4 color1, half4 color2, half4 color3, half num)
{
    half4 a = lerp(color2, color1, step(num, 0.333));
    half4 b = lerp(color3, a, step(num, 0.666));
    // return lerp(a, b, num);
    return b;
}

half Sequin(float2 uv, half seed, out half4 outColor, out half2 random)
{
    float2 n = floor(uv);
    float2 f = frac(uv);
    half draw = 0;
    random = 0;
    half4 newRandom1;
    half4 newRandom2;
    if (f.x <= 0.5)
    {
        if (f.y <= 0.5)
        {
            //左上角
            half4 sudokuOffset1 = half4(0, 0, -1, -1);
            half4 sudokuOffset2 = half4(-1, 0, 0, -1);
            draw += Sequin(sudokuOffset1, n, uv, seed, newRandom1);
            draw += Sequin(sudokuOffset2, n, uv, seed, newRandom2);
        }
        else
        {
            //左下角
            half4 sudokuOffset1 = half4(0, 0, -1, 1);
            half4 sudokuOffset2 = half4(-1, 0, 0, 1);
            draw += Sequin(sudokuOffset1, n, uv, seed, newRandom1);
            draw += Sequin(sudokuOffset2, n, uv, seed, newRandom2);
        }
    }
    else
    {
        if (f.y <= 0.5)
        {
            half4 sudokuOffset1 = half4(0, 0, 1, -1);
            half4 sudokuOffset2 = half4(1, 0, 0, -1);
            draw += Sequin(sudokuOffset1, n, uv, seed, newRandom1);
            draw += Sequin(sudokuOffset2, n, uv, seed, newRandom2);
        }
        else
        {
            half4 sudokuOffset1 = half4(0, 0, 1, 1);
            half4 sudokuOffset2 = half4(1, 0, 0, 1);
            draw += Sequin(sudokuOffset1, n, uv, seed, newRandom1);
            draw += Sequin(sudokuOffset2, n, uv, seed, newRandom2);
        }
    }
    random = newRandom1.xy + newRandom1.zw + newRandom2.xy + newRandom2.zw;
    random = saturate(random);

    outColor = lerp3(_SequinColor0, _SequinColor1, _SequinColor2, frac(uv * 0.5).y);
    // outColor = outColor * _SequinBrightness;
    return draw;
}

void Sequin(half2 uv, inout SurfaceData outSurfaceData, inout SurfaceData48 outSurfaceData48)
{
    half4 color;
    half2 random;

    half draw = Sequin(uv * _SequinDensity, _SequinRandomSeed, color, random);
    outSurfaceData48.sequinSpecular = color;

    outSurfaceData48.sequinMask = saturate(draw);
    outSurfaceData48.sequinBrightness = _SequinBrightness;

    random = abs(random * 2 - 1);
    half3 normal;
    normal.xy = lerp(0.5, random, draw) * 2.0 - 1.0;
    normal.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normal.xy, normal.xy))));
    outSurfaceData48.sequinNormalTS = normal;
}

void SampleBaseMapLayer(float2 uv, TEXTURE2D_PARAM(map, sampler_map), half useMapAlpha, half4 baseColor, half metallic,
                        half smoothness, out half layerAlpha,
                        inout SurfaceData outSurfaceData)
{
    half4 baseMap = SAMPLE_TEXTURE2D(map, sampler_map, uv);
    layerAlpha = baseMap.a;
    half l = baseColor.a;
    outSurfaceData.alpha *= lerp(1, layerAlpha, l * useMapAlpha);

    l = baseColor.a * layerAlpha;
    outSurfaceData.albedo = lerp(outSurfaceData.albedo, baseMap.rgb * baseColor.rgb, l);
    outSurfaceData.metallic = lerp(outSurfaceData.metallic, metallic, l);
    outSurfaceData.smoothness = lerp(outSurfaceData.smoothness, smoothness, l);
}

void SampleNormalAOMapLayer(float2 uv, TEXTURE2D_PARAM(map, sampler_map), half scale, half layerAlpha, half alphaBlend,
                            inout SurfaceData outSurfaceData)
{
    half4 n = SAMPLE_TEXTURE2D(map, sampler_map, uv);
    half3 normal = UnpackNormalScale(n, scale);
    normal = normalize(normal);
    outSurfaceData.normalTS = alphaBlend == 0
                                  ? BlendNormal(outSurfaceData.normalTS, normal)
                                  : lerp(outSurfaceData.normalTS, normal, layerAlpha);

    #ifdef _OCCLUSIONMAP
    outSurfaceData.occlusion=lerp(outSurfaceData.occlusion,LerpWhiteTo(n.z, _OcclusionStrength),layerAlpha);
    #endif

    // outSurfaceData.alpha*=n.z;
}

half2 GetUV(half4 channel, half2 uv0, half2 uv1, half2 uv2, half2 uv3)
{
    half2 uv = 0;
    uv += channel.x * uv0;
    uv += channel.y * uv1;
    uv += channel.z * uv2;
    uv += channel.w * uv3;
    return uv;
}

//==================================48Add End==================================//
//=============================================================================//

inline void InitializeStandardLitSurfaceData(float4 uv01, float4 uv23,float4 vertexColor,float faceSign, half furLayer,
                                             out SurfaceData outSurfaceData, out SurfaceData48 outSurfaceData48)
{
    //=============================================================================//
    //=================================48Change Start=================================//
    half2 baseMapUV = TRANSFORM_TEX(uv01.xy, _BaseMap);
    half2 uv0 = uv01.xy;
    half2 uv1 = uv01.zw;
    half2 uv2 = uv23.xy;
    half2 uv3 = uv23.zw;
    half4 baseColor = _BaseColor;

    half4 albedoAlpha = SampleAlbedoAlpha(baseMapUV, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

    half alpha = albedoAlpha.a;

    #ifdef _FUR
    float FurPattern = 1;
    FurPattern = SAMPLE_TEXTURE2D_LOD(_FurPatternMap, sampler_FurPatternMap, TRANSFORM_TEX(uv0, _FurPatternMap),0).r;
    FurPattern=lerp(_FurPatternMapControlMin,_FurPatternMapControlMax,FurPattern);
    
    alpha *= FurPattern * (1.0 - furLayer);
    alpha = furLayer==0?1:alpha;
    #endif

    outSurfaceData.alpha = Alpha(alpha, baseColor, _Cutoff);
    //==================================48Change End==================================//
    //=============================================================================//

    half4 specGloss = SampleMetallicSpecGloss(baseMapUV, albedoAlpha.a);
    outSurfaceData.albedo = albedoAlpha.rgb * baseColor.rgb;
    outSurfaceData.albedo = AlphaModulate(outSurfaceData.albedo, outSurfaceData.alpha);

    #if _SPECULAR_SETUP
    outSurfaceData.metallic = half(1.0);
    outSurfaceData.specular = specGloss.rgb;
    #else
    outSurfaceData.metallic = specGloss.r;
    outSurfaceData.specular = half3(0.0, 0.0, 0.0);
    #endif

    #ifdef _GRADUALCOLOR
    outSurfaceData.albedo = lerp(outSurfaceData.albedo, _GradualColor.rgb,
                                   smoothstep(_GradualStart, _GradualEnd, saturate(uv3.y)));
    #endif

    outSurfaceData.smoothness = specGloss.a;
    outSurfaceData.normalTS = SampleNormal(baseMapUV, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);

    #ifdef _COTNROLMAP_SMO
    outSurfaceData.occlusion =LerpWhiteTo(specGloss.b, _OcclusionStrength);
    #else
    outSurfaceData.occlusion = SampleOcclusion(baseMapUV);
    #endif
    outSurfaceData.emission = SampleEmission(baseMapUV, _EmissionColor.rgb,
                                             TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
    
    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    half2 clearCoat = SampleClearCoat(baseMapUV);
    outSurfaceData.clearCoatMask = clearCoat.r;
    outSurfaceData.clearCoatSmoothness = clearCoat.g;
    #else
    outSurfaceData.clearCoatMask = half(0.0);
    outSurfaceData.clearCoatSmoothness = half(0.0);
    #endif

    #if defined(_DETAIL)
    half detailMask = SAMPLE_TEXTURE2D(_DetailMask, sampler_DetailMask, baseMapUV).a;
    float2 detailUv = baseMapUV * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
    outSurfaceData.albedo = ApplyDetailAlbedo(detailUv, outSurfaceData.albedo, detailMask);
    outSurfaceData.normalTS = ApplyDetailNormal(detailUv, outSurfaceData.normalTS, detailMask);
    #endif

    //=============================================================================//
    //=================================48Add Start=================================//
    outSurfaceData48 = (SurfaceData48)0;
    outSurfaceData48.Anisotropy = _Anisotropy;

    half layerAlpha = 1;
    half2 uvLayer;
    #ifdef _BASEMAPLAYER1
    uvLayer=GetUV(_UVLayer1,uv0,uv1,uv2,uv3);
    SampleBaseMapLayer(TRANSFORM_TEX(uvLayer, _BaseMapLayer1), TEXTURE2D_ARGS(_BaseMapLayer1, sampler_BaseMapLayer1),
                       _UseMapAlphaLayer1,_BaseColoLayer1,_MetallicLayer1,_SmoothnessLayer1, layerAlpha, outSurfaceData);
    #endif
    #ifdef _NORMALMAPLAYER1
    uvLayer=GetUV(_UVLayer1,uv0,uv1,uv2,uv3);
    SampleNormalAOMapLayer(TRANSFORM_TEX(uvLayer, _BumpMapLayer1), TEXTURE2D_ARGS(_BumpMapLayer1, sampler_BumpMapLayer1),
                         _BumpScaleLayer1, layerAlpha, _BumpAlphaBlendLayer1, outSurfaceData);
    #endif
    #ifdef _BASEMAPLAYER2
    uvLayer=GetUV(_UVLayer2,uv0,uv1,uv2,uv3);
    SampleBaseMapLayer(TRANSFORM_TEX(uvLayer, _BaseMapLayer2), TEXTURE2D_ARGS(_BaseMapLayer2, sampler_BaseMapLayer2),_UseMapAlphaLayer2,_BaseColoLayer2,_MetallicLayer2,_SmoothnessLayer2,layerAlpha,outSurfaceData);
    #endif
    #ifdef _NORMALMAPLAYER2
    uvLayer=GetUV(_UVLayer2,uv0,uv1,uv2,uv3);
    SampleNormalAOMapLayer(TRANSFORM_TEX(uvLayer, _BumpMapLayer2), TEXTURE2D_ARGS(_BumpMapLayer2, sampler_BumpMapLayer2),_BumpScaleLayer2,layerAlpha,_BumpAlphaBlendLayer2,outSurfaceData);
    #endif
    #ifdef _BASEMAPLAYER3
    uvLayer=GetUV(_UVLayer3,uv0,uv1,uv2,uv3);
    SampleBaseMapLayer(TRANSFORM_TEX(uvLayer, _BaseMapLayer3), TEXTURE2D_ARGS(_BaseMapLayer3, sampler_BaseMapLayer3),_UseMapAlphaLayer3,_BaseColoLayer3,_MetallicLayer3,_SmoothnessLayer3,layerAlpha,outSurfaceData);
    #endif
    #ifdef _NORMALMAPLAYER3
    uvLayer=GetUV(_UVLayer3,uv0,uv1,uv2,uv3);
    SampleNormalAOMapLayer(TRANSFORM_TEX(uvLayer, _BumpMapLayer3), TEXTURE2D_ARGS(_BumpMapLayer3, sampler_BumpMapLayer3),_BumpScaleLayer3,layerAlpha,_BumpAlphaBlendLayer3,outSurfaceData);
    #endif

    #ifdef _THREADMAP
    float2 threadUV = TRANSFORM_TEX(uv1, _ThreadMap);
    half3 threadRemap = half3(_ThreadAOScale, _ThreadNormalScale, _ThreadSmoothnessScale);
    ApplyThreadMapping(threadUV, threadRemap, outSurfaceData);
    #endif

    #ifdef _FUZZMAP
    #ifdef _THREADMAP
    float2 fuzzUV = TRANSFORM_TEX(uv1, _ThreadMap);
    #else
        float2 fuzzUV =baseMapUV;
    #endif
    half fuzz = lerp(0.0h, SAMPLE_TEXTURE2D(_FuzzMap, sampler_FuzzMap, _FuzzScale * fuzzUV).r, _FuzzIntensity);
    outSurfaceData.albedo = saturate(outSurfaceData.albedo + fuzz.xxx);
    #endif

    #ifdef _SEQUIN
    Sequin(uv1, outSurfaceData, outSurfaceData48);
    #endif

    #ifdef _MATCAP
    half2 uvDistance = (uv0.xy - 0.5) * 2;
    real3 normal;
    normal.xy = clamp(uvDistance, -1, 1);
    normal.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normal.xy, normal.xy))));
    outSurfaceData.normalTS = normal;
    AlphaDiscard(saturate(1 - length(uvDistance)), _Cutoff);
    #endif

    #if defined(_DOUBLESIDED)
    ApplyDoubleSidedFlipOrMirror(faceSign, _DoubleSidedConstants.xyz, outSurfaceData.normalTS);
    #endif

#ifdef _LASHES
BlendTexture(uv0, _LashesTintMap, _LashesTintColor1, _LashesTintColor2, _LashesTintColor3,outSurfaceData.albedo,outSurfaceData.alpha);
#endif

#ifdef _HAIR
BlendTexture(uv0,vertexColor,_HairMaskMap, _HairTintColor1, _HairTintColor2, _HairTintColor3,outSurfaceData.albedo,outSurfaceData.alpha);
outSurfaceData.occlusion =LerpWhiteTo( SampleOcclusion(uv1).r, _OcclusionStrength);
#endif
    
    outSurfaceData.alpha = lerp(_AlphaControlMin, _AlphaControlMax, outSurfaceData.alpha);
    outSurfaceData.specular = _FabricSpecColor.rgb;
    ReplaceSpecCube();

    #ifdef _MATERIAL_FABRIC
    // 遵循物理高光
    //outSurfaceData.albedo *= (1.0 - Max3(outSurfaceData.specular.r, outSurfaceData.specular.g, outSurfaceData.specular.b));
    #endif

    #ifdef _FUR
    outSurfaceData.occlusion = outSurfaceData.occlusion * LerpWhiteTo(furLayer, _OcclusionStrength);;
    #endif

    #ifdef _CHARACTER
    outSurfaceData48.smoothnessB = _SmoothnessBMultiplier*_Smoothness;
    outSurfaceData.smoothness =lerp(outSurfaceData.smoothness, outSurfaceData.smoothness * _SmoothnessAMultiplier*_Smoothness,outSurfaceData.alpha);
    outSurfaceData48.lobeMix =lerp(0,_SmoothnessLobeMix,outSurfaceData.alpha);

    half thickness =0;
    #ifdef _THICKNESSMAP
    thickness = SAMPLE_TEXTURE2D(_ThicknessMap, sampler_ThicknessMap, baseMapUV).r;
    #else
    thickness=1-vertexColor.r;
    #endif
    
    outSurfaceData48.thickness = lerp(_ThicknessMin, _ThicknessMax,thickness);
    outSurfaceData48.subsurfaceMask=_Transmittance;

    half3 aoColor=lerp(1,_AOColor,outSurfaceData.alpha);
    outSurfaceData.albedo=lerp(outSurfaceData.albedo*aoColor,outSurfaceData.albedo,  outSurfaceData.occlusion); 

    // //唇彩的遮罩是放在法线A通道上的，需要提取出来
    // half4 newNormalTS= SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap,baseMapUV);
    // outSurfaceData.clearCoatMask*=saturate(newNormalTS.a*2-1);
    // // outSurfaceData.albedo=saturate(newNormalTS.a*2-1).xxx;
    // newNormalTS.a=newNormalTS.b;//感觉还是有问题
    // outSurfaceData.normalTS = UnpackNormalScale( newNormalTS, _BumpScale);

    // //唇彩光滑度
    // half ccs= outSurfaceData.clearCoatSmoothness*2-1;
    // outSurfaceData.smoothness=lerp(outSurfaceData.smoothness,outSurfaceData.smoothness*saturate(ccs+1),outSurfaceData.clearCoatMask);
    // outSurfaceData.clearCoatSmoothness=lerp(outSurfaceData.clearCoatSmoothness,saturate(ccs),outSurfaceData.clearCoatMask);
    
    // outSurfaceData.specular=SAMPLE_TEXTURE2D(_ControlMap, sampler_ControlMap, baseMapUV).g.xxx;
    // outSurfaceData.specular=0;
    // outSurfaceData.albedo=SAMPLE_TEXTURE2D(_ControlMap, sampler_ControlMap, baseMapUV).g;

    #endif
    
    outSurfaceData48.clearCoatNormalTS = outSurfaceData.normalTS;
    
    AlphaDiscard(outSurfaceData.alpha, _Cutoff);

    //==================================48Add End==================================//
    //=============================================================================//
}

#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
