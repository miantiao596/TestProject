#ifndef UNIVERSAL_LIGHTING_INCLUDED
#define UNIVERSAL_LIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
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

float3 KajiyaKayDiffuseAttenuation(float3 BaseColor,float Scatter, float3 L, float3 V, half3 N, float Shadow)
{
	// Use soft Kajiya Kay diffuse attenuation
	float KajiyaDiffuse = 1 - abs(dot(N, L));

	float3 FakeNormal = normalize(V - N * dot(V, N));
	//N = normalize( DiffuseN + FakeNormal * 2 );
	N = FakeNormal;
	// Hack approximation for multiple scattering.
	float NoL = saturate((dot(N, L) + 1)*0.25);
	float DiffuseScatter = (1 / PI) * lerp(NoL, KajiyaDiffuse, 0.33) * Scatter;
	float Luma = Luminance(BaseColor);
	float3 ScatterTint = pow(BaseColor / max(Luma,0.01), max(0.75 - Shadow,0.001));
	return sqrt(BaseColor) * DiffuseScatter * ScatterTint;
}


half3 HairSpecularShading(half3 BiTangentWS, half3 V, half3 L, half3 NormalWS,half3 SpecularColor, half LightStrength, half LightExponent, half LightPosition, half lightAttenuation, half LambertValue)
{
    half3 L0 = half3 (normalize(L).x , ( normalize(L).y + ( LightPosition) ) , normalize(L).z);
    half3 V0 = normalize(V+L0);
    half VdotB = dot(V0,BiTangentWS);
    half Lambert = dot(NormalWS,normalize(L))*LambertValue+(1-LambertValue);
    half Specular = saturate(pow(sqrt(1-VdotB*VdotB),LightExponent))*LightStrength;
    half3 FianlSpecularColor = SpecularColor * Specular * smoothstep(0-1,1,VdotB)*saturate(Lambert*Lambert*Lambert)*lightAttenuation;

	return FianlSpecularColor; 
}

half3 HairBaseShading(half3 BaseColor,half4 Scatter,half3 BiTangentWS, half3 V, half3 L, half Shadow, half3 NormalWS)
{
	half3 S = 0;
	
	//基础色
	S = lerp(BaseColor,
        max(KajiyaKayDiffuseAttenuation(BaseColor,Scatter.r, L, V, BiTangentWS, Shadow),0.0),
        Scatter.g)
        *saturate(max(dot(NormalWS,L),0)+1-Scatter.a);//一定要加Max，坑
	S = -min(-S, 0.0);
	return S; 
}


void MainDirectLighting (Light light,half3 DiffuseColor,half Specular,half Roughness,half3 WorldPos, half3 BiTangentWS, half3 V,
								half4 Scatter,half3 NormalWS, half3 SpecularColor1,half3 SpecularAdjust,half3 SpecularColor2,half3 SpecularAdjust2, out half3 DirectLighting)
{
    DirectLighting = half3(0.5, 0.5, 0);
        
        //主光
        half3 DirectLighting_MainLight = half3(0,0,0);
        {
			//Light light = GetMainLight(ShadowCoord,WorldPos,ShadowMask);
			half3 L = light.direction;
			half3 distanceAttenuation = light.shadowAttenuation * light.distanceAttenuation;
			half Shadow = saturate(light.shadowAttenuation + 1-Scatter.b);

            half LightStrength1 = SpecularAdjust.x;
            half LightExponent1 = SpecularAdjust.y;
            half LightPosition1 = SpecularAdjust.z;
            //高光的灯光改成观察方向，仿照永劫无间
			half3 bsdfValue = HairSpecularShading(BiTangentWS,V,L,NormalWS, SpecularColor1,LightStrength1,LightExponent1,LightPosition1,light.distanceAttenuation,1);

            half LightStrength2 = SpecularAdjust2.x;
            half LightExponent2 = SpecularAdjust2.y;
            half LightPosition2 = SpecularAdjust2.z;

            bsdfValue += HairSpecularShading(BiTangentWS,V,L,NormalWS, SpecularColor2,LightStrength2,LightExponent2,LightPosition2,1,0.5);

            bsdfValue += HairBaseShading (DiffuseColor,Scatter,BiTangentWS,V,L,Shadow, NormalWS);

			half3 LightColor = light.color * PI * Shadow * light.distanceAttenuation;
			DirectLighting_MainLight = bsdfValue * LightColor;

        }
        DirectLighting = DirectLighting_MainLight;
}

void AdditionalLightColor (Light light,half3 DiffuseColor,half3 WorldPos, half3 BiTangentWS, half3 V,
								half4 Scatter,half3 NormalWS, out half3 additionalLightColor)
{
       
        //附加光
        half3 AdditionalLightColor = half3(0,0,0);
            half3 L = light.direction;
			half Shadow = light.shadowAttenuation * light.distanceAttenuation;
			half3 bsdfValue = HairBaseShading(DiffuseColor,Scatter,BiTangentWS,V,L,light.shadowAttenuation, NormalWS);
			half3 LightColor = light.color * PI * Shadow * light.distanceAttenuation;
            AdditionalLightColor = bsdfValue * LightColor;
        
        additionalLightColor =  AdditionalLightColor;
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

    half3 lightingColor = CalculateLightingColor(lightingData, albedo);

    return half4(lightingColor, alpha);
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
half4 HairUniversalFragmentPBR(InputData inputData, SurfaceData surfaceData, half4 Scatter, half3 BiTangentWS,half3 SpecularColor,half3 SpecularAdjust,half3 SpecularColor2,half3 SpecularAdjust2)
{
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
    uint meshRenderingLayers = GetMeshRenderingLayer();

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

	lightingData.mainLightColor = 0;
    #if _RECEIVE_ADDITIONAL_SELF_SHADOW
    AdditionalLightColor(mainLight, surfaceData.albedo, inputData.positionWS,
	    BiTangentWS, inputData.viewDirectionWS, Scatter, inputData.normalWS, lightingData.mainLightColor);
    #else
    MainDirectLighting(mainLight,surfaceData.albedo, surfaceData.specular, surfaceData.smoothness, inputData.positionWS,
	    BiTangentWS, inputData.viewDirectionWS, Scatter, inputData.normalWS, SpecularColor,SpecularAdjust,SpecularColor2,SpecularAdjust2, lightingData.mainLightColor);
    #endif
    

    uint pixelLightCount = GetAdditionalLightsCount();

    
    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
        int sceneLightIndex = GetPerObjectLightIndex(lightIndex);
        #if _RECEIVE_ADDITIONAL_SELF_SHADOW
        if (sceneLightIndex == _AdditionalSelfShadowLightIndex)
        {
            half additionalAttenuation = CalaulateShadowAttenuation(_AdditionalSelfShadowMapRT,sampler_AdditionalSelfShadowMapRT,_AdditionalSelfShadowWorldToClip,
                        _AdditionalSelfShadowParam,_AdditionalSelfShadowLightDirection,inputData.positionWS, inputData.normalWS,_AdditionalSelfShadowIntensity);
                        light.shadowAttenuation = additionalAttenuation;
        }
            #if _RECEIVE_ADDITIONAL_SELF_SHADOW2
            if(sceneLightIndex == _CustomShadowLightIndex)
            {
                half additionalAttenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
                        ,inputData.positionWS, inputData.normalWS,_CustomSelfShadowIntensity);
                        light.shadowAttenuation = additionalAttenuation;
            }
            #endif
        #elif _RECEIVE_ADDITIONAL_SELF_SHADOW2
        if(sceneLightIndex == _CustomShadowLightIndex)
        {
            half additionalAttenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
                    ,inputData.positionWS, inputData.normalWS,_CustomSelfShadowIntensity);
                    light.shadowAttenuation = additionalAttenuation;
        }
        #else
        light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
        #endif


            
       half3 additionalLightsColor = 0;

       #if _RECEIVE_ADDITIONAL_SELF_SHADOW
       if (sceneLightIndex == _AdditionalSelfShadowLightIndex)
       {
           MainDirectLighting(light,surfaceData.albedo, surfaceData.specular, surfaceData.smoothness, inputData.positionWS,
	           BiTangentWS, inputData.viewDirectionWS, Scatter, inputData.normalWS, SpecularColor,SpecularAdjust,SpecularColor2,SpecularAdjust2, additionalLightsColor);
       }
       #else
       {
           AdditionalLightColor(light, surfaceData.albedo, inputData.positionWS,
	           BiTangentWS, inputData.viewDirectionWS, Scatter, inputData.normalWS, additionalLightsColor);
       }
       #endif

       #if !defined(_SCREEN_SPACE_OCCLUSION)
       light.color *= aoFactor.directAmbientOcclusion;
       #endif
       lightingData.additionalLightsColor += additionalLightsColor;
        
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
    //return CalculateFinalColor(lightingData, surfaceData.alpha);
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
