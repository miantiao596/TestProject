#ifndef FASCENEEFFECT_INCLUDED
#define FASCENEEFFECT_INCLUDED

	#include "../FALib/FACustomFogLib.hlsl"
	#include "../FALib/FALightingSimple.hlsl"

	struct Attributes
	{
		float4 positionOS   : POSITION;
		half3 normalOS     : NORMAL;
		half4 tangentOS    : TANGENT;
		float4 uv           : TEXCOORD0;
		float4 uvLM         : TEXCOORD1;
		//UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct VaryingsEffectObject
	{
		float4 positionCS               : SV_POSITION;
		float4 uvAndUvLM                    : TEXCOORD0;
		float4 positionWSAndFogFactor   : TEXCOORD1; // xyz: positionWS, w: vertex fog factor
		half3  normalWS                 : TEXCOORD2;
		half3 tangentWS				    : TEXCOORD3;
		half3 bitangentWS			    : TEXCOORD4;
		half4 fogColor                  : TEXCOORD5;
		float4	uvCombinedAO				: TEXCOORD6;
		float4	uvBump						: TEXCOORD7;
		float4	uv2AndUV4							: TEXCOORD8;
		float4	uv3							: TEXCOORD9;
		#ifdef _MAIN_LIGHT_SHADOWS
		float4 shadowCoord			: TEXCOORD10; // compute shadow coord per-vertex for the main light
		#endif
		half2 uvNFlow                   : TEXCOORD11;
	};

	struct WaveData {
		float4 wave;
		float speed;
	};
	float3 GerstnerWave(WaveData data, float3 p, inout float3 tangent, inout float3 binormal)
	{
		// to do in inspector
		//float angle = wave.x;
		//float2 dir = float2(cos(angle), sin(angle));

		float speed = _Time.y * data.speed;
		float steepness = data.wave.z * 0.1;
		float wavelength = data.wave.w;
		float k = 6.28318 / wavelength; // 2 * PI
		float c = sqrt(9.8 / k);
		float2 d = normalize(data.wave.xy);
		float f = k * (dot(d, p.xz) - c * speed);
		float a = steepness / k;
		float sinF = sin(f);
		float cosF = cos(f);
		float sinSteepness = steepness * sinF;
		float cosSteepness = steepness * cosF;

		tangent += float3(
			-d.x * d.x * sinSteepness,
			d.x * cosSteepness,
			-d.x * d.y * sinSteepness
			);
		binormal += float3(
			-d.x * d.y * sinSteepness,
			d.y * cosSteepness,
			-d.y * d.y * sinSteepness
			);
		return float3(
			d.x * (a * cosF),
			a * sinF,
			d.y * (a * cosF)
			);
	}

	void ComputeWaves(inout Attributes v, out float waveHeight)
	{
		float3 gridPoint = TransformObjectToWorld(v.positionOS.xyz);
		float3 tangent = float3(1, 0, 0);
		float3 binormal = float3(0, 0, 1);
		float3 p = gridPoint;

		WaveData waveData[4];
		waveData[0].wave = _GerstnerWaveA;
		waveData[0].speed = _GerstnerSpeedA;

		waveData[1].wave = _GerstnerWaveB;
		waveData[1].speed = _GerstnerSpeedB;

		waveData[2].wave = _GerstnerWaveC;
		waveData[2].speed = _GerstnerSpeedC;

		waveData[3].wave = _GerstnerWaveD;
		waveData[3].speed = _GerstnerSpeedD;


		UNITY_LOOP
		for (uint i = 0; i < _WaveCount; i++)
		{
			p += GerstnerWave(waveData[i], gridPoint, tangent, binormal);
		}

		float3 normal = normalize(cross(binormal, tangent));
		p = TransformWorldToObject(p);

		float fakeOffset = (p.y + _WaveEffectsBoost) - v.positionOS.y;
		float amplitude = _WaveAmplitude;

		// #if _DISPLACEMENT_MASK_ON
		// amplitude *= v.color.b;
		// #endif

		waveHeight = amplitude * (fakeOffset * 0.5 + 0.5);
		v.positionOS.xyz = lerp(v.positionOS.xyz, p, amplitude);
		v.normalOS = lerp(v.normalOS, normal, amplitude * _WaveNormal);
	}

	// Flow map
	float4 SampleFlowMap(Texture2D tex,	float2 texUV, Texture2D flowMap,float2 uv, float speed,	float intensity)
	{

		float4 flowVal = (SAMPLE_TEXTURE2D(flowMap, SceneEffect_trilinear_repeat_sampler, uv) * 2 - 1) * intensity;

		float dif1 = frac(_Time.x * speed + 0.5);
		float dif2 = frac(_Time.x * speed);

		float lerpVal = abs((0.5 - dif1) / 0.5);

		float4 col1 = SAMPLE_TEXTURE2D(tex, SceneEffect_trilinear_repeat_sampler, texUV - flowVal.xy * dif1);
		float4 col2 = SAMPLE_TEXTURE2D(tex, SceneEffect_trilinear_repeat_sampler, texUV - flowVal.xy * dif2);
		return lerp(col1, col2, lerpVal);
	}
	float2 AnimatedUV(float2 uv, float2 tilings, float2 speeds)
	{
		float2 coords;

		coords.xy = uv * tilings.xy;

		#if _WORLD_UV
		coords += speeds * _Time.xx;
		#else
		coords += frac(speeds * _Time.xx);
		#endif

		return coords;
	}

	float4 DualAnimatedUV(float2 uv, float4 tilings, float4 speeds) 
	{
		float4 coords;

		coords.xy = uv * tilings.xy;
		coords.zw = uv * tilings.zw;

		#if _WORLD_UV
		coords += speeds * _Time.x;
		#else
		coords += frac(speeds * _Time.x);
		#endif

		return coords;
	}

	float3 NormalBlendReoriented(float3 A, float3 B)
	{
		float3 t = A.xyz + float3(0.0, 0.0, 1.0);
		float3 u = B.xyz * float3(-1.0, -1.0, 1.0);
		return (t / t.z) * dot(t, u) - u;
	}

	// Global Normal Blend
	float3 UnpackScaleNormal(float4 packednormal, float bumpScale) {
		#if defined(UNITY_NO_DXT5nm)
		return packednormal.xyz * 2 - 1;
		#else
		half3 normal;
		normal.xy = (packednormal.wy * 2 - 1);
		#if (SHADER_TARGET >= 30)
		// SM2.0: instruction count limitation
		// SM2.0: normal scaler is not supported
		normal.xy *= bumpScale;
		#endif
		normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
		return normal;
		#endif
	}

    float3 ComputeNormals(real3x3 tangentToWorld,float3 worldPosition, VaryingsEffectObject IN)
	{
		float3 worldNormal = float3(0,1,0);
		#if _NORMALSMODE_FACET
		float3 dpdx = ddx(worldPosition);
			float3 dpdy = ddy(worldPosition);
			worldNormal = normalize(cross(dpdy, dpdx));
		#else
			float3 tangentNormal;

		#if _NORMALSMODE_SINGLE || _NORMALSMODE_DUAL
			
			float4 nA = SAMPLE_TEXTURE2D(_NormalMapA, SceneEffect_trilinear_repeat_sampler, IN.uvBump.xy);
			float4 nB = SAMPLE_TEXTURE2D(_NormalMapA, SceneEffect_trilinear_repeat_sampler, IN.uvBump.zw);

			float3 normalA = UnpackScaleNormal(nA, _NormalMapAIntensity);
			float3 normalB = UnpackScaleNormal(nB, _NormalMapAIntensity);

			tangentNormal = NormalBlendReoriented(normalA, normalB);

			#if _NORMALSMODE_DUAL
					float3 normalC = UnpackScaleNormal(SAMPLE_TEXTURE2D(_NormalMapB, SceneEffect_trilinear_repeat_sampler, IN.uv2AndUV4.xy), _NormalMapBIntensity);
					tangentNormal = NormalBlendReoriented(tangentNormal, normalC);
			#endif
		#endif

		#if _NORMALSMODE_FLOWMAP
				float4 flowNormal = SampleFlowMap(_NormalMapA, IN.uvBump.xy, _FlowMap, IN.uvBump.zw, _FlowSpeed, _FlowIntensity);
				tangentNormal = UnpackNormalScale(flowNormal, _NormalMapAIntensity);
		#endif

		// Far Normals
		#if _NORMAL_FAR_ON
				float4 nfA = SAMPLE_TEXTURE2D(_NormalMapFar, SceneEffect_trilinear_repeat_sampler, IN.uv3.xy);
				float4 nfB = SAMPLE_TEXTURE2D(_NormalMapFar, SceneEffect_trilinear_repeat_sampler, IN.uv3.zw);

				float3 normalFarA = UnpackScaleNormal(nfA, _NormalMapFarIntensity);
				float3 normalFarB = UnpackScaleNormal(nfB, _NormalMapFarIntensity);

				float3 farNormals = NormalBlendReoriented(normalFarA, normalFarB);

				tangentNormal = lerp(tangentNormal, farNormals, IN.uv2AndUV4.z);
		#endif
		
		// Combined tangent to world
		float3 normalWS = TransformTangentToWorld(tangentNormal, tangentToWorld);
		worldNormal = normalize(normalWS);
	#endif


	#if _DOUBLE_SIDED_ON
			float3 flippedNormals = data.worldNormal;
			flippedNormals.y = -flippedNormals.y;

			data.worldNormal = lerp(flippedNormals, data.worldNormal, data.vFace);
	#endif
		//data.worldNormal = float3(0, 1, 0);
		return  worldNormal;
	}

	VaryingsEffectObject SceneEffectVertex(Attributes input)
	{
		#if _DISPLACEMENTMODE_GERSTNER
		float waveHeight;
		ComputeWaves(input,waveHeight);
		#endif
		VaryingsEffectObject output = (VaryingsEffectObject)0;
		VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

		// 和VertexPositionInputs差不多，包含了world space中的normal, tangent and bitangent
		// 如果没使用到会被剔除
		VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

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

		#ifdef _MAIN_LIGHT_SHADOWS
		// main light的shadow coord在vertex里计算
		// 如果应用了cascades, URP会在screen space里重构
		// 其他情况下URP会在light space(没有 depth pre-pass and shadow collect pass)里重构shadow
		output.shadowCoord = GetShadowCoord(vertexInput);
		#endif
		
        float2 uvCombinedSmoothnessUV = input.uv.xy;  // UV1

		#if _NORMALSMODE_FLOWMAP
			output.uvBump.xy = input.uv * _NormalMapATilings.xy;
			output.uvBump.zw = input.uv * _FlowTiling.xy + _FlowTiling.zw;
		#else
			output.uvBump = DualAnimatedUV(input.uv, _NormalMapATilings, _NormalMapASpeeds);
		#endif

		#if _NORMALSMODE_DUAL
		output.uv2AndUV4.xy = AnimatedUV(input.uv, _NormalMapBTilings.xy, _NormalMapBSpeeds.xy).xy;
		#endif

		#if _NORMAL_FAR_ON
		output.uv3 = DualAnimatedUV(input.uv, _NormalMapFarTilings, _NormalMapFarSpeeds);
		#endif

		#if _NORMAL_FAR_ON || _DISPLACEMENTMODE_GERSTNER
		output.uv2AndUV4.zw = float2(0, 0);
		output.uv2AndUV4.z = saturate(-TransformWorldToView(output.positionWSAndFogFactor.xyz).z / _NormalFarDistance);
			#if _DISPLACEMENTMODE_GERSTNER
			output.uv2AndUV4.w = waveHeight;
			#endif
		#endif
		
		if (_EnableDFlowMap)
		{
			output.uvNFlow = input.uv * _DFlowTiling.xy + _DFlowTiling.zw;
		}
		

		output.uvCombinedAO.xy = TRANSFORM_TEX(input.uv, _CombinedAO);
		output.uvCombinedAO.zw = uvCombinedSmoothnessUV * _SmoothnessTillingAndOffset.xy + _SmoothnessTillingAndOffset.zw;

		CustomMixFogColor(vertexInput.positionWS, output.fogColor.xyz, output.fogColor.w);
		return output;
	}

	// 对应官方的InitializeSurfaceData
	inline FASurfaceData InitializeFASurfaceDataCustom(VaryingsEffectObject input, half facing = 1)
	{
		FASurfaceData outSurfaceData = (FASurfaceData)0;
        float2 mainTexUV = input.uvAndUvLM.xy;
		half4 main_color;
		if (_EnableDFlowMap)
		{
			main_color = SampleFlowMap(_MainTex, mainTexUV, _DFlowMap, input.uvNFlow, _DFlowSpeed, _DFlowIntensity);
		}
		else
		{
			main_color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, mainTexUV);
		}
		
		half4 albedo = _Color * main_color;
        
		half4 ao_m_s_e = SAMPLE_TEXTURE2D(_CombinedAO, sampler_CombinedAO, input.uvCombinedAO.xy);
	
		half occlusion = saturate(ao_m_s_e.r * _CombinedScaledParams.r);
		half metallic = saturate(ao_m_s_e.g * _CombinedScaledParams.g);
		half smoothness = saturate((1 - SAMPLE_TEXTURE2D(_CombinedAO, sampler_CombinedAO, input.uvCombinedAO.zw).b) * _CombinedScaledParams.b);	//输出的贴图b通道是粗糙度,这里反成光滑度
		half emission = ao_m_s_e.a;
		
		outSurfaceData.albedo = albedo.rgb;
		outSurfaceData.alpha = albedo.a;

		outSurfaceData.occlusion = occlusion;
		outSurfaceData.metallic = metallic;
		outSurfaceData.smoothness = smoothness;
		
		return outSurfaceData;
	}

	half4 OutputSceneObjectStandardColor(VaryingsEffectObject input, FASurfaceData surfaceData, half facing = 1)
	{
		#if defined(_ALPHATEST_ON)
			clip(surfaceData.alpha - _Cutoff);
		#endif
		
		float3 positionWS = input.positionWSAndFogFactor.xyz;
		real3x3 tangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);
		float3 normalWS = ComputeNormals(tangentToWorld,positionWS, input);
		normalWS = normalize(normalWS) * facing;
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

		#ifdef _MAIN_LIGHT_SHADOWS
			Light mainLight = GetMainLight(input.shadowCoord);
		#else
			Light mainLight = GetMainLight();
		#endif
		
		if(!_EnableURPShadowMapping)
            mainLight.shadowAttenuation = 1;

		float2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);

		// #if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
		// 	AmbientOcclusionFactor aoFactor = CustomGetScreenSpaceAmbientOcclusion(uvScreen);
		// 	mainLight.color *= aoFactor.directAmbientOcclusion;
		// 	surfaceData.occlusion = min(surfaceData.occlusion, aoFactor.indirectAmbientOcclusion);
		// #endif

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
				
				if(!_EnableURPShadowMapping)
				    light.shadowAttenuation = 1;
                    
                    
				#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
					light.color *= aoFactor.directAmbientOcclusion;
				#endif
				light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
				color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
			}
#endif
		
		half alpha = 1.0;
		#if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
			alpha = surfaceData.alpha;
		#endif

		
		
        float4 final_color = half4(color, alpha);
#ifdef _ALPHAPREMULTIPLY_ON
		final_color.rgb *= final_color.a;
#endif

		//return half4(final_color.rgb, 1);
		return final_color;
	}

	half4 OutputSceneEffectPBRColor(VaryingsEffectObject input, half facing = 1)
	{
		//return half4(1, 1, 1, 1);
		// When the scene object becomes too large(e.g. a mountain), fog will look jaggy from some direction.
		// So we compute fog factor in fragemet shader, and the clip position should be reverted from NDC space(by multiply w).
		//float fogFactor = ComputeFogFactorLinear(input0.positionCS.z * input0.positionCS.w);
		FASurfaceData surfaceData = InitializeFASurfaceDataCustom(input);
		half4 color = OutputSceneObjectStandardColor(input, surfaceData, facing);
		color.rgb = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);
		return color;
	}

	half4 SceneEffectFragment(VaryingsEffectObject inputSceneObject, half facing : VFACE) : SV_Target
	{
		return OutputSceneEffectPBRColor(inputSceneObject, facing);
	}

#endif
