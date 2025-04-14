#ifndef FASTANDARDLIB_INCLUDE
#define FASTANDARDLIB_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#include "../FALib/FALighting.hlsl"
#include "../FALib/FACustomFogLib.hlsl"
#include "../FALib/FaCustomSSAO.hlsl"
#include "../FALib/FADebug.hlsl"
#include "../FALib/DepthTextureUtil.hlsl"
//#include "../FALib/FAShadowTentFilter.hlsl"
#include "../FALib/FACharacterEffect.hlsl"
#include "Assets/UT/Shaders/URP/Lib/SelfShadow-lib.hlsl"
#include "Assets/UT/Shaders/URP/Character/CharacterInput.hlsl"

struct Attributes
{
	float4 positionOS   : POSITION;
	half3 normalOS     : NORMAL;
	half4 tangentOS    : TANGENT;
	float4 uv           : TEXCOORD0;
	float4 uvLM         : TEXCOORD1;
	//UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
	float4 positionCS               : SV_POSITION;
	float2 uv                       : TEXCOORD0;
	float2 uvLM                     : TEXCOORD1;
	float3 positionWS               : TEXCOORD2; // xyz: positionWS, w: vertex fog factor
	half3  normalWS                 : TEXCOORD3;
	// #ifdef _NORMALMAP
	half3 tangentWS				: TEXCOORD4;
	half3 bitangentWS			: TEXCOORD5;
	half4 fogColor               : TEXCOORD6;
	// #endif
	// #ifdef _MAIN_LIGHT_SHADOWS || _MAIN_LIGHT_SHADOWS_CASCADE
	#if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE)
	float4 shadowCoord			: TEXCOORD7; // compute shadow coord per-vertex for the main light
	#endif
	#if defined(_ENABLE_FLATTEN)
	float3 originPosWS          : TEXCOORD11;
	#endif
	//#ifdef _EVOLVE_ON
	//	EVOLVE_PARAMS(7)
	//#endif
	#ifdef _EVOLVE2_ON
	float4 texcoord   : TEXCOORD8;
	half3 normalOS   : NORMAL;
	#endif
	#ifdef _IRIDESCENCE
	float2 matcapUV  : TEXCOORD9;
	#endif
	#ifdef _HOLOGRAM2_ON
	float4 positionOSAndDirect   :   TEXCOORD10; 
	#endif
};


Varyings LitPassVertex(Attributes input)
{
	Varyings output;

	// VertexPositionInputs包括了很多空间(world, view, homogeneous clip space)的 position
	// 编译的时候会剔除未使用到的references(比如说未使用view space)
	// 这种结构具有更大的灵活性，也没有额外的消耗
	//input.positionOS = float4(input.uv.xy, 0.0, 1.0);
	VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

	// 和VertexPositionInputs差不多，包含了world space中的normal, tangent and bitangent
	// 如果没使用到会被剔除
	VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

	// TRANSFORM_TEX is the same as the old shader library.
	output.uv = TRANSFORM_TEX(input.uv, _MainTex);
	output.uvLM = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;

	// 目前就使用vertex input中的clip space position
	output.positionCS = vertexInput.positionCS;

	// Computes fog factor per-vertex.
	//float fogFactor = ComputeFogFactorLinear(vertexInput.positionCS.z);
	output.positionWS = vertexInput.positionWS;

	output.normalWS = vertexNormalInput.normalWS;

	// 上面所说的新的Input结构灵活性在这里可以体现出来
	// 当一个没有定义normal map的变种存在时，tangentWS和bitangentWS不会被引用
	// 而GetVertexNormalInputs只是把normal从object转换到world space中
// #ifdef _NORMALMAP
	output.tangentWS = vertexNormalInput.tangentWS;
	output.bitangentWS = vertexNormalInput.bitangentWS;
// #endif

#if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE)
	// main light的shadow coord在vertex里计算
	// 如果应用了cascades, URP会在screen space里重构
	// 其他情况下URP会在light space(没有 depth pre-pass and shadow collect pass)里重构shadow
	output.shadowCoord = GetShadowCoord(vertexInput);
#endif
	
	#if defined(_ENABLE_FLATTEN)
	output.originPosWS = output.positionWS;
	// 1.计算顶点沿着相机朝向需要前进的距离，然后获得该类似正交视角的顶点。
	// 2.计算顶点沿着相机视线方向需要前进的距离，并根据正交顶点和原顶点求出透视视角下顶点的期望位置。
	float3 flattenDirection = normalize(_CameraForward.xyz);
	float3 camViewDirection = normalize(output.positionWS.xyz - _CameraPos.xyz);
	float3 originPos = float3(0, 0, 0) - flattenDirection * _FlattenPlaneOffset;
	float flattenProjectionDistance = dot(output.positionWS.xyz - originPos, flattenDirection);
	float3 flattenProjection = flattenProjectionDistance * flattenDirection;
	float safeNormViewProjFlatten = saturate(abs(dot(flattenDirection, camViewDirection)));
	float viewProjectionDistance = flattenProjectionDistance / safeNormViewProjFlatten;
	float3 viewProjection = viewProjectionDistance * camViewDirection;
	float3 flattenedVertex = output.positionWS.xyz - viewProjection;
	float diffProjFromPos2OriginInObjSpace = dot(flattenDirection, _FlattenWorldOriginPos - output.positionWS.xyz);
	float invViewProjDis = diffProjFromPos2OriginInObjSpace / safeNormViewProjFlatten;
	flattenedVertex -= camViewDirection * invViewProjDis * _FlattenFactor;
	
	output.positionWS = flattenedVertex;
	output.positionCS = TransformWorldToHClip(output.positionWS);
	#endif
	
#ifdef _EVOLVE2_ON
    float4 posWorld = float4(output.positionWS.xyz, 1);
    float3 vertexOffset = Evolove2GetVertexOffset(posWorld);
    float3 newPosOS = input.positionOS.xyz + vertexOffset;
    
    VertexPositionInputs vertexOffsetInput = GetVertexPositionInputs(newPosOS);
    output.positionCS = vertexOffsetInput.positionCS;
    output.positionWS = vertexOffsetInput.positionWS.xyz;

    output.texcoord = input.positionOS;
    output.normalOS = input.normalOS;
#endif
#ifdef _IRIDESCENCE
    output.matcapUV.x = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), normalize(input.normalOS));
    output.matcapUV.y = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalize(input.normalOS));
    output.matcapUV = output.matcapUV * 0.5 + 0.5;
#endif

#ifdef _HOLOGRAM2_ON
    float4 posOSAndDirect = Hologram2Vertex(input.positionOS.xyz, vertexInput.positionWS.xyz);
    float3 posOS = posOSAndDirect.xyz;
    output.positionCS = TransformObjectToHClip(posOS);
    output.positionOSAndDirect.xyz = input.positionOS.xyz;
    output.positionOSAndDirect.w = posOSAndDirect.w;
#endif
	CustomMixFogColor(vertexInput.positionWS, output.fogColor.xyz, output.fogColor.w);
	return output;
}

real3 SampleMainLightCookieWithDistort(float3 samplePositionWS)
{
	if(!IsMainLightCookieEnabled())
		return real3(1,1,1);

	float2 uv = ComputeLightCookieUVDirectional(_MainLightWorldToLight, samplePositionWS, float4(1, 1, 0, 0), URP_TEXTURE_WRAP_MODE_NONE);
	real4 color = SampleMainLightCookieTexture(uv + _Time.y * _LKDistortWaveSpeed.xy);

	return IsMainLightCookieTextureRGBFormat() ? color.rgb
			 : IsMainLightCookieTextureAlphaFormat() ? color.aaa
			 : color.rrr;
}

half3 CustomFAGlossyEnvironmentReflection(half3 reflectVector, half perceptualRoughness, half occlusion)
{
	#if !defined(_ENVIRONMENTREFLECTIONS_OFF)
	half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);

	half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(_ReflectionProbeMap, sampler_ReflectionProbeMap, reflectVector, mip);
	#if _IRIDESCENCE
	encodedIrradiance *= _IridescenceReflectionPower;
	#endif

	#if defined(UNITY_USE_NATIVE_HDR) || defined(UNITY_DOTS_INSTANCING_ENABLED)
	half3 irradiance = encodedIrradiance.rgb;
	#else
	half3 irradiance = DecodeHDREnvironment(encodedIrradiance, _ReflectionProbeMap_HDR);
	#endif
	return irradiance * occlusion;
	#endif
    
	return _GlossyEnvironmentColor.rgb * occlusion;
}

half3 CustomFAEnvironmentBRDF(FABRDFData brdfData, half3 indirectDiffuse, half3 indirectSpecular, half fresnelTerm, half3 iridescenceTerm)
{
	half3 c = indirectDiffuse * brdfData.diffuse;
	float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
	#if _IRIDESCENCE
	c += indirectSpecular * surfaceReduction * lerp(brdfData.specular * iridescenceTerm, brdfData.grazingTerm, iridescenceTerm);
	#else
	c += indirectSpecular * surfaceReduction * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm);
	#endif
	return c;
}

half3 CustomFAGlobalIllumination(FABRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS, half atten, half EnvironmentReflectionIntensity, half3 iridescenceTerm)
{
	half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    
	half3 indirectDiffuse = bakedGI * occlusion;
	half3 indirectSpecular = CustomFAGlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion) * EnvironmentReflectionIntensity;
    
	half atten_power = clamp(atten, 0.35, 1);
	indirectSpecular = indirectSpecular * pow(atten_power, 1.5);
	
	half NoV = saturate(dot(normalWS, viewDirectionWS));
	half fresnelTerm = Pow4(1.0 - NoV);
	
	return CustomFAEnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm, iridescenceTerm);
}

half3 CustomDirectBRDF(FABRDFData brdfData, half3 lightDirectionWS, half3 normalWS, half3 viewDirectionWS, half3 fresnelIridescenceLight)
{
	half3 halfDir = SafeNormalize(lightDirectionWS + viewDirectionWS);
	half LoH = saturate(dot(lightDirectionWS, halfDir));
	float cosTheta1 = dot(halfDir, float3(lightDirectionWS));
	half3 specularTerm = FADirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);
	
	#if _IRIDESCENCE
	specularTerm *= LoH;
	specularTerm *= fresnelIridescenceLight;
	#endif
	//限制高光不超过7，防止开了bloom的情况下，金属度和光滑度非常高的物体闪烁的情况
	half3 color = clamp(specularTerm * brdfData.specular,0,7) + brdfData.diffuse;
	return color;
}

half3 CustomFALightingPhysicallyBased(FABRDFData brdfData, Light light, half3 normalWS, half3 viewDirectionWS, half3 fresnelIridescenceLight = half3(1,1,1))
{
	//提高精度，规避移动平台的衰减硬边缘
	half NdotL = saturate(dot(normalWS, light.direction));
	half3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation * NdotL);
	return CustomDirectBRDF(brdfData, light.direction, normalWS, viewDirectionWS, fresnelIridescenceLight) * radiance;
}

half4 OutputStandardColor(Varyings input, FASurfaceData surfaceData, half3 cookie, half facing = 1)
{
#if defined(_ALPHATEST_ON)
	clip(surfaceData.alpha - _Cutoff);
#endif

	half3 normalWS = TransformTangentToWorld(surfaceData.normalTS, half3x3(input.tangentWS, input.bitangentWS, input.normalWS));

	normalWS = normalize(normalWS) * facing;

	float3 positionWS = input.positionWS.xyz;
	half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
	

	// BRDFData保存了经过能量转换过的diffuse, specular material reflections 和 roughness
	// 如果想要自定义着色模型，替换下面的就可以了
	FABRDFData brdfData;
	InitializeFABRDFData(surfaceData, brdfData);

#if _ENABLE_SHADING_DEBUG
		return OutputDebugColor(surfaceData, brdfData);
#endif

#ifdef LIGHTMAP_ON
	// Normal is required in case Directional lightmaps are baked
	half3 bakedGI = FASampleLightmap(input.uvLM, normalWS);
#else
	#ifdef CHARACTER_AMBIENT_COLOR
		half3 bakedGI = max(0, _CharacterAmbientColor.rgb);
		//bakedGI = half3(1, 1, 1);
	#else
		// 球谐SampleSH是per-pixel的，还有SampleSHVertex and SampleSHPixel可供选择
		half3 bakedGI = SampleSH(normalWS);
	#endif
#endif

	// URP提供的light struct可以抽象shader变量
	// 其中包括了light direction, color, distanceAttenuation 和 shadowAttenuation
	// URP根据灯光和平台采用不同的着色方法
	// 禁止在shader里引用light变量，使用GetLight函数填充light struct
#if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE)
	// Main light是directional light, 有一组特定的variables和shading path
	// 假如只有一盏directional light就像下面这样
	// 当传入一个shadowcoord(per-vertex)的时候，shadowAttenuation会被计算
	Light mainLight = GetMainLight(input.shadowCoord);
#else
	Light mainLight = GetMainLight();
#endif
	#if defined(_LIGHT_COOKIES)
	// real3 cookie = SampleMainLightCookie(input.positionWS.xyz);
	mainLight.color *= cookie;
	#endif

	// 不用时编译器会优化
	float2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);

#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
    AmbientOcclusionFactor aoFactor = CustomGetScreenSpaceAmbientOcclusion(uvScreen);
    mainLight.color *= aoFactor.directAmbientOcclusion;
    surfaceData.occlusion = min(surfaceData.occlusion, aoFactor.indirectAmbientOcclusion);
#endif

    if(!_EnableURPShadowMapping)
        mainLight.shadowAttenuation = 1;
    
	// additionalLights的阴影具有限制
	// 如果additionalLightsRenderingMode是LightRenderingMode.PerPixel并且lightType是LightType.Spot并且可见光存在并且阴影存在，additionalLightsCastShadows才为true
	// 暂时使用主光源的阴影衰减进行计算
	half atten = clamp(mainLight.shadowAttenuation, _CombinedScaledParams.w, 1);
	//临时添加
    
	// _IgnoreMainShadowAtten 1 atten 0 
	// _IgnoreMainShadowAtten 0 atten atten
	atten = _IgnoreMainShadowAtten + atten * (-1 * _IgnoreMainShadowAtten + 1);
	// Mix diffuse GI with environment reflections.

	#if defined(_IRIDESCENCE) && !defined(_LOW_DETAIL)
	half3 fresnelIridescence = SAMPLE_TEXTURE2D(_IridescenceMatCap, sampler_IridescenceMatCap, input.matcapUV).rgb;
	#else
	half3 fresnelIridescence = half3(1,1,1);
	#endif
	
	half3 color = CustomFAGlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS, atten, _EnvironmentReflectionIntensity, fresnelIridescence);
	mainLight.shadowAttenuation = lerp(1, mainLight.shadowAttenuation, _URPShadowIntensity);
#if _RECEIVE_SELF_SHADOW
	#if defined(_ENABLE_FLATTEN)
	half attenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
			, input.originPosWS, input.normalWS,_CustomSelfShadowIntensity);
	#else
	half attenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
			,input.positionWS, input.normalWS,_CustomSelfShadowIntensity);
	#endif
	mainLight.shadowAttenuation = lerp(1, attenuation, _SelfShadowIntensityCtr) * mainLight.shadowAttenuation;
#endif
    
// #if _IRIDESCENCE
//     color += FALightingPhysicallyBasedIridescence(brdfData, mainLight, normalWS, viewDirectionWS, fresnelIridescence);
// #else
//     color += CustomFALightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);
// #endif

	half3 fresnelTerm = half3(1,1,1);
	#if _IRIDESCENCE
	fresnelTerm = fresnelIridescence;
	#endif
	color += CustomFALightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS, fresnelTerm) * _CharacterMainLightIntensity * _CharacterMainLightColor;

	Light light;
#ifdef _FORWARD_PLUS_Z_BINING
    //方向光单独处理，因为方向光肯定会计算，不受culling影响，没必要走tile、zbin那套判断。
	bool isMatch;
	for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_LIGHTS); lightIndex++)
	{
		Light light = ForwardPlusGetAdditionalLight(lightIndex, positionWS, isMatch);
		if(!_EnableURPShadowMapping)
			light.shadowAttenuation = 1;
		if (isMatch)
		{
	#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
			light.color *= aoFactor.directAmbientOcclusion;
	#endif
	#if _RECEIVE_SELF_SHADOW
			if (_EnableSelfShadowMapping && _CustomShadowUseAdditionalLight)
			{
				if(lightIndex == _CustomShadowAdditionalLightIndex)
					light.shadowAttenuation = lerp(1, attenuation, _SelfShadowIntensityCtr);
			}
	#endif
			color += CustomFALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS, fresnelTerm);
		}
	}
	ClusteredLightLoop cll = ClusteredLightLoopInit(uvScreen, positionWS);
	while (ClusteredLightLoopNextWord(cll)) {
		while (ClusteredLightLoopNextLight(cll)) { 
			uint lightIndex = ClusteredLightLoopGetLightIndex(cll);
			Light light = ForwardPlusGetAdditionalLight(lightIndex, positionWS, isMatch);
			if(!_EnableURPShadowMapping)
                light.shadowAttenuation = 1;
			if (isMatch)
			{
	#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
				light.color *= aoFactor.directAmbientOcclusion;
	#endif
	#if _RECEIVE_SELF_SHADOW
				if (_EnableSelfShadowMapping && _CustomShadowUseAdditionalLight)
				{
					if(lightIndex == _CustomShadowAdditionalLightIndex)
						light.shadowAttenuation = lerp(1, attenuation * light.shadowAttenuation, _SelfShadowIntensityCtr);
				}
	#endif
				color += CustomFALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS, fresnelTerm);
			}
		}
	}
#else //_FORWARD_PLUS_Z_BINING
	// URP Lighting
	uint pixelLightCount = GetAdditionalLightsCount(); // Max 8
	for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
	{
		Light light = GetAdditionalLight(lightIndex, input.positionWS);
		#if _RECEIVE_ADDITIONAL_SELF_SHADOW
		if (GetPerObjectLightIndex(lightIndex) == _AdditionalSelfShadowLightIndex)
		{
			#if defined(_ENABLE_FLATTEN)
			half additionalAttenuation = CalaulateShadowAttenuation(_AdditionalSelfShadowMapRT,sampler_AdditionalSelfShadowMapRT,_AdditionalSelfShadowWorldToClip,
				_AdditionalSelfShadowParam,_AdditionalSelfShadowLightDirection,input.originPosWS, input.normalWS,_AdditionalSelfShadowIntensity);
			#else
			half additionalAttenuation = CalaulateShadowAttenuation(_AdditionalSelfShadowMapRT,sampler_AdditionalSelfShadowMapRT,_AdditionalSelfShadowWorldToClip,
				_AdditionalSelfShadowParam,_AdditionalSelfShadowLightDirection,input.positionWS, input.normalWS,_AdditionalSelfShadowIntensity);
			#endif
			light.shadowAttenuation = lerp(1, additionalAttenuation, _AddiShadowIntensity);
		}
		#if _RECEIVE_ADDITIONAL_SELF_SHADOW2
		if(GetPerObjectLightIndex(lightIndex) == _CustomShadowLightIndex)
		{
			#if defined(_ENABLE_FLATTEN)
			half additionalAttenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
			,input.originPosWS, input.normalWS,_CustomSelfShadowIntensity);
			#else
			half additionalAttenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
			,input.positionWS, input.normalWS,_CustomSelfShadowIntensity);
			#endif
			light.shadowAttenuation = additionalAttenuation;
		}
		#endif
		#elif _RECEIVE_ADDITIONAL_SELF_SHADOW2
		if(GetPerObjectLightIndex(lightIndex) == _CustomShadowLightIndex)
		{
			#if defined(_ENABLE_FLATTEN)
			half additionalAttenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
			,input.originPosWS, input.normalWS,_CustomSelfShadowIntensity);
			#else
			half additionalAttenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
			,input.positionWS, input.normalWS,_CustomSelfShadowIntensity);
			#endif
			light.shadowAttenuation = additionalAttenuation;
		}
		#else
		int perObjectLightIndex = GetPerObjectLightIndex(lightIndex);
		light = GetAdditionalPerObjectLight(perObjectLightIndex, positionWS);
		#endif
		
		#if defined(_LIGHT_COOKIES)
			real3 cookieColor = SampleAdditionalLightCookie(lightIndex, input.positionWS);
			light.color *= cookieColor;	
		#endif
		
		// if(!_EnableURPShadowMapping)
  //           light.shadowAttenuation = 1;
		
	#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
		light.color *= aoFactor.directAmbientOcclusion;
	#endif
	// #if _IRIDESCENCE
	// 		//half3 fresnelIridescenceLight = SAMPLE_TEXTURE2D(_IridescenceMainLightMatCap, sampler_IridescenceLightMatCap, input.matcapUV).rgb;
	// 	color += FALightingPhysicallyBasedIridescence(brdfData, light, normalWS, viewDirectionWS, fresnelIridescence);
	// #else
	// 	color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
	// #endif
		color += CustomFALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS, fresnelTerm);
	}
#endif //_FORWARD_PLUS_Z_BINING

//#endif

#ifdef _EVOLVE2_ON
    half4 emissionAndOpacity = Evolove2GetEmissionAndOpacity(positionWS, input.texcoord.xyz,  input.normalOS.xyz, input.normalWS, viewDirectionWS);
    // 确保进化后原有亮度不变
    surfaceData.emission = max(surfaceData.emission, emissionAndOpacity.rgb);
    clip(emissionAndOpacity.a - 0.01);
    // 确保进化后原有透明度不变
    surfaceData.alpha = min(surfaceData.alpha, emissionAndOpacity.a);
#endif
	// Emission
	color += surfaceData.emission;
    //color += saturate(surfaceData.emission);
	//#if _SPECULAR_SETUP
	//	return half4(1,1,1,1);
	//#else
	//	return half4(0,0,0,1);
	//#endif
	
	if(_EnableFresnel)
    {   
        float NdotV = saturate(dot(normalWS , viewDirectionWS));
        half power = max(0.0001, _FresnelOriginalPower); // 防止精度引起数值出现无限大
        half rim = pow(1 - NdotV, power) * _FresnelOriginalScale;
        half3 fresnel = _FresnelOriginalColor.rgb * rim;
        color = color + fresnel;
    }

	half alpha = 1.0;
#if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) // defined(_EVOLVE2_ON)
	alpha = surfaceData.alpha;	
#endif
	
#ifdef _DISSOLVE_ON
	color = DissolveColor(color, input.uv);
#endif

    half4 finalColor = half4(color, alpha);
#ifdef _HOLOGRAM2_ON
    finalColor = Hologram2Fragment(finalColor, input.uv, input.positionOSAndDirect.xyz, positionWS, input.normalWS, input.tangentWS, input.bitangentWS, input.positionOSAndDirect.w);
#endif

#ifdef _ALPHAPREMULTIPLY_ON
    finalColor.rgb *= finalColor.a;
#endif
#ifndef NO_TPA
    finalColor.a *= _TPA;
#endif
	return finalColor;
}

half4 LitPassFragment(Varyings input, half facing : VFACE) : SV_Target
{
	#if defined(_DITHER_FADEOUT)
	// 边缘光
	half3 viewDirWS = SafeNormalize(GetCameraPositionWS() - input.positionWS.xyz);
	float rim = 1.0 - saturate(dot(viewDirWS, input.normalWS));
	rim = smoothstep(1 - _ActorRimWidth, 1, rim);
	rim = smoothstep(0, _ActorRimSmoothness, rim);

	half dither = lerp(_DitherOpacity, 1, rim);
	half4 rimColor = _ActorRimColor * _ActorRimIntensity;
	
	NiloDoDitherFadeoutClip(input.positionCS.xy, dither);
	#endif

	float2 inputUV = input.uv;
	half3 cookie = half3(1, 1, 1);
	#if defined(_LIGHT_COOKIES)
	float mainLightCookieEnabled = step(0.5, IsMainLightCookieEnabled());
	float cookieEnabled = mainLightCookieEnabled * step(0.5, _EnableLightCookieDistortion);
	float3 causticFromCookie = SampleMainLightCookieWithDistort(input.positionWS.xyz);
	causticFromCookie = lerp(cookie, causticFromCookie, mainLightCookieEnabled);
	float2 distortion = causticFromCookie.rg * _LKDistortStrength;
	cookie = causticFromCookie;
	inputUV += lerp(float2(0, 0), distortion, cookieEnabled);
	#endif

	// Surfacedata包含了albedo, metallic, specular, smoothness, occlusion, emission以及alpha
	// InitializeStandarLitSurfaceData初始化是基于standard shader规则,也可以自己写函数初始化Surfacedata
	FASurfaceData surfaceData = InitializeFASurfaceData(inputUV);
	half4 color = OutputStandardColor(input, surfaceData, cookie, facing);
	
	color.rgb = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);
	#if defined(_LIGHT_COOKIES)
	color.rgb += lerp(half3(0, 0, 0), causticFromCookie, cookieEnabled) * _LKDistortLightStrength;
	#endif

	#if defined(_DITHER_FADEOUT)
	return lerp(color, lerp(color, /*color * */rimColor, _ActorRimBlend), rim);
	#endif
	return color;
}
#endif
