#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

#define _HAIR

float4 _HairTintColor1;
float4 _HairTintColor2;
float4 _HairTintColor3;

TEXTURE2D(_HairMaskMap);
SAMPLER(sampler_HairMaskMap);

half3 ColorBlend(half3 SrcColor, half SrcAlpha, half3 DstColor)
{
    return SrcAlpha * SrcColor + (1 - SrcAlpha) * DstColor;
}

void BlendTexture(
    half2 uv,float4 vertexColor, TEXTURE2D (MaskMap),
    half4 color1, half4 color2, half4 color3,
    inout half3 albedo,inout half alpha)
{
    half4 maskMap = SAMPLE_TEXTURE2D(MaskMap, sampler_LinearClamp, uv);
    
    half3 color = 0;

    color=lerp(color3,color2,vertexColor.g);
    color=lerp(color,color1,vertexColor.r);

    albedo = color*maskMap.r;
     alpha =saturate(maskMap.b+maskMap.a) ;
}