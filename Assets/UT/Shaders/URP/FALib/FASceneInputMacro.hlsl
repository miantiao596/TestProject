#ifndef FA_SCENE_INPUT_MACRO
	#define FA_SCENE_INPUT_MACRO

	#include "FABaseInputMacro.hlsl"

	#define SCENE_INPUT_BASE_TEX \
	BASE_INPUT_BASE_TEX \
	BASE_INPUT_COMBINED_TEX
	#define SCENE_INPUT_BASE \
	BASE_INPUT_BASE \
	BASE_INPUT_COMBINED \
	BASE_INPUT_EMISSION \
	BASE_INPUT_LIGHT	\
	BASE_INPUT_ALPHAPREMULTIPLIED

	#define SCENE_INPUT_MAIN2_TEX \
	TEXTURE2D(_MainTex2);					SAMPLER(sampler_MainTex2);
	#define SCENE_INPUT_MAIN2 \
	float4	_MainTex2_ST;

	#define SCENE_INPUT_NORMAL2_TEX \
	TEXTURE2D(_BumpMap2);					SAMPLER(sampler_BumpMap2);
	#define SCENE_INPUT_NORMAL2 \
	float4	_BumpMap2_ST; \
	half	_BumpScale2;
	//half	_Enable_NormalAdd; \

	#define SCENE_INPUT_EMISSION_EXTRA_TEX \
	TEXTURE2D(_EmissionTexture);			SAMPLER(sampler_EmissionTexture);
	#define SCENE_INPUT_EMISSION_EXTRA \
	float4	_EmissionTexture_ST;

	#define SCENE_INPUT_DISSOLVE_TEX \
	BASE_INPUT_DISSOLVE_TEX
	#define SCENE_INPUT_DISSOLVE \
	BASE_INPUT_DISSOLVE \
	half	_DissolvePercent;

#endif