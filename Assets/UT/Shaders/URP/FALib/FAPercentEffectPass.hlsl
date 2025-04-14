#ifndef FA_PERCENT_EFFECT_PASS_INCLUDED
	#define FA_PERCENT_EFFECT_PASS_INCLUDED

	#include "../FALib/FAPBRLib.hlsl"

	//#ifdef _ICE_ON
	//	half3 GetIceColor(half3 V, half3 N, float3 posWorld, float2 uv)
	//	{
	//		half4 col_ice = SAMPLE_TEXTURE2D(_IceReflect, sampler_IceReflect, TRANSFORM_TEX(uv, _IceReflect));
	//		half4 freezeColor = _FreezeColor;
	//		half fresnelBase = _FresnelBase;
	//		half fresnelScale = _FresnelScale;
	//		half fresnelSensitive = _FresnelSensitive;
	//		half4 fresnelColor = l_FresnelColor;
	//		half fresnel = fresnelBase + fresnelScale * pow(1 - saturate(dot(N, V)), max(HALF_MIN, fresnelSensitive));
	//		half3 color = lerp(col_ice.rgb, fresnelColor.rgb, fresnel);

	//		half4 ice_detail = SAMPLE_TEXTURE2D(_IceDetail, sampler_IceDetail, TRANSFORM_TEX(uv, _IceDetail));
	//		half4 ice_mask = SAMPLE_TEXTURE2D(_IceMask, sampler_IceMask, TRANSFORM_TEX(uv, _IceMask));

	//		color += ice_detail.rgb * ice_mask.r * 4;
	//		color *= freezeColor.rgb;

	//		return color;
	//	}
	//#endif

	//#ifdef _STONE_ON
	//	half3 GetStoneColor(half3 N, float3 posWorld, float2 uv, Light light)
	//	{
	//		//half3 gray = half3(0.27, 0.66, 0.07);
	//		//half c = saturate(dot(albedo, gray));
	//		//gray = half3(c, c, c);

	//		float3 L = normalize(light.direction);
	//		half4 stone = SAMPLE_TEXTURE2D(_StoneTex, sampler_StoneTex, TRANSFORM_TEX(uv, _StoneTex)) * saturate(dot(N, L));
	//		half3 color = stone.xyz;
	//		//half3 color = gray * stone.xyz * 6;

	//		return color;
	//	}
	//#endif
    
    /*
	#ifdef _INVISIBILITY_ON
		half4 InvisibilityColor(half2 uv, float3 normalWS, float3 viewDirectionWS)
		{
			half keepVal = -GetInvisibilityClipVal(uv);
			half invisibilityColorLength = _InvisibilityColorLength;
			half4 invisibilityColor = _InvisibilityColor;

			half fresnel = pow(1 - saturate(dot(normalWS, viewDirectionWS)), 2);
			half4 fresnelCol = half4(fresnel * invisibilityColor.rgb, fresnel);

			half edgeRange = step(keepVal, invisibilityColorLength);
			half4 finalColor = lerp(fresnelCol ,invisibilityColor, edgeRange);
			return finalColor;
		}
	#endif
    */
	half3 GetEdgeColor(half3 oriColor, half percentFactor)
	{
		half3 color = oriColor;
		if (percentFactor <= _DissolvePercent && percentFactor >= _DissolvePercent - 0.05)
		{
			color = half3(1, 1, 1);
		}
		return color;
	}


	inline FASurfaceData CustomInitializeFASurfaceData(float2 uv, half4 albedo, half metallic = 0, half smoothness = 0, half emission = 0)
	{
		FASurfaceData outSurfaceData = (FASurfaceData)0;

		half4 ao_m_s_e = SAMPLE_TEXTURE2D(_CombinedAO, sampler_CombinedAO, TRANSFORM_TEX(uv, _CombinedAO));
		half occlusion = saturate(ao_m_s_e.r * _CombinedScaledParams.r);

		outSurfaceData.albedo = albedo.rgb;
		outSurfaceData.alpha = albedo.a;

		outSurfaceData.metallic = metallic;
		outSurfaceData.smoothness = smoothness;

		half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv);
		outSurfaceData.normalTS = UnpackNormalScale(n, _BumpScale);

		outSurfaceData.occlusion = occlusion;
		outSurfaceData.emission = emission * (albedo + _EmissionColor).rgb * _Emissive_Intensity;

		return outSurfaceData;
	}

	half4 OutputEffectColor(Varyings input, float facing = 1)
	{
		//#if defined(_DITHER_FADEOUT) && !defined(_HOLOGRAM_RIM_ON)
		#if defined(_DITHER_FADEOUT)
			// 边缘光
			half3 viewDirWS = SafeNormalize(GetCameraPositionWS() - input.positionWSAndFogFactor.xyz);
			float rim = 1.0 - saturate(dot(viewDirWS, input.normalWS));
			rim = smoothstep(1 - _ActorRimWidth, 1, rim);
			rim = smoothstep(0, _ActorRimSmoothness, rim);
		
			half dither = lerp(_DitherOpacity, 1, rim);
			half4 rimColor = _ActorRimColor * _ActorRimIntensity;
			NiloDoDitherFadeoutClip(input.positionCS.xy, dither);
		#endif

		float3 positionWS = input.positionWSAndFogFactor.xyz;
		half percentFactor = GetPercentEffectFactor(positionWS);
		half serrationFactor = GetPercentEffectSerration(positionWS);

		//#ifdef _INVISIBILITY_ON
		//	clip(-GetInvisibilityClipVal(input.uv));
		//#elif defined(_PERCENTEFFECT_ON)
		//	clip(_DissolvePercent - (percentFactor - serrationFactor));
		//#endif

		half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);

		half4 mainColor = _Color * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
		#if defined(_ALPHATEST_ON)
			clip(mainColor.a - _Cutoff);
		#endif

		half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uv);
		half3 normalTS = UnpackNormalScale(n, _BumpScale);
		half3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
		normalWS = normalize(normalWS) * facing;

		//#ifdef _INVISIBILITY_ON
		//	return InvisibilityColor(input.uv, normalWS, viewDirectionWS);
		//#endif

		Light mainLight = GetMainLight();

		FASurfaceData surfaceData;
			
		//#if defined(_ICE_ON)
		//	half3 effectColor = GetIceColor(viewDirectionWS, normalWS, positionWS, input.uv);
		//  surfaceData = CustomInitializeFASurfaceData(input.uv, half4(effectColor, _FreezeColor.a), 0, 0.3, 0);
		//#elif defined(_STONE_ON)
		//	half3 effectColor = GetStoneColor(normalWS, positionWS, input.uv, mainLight);
		//	surfaceData = CustomInitializeFASurfaceData(input.uv, half4(effectColor,1), 0, 0, 0);
		//#endif

		FABRDFData brdfData;
		InitializeFABRDFData(surfaceData, brdfData);

#if _ENABLE_SHADING_DEBUG
		return OutputDebugColor(surfaceData, brdfData);
#endif

		#ifdef CHARACTER_AMBIENT_COLOR
			half3 bakedGI = max(0, _CharacterAmbientColor.rgb);
		#else
			half3 bakedGI = SampleSH(normalWS);
		#endif
		float2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);
		half atten = clamp(mainLight.shadowAttenuation, _CombinedScaledParams.w, 1);
		half3 color = FAGlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS, uvScreen, atten);
		color += FALightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);

		color = GetEdgeColor(color, percentFactor);
		color = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);

		half4 final_color = half4(color, surfaceData.alpha);
		//#if (_ICE_ON)
		//	final_color = lerp(final_color, mainColor, _Ratio);
		//#endif

		#if defined(_DITHER_FADEOUT)
			return lerp(final_color, lerp(final_color, /*color * */rimColor, _ActorRimBlend), rim);
		#endif
		return final_color;
		//return half4(color, 1);
	}

	half4 PercentEffectPassFragment(Varyings input, float facing : VFACE) : SV_Target
	{
		return OutputEffectColor(input, facing);
	}

#endif
