#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#if UT_RENDERING
#include "Assets/UT/Shaders/URP/Character/CharacterInput.hlsl"
#endif

CBUFFER_START(UnityPerMaterial)
	half _isFace;
	half _NormalBlend;
	half _MaskBlend;
	float4 _BaseMap_ST;
	half4 _BaseColor;
	half4 _EmissionColor;
	half _Cutoff;
	half _Smoothness;
	half _Metallic;
	half _BumpScale;
	half _OcclusionStrength;
	half _Surface;
	half _SSSIntensity;
	half _SkinThickness;
	half _SkinCurvature;
	
	half _Spot;
	half _SpotSaturation;

#if UT_RENDERING
	half _FogMode;
	half _FogIntensity;
#endif
CBUFFER_END
#define smp _Linear_Repeat
SAMPLER(smp);

TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);   float4 _BaseMap_TexelSize;  float4 _BaseMap_MipInfo;
TEXTURE2D(_SSSMap);             SAMPLER(sampler_SSSMap);
TEXTURE2D(_BumpMap);            SAMPLER(sampler_BumpMap);
TEXTURE2D(_MaskMap);            SAMPLER(sampler_MaskMap);


#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
