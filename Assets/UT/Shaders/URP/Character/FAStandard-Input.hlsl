#ifndef FA_STANDARD_INPUT
	#define FA_STANDARD_INPUT

	#include "../FALib/FACharacterInputMacro.hlsl"
    #include "../FALib/FASceneShadowInputMacro.hlsl"
	CHARACTER_INPUT_BASE_TEX

	CHARACTER_INPUT_IRIDESCENCE_TEX

	CHARACTER_INPUT_EFFECT_ALL_TEX

	// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
	CBUFFER_START(UnityPerMaterial)

	CHARACTER_INPUT_BASE

	CHARACTER_INPUT_IRIDESCENCE

	CHARACTER_INPUT_EFFECT_ALL
	
	SCENE_SHADOW_INPUT

	real4 _ReflectionProbeMap_HDR;

	// 边缘光
	half _ActorRimWidth;
	half _ActorRimSmoothness;
	half4 _ActorRimColor;
	half _ActorRimIntensity;
	half _ActorRimBlend;

	//阴影强度
    half _URPShadowIntensity;
    half _SelfShadowIntensityCtr;
    half _AddiShadowIntensity;

	// 压扁
	float _FlattenPlaneOffset;
	float _FlattenFactor;
	float3 _FlattenWorldOriginPos;

	// LightCookie扭曲
	half _EnableLightCookieDistortion;
	half4 _LKDistortWaveSpeed;
	half _LKDistortStrength;
	half _LKDistortLightStrength;

	CBUFFER_END

	float4 _CameraForward;
	float4 _CameraPos;
#endif