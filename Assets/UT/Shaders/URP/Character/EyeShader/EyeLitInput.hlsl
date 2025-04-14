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
    //COLOR
    half4 _EyeBallColor, _IrisBaseColor, _IrisExtraColorAmountA, _IrisMarginColor;
    
    float4 _MainTex_ST; 
    //VECTTOR
    half4 _IrisBasePosition;
    //FLOAT
    half   _NormalScale, _EyeSize, _LensGloss,_IrisParallaxPower, _IrisContrast,_IrisMargin,
           _IrisPupilMetalness, _EyeBallMetalness, _IrisSize,
           _EyeBallGloss,_Final_illumination,_Srcface,_Surface;

#if UT_RENDERING
	half _FogMode;
	half _FogIntensity;
#endif

CBUFFER_END
#define smp _Linear_Repeat
SAMPLER(smp);

TEXTURE2D(_MainTex);       SAMPLER(sampler_MainTex);  float4 _MainTex_TexelSize;  float4 _MainTex_MipInfo;
TEXTURE2D(_ScleraTex);     SAMPLER(sampler_ScleraTex);  
TEXTURE2D(_EyeMask);       SAMPLER(sampler_EyeMask);
TEXTURE2D(_Normal);        SAMPLER(sampler_Normal);
TEXTURE2D(_Normal2);       SAMPLER(sampler_Normal2);



#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
