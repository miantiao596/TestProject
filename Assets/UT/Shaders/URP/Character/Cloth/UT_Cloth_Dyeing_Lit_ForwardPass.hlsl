#ifndef UT_CLOTH_DYEING_LIT_FORWARDPASS_INCLUDED
#define UT_CLOTH_DYEING_LIT_FORWARDPASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#if UT_RENDERING
#include "../../FALib/FAHeightFogDebug.hlsl"
#include "../../FALib/FACustomFogLib.hlsl"
#include "../../Lib/SelfShadow-lib.hlsl"
#endif

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float3 positionWS               : TEXCOORD1;
    float3 normalWS                 : TEXCOORD2;
    half4 tangentWS                 : TEXCOORD3;    // xyz: tangent, w: sign
    half4 fogColor                  : TEXCOORD4;
    half  fogFactor                 : TEXCOORD5;

// = #if defined(_MAIN_LIGHT_SHADOWS) || (defined(_MAIN_LIGHT_SHADOWS_SCREEN) && !defined(_SURFACE_TYPE_TRANSPARENT))
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD6;
#endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
    float4 positionCS               : SV_POSITION;
};

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

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;

    inputData.positionWS = input.positionWS;
    inputData.positionCS = input.positionCS;

    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

    inputData.tangentToWorld = tangentToWorld;
    inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = viewDirWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif
    inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);

	#if defined(_CHARACTER_AMBIENT_COLOR)
		inputData.bakedGI = max(0, _CharacterAmbientColor.rgb);
	#else
        inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
	#endif

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

    #if defined(DEBUG_DISPLAY)
    #if defined(LIGHTMAP_ON)
    inputData.staticLightmapUV = input.staticLightmapUV;
    #else
    inputData.vertexSH = input.vertexSH;
    #endif
    #endif
}

half4 ClothUniversalFragmentPBR(InputData inputData, SurfaceData surfaceData)
{
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    bool specularHighlightsOff = true;
    #else
    bool specularHighlightsOff = false;
    #endif
    BRDFData brdfData;

    // NOTE: can modify "surfaceData"...
    InitializeBRDFData(surfaceData, brdfData);

    #if defined(DEBUG_DISPLAY)
    half4 debugColor;

    if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
    {
        return debugColor;
    }
    #endif

    // Clear-coat calculation...
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
    #elif defined (_RECEIVE_SELF_SHADOW)
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
                                              inputData.bakedGI, surfaceData.occlusion, inputData.positionWS,
                                              inputData.normalWS, inputData.viewDirectionWS, inputData.normalizedScreenSpaceUV);
    lightingData.mainLightColor = LightingPhysicallyBased(brdfData, brdfDataClearCoat,
                                                          mainLight,
                                                          inputData.normalWS, inputData.viewDirectionWS,
                                                          surfaceData.clearCoatMask, specularHighlightsOff);

    // _ADDITIONAL_LIGHTS
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
        lightingData.additionalLightsColor += LightingPhysicallyBased(brdfData, brdfDataClearCoat, light,
                                                                      inputData.normalWS, inputData.viewDirectionWS,
                                                                      surfaceData.clearCoatMask, specularHighlightsOff);
    LIGHT_LOOP_END

    #if REAL_IS_HALF
    #if _FAKE_SHADOW
    half3 finalColor = CalculateLightingColor(lightingData, 1);
    finalColor = finalColor * fakeShadowAttenuation;
    return half4(finalColor, surfaceData.alpha);
    #else
    // Clamp any half.inf+ to HALF_MAX
    return min(CalculateFinalColor(lightingData, surfaceData.alpha), HALF_MAX);
    #endif
    #else
    #if _FAKE_SHADOW
    half3 finalColor = CalculateLightingColor(lightingData, 1);
    finalColor = finalColor * lerp(1,fakeShadowAttenuation,_FakeShadowIntensity);
    return half4(finalColor, surfaceData.alpha);
    #else
    return CalculateFinalColor(lightingData, surfaceData.alpha);
    #endif
    #endif
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half fogFactor = 0;
    #if !defined(_FOG_FRAGMENT)
        fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    #endif

    output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);

    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    output.tangentWS = tangentWS;

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    output.fogFactor = fogFactor;

    output.positionWS = vertexInput.positionWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
#endif

    output.positionCS = vertexInput.positionCS;
#if UT_RENDERING
    CustomMixFogColor(vertexInput.positionWS, output.fogColor.xyz, output.fogColor.w);
#endif

    return output;
}

// Used in Standard (Physically Based) shader
void LitPassFragment(Varyings input, out half4 outColor : SV_Target0)
{
    SurfaceData surfaceData;
    InitializeStandardLitSurfaceData(input.uv, surfaceData);

    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);
    
    #if defined(DEBUG_DISPLAY)
    SetupDebugDataTexture(inputData, input.uv, _MainTex_TexelSize, _MainTex_MipInfo, GetMipCount(TEXTURE2D_ARGS(_MainTex, smp)));
    #endif
    
    half4 color = ClothUniversalFragmentPBR(inputData, surfaceData);

    #if _ENABLE_HEIGHT_FOG_SHADING_DEBUG
    outColor = OutputHeightFogColor(input.fogColor.xyz, input.fogColor.w);
    return;
    #endif

    #if (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    #else
    color.rgb = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);
    #endif
    color.a = OutputAlpha(color.a, IsSurfaceTypeTransparent(_Surface));
    outColor = color;
}

#endif //UT_CLOTH_DYEING_LIT_FORWARDPASS_INCLUDED
