#ifndef UNIVERSAL_BRDF_INCLUDED
#define UNIVERSAL_BRDF_INCLUDED

#include "48BSDF.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Deprecated.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"

#define kDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) // standard dielectric reflectivity coef at incident angle (= 4%)


TEXTURE2D(_PreIntegratedFGD_GGXDisneyDiffuse);
TEXTURE2D(_PreIntegratedFGD_CharlieAndFabric);

struct BRDFData
{
    half3 albedo;
    half3 diffuse;
    half3 specular;
    half reflectivity;
    half perceptualRoughness;
    half roughness;
    half roughness2;
    half grazingTerm;

    // We save some light invariant BRDF terms so we don't have to recompute
    // them in the light loop. Take a look at DirectBRDF function for detailed explaination.
    half normalizationTerm; // roughness * 4.0 + 2.0
    half roughness2MinusOne; // roughness^2 - 1.0

    //=============================================================================//
    //=================================48Add Start=================================//
    half anisotropy;
    float3 normalWS;
    float3 tangentWS;
    float3 bitangentWS;
    // half3x3 tangentToWorld;
    float3 viewDirectionWS;

    half NdotV;
    half ClampNdotV;

    float3 iblR;
    half iblPerceptualRoughness;
    half diffuseFGD;
    float3 specularFGD;
    float roughnessT;
    float roughnessB;
    half3 fresnel0;

    float partLambdaV;
    float energyCompensationFactor;
    float lobeMix;
    float thickness;
    float3 transmittance;
    float diffusePower;

    half iblPerceptualRoughnessB;
    float perceptualRoughnessB;
    float roughnessTB;
    float roughnessBB;
    float partLambdaVB;
    float3 specularFGDB;
    float energyCompensationFactorB;

    float3 CustomValue;
    float Scatter;

    float cuticleAngleR;
    float cuticleAngleTT;
    float cuticleAngleTRT;
    float roughnessR;
    float roughnessTT;
    float roughnessTRT;
    float3 absorption;
    float distributionNormalizationFactor;
    float perceptualRoughnessRadial;
    //==================================48Add End==================================//
    //=============================================================================//
};

#include "ShaderLibrary/Character/Hair_BRDF.hlsl"
#include "./SubsurfaceScattering/SubsurfaceScattering.hlsl"

half ReflectivitySpecular(half3 specular)
{
    #if defined(SHADER_API_GLES)
    return specular.r; // Red channel - because most metals are either monochrome or with redish/yellowish tint
    #else
    return Max3(specular.r, specular.g, specular.b);
    #endif
}

half OneMinusReflectivityMetallic(half metallic)
{
    // We'll need oneMinusReflectivity, so
    //   1-reflectivity = 1-lerp(dielectricSpec, 1, metallic) = lerp(1-dielectricSpec, 0, metallic)
    // store (1-dielectricSpec) in kDielectricSpec.a, then
    //   1-reflectivity = lerp(alpha, 0, metallic) = alpha + metallic*(0 - alpha) =
    //                  = alpha - metallic * alpha
    half oneMinusDielectricSpec = kDielectricSpec.a;
    return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
}

half MetallicFromReflectivity(half reflectivity)
{
    half oneMinusDielectricSpec = kDielectricSpec.a;
    return (reflectivity - kDielectricSpec.r) / oneMinusDielectricSpec;
}

inline void InitializeBRDFDataDirect(half3 albedo, half3 diffuse, half3 specular, half reflectivity,
                                     half oneMinusReflectivity, half smoothness, inout half alpha,
                                     out BRDFData outBRDFData)
{
    outBRDFData = (BRDFData)0;
    outBRDFData.albedo = albedo;
    outBRDFData.diffuse = diffuse;
    outBRDFData.specular = specular;
    outBRDFData.reflectivity = reflectivity;

    outBRDFData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(smoothness);
    outBRDFData.roughness = max(PerceptualRoughnessToRoughness(outBRDFData.perceptualRoughness), HALF_MIN_SQRT);
    outBRDFData.roughness2 = max(outBRDFData.roughness * outBRDFData.roughness, HALF_MIN);
    outBRDFData.grazingTerm = saturate(smoothness + reflectivity);
    outBRDFData.normalizationTerm = outBRDFData.roughness * half(4.0) + half(2.0);
    outBRDFData.roughness2MinusOne = outBRDFData.roughness2 - half(1.0);

    // Input is expected to be non-alpha-premultiplied while ROP is set to pre-multiplied blend.
    // We use input color for specular, but (pre-)multiply the diffuse with alpha to complete the standard alpha blend equation.
    // In shader: Cs' = Cs * As, in ROP: Cs' + Cd(1-As);
    // i.e. we only alpha blend the diffuse part to background (transmittance).
    #if defined(_ALPHAPREMULTIPLY_ON)
        // TODO: would be clearer to multiply this once to accumulated diffuse lighting at end instead of the surface property.
        outBRDFData.diffuse *= alpha;
    #endif
}

// Legacy: do not call, will not correctly initialize albedo property.
inline void InitializeBRDFDataDirect(half3 diffuse, half3 specular, half reflectivity, half oneMinusReflectivity,
                                     half smoothness, inout half alpha, out BRDFData outBRDFData)
{
    InitializeBRDFDataDirect(half3(0.0, 0.0, 0.0), diffuse, specular, reflectivity, oneMinusReflectivity, smoothness,
                             alpha, outBRDFData);
}

// Initialize BRDFData for material, managing both specular and metallic setup using shader keyword _SPECULAR_SETUP.
inline void InitializeBRDFData(half3 albedo, half metallic, half3 specular, half smoothness, inout half alpha,
                               out BRDFData outBRDFData)
{
    #ifdef _SPECULAR_SETUP
    half reflectivity = ReflectivitySpecular(specular);
    half oneMinusReflectivity = half(1.0) - reflectivity;
    half3 brdfDiffuse = albedo * oneMinusReflectivity;
    half3 brdfSpecular = specular;
    #else
    half oneMinusReflectivity = OneMinusReflectivityMetallic(metallic);
    half reflectivity = half(1.0) - oneMinusReflectivity;
    half3 brdfDiffuse = albedo * oneMinusReflectivity;
    half3 brdfSpecular = lerp(kDieletricSpec.rgb, albedo, metallic);
    #endif

    InitializeBRDFDataDirect(albedo, brdfDiffuse, brdfSpecular, reflectivity, oneMinusReflectivity, smoothness, alpha,
                             outBRDFData);
}

half3 EnvironmentBRDFSheen(BRDFData brdfData, half fresnelTerm)
{
    float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
    return half3(surfaceReduction * lerp(0.0, brdfData.grazingTerm, fresnelTerm).xxx);
}

//=============================================================================//
//=================================48Add Start=================================//
//薄膜干涉
float3 GetIridescenceF(float clearCoatMask, float3 fresnel0, float NoV, float IridescenceThickness,
                       float iridescenceIntensity)
{
    //评估彩虹色
    float viewAngle = ClampNdotV(NoV);
    float topIor = 1.0;
    #ifdef _CLEARCOAT
    topIor = lerp(1.0, 1.5, clearCoatMask);
    viewAngle = sqrt(1.0 + Sq(1.0f / topIor) * (Sq(NoV) - 1.0));
    #endif

    float3 F_Iridescence = EvalIridescence(topIor, viewAngle, IridescenceThickness, fresnel0,
                                           lerp(0.1, 10, iridescenceIntensity));
    return F_Iridescence;
}


// For image based lighting, a part of the BSDF is pre-integrated.
// This is done both for specular GGX height-correlated and DisneyDiffuse
// reflectivity is  Integral{(BSDF_GGX / F) - use for multiscattering
void GetPreIntegratedFGDGGXAndDisneyDiffuse(float NdotV, float perceptualRoughness, float3 fresnel0, float F90,
                                            out float3 specularFGD, out float diffuseFGD, out float reflectivity)
{
    #ifdef _FGDMAP
    // We want the LUT to contain the entire [0, 1] range, without losing half a texel at each side.
    float2 coordLUT = Remap01ToHalfTexelCoord(float2(sqrt(NdotV), perceptualRoughness), 64);
    float3 preFGD = SAMPLE_TEXTURE2D_LOD(_PreIntegratedFGD_GGXDisneyDiffuse, sampler_LinearClamp, coordLUT, 0).xyz;
    #else
    // 后续优化为贴图采样
    float3 preFGD = IntegrateGGXAndDisneyDiffuseFGD(NdotV,perceptualRoughness,512).xyz;
    #endif
    preFGD = saturate(preFGD);

    // Pre-integrate GGX FGD
    // Integral{BSDF * <N,L> dw} =
    // Integral{(F0 + (F90 - F0) * (1 - <V,H>)^5) * (BSDF / F) * <N,L> dw} =
    // (F90 - F0) * Integral{(1 - <V,H>)^5 * (BSDF / F) * <N,L> dw} + F0 * Integral{(BSDF / F) * <N,L> dw}=
    // (F90 - F0) * x + F0 * y
    specularFGD = (F90 - fresnel0) * preFGD.xxx + fresnel0 * preFGD.yyy;

    // Pre integrate DisneyDiffuse FGD:
    // z = DisneyDiffuse
    // Remap from the [0, 1] to the [0.5, 1.5] range.
    diffuseFGD = preFGD.z + 0.5;

    reflectivity = preFGD.y;
}

void GetPreIntegratedFGDCharlieAndFabricLambert(BRDFData bsdfData, float NdotV, float perceptualRoughness,
                                                float3 fresnel0, out float3 specularFGD, out float diffuseFGD,
                                                out float reflectivity)
{
    #ifdef _FGDMAP
    float3 preFGD = SAMPLE_TEXTURE2D_LOD(_PreIntegratedFGD_CharlieAndFabric, sampler_LinearClamp,
                                         float2(NdotV, perceptualRoughness), 0).xyz;
    #else
    // 后续优化为贴图采样
    float3 preFGD = IntegrateCharlieAndFabricLambertFGD(bsdfData.viewDirectionWS, bsdfData.normalWS, perceptualRoughness,512);
    #endif
    preFGD = saturate(preFGD);

    specularFGD = lerp(preFGD.xxx, preFGD.yyy, fresnel0) * 2.0f * PI;

    // z = FabricLambert
    diffuseFGD = preFGD.z;

    reflectivity = preFGD.y;
}


float CalculateEnergyCompensationFromSpecularReflectivity(float specularReflectivity)
{
    float energyCompensation = 1.0 / specularReflectivity - 1.0;
    return energyCompensation;
}

float3 ApplyEnergyCompensationToSpecularLighting(float3 specularLighting, float3 fresnel0, float energyCompensation)
{
    specularLighting *= 1.0 + fresnel0 * energyCompensation;
    return specularLighting;
}

float3 GetEnergyCompensationFactor(float specularReflectivity, float3 fresnel0)
{
    float ec = CalculateEnergyCompensationFromSpecularReflectivity(specularReflectivity);
    return ApplyEnergyCompensationToSpecularLighting(float3(1.0, 1.0, 1.0), fresnel0, ec);
}

void InitializeBRDFData_Fabric(half reflectivity, half oneMinusReflectivity, half3 brdfDiffuse, half3 brdfSpecular,
                               inout SurfaceData surfaceData, inout SurfaceData48 surfaceData48,
                               inout InputData inputData, inout InputData48 inputData48, inout BRDFData outBRDFData)
{
    outBRDFData.anisotropy = surfaceData48.Anisotropy;
    outBRDFData.fresnel0 = surfaceData.specular;
    outBRDFData.iblPerceptualRoughness = outBRDFData.perceptualRoughness;
    ConvertAnisotropyToClampRoughness(outBRDFData.perceptualRoughness, outBRDFData.anisotropy, outBRDFData.roughnessT,
                                      outBRDFData.roughnessB);
    #ifdef _FABRIC_SILK
    float TdotV = dot(outBRDFData.tangentWS,   outBRDFData.viewDirectionWS);
    float BdotV = dot(outBRDFData.bitangentWS, outBRDFData.viewDirectionWS);        
    outBRDFData.partLambdaV=GetSmithJointGGXAnisoPartLambdaV(TdotV, BdotV, outBRDFData.ClampNdotV, outBRDFData.roughnessT, outBRDFData.roughnessB);
    #endif
    float unused;
    float3 iblN;
    #ifdef _FABRIC_SILK
    GetPreIntegratedFGDGGXAndDisneyDiffuse(outBRDFData.ClampNdotV, outBRDFData.iblPerceptualRoughness, outBRDFData.fresnel0, 1.0f,outBRDFData.specularFGD, outBRDFData.diffuseFGD, unused);
    GetGGXAnisotropicModifiedNormalAndRoughness(outBRDFData.bitangentWS, outBRDFData.tangentWS, outBRDFData.normalWS, outBRDFData.viewDirectionWS, outBRDFData.anisotropy, outBRDFData.iblPerceptualRoughness, iblN, outBRDFData.iblPerceptualRoughness);
    #else
    GetPreIntegratedFGDCharlieAndFabricLambert(outBRDFData, outBRDFData.ClampNdotV, outBRDFData.iblPerceptualRoughness,
                                               outBRDFData.fresnel0, outBRDFData.specularFGD, outBRDFData.diffuseFGD,
                                               unused);
    iblN = outBRDFData.normalWS;
    #endif
    outBRDFData.iblR = reflect(-outBRDFData.viewDirectionWS, iblN);
}

void InitializeBRDFData_StackLit(half reflectivity, half oneMinusReflectivity, half3 brdfDiffuse, half3 brdfSpecular,
                                 inout SurfaceData surfaceData, inout SurfaceData48 surfaceData48,
                                 inout InputData inputData, inout InputData48 inputData48, inout BRDFData outBRDFData)
{
    outBRDFData.anisotropy = surfaceData48.Anisotropy;
    outBRDFData.lobeMix = surfaceData48.lobeMix;
    outBRDFData.specular =surfaceData.specular;
    outBRDFData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surfaceData.smoothness);
    outBRDFData.perceptualRoughnessB = PerceptualSmoothnessToPerceptualRoughness(surfaceData48.smoothnessB);

    outBRDFData.diffusePower = GetDiffusePower();

    FillMaterialTransmission(surfaceData48.thickness, outBRDFData);
    outBRDFData.transmittance *= surfaceData48.subsurfaceMask;

    #ifdef _SPECULAR_SETUP
    outBRDFData.fresnel0 = outBRDFData.specular;
    #else
    outBRDFData.fresnel0 = ComputeFresnel0(surfaceData.albedo, surfaceData.metallic, DEFAULT_SPECULAR_VALUE);
    #endif

    ConvertAnisotropyToRoughness(outBRDFData.perceptualRoughness, outBRDFData.anisotropy, outBRDFData.roughnessT,
                                 outBRDFData.roughnessB);
    ConvertAnisotropyToRoughness(outBRDFData.perceptualRoughnessB, outBRDFData.anisotropy, outBRDFData.roughnessTB,
                                 outBRDFData.roughnessBB);

    // outBRDFData.roughnessT = ClampRoughnessForAnalyticalLights(outBRDFData.roughnessT);
    // outBRDFData.roughnessB = ClampRoughnessForAnalyticalLights(outBRDFData.roughnessB);
    // outBRDFData.roughnessTB = ClampRoughnessForAnalyticalLights(outBRDFData.roughnessTB);
    // outBRDFData.roughnessBB = ClampRoughnessForAnalyticalLights(outBRDFData.roughnessBB);

    //=================

    float specularReflectivity[2];
    float diffuseFGD[2];

    // Also important: iblPerceptualRoughness[] is used for specular occlusion
    outBRDFData.iblPerceptualRoughness = outBRDFData.perceptualRoughness;
    outBRDFData.iblPerceptualRoughnessB = outBRDFData.perceptualRoughnessB;


    // This will be used for the factored out base layer FGD fetches
    float3 f0forCalculatingFGD = outBRDFData.fresnel0;

    #ifdef _SPECULAR_SETUP
    float F90 =saturate(50.0 * dot(f0forCalculatingFGD, 0.333));
    #else
    float F90 = 1.0;
    #endif
    GetPreIntegratedFGDGGXAndDisneyDiffuse(outBRDFData.ClampNdotV,
                                           outBRDFData.iblPerceptualRoughness,
                                           f0forCalculatingFGD,
                                           F90,
                                           outBRDFData.specularFGD,
                                           diffuseFGD[0],
                                           specularReflectivity[0]);

    GetPreIntegratedFGDGGXAndDisneyDiffuse(outBRDFData.ClampNdotV,
                                           outBRDFData.iblPerceptualRoughnessB,
                                           f0forCalculatingFGD,
                                           F90,
                                           outBRDFData.specularFGDB,
                                           diffuseFGD[1],
                                           specularReflectivity[1]);
    outBRDFData.CustomValue = outBRDFData.specular;
    outBRDFData.partLambdaV = GetSmithJointGGXPartLambdaV(outBRDFData.NdotV, outBRDFData.roughnessT);
    outBRDFData.partLambdaVB = GetSmithJointGGXPartLambdaV(outBRDFData.NdotV, outBRDFData.roughnessTB);

    float3 iblN = outBRDFData.normalWS;
    outBRDFData.iblR = reflect(-outBRDFData.viewDirectionWS, iblN);

    outBRDFData.energyCompensationFactor = GetEnergyCompensationFactor(specularReflectivity[0], outBRDFData.fresnel0);
    outBRDFData.energyCompensationFactorB = GetEnergyCompensationFactor(specularReflectivity[1], outBRDFData.fresnel0);

    outBRDFData.specularFGD *= (1 - outBRDFData.lobeMix);
    outBRDFData.specularFGDB *= (outBRDFData.lobeMix);
    outBRDFData.diffuseFGD = lerp(diffuseFGD[0], diffuseFGD[1], outBRDFData.lobeMix);
}

inline void InitializeBRDFData(inout SurfaceData surfaceData, inout SurfaceData48 surfaceData48,
                               inout InputData inputData, inout InputData48 inputData48, out BRDFData outBRDFData)
{
    #ifdef _IRIDESCENCE
    surfaceData.albedo = GetIridescenceF(surfaceData.clearCoatMask, surfaceData.albedo,
                                         dot(inputData.normalWS, inputData.viewDirectionWS), _IridescenceThickness,
                                         _IridescenceIntensity);
    surfaceData.albedo = saturate(surfaceData.albedo);
    // outBRDFData.fresnel0=(SAMPLE_TEXTURECUBE(_LaserMap, sampler_LaserMap, reflect(-inputData.viewDirectionWS, inputData.normalWS)));
    #endif

    #ifdef _SPECULAR_SETUP
    half reflectivity = ReflectivitySpecular(surfaceData.specular);
    half oneMinusReflectivity = half(1.0) - reflectivity;
    half3 brdfDiffuse = surfaceData.albedo * oneMinusReflectivity;
    half3 brdfSpecular = surfaceData.specular;
    #else
    half oneMinusReflectivity = OneMinusReflectivityMetallic(surfaceData.metallic);
    half reflectivity = half(1.0) - oneMinusReflectivity;
    half3 brdfDiffuse = surfaceData.albedo * oneMinusReflectivity;
    half3 brdfSpecular = lerp(kDieletricSpec.rgb, surfaceData.albedo, surfaceData.metallic);
    #endif

    #if defined (_MATERIAL_FABRIC)
    #ifdef _FABRIC_SILK
    InitializeBRDFDataDirect(surfaceData.albedo, brdfDiffuse, brdfSpecular, reflectivity, oneMinusReflectivity,surfaceData.smoothness, surfaceData.alpha, outBRDFData);
    #else
    InitializeBRDFDataDirect(surfaceData.albedo, brdfDiffuse, brdfSpecular, 1.0h, oneMinusReflectivity,lerp(0.0h, 0.5h, surfaceData.smoothness),surfaceData.alpha, outBRDFData);
    #endif
    //InitializeBRDFDataDirect会清空outBRDFData，所有赋值需要在outBRDFData之后
    outBRDFData.normalWS=inputData.normalWS;
    outBRDFData.viewDirectionWS=inputData.viewDirectionWS;
    outBRDFData.tangentWS=inputData48.tangentWS;
    outBRDFData.bitangentWS=inputData48.bitangentWS;
    outBRDFData.NdotV=dot(outBRDFData.normalWS, outBRDFData.viewDirectionWS);
    outBRDFData.ClampNdotV = ClampNdotV(outBRDFData.NdotV);

    InitializeBRDFData_Fabric( reflectivity,  oneMinusReflectivity,  brdfDiffuse, brdfSpecular, surfaceData,surfaceData48,  inputData,  inputData48,   outBRDFData);
    
    #elif defined (_CHARACTER)
    InitializeBRDFDataDirect(surfaceData.albedo, brdfDiffuse, brdfSpecular, reflectivity, oneMinusReflectivity,
                             surfaceData.smoothness, surfaceData.alpha, outBRDFData);
    //InitializeBRDFDataDirect会清空outBRDFData，所有赋值需要在outBRDFData之后
    outBRDFData.normalWS = inputData.normalWS;
    outBRDFData.viewDirectionWS = inputData.viewDirectionWS;
    outBRDFData.tangentWS = inputData48.tangentWS;
    outBRDFData.bitangentWS = inputData48.bitangentWS;
    outBRDFData.NdotV = dot(outBRDFData.normalWS, outBRDFData.viewDirectionWS);
    outBRDFData.ClampNdotV = ClampNdotV(outBRDFData.NdotV);

    InitializeBRDFData_StackLit(reflectivity, oneMinusReflectivity, brdfDiffuse, brdfSpecular, surfaceData,
                                surfaceData48, inputData, inputData48, outBRDFData);
    #else
    InitializeBRDFDataDirect(surfaceData.albedo, brdfDiffuse, brdfSpecular, reflectivity, oneMinusReflectivity, surfaceData.smoothness, surfaceData.alpha, outBRDFData);
    outBRDFData.viewDirectionWS=inputData.viewDirectionWS;
    outBRDFData.normalWS=inputData.normalWS;
    outBRDFData.iblR = reflect(-outBRDFData.viewDirectionWS, outBRDFData.normalWS);
    #endif

    #ifdef _HAIR
    outBRDFData.tangentWS = inputData48.tangentWS;
    ConvertSurfaceDataToBSDFData( outBRDFData);
    #endif
}


float4 IntegrateCharlieAndFabricLambertFGD(float3 V, float3 N, float roughness, uint sampleCount = 4096)
{
    // Ref: "Production Friendly Microfacet Sheen BRDF": http://www.aconty.com/pdf/s2017_pbs_imageworks_sheen.pdf
    float NdotV = ClampNdotV(dot(N, V));
    float4 acc = float4(0.0, 0.0, 0.0, 0.0);
    float3x3 localToWorld = GetLocalFrame(N);
    float rcpSampleCount = rcp(sampleCount);
    for (uint i = 0; i < sampleCount; ++i)
    {
        // uniformly sample the hemisphere (recommended by the paper)
        float3 localL = SampleConeStrata(i, rcpSampleCount, 0.0f);
        float NdotL = localL.z;
        float3 L = mul(localL, localToWorld);

        // evaluate cos-weighted "Charlie" BRDF without the Fresnel term
        float3 H = normalize(V + L);
        float NdotH = dot(N, H);
        float weight = D_Charlie(NdotH, roughness) * V_Charlie(NdotL, NdotV, roughness) * NdotL;

        // Integral{BSDF * <N,L> dw} =
        // Integral{(F0 + (1 - F0) * (1 - <V,H>)^5) * (BSDF / F) * <N,L> dw} =
        // (1 - F0) * Integral{(1 - <V,H>)^5 * (BSDF / F) * <N,L> dw} + F0 * Integral{(BSDF / F) * <N,L> dw}=
        // (1 - F0) * x + F0 * y = lerp(x, y, F0)
        float VdotH = dot(V, H);
        acc.x += weight * pow(1 - VdotH, 5);
        acc.y += weight;

        // for Fabric Lambert we still use a Cosine importance sampling
        float weightOverPdf;
        float2 u = Hammersley2d(i, sampleCount);
        ImportanceSampleLambert(u, localToWorld, L, NdotL, weightOverPdf);
        float fabricLambert = FabricLambertNoPI(roughness);
        acc.z += fabricLambert * weightOverPdf;
    }

    // Normalize the accumulated value
    acc *= 1.0f / sampleCount;
    // should be multiplied by 2pi, but to keep the values in [0, 1] range for texture storage we defer the multiplication to sampling in GetPreIntegratedFGDCharlieAndFabricLambert
    return acc;
}

/*
float3 IntegrateSpecularCottonWoolIBLRef(BRDFData bsdfData,half3 indirectSpecular,uint sampleCount = 2048)
{
    float3 V=bsdfData.viewDirectionWS;
    // In case of the cotton wool, the material is not anisotropic so we don't need a specific local frame
    float3x3 localToWorld = GetLocalFrame(bsdfData.normalWS);
    float    NdotV        = ClampNdotV(dot(bsdfData.normalWS, V));
    float3 acc   = float3(0.0, 0.0, 0.0);

    // Add some jittering on Hammersley2d
    float2 randNum  = InitRandom(V.xy * 0.5 + 0.5);

    float roughnessT;
    float roughnessB;
    ConvertAnisotropyToClampRoughness(bsdfData.perceptualRoughness, bsdfData.anisotropy, roughnessT, roughnessB);
    float3 fresnel0=bsdfData.specular;
    
    float rcpSampleCount = rcp(sampleCount);
    for (uint i = 0; i < sampleCount; ++i)
    {
        float2 u    = Hammersley2d(i, sampleCount);
        u           = frac(u + randNum);

        float3 localL = SampleHemisphereCosine(u.x, u.y);
        float NdotL = localL.z;
        float3 L = mul(localL, localToWorld);

        float LdotV, NdotH, LdotH, invLenLV;
        GetBSDFAngle(V, L, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);

        // Incident Light intensity
        //float4 val = SampleEnv(lightLoopContext, lightData.envIndex, L, 0, lightData.rangeCompressionFactorCompensation, 0.5);
        half3 val = indirectSpecular;
        
        // BRDF Data
        float3 F = F_Schlick(fresnel0, LdotH);
        float D = D_Charlie(NdotH, roughnessT);
        float Vis = V_Charlie(NdotL, NdotV, roughnessT);

        // The sample is multiplied by NdotL and divided by pdf: acc += f(w)*l(w)*cos(w)/pdf.
        // For cos-weighted importance sampling pdf=NdotL/PI. NdotL cancels out and we multiply by PI in the end
        acc += F * D * Vis * val.rgb;
    }
    return acc * PI / sampleCount;
}

float3 IntegrateSpecularSilkIBLRef(BRDFData bsdfData,half3 indirectSpecular,uint sampleCount = 2048)
{
    float3 V=bsdfData.viewDirectionWS;
    // Given that it may be anisotropic we need to compute the tangent oriented basis
    float3x3 localToWorld = float3x3(bsdfData.tangentWS, bsdfData.bitangentWS, bsdfData.normalWS);
    float    NdotV        = ClampNdotV(dot(bsdfData.normalWS, V));
    float3 acc   = float3(0.0, 0.0, 0.0);

    // Add some jittering on Hammersley2d
    float2 randNum  = InitRandom(V.xy * 0.5 + 0.5);

     
    float roughnessT;
    float roughnessB;
    ConvertAnisotropyToClampRoughness(bsdfData.perceptualRoughness, bsdfData.anisotropy, roughnessT, roughnessB);
    float3 fresnel0=bsdfData.specular;
    
    for (uint i = 0; i < sampleCount; ++i)
    {
        float2 u    = Hammersley2d(i, sampleCount);
        u           = frac(u + randNum);

        float VdotH;
        float NdotL;
        float3 L;
        float weightOverPdf;
        ImportanceSampleAnisoGGX(u, V, localToWorld, roughnessT, roughnessB, NdotV, L, VdotH, NdotL, weightOverPdf);

        if (NdotL > 0.0)
        {
            // Fresnel component is apply here as describe in ImportanceSampleGGX function
            float3 FweightOverPdf = F_Schlick(fresnel0, VdotH) * weightOverPdf;

            //float4 val = SampleEnv(lightLoopContext, lightData.envIndex, L, 0, lightData.rangeCompressionFactorCompensation, 0.5);
            half3 val = indirectSpecular;
            
            acc += FweightOverPdf * val.rgb;
        }
    }
    return acc / sampleCount;
}
*/
//==================================48Add End==================================//
//=============================================================================//

inline void InitializeBRDFData(inout SurfaceData surfaceData, out BRDFData brdfData)
{
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness,
                       surfaceData.alpha, brdfData);
}

half3 ConvertF0ForClearCoat15(half3 f0)
{
    return ConvertF0ForAirInterfaceToF0ForClearCoat15Fast(f0);
}

inline void InitializeBRDFDataClearCoat(half clearCoatMask, half clearCoatSmoothness, inout BRDFData baseBRDFData,
                                        out BRDFData outBRDFData)
{
    outBRDFData = (BRDFData)0;
    outBRDFData.albedo = half(1.0);

    // Calculate Roughness of Clear Coat layer
    outBRDFData.diffuse = kDielectricSpec.aaa; // 1 - kDielectricSpec
    outBRDFData.specular = kDielectricSpec.rgb;
    outBRDFData.reflectivity = kDielectricSpec.r;

    outBRDFData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(clearCoatSmoothness);
    outBRDFData.roughness = max(PerceptualRoughnessToRoughness(outBRDFData.perceptualRoughness), HALF_MIN_SQRT);
    outBRDFData.roughness2 = max(outBRDFData.roughness * outBRDFData.roughness, HALF_MIN);
    outBRDFData.normalizationTerm = outBRDFData.roughness * half(4.0) + half(2.0);
    outBRDFData.roughness2MinusOne = outBRDFData.roughness2 - half(1.0);
    outBRDFData.grazingTerm = saturate(clearCoatSmoothness + kDielectricSpec.x);

    // Modify Roughness of base layer using coat IOR
    half ieta = lerp(1.0h, CLEAR_COAT_IETA, clearCoatMask);
    half coatRoughnessScale = Sq(ieta);
    half sigma = RoughnessToVariance(PerceptualRoughnessToRoughness(baseBRDFData.perceptualRoughness));

    baseBRDFData.perceptualRoughness = RoughnessToPerceptualRoughness(VarianceToRoughness(sigma * coatRoughnessScale));

    // Recompute base material for new roughness, previous computation should be eliminated by the compiler (as it's unused)
    baseBRDFData.roughness = max(PerceptualRoughnessToRoughness(baseBRDFData.perceptualRoughness), HALF_MIN_SQRT);
    baseBRDFData.roughness2 = max(baseBRDFData.roughness * baseBRDFData.roughness, HALF_MIN);
    baseBRDFData.normalizationTerm = baseBRDFData.roughness * 4.0h + 2.0h;
    baseBRDFData.roughness2MinusOne = baseBRDFData.roughness2 - 1.0h;

    // Darken/saturate base layer using coat to surface reflectance (vs. air to surface)
    baseBRDFData.specular = lerp(baseBRDFData.specular, ConvertF0ForClearCoat15(baseBRDFData.specular), clearCoatMask);
    // TODO: what about diffuse? at least in specular workflow diffuse should be recalculated as it directly depends on it.
}

BRDFData CreateClearCoatBRDFData(SurfaceData surfaceData,InputData48 inputData48, inout BRDFData brdfData)
{
    BRDFData brdfDataClearCoat = (BRDFData)0;

    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    // base brdfData is modified here, rely on the compiler to eliminate dead computation by InitializeBRDFData()
    InitializeBRDFDataClearCoat(surfaceData.clearCoatMask, surfaceData.clearCoatSmoothness, brdfData,
                                brdfDataClearCoat);
    //=============================================================================//
    //=================================48Change Start=================================//
    brdfData.normalWS=inputData48.clearCoatNormalWS;
    //==================================48Change End==================================//
    //=============================================================================//
    #endif

    return brdfDataClearCoat;
}

// Computes the specular term for EnvironmentBRDF
half3 EnvironmentBRDFSpecular(BRDFData brdfData, half fresnelTerm)
{
    float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
    return half3(surfaceReduction * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm));
}

half3 EnvironmentBRDF(BRDFData brdfData, half3 indirectDiffuse, half3 indirectSpecular, half fresnelTerm)
{
    //=============================================================================//
    //=================================48Change Start=================================//
    // half3 c = indirectDiffuse * brdfData.diffuse;
    // c += indirectSpecular * EnvironmentBRDFSpecular(brdfData, fresnelTerm);
    // return c;

    half3 c = 0;
    #if defined (_MATERIAL_FABRIC)
    c += indirectDiffuse* brdfData.diffuse*brdfData.diffuseFGD;
    c += indirectSpecular*brdfData.specularFGD;
    // #ifdef _FABRIC_SILK
    // c += indirectSpecular * EnvironmentBRDFSpecular(brdfData, fresnelTerm);
    // #else
    // c += indirectSpecular * EnvironmentBRDFSheen(brdfData, fresnelTerm);
    // #endif

    // #ifdef _FABRIC_SILK
    // c += IntegrateSpecularSilkIBLRef(brdfData, indirectSpecular);
    // #else
    // c += IntegrateSpecularCottonWoolIBLRef(brdfData, indirectSpecular);
    // #endif
    #elif defined (_CHARACTER)
    c += indirectDiffuse * brdfData.diffuse * brdfData.diffuseFGD;
    c += indirectSpecular * brdfData.specularFGD;
    c += indirectSpecular * brdfData.specularFGDB;
    #elif defined (_HAIR)
    float3 L = normalize(brdfData.viewDirectionWS - brdfData.normalWS * dot(brdfData.viewDirectionWS, brdfData.normalWS));
    CBSDF cbsdf = EvaluateBSDF(brdfData.viewDirectionWS, L, brdfData);
    c += indirectDiffuse* cbsdf.specR;
    c += indirectDiffuse * brdfData.diffuse ;
    #else
    c += indirectDiffuse * brdfData.diffuse;
    c += indirectSpecular * EnvironmentBRDFSpecular(brdfData, fresnelTerm);
    #endif
    return c;

    //==================================48Change End==================================//
    //=============================================================================//
}

// Environment BRDF without diffuse for clear coat
half3 EnvironmentBRDFClearCoat(BRDFData brdfData, half clearCoatMask, half3 indirectSpecular, half fresnelTerm)
{
    float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
    return indirectSpecular * EnvironmentBRDFSpecular(brdfData, fresnelTerm) * clearCoatMask;
}

//=============================================================================//
//=================================48Add Start=================================//

// Ref: https://www.slideshare.net/jalnaga/custom-fabric-shader-for-unreal-engine-4
//对于织物，我们有两种BRDF
//非金属：棉、斜纹棉布、亚麻和普通织物
//棉：粗糙度1.0（除非湿）-毛边-镜面颜色是白色的，但看起来像去饱和。
//金属：丝绸、缎子、天鹅绒、尼龙和聚酯
//丝：粗糙度0.3 - 0.7 -各向异性-不同的镜面颜色

// This function apply BSDF. Assumes that NdotL is positive.
CBSDF EvaluateBSDF_Fabric(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    CBSDF cbsdf;
    ZERO_INITIALIZE(CBSDF, cbsdf);

    float3 N = normalWS;
    float3 L = lightDirectionWS;
    float3 V = viewDirectionWS;

    float NdotV = dot(N, V);
    float NdotL = dot(N, L);
    float clampedNdotV = ClampNdotV(NdotV);
    float clampedNdotL = saturate(NdotL);
    //计算翻转后的 NdotL，用于处理透射（transmission）效果。
    //float flippedNdotL = ComputeWrappedDiffuseLighting(-NdotL, TRANSMISSION_WRAP_LIGHT);

    float LdotV, NdotH, LdotH, invLenLV;
    GetBSDFAngle(V, L, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);

    float diffTerm;
    float3 specTerm;

    #ifdef _FABRIC_SILK
    {
        // For silk we just use a tinted anisotropy
        float3 H = (L + V) * invLenLV;

        // For anisotropy we must not saturate these values
        float TdotH = dot(brdfData.tangentWS, H);
        float TdotL = dot(brdfData.tangentWS, L);
        float BdotH = dot(brdfData.bitangentWS, H);
        float BdotL = dot(brdfData.bitangentWS, L);


       float partLambdaV = brdfData.partLambdaV;
        
        // 计算各向异性反射的 DV 项，包括分布函数和可见性函数。
        // TODO: Do comparison between this correct version and the one from isotropic and see if there is any visual difference
        // We use abs(NdotL) to handle the none case of double sided
        float DV = DV_SmithJointGGXAniso(TdotH, BdotH, NdotH, clampedNdotV, TdotL, BdotL, abs(NdotL),
                                            brdfData.roughnessT, brdfData.roughnessB, partLambdaV);

        // Fabric are dieletric but we simulate forward scattering effect with colored specular (fuzz tint term)
        float3 F = F_Schlick(brdfData.fresnel0, LdotH);

        specTerm = F * DV;

        // Use abs NdotL to evaluate diffuse term also for transmission
        // TODO: See with Evgenii about the clampedNdotV here. This is what we use before the refactor
        // but now maybe we want to revisit it for transmission
        diffTerm = DisneyDiffuse(clampedNdotV, abs(NdotL), LdotV, brdfData.perceptualRoughness);
    }
    #else // MATERIALFEATUREFLAGS_FABRIC_SILK
    {
        float D = D_Charlie(NdotH, brdfData.roughnessT);
        // V_Charlie is expensive, use approx with V_Ashikhmin instead
        // float Vis = V_Charlie(NdotL, clampedNdotV, bsdfData.roughness);
        float Vis = V_Ashikhmin(NdotL, clampedNdotV);

        // Fabric are dieletric but we simulate forward scattering effect with colored specular (fuzz tint term)
        // We don't use Fresnel term for CharlieD
        float3 F = brdfData.fresnel0;

        specTerm = F * Vis * D;

        diffTerm = FabricLambert(brdfData.roughnessT);
    }
    #endif

    // The compiler should optimize these. Can revisit later if necessary.
    cbsdf.diffR = diffTerm * clampedNdotL;
    // cbsdf.diffT = diffTerm * flippedNdotL;

    // Probably worth branching here for perf reasons.
    // This branch will be optimized away if there's no transmission (as NdotL > 0 is tested in IsNonZeroBSDF())
    // And we hope the compile will move specTerm in the branch in case of transmission (TODO: verify as we fabric this may not be true as we already have branch above...)
    if (NdotL > 0)
    {
        cbsdf.specR = specTerm * clampedNdotL;
    }

    // We don't multiply by 'bsdfData.diffuseColor' here. It's done only once in PostEvaluateBSDF().
    return cbsdf;
}

half3 CottonBSDF(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    half LdotV, NdotH, LdotH, invLenLV;

    half NdotL = saturate(dot(normalWS, lightDirectionWS));
    half NdotV = saturate(dot(normalWS, viewDirectionWS));
    half clampedNdotV = ClampNdotV(NdotV);

    //计算 BSDF 所需的角度信息，包括 LdotV（光线与视线的点积）、NdotH（法线与半角向量的点积）、LdotH（光线与半角向量的点积）、invLenLV（光线与视线向量的长度倒数）。
    GetBSDFAngle(viewDirectionWS, lightDirectionWS, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);

    half roughness = brdfData.roughness;

    half D = D_CharlieNoPI(NdotH, roughness);
    half V = V_Ashikhmin(NdotL, clampedNdotV);
    half3 F = F_Schlick(brdfData.specular, LdotH);

    half3 Fr = saturate(V * D) * F;

    return Fr;
}

half3 SilkBSDF(BRDFData brdfData, half3 normalWS, half3 tangentWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    return brdfData.specular * DV_Anisotropy(normalWS, tangentWS, viewDirectionWS, brdfData.perceptualRoughness,
                                             brdfData.anisotropy, lightDirectionWS);
}

CBSDF EvaluateBSDF_StackLit(BRDFData bsdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    CBSDF cbsdf;
    ZERO_INITIALIZE(CBSDF, cbsdf);

    float3 N = normalWS;
    float3 L = lightDirectionWS;
    float3 V = viewDirectionWS;

    float NdotV = bsdfData.NdotV;
    float ClampNdotV = bsdfData.ClampNdotV;
    float NdotL = dot(N, L);

    float LdotV = dot(L, V); // note: LdotV isn't reused elsewhere, just here.
    float invLenLV = rsqrt(max(2.0 * LdotV + 2.0, FLT_EPS));
    // invLenLV = rcp(length(L + V)), clamp to avoid rsqrt(0) = inf, inf * 0 = NaN
    float savedLdotH = saturate(invLenLV * LdotV + invLenLV);
    float NdotH = saturate((NdotL + NdotV) * invLenLV); // Do not clamp NdotV here

    NdotV = ClampNdotV;


    // TODO: Proper Fresnel
    // float F90 = ComputeF90(bsdfData.fresnel0);
    float F90 = 1;
    float3 F = F_Schlick(bsdfData.fresnel0, F90, savedLdotH);

    float3 DV; // BSDF results per lobe
    DV[0] = DV_SmithJointGGX(NdotH, NdotL, NdotV, bsdfData.roughnessT, bsdfData.partLambdaV);
    DV[1] = DV_SmithJointGGX(NdotH, NdotL, NdotV, bsdfData.roughnessTB, bsdfData.partLambdaVB);

    cbsdf.specR = max(0, NdotL) * F * lerp(DV[0] * bsdfData.energyCompensationFactor,
                                           DV[1] * bsdfData.energyCompensationFactorB,
                                           bsdfData.lobeMix);


    // TODO: config option + diffuse GGX
    float3 diffTerm = Lambert();

    float diffuseNdotL = saturate(NdotL);

    diffuseNdotL = pow(diffuseNdotL, bsdfData.diffusePower + 1);
    diffuseNdotL *= bsdfData.diffusePower * 0.5 + 1; // normalize

    cbsdf.diffR = diffTerm * diffuseNdotL;
    // TODO: Note for Stephane: I use -inNdotL here as it match visually what was done before the refactor but I guess it should be -diffuseNdotL
    cbsdf.diffT = diffTerm * ComputeWrappedDiffuseLighting(-NdotL, TRANSMISSION_WRAP_LIGHT);

    cbsdf.diffT *= bsdfData.transmittance;
    cbsdf.specT *= bsdfData.transmittance;
    return cbsdf;
}

//==================================48Add End==================================//
//=============================================================================//

// Computes the scalar specular term for Minimalist CookTorrance BRDF
// NOTE: needs to be multiplied with reflectance f0, i.e. specular color to complete
half DirectBRDFSpecular(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    float3 lightDirectionWSFloat3 = float3(lightDirectionWS);
    float3 halfDir = SafeNormalize(lightDirectionWSFloat3 + float3(viewDirectionWS));

    float NoH = saturate(dot(float3(normalWS), halfDir));
    half LoH = half(saturate(dot(lightDirectionWSFloat3, halfDir)));

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // BRDFspec = (D * V * F) / 4.0
    // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
    // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155

    // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
    // We further optimize a few light invariant terms
    // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
    float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;

    half LoH2 = LoH * LoH;
    half specularTerm = brdfData.roughness2 / ((d * d) * max(0.1h, LoH2) * brdfData.normalizationTerm);

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
    #if REAL_IS_HALF
    specularTerm = specularTerm - HALF_MIN;
    // Update: Conservative bump from 100.0 to 1000.0 to better match the full float specular look.
    // Roughly 65504.0 / 32*2 == 1023.5,
    // or HALF_MAX / ((mobile) MAX_VISIBLE_LIGHTS * 2),
    // to reserve half of the per light range for specular and half for diffuse + indirect + emissive.
    specularTerm = clamp(specularTerm, 0.0, 1000.0); // Prevent FP16 overflow on mobiles
    #endif

    return specularTerm;
}

// Based on Minimalist CookTorrance BRDF
// Implementation is slightly different from original derivation: http://www.thetenthplanet.de/archives/255
//
// * NDF [Modified] GGX
// * Modified Kelemen and Szirmay-Kalos for Visibility term
// * Fresnel approximated with 1/LdotH
half3 DirectBDRF(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS,
                 bool specularHighlightsOff)
{
    // Can still do compile-time optimisation.
    // If no compile-time optimized, extra overhead if branch taken is around +2.5% on some untethered platforms, -10% if not taken.
    [branch] if (!specularHighlightsOff)
    {
        half specularTerm = DirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);
        half3 color = brdfData.diffuse + specularTerm * brdfData.specular;
        return color;
    }
    else
        return brdfData.diffuse;
}

// Based on Minimalist CookTorrance BRDF
// Implementation is slightly different from original derivation: http://www.thetenthplanet.de/archives/255
//
// * NDF [Modified] GGX
// * Modified Kelemen and Szirmay-Kalos for Visibility term
// * Fresnel approximated with 1/LdotH
half3 DirectBRDF(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    #ifndef _SPECULARHIGHLIGHTS_OFF
    return brdfData.diffuse + DirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS) * brdfData.
        specular;
    #else
    return brdfData.diffuse;
    #endif
}

#endif
