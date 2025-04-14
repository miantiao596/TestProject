#ifndef SELF_SHADOW_TENT_FILTER
#define SELF_SHADOW_TENT_FILTER

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

static void GetTent3Weights(float2 kernelOffset, out float4 weightsX, out float4 weightsY)
{
    // weightsX = GetTent3Weights(kernelOffset.x);
    // weightsY = GetTent3Weights(kernelOffset.y);
    float2 a = 0.5 - kernelOffset;
    float2 b = 0.5 + kernelOffset;
    float2 c = max(0, -kernelOffset);
    float2 d = max(0, kernelOffset);
    float2 w1 = a * a * 0.5;
    float2 w2 = (1 + a) * (1 + a) * 0.5 - w1 - c * c;
    float2 w4 = b * b * 0.5;
    float2 w3 = (1 + b) * (1 + b) * 0.5 - w4 - d * d;
    weightsX = float4(w1.x, w2.x, w3.x, w4.x);
    weightsY = float4(w1.y, w2.y, w3.y, w4.y);
}

static float2 GetGroupTapUV(half4 shadowParam, float2 groupCenterCoord, float2 weightsX, float2 weightsY)
{
    float offsetX = weightsX.y / (weightsX.x + weightsX.y);
    float offsetY = weightsY.y / (weightsY.x + weightsY.y);
    float2 coord = groupCenterCoord - 0.5 + float2(offsetX, offsetY);
    return coord * shadowParam.xy;
}


static float4 GetTent3GroupWeights(float4 weightsX, float4 weightsY)
{
    float4 tapWeights;
    tapWeights.x = dot(weightsX.xyxy, weightsY.xxyy);
    tapWeights.y = dot(weightsX.zwzw, weightsY.xxyy);
    tapWeights.z = dot(weightsX.xyxy, weightsY.zzww);
    tapWeights.w = dot(weightsX.zwzw, weightsY.zzww);
    return tapWeights / dot(tapWeights, 1);
}

float SampleShadowPCF(Texture2D tex,SamplerComparisonState smp,float2 uv, float depth)
{
    return SAMPLE_TEXTURE2D_SHADOW(tex, smp, float4(uv, depth, 0));
}

float SampleShadowPCF3x3_4Tap(Texture2D tex,half4 shadowParam,SamplerComparisonState smp,float3 uvd)
{
    float2 texelCoord = shadowParam.zw * uvd.xy;
    float2 texelOriginal = round(texelCoord);
    float2 kernelOffset = texelCoord - texelOriginal;
    float4 weightsX, weightsY;

    //return SampleShadowPCF(tex,smp,uvd.xy,uvd.z);
    
    //返回x轴和y轴的权重
    GetTent3Weights(kernelOffset, weightsX, weightsY);

    //左下
    float2 uv0 = GetGroupTapUV(shadowParam,texelOriginal + float2(-1, -1), weightsX.xy, weightsY.xy);
    //右下
    float2 uv1 = GetGroupTapUV(shadowParam,texelOriginal + float2(1, -1), weightsX.zw, weightsY.xy);
    //左上
    float2 uv2 = GetGroupTapUV(shadowParam,texelOriginal + float2(-1, 1), weightsX.xy, weightsY.zw);
    //右上
    float2 uv3 = GetGroupTapUV(shadowParam,texelOriginal + float2(1, 1), weightsX.zw, weightsY.zw);

    float4 weights = GetTent3GroupWeights(weightsX, weightsY);

    float4 tap4;
    tap4.x = SampleShadowPCF(tex,smp,uv0, uvd.z);
    tap4.y = SampleShadowPCF(tex,smp,uv1, uvd.z);
    tap4.z = SampleShadowPCF(tex,smp,uv2, uvd.z);
    tap4.w = SampleShadowPCF(tex,smp,uv3, uvd.z);

    // return tap4.x;
    return dot(tap4, weights);
}

#endif