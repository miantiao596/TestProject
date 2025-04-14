#ifndef CRACK_PLANE_INPUT
#define CRACK_PLANE_INPUT

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

TEXTURE2D(_MainTex);				SAMPLER(sampler_MainTex);
TEXTURE2D(_CombinedAO);				SAMPLER(sampler_CombinedAO);
TEXTURE2D(_EmissionTex);			SAMPLER(sampler_EmissionTex);
TEXTURE2D(_MaskTex);			    SAMPLER(sampler_MaskTex);
TEXTURE2D(_DissolutionTex);			SAMPLER(sampler_DissolutionTex);
TEXTURE2D(_PolarTex);				SAMPLER(sampler_PolarTex);
sampler2D _ParallaxTex;
TEXTURE2D(_RampMask);				SAMPLER(sampler_RampMask);


CBUFFER_START(UnityPerMaterial)
    half4 _MainTex_ChannelMask;
    half _MainTex_U;
    half _MainTex_V;
    

    
    float4 _EmissionTex_ST;
    float4 _BumpMap_ST;
    half _BumpScale;
        
    half _FogMode;
	half _FogIntensity;
    
    half _Cutoff;
    
    // Mask
    float4 _MaskTex_ST;
    half4 _MaskTex_ChannelMask;
    half _MaskTex_U;
    half _MaskTex_V;
    
    // Dissolve 
    float4 _DissolutionTex_ST;    
    half4 _DissolutionTex_ChannelMask;
    half _DissolutionTex_U;
    half _DissolutionTex_V;
    half _DissolutionReverse;
    half _DissolutionPercent;
    half _DissolutionSoftEdge;
    half _DissolutionEdgeWidth;
    half4 _DissolutionEdgeColor;
    
    // Parallax
    half4 _ParallaxTex_ST;
    float _PlaneHeight;
    half _InvertedColor;

    // Polar Coordinate
    half4 _PolarColor;
    half _ParallaxScale;
    half _PolarColorIntensity;
    half _Polar_Speed_U;
    half _Polar_Speed_V;
    
    // CustomData
    half useCustomData;
    half4 _RampMask_ST;
    float4 _MainTex_ST;
    float4 _CombinedAO_ST;
    half4 _CombinedScaledParams;
    half4 _Color;
    half4 _EmissionColor;
    half _Emissive_Intensity;

    half _TPA;
CBUFFER_END
#endif            