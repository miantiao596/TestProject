#ifndef SCENESEAGRASS_INCLUDED
	#define SCENESEAGRASS_INCLUDED

	// #include "../Lib/FALighting.hlsl"
	// #include "../Lib/FAEffectLib.hlsl"
	// #include "../Lib/FAHeightFogDebug.hlsl"
	#include "../FALib/FACustomFogLib.hlsl"
	#include "../FALib/FALightingSimple.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Assets/UT/Shaders/URP/Lib/SelfShadow-lib.hlsl"
	// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
	#include "../Lib/Ut-SpaceTransforms.hlsl"

	#define MAXWINDSTRENGTH 10

    struct AttributesSceneObject
    {
    	float4 positionOS   : POSITION;
    	half3 normalOS      : NORMAL;
    	half4 tangentOS     : TANGENT;
    	float4 uv           : TEXCOORD0;
    	float4 uvLM         : TEXCOORD1;
    };
	struct VaryingsSceneObject
	{
		float4 positionCS               	: SV_POSITION;
		float4 uvAndUvLM                	: TEXCOORD0;
		float4 positionWSAndFogFactor   	: TEXCOORD1; // xyz: positionWS, w: vertex fog factor
		half3  normalWS                 	: TEXCOORD2;
		// half3 tangentWS						: TEXCOORD3;
		// half3 bitangentWS					: TEXCOORD4;
		// float2 uvBump						: TEXCOORD3;
		float3 uvRootAndHeight				: TEXCOORD4;
		half4 fogColor						: TEXCOORD5;
		half4 windNormalWSAndStrength	: TEXCOORD6;
		DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 7);
#ifdef _MAIN_LIGHT_SHADOWS
		float4 shadowCoord					: TEXCOORD8; // compute shadow coord per-vertex for the main light
#endif
	};

	half4 SmoothCurve(half x)
	{
		return x * x * (3.0 - 2.0 * x);
	}
	half4 TriangleWave(float4 x)
	{
		return abs(frac(x + 0.5) * 2.0 - 1.0);
	}
	half4 SmoothTriangleWave(half4 x)
	{
		return SmoothCurve(TriangleWave(x));
	}


	VaryingsSceneObject SceneObjectVertex(AttributesSceneObject input, uint instanceID : SV_InstanceID)
	{
		VaryingsSceneObject output = (VaryingsSceneObject)0;

		VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz, instanceID);

		float3 posWS = vertexInput.positionWS;
		half3 normalWS = TransformObjectToWorldNormal(input.normalOS, instanceID);
		
		output.uvAndUvLM.xy = TRANSFORM_TEX(input.uv, _MainTex);
		output.uvAndUvLM.zw = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;

		float3 rootPosWS = GetObjectToWorldMatrix(instanceID)._14_24_34;
		output.uvRootAndHeight.xy = (rootPosWS.xz * _GlobalColTex_ST.xy) / TERRAINSIZE + _GlobalColTex_ST.zw;
		output.uvRootAndHeight.z = input.positionOS.y;

		half swayMask = input.uv.y;
		swayMask = saturate(swayMask);
		swayMask = pow(swayMask, 2);

		//暂时这么处理，后面风场需要全局控制
		_WindDirection *= 0.017453;
		half3 windDir = normalize(half3(cos(_WindDirection), 0, sin(_WindDirection)));

		float2 windUV = frac(posWS.xz / (_WindWaveSize * TERRAINSIZE));
		//风吹麦浪贴图根据风向旋转uv
		windUV -= float2(0.5, 0.5);
		windUV = float2(windUV.x * windDir.x + windUV.y * windDir.z, windUV.y * windDir.x - windUV.x * windDir.z);
		windUV += float2(0.5, 0.5);
		windUV.x -= frac((_Time.x * _WindWaveSpeed * abs(windDir.x) + 0.5)) * 2.0 - 1.0;
		windUV.y -= frac((_Time.x * _WindWaveSpeed * abs(windDir.z) + 0.5)) * 2.0 - 1.0;
		half windStrength = SAMPLE_TEXTURE2D_LOD(_WindControlMap, sampler_WindControlMap, windUV, 0);
		windStrength *= _WindStrength;
		// offset in world space
		//摆动
		half3 swayAxis = normalize(TransformObjectToWorld(half3(0,1,0), instanceID) - rootPosWS);
		float3 selfRoot = half3(posWS.x, rootPosWS.y, posWS.z);
		half3 growDir = posWS - selfRoot;
		half3 binAxis = cross(windDir, swayAxis);
		half3 offsetDir = cross(normalize(growDir), binAxis);
		offsetDir = normalize(offsetDir);
		half growLength = length(growDir);
		//growLength = lerp(growLength, 1.2 * growLength, saturate(windStrength/10));适当拉伸
		float3 dstVec = normalize((growDir + offsetDir * windStrength * swayMask));
		posWS = selfRoot + dstVec * growLength;
		//颤动
		half detailAmp = 0.1f;
		half objPhase = dot(rootPosWS, 1);
		half vtxPhase = dot(vertexInput.positionWS, _FoliageFlutter + objPhase);
		half2 wavesIn = _Time.yy + half2(vtxPhase, objPhase);
		half4 waves = frac(wavesIn.xxyy * half4(1.975, 0.793, 0.375, 0.193)) * 2.0 - 1.0;
		waves = SmoothTriangleWave(waves);
		half2 waveSum = waves.xz + waves.yw;
		float3 bend = _FoliageFlutter * detailAmp * normalWS * windStrength;
		posWS += (waveSum.xyx * bend * swayMask);
		
		output.windNormalWSAndStrength.xyz = normalWS + windDir * windStrength;
		output.windNormalWSAndStrength.w = windStrength / MAXWINDSTRENGTH;

		output.positionCS = TransformWorldToHClip(posWS);
		output.positionWSAndFogFactor = float4(posWS, 1);
		output.normalWS = normalWS;

#ifndef _PIXELFOG_ON
		CustomMixFogColor(vertexInput.positionWS, output.fogColor.xyz, output.fogColor.w);
#endif
#ifdef _MAIN_LIGHT_SHADOWS
		output.shadowCoord = GetShadowCoord(vertexInput);
#endif

		return output;
	}

	half3 GrassLightingBased(half3 albedo, half3 bakedGI, Light light, float3 normalWS, float3 viewDir, half3 windNormalWS, half ao, half height)
	{
		half NdotV = saturate(dot(viewDir, normalWS));
		half fresnelTerm = Pow4(1.0 - max(NdotV, 0));
		half LdotV = saturate(dot(viewDir, light.direction));
		half NdotL = saturate(dot(light.direction, normalWS));
		half3 lvhalf = normalize(light.direction + viewDir);
		half NdotH = max(dot(normalWS, lvhalf), 0.0);
		half NdotH2 = max(dot(windNormalWS, lvhalf), 0.0);
		NdotH *= NdotH2;

		half3 diffuse = albedo.rgb * 0.5 * (1 - LdotV) * fresnelTerm * _Translucency;
		half factor = saturate(abs(height / _SpecularHeight));
		half3 specular = pow(lerp(0, NdotH, factor), _SpecularPower) * light.color * _SpecularColor * _SpecularStrength * light.distanceAttenuation * light.shadowAttenuation;
		specular = smoothstep(0, 1, specular);
		half3 transCol = (diffuse * ao + NdotL) * light.color * light.distanceAttenuation * light.shadowAttenuation + bakedGI;
		half3 fresnelCol = (fresnelTerm * 0.04 + 0.021) * transCol;
		half3 col = fresnelCol * light.shadowAttenuation * light.shadowAttenuation * pow(ao * ao, _TranslucencyContrast) * _TranslucencyStrength + transCol * albedo + specular;
		return col;
	}

	half4 SceneObjectFragment(VaryingsSceneObject input, half facing : VFACE) : SV_Target
	{
		half3 normalWS = normalize(input.normalWS);
		float3 positionWS = input.positionWSAndFogFactor.xyz;
		
		float2 mainTexUV = input.uvAndUvLM.xy;
		half ao = saturate(mainTexUV.y / _AOCorrect);
		half4 main_color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, mainTexUV);
		half3 albedo = main_color * _Color;
		half3 global_color = SAMPLE_TEXTURE2D(_GlobalColTex, sampler_GlobalColTex, input.uvRootAndHeight.xy);
		half3 topCol = lerp(_Color_Top, global_color, _GlobalColBlendAlpha);
		topCol = lerp(albedo, topCol, _TopColAlpha);
		half topFactor = pow(saturate((1 - ao) / (1 - _MidPos)), _TopPow);
		topCol = lerp(topCol, albedo, topFactor);
		half bottomFactor = saturate(ao / _MidPos);
		albedo = lerp(_Color_Bottom * albedo, topCol, bottomFactor);
		
		half windStrength = input.windNormalWSAndStrength.w;
		half windColorBlend = smoothstep(_MinWindFallRemap, _MaxWindFallRemap, windStrength);
		albedo = lerp(albedo, _Color_Wind * albedo, windColorBlend);
		float3 windNormalWS = normalize(input.windNormalWSAndStrength.xyz);
		
#if defined(_ALPHATEST_ON)
		half alpha = main_color.a * _Color.a;
		clip(alpha - _Cutoff);
#endif
		
		
		// half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uvBump);
		// half3 normalTS = UnpackNormalScale(n, _BumpScale) * facing;
		// float3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
		// normalWS = normalize(normalWS) * facing;


		#if _FAKE_SHADOW
		half fakeShadowAttenuation = 1;
		if( _IsSwitchPass == 0)
		{
			half attenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
				,positionWS, normalWS,_CustomSelfShadowIntensity);
			fakeShadowAttenuation = attenuation;
		}
		else
		{
			half additionalAttenuation = CalaulateShadowAttenuation(_AdditionalSelfShadowMapRT,sampler_AdditionalSelfShadowMapRT,_AdditionalSelfShadowWorldToClip,
							_AdditionalSelfShadowParam,_AdditionalSelfShadowLightDirection,positionWS, normalWS,_AdditionalSelfShadowIntensity);
			fakeShadowAttenuation = additionalAttenuation;
		}
		#endif
		
		#if _FAKE_SHADOW
			#if _MAIN_LIGHT_SHADOWS
			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
			float4 shadowCoord = input.shadowCoord;
			Light mainLight = GetMainLight(shadowCoord);
			#endif
			#elif _MAIN_LIGHT_SHADOWS_CASCADE
			float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
			Light mainLight = GetMainLight(shadowCoord);
			#else
			Light mainLight = GetMainLight();
			#endif
		#elif _RECEIVE_SELF_SHADOW
		Light mainLight = GetMainLight();
		half attenuation = CalaulateShadowAttenuation(_CustomSelfShadowMapRT,sampler_CustomSelfShadowMapRT,_SelfShadowWorldToClip,_SelfShadowParam,_SelfShadowLightDirection
				,positionWS, normalWS,_CustomSelfShadowIntensity);
		mainLight.shadowAttenuation = attenuation;
		#else
			#if _MAIN_LIGHT_SHADOWS
			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
			float4 shadowCoord = input.shadowCoord;
			Light mainLight = GetMainLight(shadowCoord);
			#endif
			#elif _MAIN_LIGHT_SHADOWS_CASCADE
			float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
			Light mainLight = GetMainLight(shadowCoord);
			#else
			Light mainLight = GetMainLight();
			#endif
		#endif

		if(!_EnableURPShadowMapping)
			mainLight.shadowAttenuation = 1;
		
		float3 viewDir = SafeNormalize(GetCameraPositionWS() - input.positionWSAndFogFactor.xyz);
		half3 bakedGI = SampleSH(normalWS);

#ifdef LIGHTMAP_ON
		half grey = Luminance(bakedGI);//bakedGI.r * 0.29 + bakedGI.g * 0.59 + bakedGI.b * 0.12;
#else
		half grey = 1;
#endif
		mainLight.color = lerp(mainLight.color * grey, mainLight.color, smoothstep(0.0, 0.2, grey));

		half3 col = GrassLightingBased(albedo, bakedGI, mainLight, normalWS, viewDir, windNormalWS, ao, input.uvRootAndHeight.z);
		
#ifdef _FORWARD_PLUS_Z_BINING
		//暂空
#else
		// URP Lighting
		uint pixelLightCount = GetAdditionalLightsCount();
		for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
		{
			Light light = GetAdditionalLight(lightIndex, positionWS);
			if(!_EnableURPShadowMapping)
			    light.shadowAttenuation = 1;
                
			light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
			col += GrassLightingBased(albedo, 0, light, normalWS, viewDir, windNormalWS, ao, input.uvRootAndHeight.z);
		}
#endif

#if _ENABLE_HEIGHT_FOG_SHADING_DEBUG
		return OutputHeightFogColor(input.fogColor.xyz, input.fogColor.w);
#endif

#ifdef _PIXELFOG_ON
		CustomMixFogColor(input.positionWSAndFogFactor.xyz, input.fogColor.xyz, input.fogColor.w);
#endif

		#if _FAKE_SHADOW
		col = col * lerp(1,fakeShadowAttenuation,_FakeShadowIntensity);
		#endif
		col = lerp(input.fogColor.xyz, col, input.fogColor.w);

		half4 color = half4(col, 1);
		return color;
	}

#endif
