#ifndef SELFSHADOW_INPUT
#define SELFSHADOW_INPUT

float4x4 _SelfShadowWorldToClip;
float4x4 _AdditionalSelfShadowWorldToClip;
float4x4 _FakeShadowWorldToClip;

half _GlobalSelfShadowDepthBias;
half _SelfShadowMappingDepthBias;
half _SelfShadowUseNdotLFix;
half _CustomSelfShadowIntensity;
half _AdditionalSelfShadowIntensity;
half3 _SelfShadowLightDirection;
half3 _AdditionalSelfShadowLightPosition;
half3 _AdditionalSelfShadowLightDirection;
half3 _FakeShadowLightDirection;
half4 _SelfShadowParam;
half4 _AdditionalSelfShadowParam;
half4 _FakeShadowParam;
half4 _AdditionalSpotLightAttenuation;

int _CustomShadowLightIndex;
int _AdditionalSelfShadowLightIndex;

half _FakeShadowIntensity;
half4 _FakeShadowColor;

int _IsSwitchPass;


TEXTURE2D(_CustomSelfShadowMapRT);
SAMPLER_CMP(sampler_CustomSelfShadowMapRT);

TEXTURE2D(_AdditionalSelfShadowMapRT);
SAMPLER_CMP(sampler_AdditionalSelfShadowMapRT);

#endif
