#ifndef FASCENEOBJECT_INCLUDED
	#define FASCENEOBJECT_INCLUDED


	#include "../FALib/FALighting.hlsl"
	#include "../FALib/FAEffectLib.hlsl"
	#include "../FALib/FAHeightFogDebug.hlsl"
	#include "../FALib/FACustomFogLib.hlsl"
	#include "Assets/UT/Shaders/URP/Lib/SelfShadow-lib.hlsl"
	#include "Assets/UT/Shaders/URP/Character/CharacterInput.hlsl"
	#include "../Lib/Ut-SpaceTransforms.hlsl"

    struct AttributesSceneObject
    {
    	float4 positionOS   : POSITION;
    	half3 normalOS     : NORMAL;
    	half4 tangentOS    : TANGENT;
    	float4 uv           : TEXCOORD0;
    	float4 uvLM         : TEXCOORD1;
        float2 uv3    : TEXCOORD2;
    	float2 uv4    : TEXCOORD3;
    };
	struct VaryingsSceneObject
	{
		float4 positionCS               : SV_POSITION;
		float4 uvAndUvLM                       : TEXCOORD0;
		float4 positionWSAndFogFactor   : TEXCOORD1; // xyz: positionWS, w: vertex fog factor
		half3  normalWS                 : TEXCOORD2;
		half3 tangentWS				: TEXCOORD3;
		half3 bitangentWS			: TEXCOORD4;
		half4 fogColor               : TEXCOORD5;
		float4	uvCombinedAO				: TEXCOORD6;
		float4	uvBump						: TEXCOORD7;
		float4	uvEmissionAndUV2			: TEXCOORD8;
		float4 uv3AndUV4                    : TEXCOORD9;
		#ifdef _MAIN_LIGHT_SHADOWS
		float4 shadowCoord			: TEXCOORD10; // compute shadow coord per-vertex for the main light
		#endif
		#ifdef _DIRT_ON
			float4	uvDirtAndExtra			: TEXCOORD11;
		#endif
		#ifdef _TOPDETAIL_ON
			float4	uvTop					: TEXCOORD12;
		#endif
		#ifdef _HEIGHTGRADIENT_ON
		    float2 uvHeightGradient         : TEXCOORD13;

		#endif  
		
        #ifdef _POSWSUV_ON
    	float2 PositionWSUV : TEXCOORD14;
	    #endif  

	
		float4 shadowMask                   : TEXCOORD13;

	};


	VaryingsSceneObject SceneObjectVertex(AttributesSceneObject input, uint instanceID : SV_InstanceID)
	{
		VaryingsSceneObject output = (VaryingsSceneObject)0;

		VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz, instanceID);

		// 和VertexPositionInputs差不多，包含了world space中的normal, tangent and bitangent
		// 如果没使用到会被剔除
		VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS, instanceID);

		// TRANSFORM_TEX is the same as the old shader library.
		output.uvAndUvLM.xy = TRANSFORM_TEX(input.uv, _MainTex);
		output.uvAndUvLM.zw = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;

		// 目前就使用vertex input中的clip space position
		output.positionCS = vertexInput.positionCS;

		// Computes fog factor per-vertex.
		//float fogFactor = ComputeFogFactorLinear(vertexInput.positionCS.z);
		output.positionWSAndFogFactor = float4(vertexInput.positionWS, 1);

		output.normalWS = vertexNormalInput.normalWS;

		// 上面所说的新的Input结构灵活性在这里可以体现出来
		// 当一个没有定义normal map的变种存在时，tangentWS和bitangentWS不会被引用
		// 而GetVertexNormalInputs只是把normal从object转换到world space中
		// #ifdef _NORMALMAP
		output.tangentWS = vertexNormalInput.tangentWS;
		output.bitangentWS = vertexNormalInput.bitangentWS;
		// #endif

#ifdef _POSWSUV_ON
		  float2 PositionWSUV= float2(output.positionWSAndFogFactor.x, output.positionWSAndFogFactor.z);   
		  _PositionWSUV_ST=_PositionWSUV_ST*0.01;
		  PositionWSUV = PositionWSUV* _PositionWSUV_ST.xy +_PositionWSUV_ST.zw;

            if(_WorldPos_Dir2 == 1)
            {
                PositionWSUV = float2(output.positionWSAndFogFactor.x, output.positionWSAndFogFactor.y)* _PositionWSUV_ST.xy +_PositionWSUV_ST.zw;
            }else if(_WorldPos_Dir2 == 2)
            {
                PositionWSUV = float2(output.positionWSAndFogFactor.y, output.positionWSAndFogFactor.z)* _PositionWSUV_ST.xy +_PositionWSUV_ST.zw;
            }
#endif
      


		#ifdef _MAIN_LIGHT_SHADOWS
		// main light的shadow coord在vertex里计算
		// 如果应用了cascades, URP会在screen space里重构
		// 其他情况下URP会在light space(没有 depth pre-pass and shadow collect pass)里重构shadow
		output.shadowCoord = GetShadowCoord(vertexInput);
		#endif
		
		//output.varyingsBase = LitPassVertex(input);
        output.uv3AndUV4.xy = input.uv3;
		output.uv3AndUV4.zw = input.uv4;
        float2 uvCombinedSmoothnessUV = input.uv.xy;  // UV1

#ifdef _POSWSUV_ON
            uvCombinedSmoothnessUV = PositionWSUV;       
#else

        if(_UVType == 1) //UV2
        {
            uvCombinedSmoothnessUV = input.uvLM.xy;
        }
        else if(_UVType == 4) //UV3
        {
            uvCombinedSmoothnessUV = output.uv3AndUV4.xy;
        }
        else if(_UVType == 5)
        {
            uvCombinedSmoothnessUV = output.uv3AndUV4.zw;
        }
#endif


       

		output.uvCombinedAO.xy = TRANSFORM_TEX(input.uv, _CombinedAO);
		output.uvCombinedAO.zw = uvCombinedSmoothnessUV * _SmoothnessTillingAndOffset.xy + _SmoothnessTillingAndOffset.zw;
		
		output.uvBump.xy = TRANSFORM_TEX(input.uv, _BumpMap);
#ifdef _ENABLE_NORMALADD_ON
		output.uvBump.zw = TRANSFORM_TEX(input.uv, _BumpMap2);
#endif

#ifdef _ENABLE_EMISSIONTEX_ON
		output.uvEmissionAndUV2.xy = TRANSFORM_TEX(input.uv, _EmissionTexture);
#else
		output.uvEmissionAndUV2.xy = float2(1, 1);
#endif

#if defined(_DIRT_ON) && !defined(_LOW_DETAIL)
		{
			output.uvDirtAndExtra.xy = TRANSFORM_TEX(input.uv, _DirtTex);
			// output.uvDirt.zw = TRANSFORM_TEX(input.uv, _DirtMaskTex);
			// output.uvDirtExtra.xy = TRANSFORM_TEX(input.uv, _DirtCombinedAO);
			// output.uvDirtExtra.zw = TRANSFORM_TEX(input.uv, _DirtBumpMap);
			output.uvDirtAndExtra.zw = TRANSFORM_TEX(input.uv, _DirtBumpMap);
		}
#endif
#if defined(_TOPDETAIL_ON) && !defined(_LOW_DETAIL)
		{
			output.uvTop.xy = TRANSFORM_TEX(input.uv, _TopTex);
			output.uvTop.zw = TRANSFORM_TEX(input.uvLM, _TopTex);
			// if (_TopMaskTex_UseUV2 == 0)
			// output.uvTop.zw = TRANSFORM_TEX(input.uv, _TopMaskTex);
			// else
			// output.uvTop.zw = TRANSFORM_TEX(input.uvLM, _TopMaskTex);
		}
#endif
		output.uvEmissionAndUV2.zw = input.uvLM.xy;
		
#ifdef _HEIGHTGRADIENT_ON
        float2 heightUV = input.uv;
        if(_HeightGradientUVType == 1)  //uv2
        {
            heightUV = input.uvLM;
        }    
        else if(_HeightGradientUVType == 3) // 世界坐标
        {
            float2 posWS = float2(output.positionWSAndFogFactor.x, output.positionWSAndFogFactor.z);   // XA
            if(_WorldPos_Dir == 1)
            {
                posWS = float2(output.positionWSAndFogFactor.x, output.positionWSAndFogFactor.y); 
            }else if(_WorldPos_Dir == 2)
            {
                posWS = float2(output.positionWSAndFogFactor.y, output.positionWSAndFogFactor.z); 
            }
            
            heightUV.x = (posWS.x - _CoordinateRange.x) / (_CoordinateRange.y - _CoordinateRange.x);
            heightUV.y = (posWS.y - _CoordinateRange.z) / (_CoordinateRange.w - _CoordinateRange.z);
        }
        output.uvHeightGradient = TRANSFORM_TEX(heightUV, _HeightGradientMaskTex);
#endif

#ifndef _PIXELFOG_ON
		CustomMixFogColor(vertexInput.positionWS, output.fogColor.xyz, output.fogColor.w);
#endif
        //output.uv3AndUV4.xy = input.uv3;
        //output.positionScreen = ComputeScreenPos(output.varyingsBase.positionCS);
  #ifdef _POSWSUV_ON
		output.PositionWSUV = PositionWSUV;
#endif


		return output;
	}

	// 对应官方的InitializeSurfaceData
	inline FASurfaceData InitializeFASurfaceDataCustom(VaryingsSceneObject input, half facing = 1)
	{
		//Varyings input = input.varyingsBase;

		FASurfaceData outSurfaceData = (FASurfaceData)0;


        float2 mainTexUV = input.uvAndUvLM.xy;
		float2  BumpMapUV = input.uvBump.xy;
		float2 uvCombinedAOUV = input.uvCombinedAO.xy;
		float2 EmissionTextureUV = input.uvCombinedAO.xy;

    
	#ifdef  _POSWSUV_ON
            mainTexUV = input.PositionWSUV;
			BumpMapUV = input.PositionWSUV;
			uvCombinedAOUV =  input.PositionWSUV;
			EmissionTextureUV =  input.PositionWSUV;
	#else
		 if(_UVType == 1)
        {
            mainTexUV = input.uvEmissionAndUV2.zw;
			BumpMapUV = input.uvEmissionAndUV2.zw;
			uvCombinedAOUV= input.uvEmissionAndUV2.zw;
			EmissionTextureUV =  input.uvEmissionAndUV2.zw;
        }
        else if(_UVType == 4)
        {
            mainTexUV = input.uv3AndUV4.xy;
			BumpMapUV = input.uv3AndUV4.xy;
			uvCombinedAOUV = input.uv3AndUV4.xy;
			EmissionTextureUV =input.uv3AndUV4.xy;
        }
	#endif


		half4 main_color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, mainTexUV);
		half4 albedo = _Color * main_color;
        
		half4 ao_m_s_e = SAMPLE_TEXTURE2D(_CombinedAO, sampler_CombinedAO, uvCombinedAOUV);
	
		half occlusion = saturate(ao_m_s_e.r * _CombinedScaledParams.r);
		half metallic = saturate(ao_m_s_e.g * _CombinedScaledParams.g);
		half smoothness = saturate((1 - SAMPLE_TEXTURE2D(_CombinedAO, sampler_CombinedAO, input.uvCombinedAO.zw).b) * _CombinedScaledParams.b);	//输出的贴图b通道是粗糙度,这里反成光滑度
		half emission = ao_m_s_e.a;

		// BlendNormals
      half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, BumpMapUV);

		half3 normalTS_0 = UnpackNormalScale(n, _BumpScale) * facing;
#ifdef _ENABLE_NORMALADD_ON
		{
			half4 n2 = SAMPLE_TEXTURE2D(_BumpMap2, sampler_BumpMap2, input.uvBump.zw);
			half3 normalTS_2 = UnpackNormalScale(n2, _BumpScale2) * facing;
			normalTS_0 = half3(normalTS_0.xy + normalTS_2.xy, normalTS_0.z * normalTS_2.z);
		}
#endif
		half3 normalTS = normalTS_0;

#if defined(_DIRT_ON) && !defined(_LOW_DETAIL)
		{
			// 脏迹
			//half4 var_dirt = SAMPLE_TEXTURE2D(_DirtTex, sampler_DirtTex, input.uvDirt.xy);
			half4 var_dirt = _DirtTex.Sample(sampler_DirtTex, input.uvDirtAndExtra.xy);
			half dirtFactor = var_dirt.a;	//SAMPLE_TEXTURE2D(_DirtMaskTex, sampler_DirtMaskTex, input.uvDirt.zw);
			// ao_m_s_e (只取gb通道用)
			//half4 ao_m_s_e_dirt = SAMPLE_TEXTURE2D(_DirtCombinedAO, sampler_DirtCombinedAO, input.uvDirtExtra.xy);
			// metallic
			half metallic_dirt = saturate(_DirtMetal /*ao_m_s_e_dirt.g * _DirtCombinedScaledParams.g*/);
			metallic = lerp(metallic, metallic_dirt, dirtFactor);
			// smoothness
			half smoothness_dirt = saturate((1-_DirtSmoothness) /*(1 - ao_m_s_e_dirt.b) * _DirtCombinedScaledParams.b*/);	//输出的贴图b通道是粗糙度,这里反成光滑度
			smoothness = lerp(smoothness, smoothness_dirt, dirtFactor);
			// albedo
			half3 albedo_dirt = _DirtColor.rgb * var_dirt.rgb;
			albedo.rgb = lerp(albedo.rgb, albedo_dirt, dirtFactor);
			// normal
			//half4 nDirt = SAMPLE_TEXTURE2D(_DirtBumpMap, sampler_DirtBumpMap, input.uvDirtExtra); //input.uvDirtExtra.zw);
			half4 nDirt = _DirtBumpMap.Sample(sampler_DirtTex, input.uvDirtAndExtra.zw);
			half3 normalTS_Dirt = UnpackNormalScale(nDirt, _DirtBumpScale) * facing;
			normalTS_Dirt = half3(normalTS_0.xy + normalTS_Dirt.xy, normalTS_0.z * normalTS_Dirt.z);
			normalTS = lerp(normalTS, normalTS_Dirt, dirtFactor);
		}
#endif
#if defined(_TOPDETAIL_ON) && !defined(_LOW_DETAIL)
		{
			// 顶部细节
			//half4 var_top = SAMPLE_TEXTURE2D(_TopTex, sampler_TopTex, input.uvTop.xy);
			half4 var_top = _TopTex.Sample(sampler_TopTex, input.uvTop.xy);
			if (_TopMaskTex_UseUV2 > 0)
			    var_top.a =  _TopTex.Sample(sampler_TopTex, input.uvTop.zw).a;
				//var_top.a = SAMPLE_TEXTURE2D(_TopTex, sampler_TopTex, input.uvTop.zw).a;
			half3x3 T2W_Matrix  = half3x3(input.tangentWS, input.bitangentWS, input.normalWS);
			half3 normalWS = TransformTangentToWorld(normalTS_0, T2W_Matrix);
			float topFactor = saturate(pow(saturate(normalWS.y) + _TopOffset, _TopPower) * _TopIntensity);
			topFactor *= var_top.a ;	//SAMPLE_TEXTURE2D(_TopMaskTex, sampler_TopMaskTex, input.uvTop.zw);
			// ao_m_s_e (只取gb通道用)
			//half4 ao_m_s_e_top = SAMPLE_TEXTURE2D(_TopCombinedAO, sampler_TopCombinedAO, input.uvTop.xy);
			// metallic
			half metallic_top = saturate(_TopMetal /*ao_m_s_e_top.g * _TopCombinedScaledParams.g*/);
			metallic = lerp(metallic, metallic_top, topFactor);
			// smoothness
			half smoothness_top = saturate((1-_TopSmoothness) /*(1 - ao_m_s_e_top.b) * _TopCombinedScaledParams.b*/);	//输出的贴图b通道是粗糙度,这里反成光滑度
			smoothness = lerp(smoothness, smoothness_top, topFactor);
			// albedo
			half3 albedo_top = _TopColor.rgb * var_top.rgb;
			albedo.rgb = lerp(albedo.rgb, albedo_top, topFactor);
			// normal
			//half4 nTop = SAMPLE_TEXTURE2D(_TopBumpMap, sampler_TopBumpMap, input.uvTop.xy);
			half4 nTop = _TopBumpMap.Sample(sampler_TopTex, input.uvTop.xy);
			half3 normalTS_Top = UnpackNormalScale(nTop, _TopBumpScale) * facing;
			normalTS_Top = half3(normalTS_0.xy + normalTS_Top.xy, normalTS_0.z * normalTS_Top.z);
			normalTS = lerp(normalTS, normalTS_Top, topFactor);
		}
#endif
		outSurfaceData.albedo = albedo.rgb;
		outSurfaceData.alpha = albedo.a;

		outSurfaceData.occlusion = occlusion;
		outSurfaceData.metallic = metallic;
		outSurfaceData.smoothness = smoothness;

#ifdef _ENABLE_EMISSIONTEX_ON
		{
			half4 emission_sample = SAMPLE_TEXTURE2D(_EmissionTexture, sampler_EmissionTexture,EmissionTextureUV);
			outSurfaceData.emission = emission_sample.rgb * _EmissionColor.rgb * _Emissive_Intensity;
			if (_UseEmissionAlphaMask)
			{
				half3 mask_color = (1 - emission_sample.a) + (emission_sample.a * _EmissionMaskColor.rgb) * _EmissionMaskColorIntensity;
				outSurfaceData.albedo *= mask_color;
			}
		}				
#else
		{
			float3 emission_main = main_color.rgb * _EmissionColor.rgb * _Emissive_Intensity;
			float3 emission_co = emission * (albedo + _EmissionColor).rgb * _Emissive_Intensity;
			outSurfaceData.emission = _MainTexAsEmissionTex ? emission_main : emission_co;
		}
#endif
		outSurfaceData.normalTS = normalTS;

		return outSurfaceData;
	}

	half4 MaskUV2(half4 sourceColor, half2 uv)
	{
	    half4 maskColor = SAMPLE_TEXTURE2D(_UV2Mask, sampler_UV2Mask, TRANSFORM_TEX(uv, _UV2Mask));
	    half clipVal;
	    if(_MASK_UV2_ChannelMask == 0)  // R
	    {
	        clipVal = maskColor.r;
	    }
	    else if(_MASK_UV2_ChannelMask == 1) // G
	    {
	        clipVal = maskColor.g;
	    }
	    else if(_MASK_UV2_ChannelMask == 2) //B
	    {
	        clipVal = maskColor.b;
	    }
	    else
	    {   
	        clipVal = maskColor.a;;
	    }
	    
	    half factor_alph = 1 - clipVal;
        sourceColor.a *= factor_alph;
        clip(sourceColor.a - 0.01);
        sourceColor.a = saturate(sourceColor.a - 0.01);
		return sourceColor;
	}

	half4 OutputSceneObjectStandardColor(VaryingsSceneObject input, FASurfaceData surfaceData, half facing = 1)
	{
		//Varyings input = input.varyingsBase;
		#if defined(_ALPHATEST_ON)
			clip(surfaceData.alpha - _Cutoff);
		#endif
	

		float3 normalWS = TransformTangentToWorld(surfaceData.normalTS, half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
		normalWS = normalize(normalWS) * facing;

		float3 positionWS = input.positionWSAndFogFactor.xyz;
		float3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);

		FABRDFData brdfData;
		InitializeFABRDFData(surfaceData, brdfData);

#if _ENABLE_SHADING_DEBUG
			return OutputDebugColor(surfaceData, brdfData);
#endif

		#ifdef LIGHTMAP_ON
			half3 bakedGI = FASampleLightmap(input.uvAndUvLM.zw, normalWS);
		#else
			half3 bakedGI = lerp(SampleSH(normalWS), max(0, _CharacterAmbientColor.rgb), _UseCharacterAmbient);
		#endif

		half4 shadowMask = CalculateShadowMask(input.uvAndUvLM.zw);

		#if defined (_MAIN_LIGHT_SHADOWS)
			//float4 shadowCoord = TransformWorldToShadowCoord(input.shadowCoord);
			Light mainLight = GetMainLight(input.shadowCoord);
		#elif defined (_MAIN_LIGHT_SHADOWS_CASCADE)
			Light mainLight = GetMainLight(TransformWorldToShadowCoord(input.positionWSAndFogFactor.xyz));
		#else
			Light mainLight = GetMainLight();
		#endif

		#if defined (SHADOWS_SHADOWMASK) && !defined (_DIASBLESHADOWMASK_ON)
			mainLight.shadowAttenuation = shadowMask.x;
		#else	
			#if _RECEIVE_SELF_SHADOW
				half attenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
					,input.positionWSAndFogFactor.xyz, input.normalWS,_CustomSelfShadowIntensity);
				mainLight.shadowAttenuation = attenuation * mainLight.shadowAttenuation;
			#endif
		#endif


		
		if(!_EnableURPShadowMapping)
            mainLight.shadowAttenuation = 1;

		float2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);

		#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
			AmbientOcclusionFactor aoFactor = CustomGetScreenSpaceAmbientOcclusion(uvScreen);
			mainLight.color *= aoFactor.directAmbientOcclusion;
			surfaceData.occlusion = min(surfaceData.occlusion, aoFactor.indirectAmbientOcclusion);
		#endif

		half atten = clamp(mainLight.shadowAttenuation, _CombinedScaledParams.w, 1);
		half3 color = FAGlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS, uvScreen, atten);
		
#ifdef LIGHTMAP_ON
		half grey = Luminance(bakedGI);//bakedGI.r * 0.29 + bakedGI.g * 0.59 + bakedGI.b * 0.12;
#else
		half grey = 1;
#endif
		mainLight.color = lerp(mainLight.color * grey, mainLight.color, smoothstep(0.0, 0.2, grey));
		color += FALightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);

		//#ifdef _ADDITIONAL_LIGHTS
			//half4 shadowMask = half4(1, 1, 1, 1);
			//uint2 grid;
			//uint additionalLightsCount = ForwardPlusGetAdditionalLightsCount(input.positionCS, grid);
			//Light light;
			//for (int i = 0; i < additionalLightsCount; ++i)
			//{
			//	ForwardPlusGetAdditionalLight(i, grid, positionWS, light);

			//	#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
			//		light.color *= aoFactor.directAmbientOcclusion;
			//	#endif
			//	light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
			//	color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
			//}
		//#endif
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
					light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
					color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
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
						light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
						color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
					}
				}
			}
#else
			// URP Lighting
			uint pixelLightCount = GetAdditionalLightsCount();
			for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
			{
				Light light = GetAdditionalLight(lightIndex, positionWS);

				#if _RECEIVE_ADDITIONAL_SELF_SHADOW
				if (GetPerObjectLightIndex(lightIndex) == _AdditionalSelfShadowLightIndex)
				{
					half additionalAttenuation = CalaulateShadowAttenuation(_AdditionalSelfShadowMapRT,sampler_AdditionalSelfShadowMapRT,_AdditionalSelfShadowWorldToClip,
								_AdditionalSelfShadowParam,_AdditionalSelfShadowLightDirection,positionWS, input.normalWS,_AdditionalSelfShadowIntensity);
					light.shadowAttenuation = additionalAttenuation;
				}
				#if _RECEIVE_ADDITIONAL_SELF_SHADOW2
				if(GetPerObjectLightIndex(lightIndex) == _CustomShadowLightIndex)
				{
					half additionalAttenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
					,positionWS, input.normalWS,_CustomSelfShadowIntensity);
					light.shadowAttenuation = additionalAttenuation;
				}
				#endif
				#elif _RECEIVE_ADDITIONAL_SELF_SHADOW2
				if(GetPerObjectLightIndex(lightIndex) == _CustomShadowLightIndex)
				{
					half additionalAttenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
					,positionWS, input.normalWS,_CustomSelfShadowIntensity);
					light.shadowAttenuation = additionalAttenuation;
				}
				#else
				int perObjectLightIndex = GetPerObjectLightIndex(lightIndex);
				light = GetAdditionalPerObjectLight(perObjectLightIndex, positionWS);
				#endif
				
				if(!_EnableURPShadowMapping)
				    light.shadowAttenuation = 1;
                    
                    
				#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
					light.color *= aoFactor.directAmbientOcclusion;
				#endif
				light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
				color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
			}
#endif

		color += surfaceData.emission;

		half alpha = 1.0;
		#if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
			alpha = surfaceData.alpha;
		#endif

		#ifdef _DISSOLVE_ON
		    half2 dissolve_uv = input.uvAndUvLM.xy;
		    if (_DissolveMaskTex_UseUV2 == 1)  // UV2
		    {
		        dissolve_uv = input.uvEmissionAndUV2.zw;
		    } 
		    else if(_DissolveMaskTex_UseUV2 == 2) // 世界坐标
		    {
		        float2 posWS = float2(positionWS.x, positionWS.z); 
		        if(_DissolveMaskTex_Dir == 1)
		        {
		            posWS = float2(positionWS.x, positionWS.y); 
		        }
		        else if(_DissolveMaskTex_Dir == 2)
		        {
		            posWS = float2(positionWS.y, positionWS.z); 
		        }
		        dissolve_uv.x = (posWS.x - _DissolveMaskTex_Range_X) / (_DissolveMaskTex_Range_Y - _DissolveMaskTex_Range_X);
		        dissolve_uv.y = (posWS.y - _DissolveMaskTex_Range_Z) / (_DissolveMaskTex_Range_W - _DissolveMaskTex_Range_Z);
		    }   
		    //if (_SoftDissolve > 0)
		    //    return DissolveColorWithSoftEdge(half4(color, alpha), dissolve_uv);
		    //else
		          //color = DissolveColor(color, dissolve_uv);  
		          
		    half4 texColor = SAMPLE_TEXTURE2D(_DissolveMask, sampler_DissolveMask, TRANSFORM_TEX(dissolve_uv, _DissolveMask));  
		    half clipVal;
		    if(_DissolveMask_ChannelMask == 0)  // R
            {
                clipVal = texColor.r;
            }
            else if(_DissolveMask_ChannelMask == 1) // G
            {
                clipVal = texColor.g;
            }
            else if(_DissolveMask_ChannelMask == 2) //B
            {
                clipVal = texColor.b;
            }
            else
            {   
                clipVal = texColor.a;;
            }
            half edgeColorLength = _EdgeColorLength;
            half4 edgeColor = _EdgeColor;
            clip(_DissolvePercent - clipVal);
            half edgeRange = step(_DissolvePercent - edgeColorLength, clipVal);
            float2 rampUV = float2(saturate((clipVal - (_DissolvePercent - edgeColorLength)) * (any(edgeColorLength) ? 1 / edgeColorLength : 0)),0.0);
            half4 rampColor = PARTILE_TEXTURE2D(_RampMask, sampler_RampMask, TRANSFORM_TEX(rampUV, _RampMask), _RampMask_ChannelMask);//.rgb;
            //half3 rampColor = SAMPLE_TEXTURE2D(_RampMask, sampler_RampMask, TRANSFORM_TEX(rampUV, _RampMask)).rgb;
            color =  lerp(color,(edgeColor * rampColor).rgb,edgeRange);      

		#endif

		#ifdef _MASK_UV2_ON
			return MaskUV2(half4(color, alpha), input.uvEmissionAndUV2.zw);
		#endif
		#ifdef _WIREFRAME_ON
            float2 width = (float2(( 1.0 - _WireframeEdgeWidth ) , ( 1.0 - _WireframeEdgeWidth )));
        	float2 rectUV = ( abs( (input.uvAndUvLM.xy * 2.0 - 1.0) ) - width );
        	float2 wireframeUV = ( 1.0 - ( rectUV / fwidth( rectUV ) ) );
        	float wireframe = ( 1.0 - saturate( min( wireframeUV.x , wireframeUV.y ) ) );
        	float2 radius = (float2(( 1.0 - _WireframeDotRadius ) , ( 1.0 - _WireframeDotRadius )));
        	float2 restDotUV = ( abs( (input.uvAndUvLM.xy * 2.0 - 1.0) ) - radius );
        	float2 dotUV = ( 1.0 - ( restDotUV / fwidth( restDotUV ) ) );
        
        	float3 wireframeColor = ( ( _WireframeEdgeColor * wireframe ) + ( saturate( ( 1.0 - max( dotUV.x , dotUV.y ) ) ) * _WireframeDotColor ) ).rgb;
        	#ifdef _ALPHATEST_ON
        	    clip( alpha - 0.5 );
        	#endif

        	color += wireframeColor;
        	alpha = wireframe * _WireframeEdgeColor.a;
        #endif
        
        #ifdef _HEIGHTGRADIENT_ON
            half4 hightTexColor = PARTILE_TEXTURE2D(_HeightGradientMaskTex, sampler_HeightGradientMaskTex, input.uvHeightGradient, _HeightGradientMaskTex_ChannelMask);
            half4 heightColor = half4( _HeightGradientColor.rgb * _HeightGradientIntensity, 1) * hightTexColor * 2.5;
            color += heightColor;
        #endif
        
        float4 final_color = half4(color, alpha);

		return final_color;
	}

	half4 OutputSceneObjectPBRColor(VaryingsSceneObject input, half facing = 1)
	{
		FASurfaceData surfaceData = InitializeFASurfaceDataCustom(input);
		half4 color = OutputSceneObjectStandardColor(input, surfaceData, facing);

		#if _ENABLE_HEIGHT_FOG_SHADING_DEBUG
			return OutputHeightFogColor(input.fogColor.xyz, input.fogColor.w);
		#endif

		#ifdef _PIXELFOG_ON
		CustomMixFogColor(input.positionWSAndFogFactor.xyz, input.fogColor.xyz, input.fogColor.w);
		#endif

		
		color.rgb = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);
		return color;
		
	}

	half4 SceneObjectFragment(VaryingsSceneObject inputSceneObject, half facing : VFACE) : SV_Target
	{
		return OutputSceneObjectPBRColor(inputSceneObject, facing);
	
	} 
	

#endif


//#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
//    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);