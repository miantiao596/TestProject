#ifndef UNIVERSAL_LIGHTING_INCLUDED
#define UNIVERSAL_LIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

#if UT_RENDERING
#include "Assets/UT/Shaders/URP/Lib/SelfShadow-lib.hlsl"
#endif

#if defined(LIGHTMAP_ON)
    #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) float2 lmName : TEXCOORD##index
    #define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT) OUT.xy = lightmapUV.xy * lightmapScaleOffset.xy + lightmapScaleOffset.zw;
    #define OUTPUT_SH(normalWS, OUT)
#else
    #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) half3 shName : TEXCOORD##index
    #define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT)
    #define OUTPUT_SH(normalWS, OUT) OUT.xyz = SampleSHVertex(normalWS)
#endif

///////////////////////////////////////////////////////////////////////////////
//                      Lighting Functions                                   //
///////////////////////////////////////////////////////////////////////////////


half3 LightingPhysicallyBased(BRDFData brdfData,
    half3 lightColor, half3 lightDirectionWS, half lightAttenuation,
    half3 normalWS, half3 viewDirectionWS, half SSSvalue)
{
    half NdotL = dot(normalWS, lightDirectionWS);

    half3 SSSLUT = SAMPLE_TEXTURE2D(_SSSMap, sampler_SSSMap, half2(clamp(NdotL*0.5+0.5,0.01,0.99),SSSvalue));

    half3 SSS = lerp(saturate(NdotL), SSSLUT, _SSSIntensity);
    half3 radiance = lightColor * (lightAttenuation * SSS);

    half3 brdf = brdfData.diffuse;

    brdf += brdfData.specular * DirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);

    return brdf * radiance;
    //return SSS;
}


struct LightingData
{
    half3 giColor;
    half3 mainLightColor;
    half3 additionalLightsColor;
};

half3 CalculateLightingColor(LightingData lightingData, half3 albedo)
{
    half3 lightingColor = 0;

    if (IsOnlyAOLightingFeatureEnabled())
    {
        return lightingData.giColor; // Contains white + AO
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_GLOBAL_ILLUMINATION))
    {
        lightingColor += lightingData.giColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_MAIN_LIGHT))
    {
        lightingColor += lightingData.mainLightColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_ADDITIONAL_LIGHTS))
    {
        lightingColor += lightingData.additionalLightsColor;
    }


    lightingColor *= albedo;


    return lightingColor;
}

half4 CalculateFinalColor(LightingData lightingData, half alpha)
{
    half3 finalColor = CalculateLightingColor(lightingData, 1);

    return half4(finalColor, alpha);
}

half4 CalculateFinalColor(LightingData lightingData, half3 albedo, half alpha, float fogCoord)
{
    #if defined(_FOG_FRAGMENT)
        #if (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
        float viewZ = -fogCoord;
        float nearToFarZ = max(viewZ - _ProjectionParams.y, 0);
        half fogFactor = ComputeFogFactorZ0ToFar(nearToFarZ);
    #else
        half fogFactor = 0;
        #endif
    #else
    half fogFactor = fogCoord;
    #endif
    half3 lightingColor = CalculateLightingColor(lightingData, albedo);
    half3 finalColor = MixFog(lightingColor, fogFactor);

    return half4(finalColor, alpha);
}

LightingData CreateLightingData(InputData inputData, SurfaceData surfaceData)
{
    LightingData lightingData;

    lightingData.giColor = inputData.bakedGI;
    lightingData.mainLightColor = 0;
    lightingData.additionalLightsColor = 0;

    return lightingData;
}
AmbientOcclusionFactor CustomGetScreenSpaceAmbientOcclusion(float2 normalizedScreenSpaceUV)  //搬运自AmbientOcclusion.hlsl
{
    AmbientOcclusionFactor aoFactor;

    #if (defined(_CUSTOM_SCREEN_SPACE_OCCLUSION) || defined(_SCREEN_SPACE_OCCLUSION)) && !defined(_SURFACE_TYPE_TRANSPARENT)
        float ssao = saturate(SampleAmbientOcclusion(normalizedScreenSpaceUV) + (1.0 - _AmbientOcclusionParam.x));
        aoFactor.indirectAmbientOcclusion = ssao;
        aoFactor.directAmbientOcclusion = lerp(half(1.0), ssao, _AmbientOcclusionParam.w);
    #else
        aoFactor.directAmbientOcclusion = half(1.0);
        aoFactor.indirectAmbientOcclusion = half(1.0);
    #endif

    #if defined(DEBUG_DISPLAY)
    switch(_DebugLightingMode)
    {
        case DEBUGLIGHTINGMODE_LIGHTING_WITHOUT_NORMAL_MAPS:
            aoFactor.directAmbientOcclusion = 0.5;
            aoFactor.indirectAmbientOcclusion = 0.5;
            break;

        case DEBUGLIGHTINGMODE_LIGHTING_WITH_NORMAL_MAPS:
            aoFactor.directAmbientOcclusion *= 0.5;
            aoFactor.indirectAmbientOcclusion *= 0.5;
            break;
    }
    #endif

    return aoFactor;
}

///////////////////////////////////////////////////////////////////////////////
//                      Fragment Functions                                   //
//       Used by ShaderGraph and others builtin renderers                    //
///////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// PBR lighting...
////////////////////////////////////////////////////////////////////////////////
half4 UniversalFragmentPBR(InputData inputData, SurfaceData surfaceData, half SSS)
{
    BRDFData brdfData;

    InitializeBRDFData(surfaceData, brdfData);

    #if defined(DEBUG_DISPLAY)
    half4 debugColor;

    if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
    {
        return debugColor;
    }
    #endif

    BRDFData brdfDataClearCoat = CreateClearCoatBRDFData(surfaceData, brdfData);
    half4 shadowMask = CalculateShadowMask(inputData); 
    AmbientOcclusionFactor aoFactor = CustomGetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);

    #if defined (_FAKE_SHADOW)
    half fakeShadowAttenuation = 1;

    if( _IsSwitchPass == 0)
    {
        half attenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
            ,inputData.positionWS, inputData.normalWS,_CustomSelfShadowIntensity);
        fakeShadowAttenuation = attenuation;
    }
    else
    {
        half additionalAttenuation = CalaulateShadowAttenuation(_AdditionalSelfShadowMapRT,sampler_AdditionalSelfShadowMapRT,_AdditionalSelfShadowWorldToClip,
                        _AdditionalSelfShadowParam,_AdditionalSelfShadowLightDirection,inputData.positionWS, inputData.normalWS,_AdditionalSelfShadowIntensity);
        fakeShadowAttenuation = additionalAttenuation;
    }
    #endif


    #if defined (_FAKE_SHADOW)
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);
    #elif _RECEIVE_SELF_SHADOW
    Light mainLight = GetMainLight();
    half attenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
            ,inputData.positionWS, inputData.normalWS,_CustomSelfShadowIntensity);
        mainLight.shadowAttenuation = attenuation;
    #else
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);
    #endif

    #if !defined(_SCREEN_SPACE_OCCLUSION)
    mainLight.color *= aoFactor.directAmbientOcclusion;
    surfaceData.occlusion = min(surfaceData.occlusion, aoFactor.indirectAmbientOcclusion);
    #endif

    // NOTE: We don't apply AO to the GI here because it's done in the lighting calculation below...
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    LightingData lightingData = CreateLightingData(inputData, surfaceData);

    lightingData.giColor = GlobalIllumination(brdfData, brdfDataClearCoat, surfaceData.clearCoatMask,
                                              inputData.bakedGI, aoFactor.indirectAmbientOcclusion, inputData.positionWS,
                                              inputData.normalWS, inputData.viewDirectionWS, inputData.normalizedScreenSpaceUV);

    lightingData.mainLightColor = LightingPhysicallyBased(brdfData, mainLight.color, mainLight.direction,
                                    mainLight.distanceAttenuation * mainLight.shadowAttenuation, inputData.normalWS, inputData.viewDirectionWS,  SSS);
    

    uint pixelLightCount = GetAdditionalLightsCount();

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
        int sceneLightIndex = GetPerObjectLightIndex(lightIndex);
        #if defined(_RECEIVE_ADDITIONAL_SELF_SHADOW)
        if (sceneLightIndex == _AdditionalSelfShadowLightIndex)
        {
            half additionalAttenuation = CalaulateShadowAttenuation(_AdditionalSelfShadowMapRT,sampler_AdditionalSelfShadowMapRT,_AdditionalSelfShadowWorldToClip,
                        _AdditionalSelfShadowParam,_AdditionalSelfShadowLightDirection,inputData.positionWS, inputData.normalWS,_AdditionalSelfShadowIntensity);
            light.shadowAttenuation = additionalAttenuation;
        }
        #if defined(_RECEIVE_ADDITIONAL_SELF_SHADOW2)
            if(sceneLightIndex == _CustomShadowLightIndex)
            {
                half additionalAttenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
                ,inputData.positionWS, inputData.normalWS,_CustomSelfShadowIntensity);
                light.shadowAttenuation = additionalAttenuation;
            }
        #endif
        #elif defined(_RECEIVE_ADDITIONAL_SELF_SHADOW2)
        if(sceneLightIndex == _CustomShadowLightIndex)
        {
            half additionalAttenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
            ,inputData.positionWS, inputData.normalWS,_CustomSelfShadowIntensity);
            light.shadowAttenuation = additionalAttenuation;
        }
        #else
        light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
        #endif

        #if !defined(_SCREEN_SPACE_OCCLUSION)
        light.color *= aoFactor.directAmbientOcclusion;
        #endif
        lightingData.additionalLightsColor +=  LightingPhysicallyBased(brdfData, light.color, light.direction,
                                                light.distanceAttenuation * light.shadowAttenuation, inputData.normalWS, inputData.viewDirectionWS,  SSS);
    LIGHT_LOOP_END
    

#if REAL_IS_HALF
    #if defined (_FAKE_SHADOW)
    half3 finalColor = CalculateLightingColor(lightingData, 1);
    finalColor = finalColor * fakeShadowAttenuation;
    return half4(finalColor, surfaceData.alpha);
    #else
    return CalculateFinalColor(lightingData, surfaceData.alpha);
    #endif
    // Clamp any half.inf+ to HALF_MAX
    return min(CalculateFinalColor(lightingData, surfaceData.alpha), HALF_MAX);
#else
    #if defined (_FAKE_SHADOW)
    half3 finalColor = CalculateLightingColor(lightingData, 1);
    finalColor = finalColor * lerp(1,fakeShadowAttenuation,_FakeShadowIntensity);
    return half4(finalColor, surfaceData.alpha);
    #else
    return CalculateFinalColor(lightingData, surfaceData.alpha);
    #endif
#endif
}



#endif
