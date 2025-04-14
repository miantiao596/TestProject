#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

#define _LASHES

half4 _LashesTintColor1;
half4 _LashesTintColor2;
half4 _LashesTintColor3;

TEXTURE2D(_LashesTintMap);


half3 ColorBlend(half3 SrcColor, half SrcAlpha, half3 DstColor)
{
    return SrcAlpha * SrcColor + (1 - SrcAlpha) * DstColor;
}

void BlendTexture(
    half2 uv, TEXTURE2D (TintMap),
    half4 color1, half4 color2, half4 color3,
    inout half3 albedo,inout half alpha)
{
    half4 tintMap = SAMPLE_TEXTURE2D(TintMap, sampler_LinearClamp, uv);
    
    half3 color = albedo.rgb;
    color = ColorBlend(color1.rgb, saturate(tintMap.r + (color1.a * 2 - 1)), color);
    color = ColorBlend(color2.rgb, saturate(tintMap.g + (color2.a * 2 - 1)), color);
    color = ColorBlend(color3.rgb, saturate(tintMap.b + (color3.a * 2 - 1)), color);

    color = lerp(albedo, color, tintMap.a);

    albedo = color;
}