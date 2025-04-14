#ifndef GLASS_INCLUDED
    #define GLASS_INCLUDED
	#include "../FALib/FALighting.hlsl"
	#include "../FALib/FACustomFogLib.hlsl"
	#include "../FALib/FaHeightFogDebug.hlsl"

	struct Attributes
	{
		float4 positionOS   : POSITION;
		half3 normalOS     : NORMAL;
		half4 tangentOS    : TANGENT;
		float4 uv           : TEXCOORD0;
		float4 uvLM         : TEXCOORD1;
		//UNITY_VERTEX_INPUT_INSTANCE_ID
	};

    struct VaryingsGlass{
    	float4 positionCS               : SV_POSITION;
    	float2 uv                       : TEXCOORD0;
    	float2 uvLM                     : TEXCOORD1;
    	float4 positionWSAndFogFactor   : TEXCOORD2; // xyz: positionWS, w: vertex fog factor
    	half3  normalWS                 : TEXCOORD3;
    	half3 tangentWS				: TEXCOORD4;
    	half3 bitangentWS			: TEXCOORD5;
    	half4 fogColor               : TEXCOORD6;
    	float2  uvThick  : TEXCOORD7;
    	float2	uvBump	 : TEXCOORD8;
    	#ifdef _MAIN_LIGHT_SHADOWS
    	float4 shadowCoord			: TEXCOORD9; // compute shadow coord per-vertex for the main light
    	#endif
    };
    
    VaryingsGlass LitPassVertexCustom(Attributes input)
    {
        VaryingsGlass output;
    	VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    	VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    	
    	output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    	output.uvLM = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;

    	output.positionCS = vertexInput.positionCS;
    	
    	output.positionWSAndFogFactor = float4(vertexInput.positionWS, 1);

    	output.normalWS = vertexNormalInput.normalWS;
    	
    	output.tangentWS = vertexNormalInput.tangentWS;
    	output.bitangentWS = vertexNormalInput.bitangentWS;
        output.uvThick = TRANSFORM_TEX(input.uv, _ThicknessTex);
        output.uvBump = TRANSFORM_TEX(input.uv, _BumpMap);
    	#ifdef _MAIN_LIGHT_SHADOWS
    	output.shadowCoord = GetShadowCoord(vertexInput);
    	#endif
    	CustomMixFogColor(vertexInput.positionWS, output.fogColor.xyz, output.fogColor.w);
        return output;    
    }

    inline FASurfaceData InitializeFASurfaceDataCustom(float2 uv, float2 uvBump)
    {
        FASurfaceData outSurfaceData = (FASurfaceData)0;
        half4 ao_m_s_e = SAMPLE_TEXTURE2D(_CombinedAO, sampler_CombinedAO, uv);
        half occlusion = saturate(ao_m_s_e.r * _CombinedScaledParams.r);
        half metallic = saturate(ao_m_s_e.g * _CombinedScaledParams.g);
        half smoothness = saturate((1 - ao_m_s_e.b) * _CombinedScaledParams.b);	//输出的贴图b通道是粗糙度,这里反成光滑度
        half emission = ao_m_s_e.a;
        
        // BlenderNormals
        half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uvBump);
        half3 normalTS = UnpackNormalScale(n, _BumpScale);
        
        half4 albedo = _Color * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

        outSurfaceData.albedo = albedo.rgb;
        outSurfaceData.alpha = albedo.a;
    
        outSurfaceData.metallic = metallic;
    
        outSurfaceData.smoothness = smoothness;
        outSurfaceData.normalTS = normalTS;
        outSurfaceData.occlusion = occlusion;
        outSurfaceData.emission = emission * (albedo + _EmissionColor).rgb * _Emissive_Intensity;
    
        return outSurfaceData;
    }
    
    half4 OutputPBRGlassColor(VaryingsGlass input, FASurfaceData surfaceData)
    {
    	
        #if defined(_ALPHATEST_ON)
            clip(surfaceData.alpha - _Cutoff);
        #endif

        half3 normalWS = TransformTangentToWorld(surfaceData.normalTS, half3x3(input.tangentWS, input.bitangentWS, input.normalWS));

	    normalWS = normalize(normalWS);

        FABRDFData brdfData;
        InitializeFABRDFData(surfaceData, brdfData);


        #ifdef LIGHTMAP_ON
            half3 bakedGI = FASampleLightmap(input.uvLM, normalWS);
        #else
            half3 bakedGI = SampleSH(normalWS);        
        #endif

        #ifdef _MAIN_LIGHT_SHADOWS
            Light mainLight = GetMainLight(input.shadowCoord);
        #else
            Light mainLight = GetMainLight();
        #endif

        // 不用时编译器会优化
        float2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);

        #if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
            AmbientOcclusionFactor aoFactor = CustomGetScreenSpaceAmbientOcclusion(uvScreen);
            mainLight.color *= aoFactor.directAmbientOcclusion;
            surfaceData.occlusion = min(surfaceData.occlusion, aoFactor.indirectAmbientOcclusion);
        #endif
        
        float3 positionWS = input.positionWSAndFogFactor.xyz;
        half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
    
        half atten = clamp(mainLight.shadowAttenuation, _CombinedScaledParams.w, 1);

	    half3 color = FAGlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS, uvScreen, atten);
    
	    color += FALightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);

        //#ifdef _ADDITIONAL_LIGHTS
            //half4 shadowMask = half4(1, 1, 1, 1);
            //uint2 grid;
            //uint additionalLightsCount = ForwardPlusGetAdditionalLightsCount(input0.positionCS, grid);
            //Light light;
            //for (int i = 0; i < additionalLightsCount; ++i)
            //{
            //    ForwardPlusGetAdditionalLight(i, grid, positionWS, light);
            //    #if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
            //        light.color *= aoFactor.directAmbientOcclusion;
            //    #endif
            //    color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
            //}
#ifdef _FORWARD_PLUS_Z_BINING
            //方向光单独处理，因为方向光肯定会计算，不受culling影响，没必要走tile、zbin那套判断。
			bool isMatch;
			for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_LIGHTS); lightIndex++)
			{
				Light light = ForwardPlusGetAdditionalLight(lightIndex, positionWS, isMatch);
				if (isMatch)
				{
                    #if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
                        light.color *= aoFactor.directAmbientOcclusion;
                    #endif
					color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
				}
			}
			ClusteredLightLoop cll = ClusteredLightLoopInit(uvScreen, positionWS);
			while (ClusteredLightLoopNextWord(cll)) {
				while (ClusteredLightLoopNextLight(cll)) { 
					uint lightIndex = ClusteredLightLoopGetLightIndex(cll);
					Light light = ForwardPlusGetAdditionalLight(lightIndex, positionWS, isMatch);
					if (isMatch)
					{
                        #if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
                            light.color *= aoFactor.directAmbientOcclusion;
                        #endif
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
				#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
					light.color *= aoFactor.directAmbientOcclusion;
				#endif
				color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
			}
#endif
        //#endif

        color += surfaceData.emission;
    
        half alpha = 1.0;
        #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
            alpha = surfaceData.alpha;
        #endif
    	#if _ENABLE_HEIGHT_FOG_SHADING_DEBUG
    	return OutputHeightFogColor(input.fogColor.xyz, input.fogColor.w);
    	#endif
        color = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);;

        //Thickness
        half thickness = tex2D(_ThicknessTex, input.uvThick).r;
        thickness += pow(1.0 - dot(viewDirectionWS, normalWS), (1.0 - _EdgeThickness) * 5);
        thickness *= _RefIntensity;
        thickness = saturate(thickness+alpha);

        return half4(color, thickness);
    }
    half4 LitPassFragmentCustom(VaryingsGlass input) : SV_Target
    {
        FASurfaceData surfaceData;
        surfaceData = InitializeFASurfaceDataCustom(input.uv, input.uvBump);
        
        return OutputPBRGlassColor(input, surfaceData);
    }
#endif