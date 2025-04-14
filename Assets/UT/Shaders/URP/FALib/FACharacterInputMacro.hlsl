#ifndef FA_CHARACTER_INPUT_MACRO
	#define FA_CHARACTER_INPUT_MACRO

	#include "FABaseInputMacro.hlsl"

	#define CHARACTER_INPUT_BASE_TEX \
	BASE_INPUT_BASE_TEX \
	BASE_INPUT_COMBINED_TEX \
	BASE_INPUT_REFLECTIONPROBE_TEX
	#define CHARACTER_INPUT_BASE \
	BASE_INPUT_BASE \
	BASE_INPUT_NORMAL \
	BASE_INPUT_COMBINED \
	BASE_INPUT_EMISSION \
	BASE_INPUT_FOG \
	BASE_INPUT_ALPHACLIP \
	half	_Intensity; \
	BASE_INPUT_FRESNEL \
	BASE_INPUT_SHASOW \
	BASE_INPUT_LIGHT \
	BASE_INPUT_ALPHAPREMULTIPLIED \


	// 眼球
	#define CHARACTER_INPUT_EYEBALL_TEX \
	TEXTURECUBE(_EyeHighlightCubeMap);		SAMPLER(sampler_EyeHighlightCubeMap);
	//TEXTURECUBE(_EyeHighlightCubeMap2);		SAMPLER(sampler_EyeHighlightCubeMap2);
	#define CHARACTER_INPUT_EYEBALL \
	half4 _EyeHighlightCubeMap_HDR;
	//half3	_SeparateLightDirection; \
	//half4	_SeparateEyeDirection; \
	//half4	_SeparateEyeDirection2;

	// 玻璃
	#define CHARACTER_INPUT_SIMPLEGLASS \
	half4	_RimColor; \
	half	_RimPower;

	// 头发
	#define CHARACTER_INPUT_HAIR_TEX \
	TEXTURE2D(_SpecularTex);				SAMPLER(sampler_SpecularTex);
	#define CHARACTER_INPUT_HAIR \
	half4	_SpecularColor; \
	half4	_SpecularColor2; \
	float4	_SpecularTex_ST; \
	half	_halfL; \
	half	_SpecularMultiplier; \
	half	_SpecularMultiplier2; \
	half	_PrimaryShift; \
	half	_PrimarySpecularScale; \
	half	_SecondaryShift; \
	half	_SecondSpecularScale;

	// PBR头发
	#define CHARACTER_INPUT_HAIRPBR \
	half4	_SpecularColor; \
	half4	_SpecularColor2; \
	half	_PrimaryShift; \
	half	_PrimarySpecularScale; \
	half	_SecondaryShift; \
	half	_SecondSpecularScale; \
	half	_Anisotropy; \
	half	_Anisotropy2; \
	half	_Fresnel0;

	// 皮肤
	#define CHARACTER_INPUT_SKIN_TEX \
	TEXTURE2D(_SSSLUT);				SAMPLER(sampler_SSSLUT); \
	TEXTURE2D(_KelemenLUT);			SAMPLER(sampler_KelemenLUT);\
	TEXTURE2D(_TranslucencyLUT);	SAMPLER(sampler_TranslucencyLUT);
	
	//TEXTURE2D(_ThicknessMap);	    SAMPLER(sampler_ThicknessMap);\
	//TEXTURE2D(_TranslucencyMap);	SAMPLER(sampler_TranslucencyMap);

	#define CHARACTER_INPUT_SKIN \
	half	_CurveFactor; \
	half    _SpecularFactor; \
	half4   _TranslucencyLUT_ST; \
	half    _Translucency; \
	half _UseURPShadowMap;
	
	//	half    _FilpAlphaChannel;\
	//half4   _ThicknessMap_ST; \
	//half4   _TranslucencyMap_ST; \
	
	// --- Do not move these commented attributes above,
	// --- or it will break the macro definition.
	/*half4	_DiffuseAdd; \*/
	/*half4	_DarkFaceColorAdd; \*/
	/*half	_Glossiness; \*/

	// 五彩斑斓的白
	#define CHARACTER_INPUT_IRIDESCENCE_TEX \
	TEXTURE2D(_IridescenceMatCap);                  SAMPLER(sampler_IridescenceMatCap);
	#define CHARACTER_INPUT_IRIDESCENCE \
	half _IridescenceReflectionPower;

	// TEXTURECUBE(_IridescenceReflectionCubeMap);		SAMPLER(sampler_IridescenceReflectionCubeMap); \


	// 角色效果相关定义
	#define CHARACTER_INPUT_EFFECT_PUBLIC \
	half	_DitherOpacity; \
	half	_DissolvePercent; \
	half	_ModelHeight; \
	half4	_EvolveParams; \
	half	_Ice_Sin1; \
	half	_Ice_Degree1; \
	half	_Ice_Sin2; \
	half	_Ice_Degree2;

	// 进化
	//#define EVOLVE_PARAMS(i) float4 result : TEXCOORD##i;
	//#define CHARACTER_INPUT_EVOLVE \
	//half4	_TransitionColor; \
	//float	_TransitionLength;
	
	// 进化2
	#define CHARACTER_INPUT_EVOLVE_2_TEX\
	TEXTURE2D(_HexPattern);					SAMPLER(sampler_HexPattern);
	#define CHARACTER_INPUT_EVOLVE_2 \
	float _HueOffset; \
	float _Tiling; \
	float _Falloff; \
	float _HexMaxOffset; \
	float4 _HexColor; \
	float _DistanceMin; \
	float _DistanceMax; \
	float4 _HexColor2; \
	float _Distance2Min; \
	float _Distance2Max; \
	float4 _FresnelColor_E; \
	float _FresnelScale_E; \
	float _FresnelPower_E; \
	float _Distance3Min; \
	float _Distance3Max; \
	float _VertexOffset; \
	float4 _LevelsStart; \
	float4 _LevelsEnd;
	// float _NoiseInfluence; \
	// float _NoiseScale;

	// 冰冻
	//#define CHARACTER_INPUT_ICE_TEX \
	//TEXTURE2D(_IceReflect);					SAMPLER(sampler_IceReflect); \
	//TEXTURE2D(_IceDetail);					SAMPLER(sampler_IceDetail); \
	//TEXTURE2D(_IceMask);					SAMPLER(sampler_IceMask);
	//#define CHARACTER_INPUT_ICE \
	//float4	_IceReflect_ST; \
	//float4	_IceDetail_ST; \
	//float4	_IceMask_ST; \
	//half4	_FreezeColor; \
	//half	_FresnelBase; \
	//half	_FresnelScale; \
	//half	_FresnelSensitive; \
	//half4	_FresnelColor;\
	//half    _Ratio;

	// 石化
	//#define CHARACTER_INPUT_STONE_TEX \
	//TEXTURE2D(_StoneTex);					SAMPLER(sampler_StoneTex);
	//#define CHARACTER_INPUT_STONE \
	//float4	_StoneTex_ST;

	// 溶解
	#define CHARACTER_INPUT_DISSOLVE_TEX \
	BASE_INPUT_DISSOLVE_TEX \
	TEXTURE2D(_RampMask);					SAMPLER(sampler_RampMask);
	#define CHARACTER_INPUT_DISSOLVE \
	BASE_INPUT_DISSOLVE \
	float4	_RampMask_ST;

	// 故障抖动
	#define CHARACTER_INPUT_GLITCH \
	half	_Hologram_GlitchSpeed; \
	half	_Hologram_GlitchInterval; \
	half4	_Hologram_GlitchOffset; \
	half	_Hologram_GlitchTiling; \
	half	_Hologram_GlitchConstant;

	// 全息
	#define CHARACTER_INPUT_HOLOGRAM \
	CHARACTER_INPUT_GLITCH \
	half4	_Hologram_Color; \
	half	_Hologram_SLine1Alpha; \
	half	_Hologram_SLine1Speed; \
	half	_Hologram_SLine1Frequency; \
	half	_Hologram_RimPower; \
	half	_Hologram_RimIntensity;
	//half4	_Hologram_RimColor; \

	// 隐身
	//#define CHARACTER_INPUT_INVISIBILITY_TEX \
	//TEXTURE2D(_InvisibilityMask);		SAMPLER(sampler_InvisibilityMask);
	//#define CHARACTER_INPUT_INVISIBILITY \
	//float4	_InvisibilityMask_ST; \
	//half	_InvisibilityColorLength; \
	//half4	_InvisibilityColor;

    
    // 全息2
    #define CHARACTER_INPUT_HOLOGRAM2_TEX \
    TEXTURE2D(_Hologram2_Line1);		SAMPLER(sampler_Hologram2_Line1);\
    TEXTURE2D(_Hologram2_LineGlitch);		SAMPLER(sampler_Hologram2_LineGlitch);\
    TEXTURE2D(_Hologram2_NormalMap);		SAMPLER(sampler_Hologram2_NormalMap);
    #define CHARACTER_INPUT_HOLOGRAM2 \
    half4 _Hologram2_Color; \
    /*half _Hologram2_Alpha;*/ \
    half _Hologram2_RandomOffset; \
    half _Hologram2_PositionSpaceFeature;\
    float _Hologram2_PositionFeature;\
    float _Hologram2_PositionDirection;\
    half _Hologram2_FresnelRGBScale;\
    half _Hologram2_FresnelRGBPower;\
    /*half _Hologram2_FresnelAlphaScale;*/ \
    /*half _Hologram2_FresnelAlphaPower;*/ \
    half4 _Hologram2_Line1_ST;\
    half _Hologram2_Line1Speed;\
    half _Hologram2_Line1Frequency;\
    half _Hologram2_Line1Hardness;\
    half _Hologram2_Line1InvertedThickness;\
    half _Hologram2_Line1Alpha;\
    half4 _Hologram2_LineGlitch_ST;\
    half3 _Hologram2_LineGlitchOffset;\
    half _Hologram2_LineGlitchSpeed;\
    half _Hologram2_LineGlitchFrequency;\
    half _Hologram2_LineGlitchHardness;\
    half _Hologram2_LineGlitchInvertedThickness;\
    half3 _Hologram2_RandomGlitchOffset;\
    half _Hologram2_RandomGlitchAmount;\
    half _Hologram2_RandomGlitchConstant;\
    half _Hologram2_RandomGlitchTiling;\
    half _Hologram2_ColorGlitchAffect;
    // Holo2的部分属性会导致某些小米机型崩溃，故删除掉
    // half3 _Hologram2_GrainScale;\
    // half _Hologram2_GrainAffect;\
    // half4 _Hologram2_GrainValues;\
    // half4 _Hologram2_NormalMap_ST;\
    // half _Hologram2_NormalScale;\
    // half _Hologram2_NormalAffect;\
    // half3 _Hologram2_DissolveScale;\
    // half _Hologram2_DissolveHide;
    
    //    TEXTURE2D(_Hologram2_MainTex);		SAMPLER(sampler_Hologram2_MainTex);\
    //    half4 _Hologram2_MainTex_ST; \
    
	#define CHARACTER_INPUT_EFFECT_ALL_TEX \
	CHARACTER_INPUT_DISSOLVE_TEX \
	CHARACTER_INPUT_EVOLVE_2_TEX \
	CHARACTER_INPUT_HOLOGRAM2_TEX 
    //CHARACTER_INPUT_INVISIBILITY_TEX \

	#define CHARACTER_INPUT_EFFECT_ALL \
	CHARACTER_INPUT_EFFECT_PUBLIC \
	CHARACTER_INPUT_DISSOLVE \
	CHARACTER_INPUT_HOLOGRAM \
    CHARACTER_INPUT_EVOLVE_2 \
    CHARACTER_INPUT_HOLOGRAM2
    // CHARACTER_INPUT_INVISIBILITY \

#endif