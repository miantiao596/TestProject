#ifndef FA_SCENEEFFECT_INPUT
	#define FA_SCENEEFFECT_INPUT

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

	TEXTURE2D(_MainTex);   SAMPLER(sampler_MainTex);
	TEXTURE2D(_CombinedAO);   SAMPLER(sampler_CombinedAO);
	TEXTURE2D(_NormalMapA);
	TEXTURE2D(_NormalMapB);
	TEXTURE2D(_NormalMapFar);
	TEXTURE2D(_FlowMap);
	TEXTURE2D(_DFlowMap);
	SamplerState SceneEffect_trilinear_repeat_sampler;


	CBUFFER_START(UnityPerMaterial)

	float4	_RampMask_ST;
	half	_DissolveMaskTex_UseUV2;
	float4	_UV2Mask_ST;
	half _MASK_UV2_ChannelMask;
	half _DissolveMask_ChannelMask;
	half4 _RampMask_ChannelMask;

	half    _UseCharacterAmbient;
    half _MainTex_UVType;
    half _Smoothness_UVType;
    half4 _SmoothnessTillingAndOffset;    
   
	//normal,Displacement
	float4 _NormalMapASpeeds;
	float4 _NormalMapATilings;
	float4 _NormalMapBSpeeds;
	float4 _NormalMapBTilings;
	float4 _NormalMapFarTilings;
	float4 _NormalMapFarSpeeds;
	float4 _FlowTiling;
	float4 _DFlowTiling;
	float4 _GerstnerWaveA;
	float4 _GerstnerWaveB;
	float4 _GerstnerWaveC;
	float4 _GerstnerWaveD;
	float _NormalMapAIntensity;
	float _NormalFarDistance;
	float _NormalMapFarIntensity;
	float _NormalMapBIntensity;
	float _FlowSpeed;
	float _FlowIntensity;
	float _DFlowSpeed;
	float _DFlowIntensity;
	float _WaveAmplitude;
	float _GerstnerSpeedA;
	float _GerstnerSpeedB;
	float _GerstnerSpeedC;
	float _GerstnerSpeedD;
	float _WaveNormal;
	float _WaveEffectsBoost;
	uint _WaveCount;

	half _FogMode;
	half _FogIntensity;

	float4 _MainTex_ST;
	float4 _CombinedAO_ST;
	half4 _Color;
	half4 _CombinedScaledParams;
	half _EnableURPShadowMapping;
	half _EnableDFlowMap;
	half _Cutoff;
	CBUFFER_END

	half4    _CharacterAmbientColor;
#endif