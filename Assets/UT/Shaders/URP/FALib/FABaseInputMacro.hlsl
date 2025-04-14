#ifndef BASE_INPUT_MACRO
	#define BASE_INPUT_MACRO

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

	#define BASE_INPUT_BASE_TEX \
	TEXTURE2D(_MainTex);					SAMPLER(sampler_MainTex);
	#define BASE_INPUT_BASE \
	float4	_MainTex_ST; \
	float4	_Color;

	#define BASE_INPUT_NORMAL \
	float4	_BumpMap_ST; \
	half	_BumpScale;

	#define BASE_INPUT_ALPHACLIP \
	half	_Cutoff;

	#define BASE_INPUT_FOG \
	half	_FogMode; \
	half	_FogIntensity;

	#define BASE_INPUT_COMBINED_TEX \
	TEXTURE2D(_CombinedAO);					SAMPLER(sampler_CombinedAO);
	#define BASE_INPUT_COMBINED \
	float4	_CombinedAO_ST; \
	half4	_CombinedScaledParams;

	#define BASE_INPUT_EMISSION \
	half	_Emissive_Intensity; \
	half4	_EmissionColor;

	#define BASE_INPUT_DISSOLVE_TEX \
	TEXTURE2D(_DissolveMask);				SAMPLER(sampler_DissolveMask);
	#define BASE_INPUT_DISSOLVE \
	float4	_DissolveMask_ST; \
	half	_EdgeColorLength; \
	half4	_EdgeColor;

	//#define BASE_INPUT_REFLECTION_TEX \
	//TEXTURE2D(_ReflectionTex);				SAMPLER(sampler_ReflectionTex);
	//#define BASE_INPUT_REFLECTION \
	//half	_ReflPower;
	
	#define BASE_INPUT_FRESNEL \
	half  _EnableFresnel; \
    half4 _FresnelOriginalColor; \
    half _FresnelOriginalPower; \
    half _FresnelOriginalScale;
    
    #define BASE_INPUT_REFLECTIONPROBE_TEX \
    TEXTURECUBE(_ReflectionProbeMap);		SAMPLER(sampler_ReflectionProbeMap);

    #define BASE_INPUT_SHASOW \
    half _CastShadow;
    
	#define BASE_INPUT_LIGHT \
	half _EnvironmentReflectionIntensity;

#ifndef NO_TPA
	#define BASE_INPUT_ALPHAPREMULTIPLIED half _TPA;
#else
	#define BASE_INPUT_ALPHAPREMULTIPLIED
#endif
	
	
#endif