#ifndef SCENESEAGRASS_INPUT
	#define SCENESEAGRASS_INPUT

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

	TEXTURE2D(_MainTex);				SAMPLER(sampler_MainTex);
	TEXTURE2D(_GlobalColTex);			SAMPLER(sampler_GlobalColTex);
	TEXTURE2D(_WindControlMap);			SAMPLER(sampler_WindControlMap);
	// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
	CBUFFER_START(UnityPerMaterial)
	float4 _MainTex_ST;
	half4 _GlobalColTex_ST;

	half4 _Color;
	half4 _Color_Top;
	half4 _Color_Bottom;
	half _MidPos;
	half _TopColAlpha;
	half _TopPow;
	half _AOCorrect;

	half _GlobalColBlendAlpha;
	// float4 _BumpMap_ST;
	// half _BumpScale;

	half3 _SpecularColor;
	half _SpecularStrength;
	half _SpecularPower;
	half _SpecularHeight;

	half _Translucency; 
	half _TranslucencyStrength;
	half _TranslucencyContrast;

	
	// half _GlobalColTexUVScale;

	half _WindDirection;
	half _WindStrength;
	half _WindWaveSize;
	half _WindWaveSpeed;
	half _FoliageFlutter;
	half3 _Color_Wind;
	half _MinWindFallRemap;
	half _MaxWindFallRemap;

	half _FogMode;
	half _FogIntensity;
	half _EnableURPShadowMapping;
	half	_Cutoff;
    //float _Fog_Blend_Mode;
	CBUFFER_END

#endif