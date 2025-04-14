#ifndef FA_SHADER_INPUT
#define FA_SHADER_INPUT

	TEXTURE2D(_CustomShadowMapRT);           SAMPLER_CMP(sampler_CustomShadowMapRT);
	sampler TrilinearClampSampler;
	float4x4 _SelfShadowWorldToClip;
	half4 _SelfShadowParam;
	half _SelfShadowRange;
	half _GlobalSelfShadowDepthBias;
	half3 _SelfShadowLightDirection;
	half _SelfShadowUseNdotLFix;
	half _CustomSelfShadowIntensity;
	half _GlobalReceiveSelfShadowMappingPosOffset;
	half _GlobalReceiveShadowMappingAmount;
	float3 _CharacterBoundCenterPosWS;
	half _CustomShadowUseAdditionalLight;
	half _CustomShadowAdditionalLightIndex;
	half _CustomSoftShadowQuality;
#endif