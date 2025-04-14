#ifndef SCENETERRAIN_INPUT
	#define SCENETERRAIN_INPUT

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

	TEXTURE2D(_MainTex);				SAMPLER(sampler_MainTex);
	TEXTURE2D(_CombinedAO);				SAMPLER(sampler_CombinedAO);
	TEXTURE2D(_BumpMap2);				SAMPLER(sampler_BumpMap2);
	TEXTURE2D(_RampMask);				SAMPLER(sampler_RampMask);
	TEXTURE2D(_EmissionTexture);		SAMPLER(sampler_EmissionTexture);
	TEXTURE2D(_DirtTex);				SAMPLER(sampler_DirtTex);
	TEXTURE2D(_DirtBumpMap);			//SAMPLER(sampler_DirtBumpMap);
	TEXTURE2D(_TopTex);					SAMPLER(sampler_TopTex);
	TEXTURE2D(_TopBumpMap);				//SAMPLER(sampler_TopBumpMap);
	TEXTURE2D(_UV2Mask);					SAMPLER(sampler_UV2Mask);
    TEXTURE2D(_HeightGradientMaskTex);           SAMPLER(sampler_HeightGradientMaskTex);
	TEXTURE2D(_DissolveMask);				SAMPLER(sampler_DissolveMask);
	// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.

	TEXTURE2D_ARRAY(_BaseMapArray);     SAMPLER(sampler_BaseMapArray);
	TEXTURE2D_ARRAY(_BumpMapArray);     SAMPLER(sampler_BumpMapArray);
	TEXTURE2D(_WeightSplat);			SAMPLER(sampler_WeightSplat);
	TEXTURE2D(_IDSplat);				SAMPLER(sampler_IDSplat);

	TEXTURE2D(_SeaGrassDistrobutionMask);				SAMPLER(sampler_SeaGrassDistrobutionMask);

	#define layerMaxNum 12

	CBUFFER_START(UnityPerMaterial)
	float4 _MainTex_ST;
	half4 _Color;
	float4 _CombinedAO_ST;
	half4 _CombinedScaledParams;
	float4 _BumpMap_ST;
	half _BumpScale;
	float4 _BumpMap2_ST;
	half _BumpScale2;
	float4 _EmissionTexture_ST;
	half4 _EmissionColor;
	half _Emissive_Intensity;
	half _MainTexAsEmissionTex;
	//float	_Enable_EmissionTex;
	half   _UseEmissionAlphaMask;
	half4   _EmissionMaskColor;
	half _EmissionMaskColorIntensity;
	// SCENE_INPUT_EMISSION_EXTRA
	//BASE_INPUT_REFLECTION
	// SCENE_INPUT_DISSOLVE
 //     
	float4	_RampMask_ST;
	half	_DissolveMaskTex_UseUV2;
    //half    _SoftDissolve;
	float4	_UV2Mask_ST;
	half _MASK_UV2_ChannelMask;
	half _DissolveMask_ChannelMask;
	half4 _RampMask_ChannelMask;
	
	float4 _DissolveMask_ST;
	half	_EdgeColorLength; 
	half4	_EdgeColor;
	half	_DissolvePercent;

	//half	_Dirt_On;
	half	_DirtMetal;
	half	_DirtSmoothness;
	float4	_DirtTex_ST;
	// float4	_DirtCombinedAO_ST;
	float4	_DirtBumpMap_ST;
	// float4	_DirtMaskTex_ST;
	half4	_DirtColor;
	half	_DirtBumpScale;
	// half4	_DirtCombinedScaledParams;

	//half	_TopDetail_On;
	half	_TopMetal;
	half	_TopSmoothness;
	float4	_TopTex_ST;
	// float4	_TopMaskTex_ST;
	half4	_TopColor;
	half	_TopBumpScale;
	// half4	_TopCombinedScaledParams;
	half	_TopMaskTex_UseUV2;
	half	_TopOffset;
	half	_TopPower;
	half	_TopIntensity;

	half    _UseCharacterAmbient;
	
    // Height Gradient
    half4 _HeightGradientColor;
    half4 _HeightGradientMaskTex_ST;
    half _HeightGradientIntensity;
    half _HeightGradientUVType;
    half _WorldPos_Dir;
    half4 _CoordinateRange;
    half4 _HeightGradientMaskTex_ChannelMask;

    // SCENE_SHADOW_INPUT
    //
    // 
    half _MainTex_UVType;
    half _Smoothness_UVType;
    half4 _SmoothnessTillingAndOffset;    
    
    half _DissolveMaskTex_Dir;
	half _DissolveMaskTex_Range_X;
	half _DissolveMaskTex_Range_Y;
	half _DissolveMaskTex_Range_Z;
	half _DissolveMaskTex_Range_W;
    //half4 _DissolveMaskTex_Range;

	half _FogMode;
	half _FogIntensity;

	half _EnableURPShadowMapping;

	half	_Cutoff;
    //float _Fog_Blend_Mode;

	int _IDSplatTexSize; 
	int _BaseMapSize; 

	half _MinBoundX;
	half _MinBoundY;
	half _BoundSize;
	half _SeaGrassShadowDark;
	half _SeaGrassShadowOffset;
	half _SeaGrassShadowFadeDis;

	CBUFFER_END

	uniform half4 _LayerTilingAndOffset[layerMaxNum];
	uniform half _LayerBumpScale[layerMaxNum];
	// uniform half _LayerMetallic[layerMaxNum];
	uniform half _LayerSmoothness[layerMaxNum];

#endif