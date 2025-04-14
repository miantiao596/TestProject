// #ifndef FA_SHADOW_TENTFITER
// #define FA_SHADOW_TENTFITER
//
// #include "FAShadowInput.hlsl"
//
// static void GetTent3Weights(float2 kernelOffset, out float4 weightsX, out float4 weightsY)
// {
//     // weightsX = GetTent3Weights(kernelOffset.x);
//     // weightsY = GetTent3Weights(kernelOffset.y);
//     float2 a = 0.5 - kernelOffset;
//     float2 b = 0.5 + kernelOffset;
//     float2 c = max(0, -kernelOffset);
//     float2 d = max(0, kernelOffset);
//     float2 w1 = a * a * 0.5;
//     float2 w2 = (1 + a) * (1 + a) * 0.5 - w1 - c * c;
//     float2 w4 = b * b * 0.5;
//     float2 w3 = (1 + b) * (1 + b) * 0.5 - w4 - d * d;
//     weightsX = float4(w1.x, w2.x, w3.x, w4.x);
//     weightsY = float4(w1.y, w2.y, w3.y, w4.y);
// }
//
// static void GetTent5Weights(float kernelOffset, out float4 weightsA, out float2 weightsB)
// {
//     float a = 0.5 - kernelOffset;
//     float b = 0.5 + kernelOffset;
//     float c = max(0, -kernelOffset);
//     float d = max(0, kernelOffset);
//     float w1 = a * a * 0.5;
//     float w2 = (2 * a + 1) * 0.5;
//     float w3 = (2 + a) * (2 + a) * 0.5 - w1 - w2 - c * c;
//
//     float w6 = b * b * 0.5;
//     float w5 = (2 * b + 1) * 0.5;
//     float w4 = (2 + b) * (2 + b) * 0.5 - w5 - w6 - d * d;
//
//     weightsA = float4(w1, w2, w3, w4);
//     weightsB = float2(w5, w6);
// }
//
// ///一个group由2x2个像素组成，根据像素的横向权重weightsX和纵向权重weightsY，利用双线性插值公式，计算出采样坐标。
// static float2 GetGroupTapUV(float2 groupCenterCoord, float2 weightsX, float2 weightsY)
// {
//     float offsetX = weightsX.y / (weightsX.x + weightsX.y);
//     float offsetY = weightsY.y / (weightsY.x + weightsY.y);
//     float2 coord = groupCenterCoord - 0.5 + float2(offsetX, offsetY);
//     return coord * _SelfShadowParam.xy;
// }
//
// ///5x5的TentFilter，对应9个group
// static void GetTent5GroupWeights(
//     float4 weightsXA, float2 weightsXB,
//     float4 weightsYA, float2 weightsYB,
//     out float3 groupWeightsA, out float3 groupWeightsB, out float3 groupWeightsC)
// {
//     
//     groupWeightsA.x = dot(weightsXA.xyxy, weightsYA.xxyy);
//     groupWeightsA.y = dot(weightsXA.zwzw, weightsYA.xxyy);
//     groupWeightsA.z = dot(weightsXB.xyxy, weightsYA.xxyy);
//
//     groupWeightsB.x = dot(weightsXA.xyxy, weightsYA.zzww);
//     groupWeightsB.y = dot(weightsXA.zwzw, weightsYA.zzww);
//     groupWeightsB.z = dot(weightsXB.xyxy, weightsYA.zzww);
//
//     groupWeightsC.x = dot(weightsXA.xyxy, weightsYB.xxyy);
//     groupWeightsC.y = dot(weightsXA.zwzw, weightsYB.xxyy);
//     groupWeightsC.z = dot(weightsXB.xyxy, weightsYB.xxyy);
//     float w = dot(groupWeightsA, 1) + dot(groupWeightsB, 1) + dot(groupWeightsC, 1);
//     float iw = rcp(w);
//     groupWeightsA *= iw;
//     groupWeightsB *= iw;
//     groupWeightsC *= iw;
// }
//
// static float4 GetTent3GroupWeights(float4 weightsX, float4 weightsY)
// {
//     float4 tapWeights;
//     tapWeights.x = dot(weightsX.xyxy, weightsY.xxyy);
//     tapWeights.y = dot(weightsX.zwzw, weightsY.xxyy);
//     tapWeights.z = dot(weightsX.xyxy, weightsY.zzww);
//     tapWeights.w = dot(weightsX.zwzw, weightsY.zzww);
//     return tapWeights / dot(tapWeights, 1);
// }
//
// float SampleShadowPCF(float2 uv, float depth)
// {
//     return SAMPLE_TEXTURE2D_SHADOW(_CustomShadowMapRT, sampler_CustomShadowMapRT, float4(uv, depth, 0));
// }
//
// float SampleShadowPCF3x3_4Tap(float3 uvd)
// {
//     float2 texelCoord = _SelfShadowParam.zw * uvd.xy;
//     float2 texelOriginal = round(texelCoord);
//     float2 kernelOffset = texelCoord - texelOriginal;
//     float4 weightsX, weightsY;
//
//     //返回x轴和y轴的权重
//     GetTent3Weights(kernelOffset, weightsX, weightsY);
//
//     //左下
//     float2 uv0 = GetGroupTapUV(texelOriginal + float2(-1, -1), weightsX.xy, weightsY.xy);
//     //右下
//     float2 uv1 = GetGroupTapUV(texelOriginal + float2(1, -1), weightsX.zw, weightsY.xy);
//     //左上
//     float2 uv2 = GetGroupTapUV(texelOriginal + float2(-1, 1), weightsX.xy, weightsY.zw);
//     //右上
//     float2 uv3 = GetGroupTapUV(texelOriginal + float2(1, 1), weightsX.zw, weightsY.zw);
//
//     float4 weights = GetTent3GroupWeights(weightsX, weightsY);
//
//     float4 tap4;
//     tap4.x = SampleShadowPCF(uv0, uvd.z);
//     tap4.y = SampleShadowPCF(uv1, uvd.z);
//     tap4.z = SampleShadowPCF(uv2, uvd.z);
//     tap4.w = SampleShadowPCF(uv3, uvd.z);
//
//     // return tap4.x;
//
//     return dot(tap4, weights);
//
// }
//
// float SampleShadowPCF5x5_9Tap(float3 uvd)
// {
//     float2 texelCoord = _SelfShadowParam.zw * uvd.xy;
//     float2 texelOriginal = round(texelCoord);
//     float2 kernelOffset = texelCoord - texelOriginal;
//
//     float4 weightsXA, weightsYA;
//     float2 weightsXB, weightsYB;
//
//     GetTent5Weights(kernelOffset.x, weightsXA, weightsXB);
//     GetTent5Weights(kernelOffset.y, weightsYA, weightsYB);
//
//     float2 uv0 = GetGroupTapUV(texelOriginal + float2(-2, -2), weightsXA.xy, weightsYA.xy);
//     float2 uv1 = GetGroupTapUV(texelOriginal + float2(0, -2), weightsXA.zw, weightsYA.xy);
//     float2 uv2 = GetGroupTapUV(texelOriginal + float2(2, -2), weightsXB.xy, weightsYA.xy);
//
//     float2 uv3 = GetGroupTapUV(texelOriginal + float2(-2, 0), weightsXA.xy, weightsYA.zw);
//     float2 uv4 = GetGroupTapUV(texelOriginal + float2(0, 0), weightsXA.zw, weightsYA.zw);
//     float2 uv5 = GetGroupTapUV(texelOriginal + float2(2, 0), weightsXB.xy, weightsYA.zw);
//
//     float2 uv6 = GetGroupTapUV(texelOriginal + float2(-2, 2), weightsXA.xy, weightsYB.xy);
//     float2 uv7 = GetGroupTapUV(texelOriginal + float2(0, 2), weightsXA.zw, weightsYB.xy);
//     float2 uv8 = GetGroupTapUV(texelOriginal + float2(2, 2), weightsXB.xy, weightsYB.xy);
//
//     float3 groupWeightsA, groupWeightsB, groupWeightsC;
//     ///5x5的TentFilter，对应9个Group
//     GetTent5GroupWeights(weightsXA, weightsXB, weightsYA, weightsYB, groupWeightsA, groupWeightsB, groupWeightsC);
//
//     float3 tapA, tapB, tapC;
//     float d = uvd.z;
//
//     tapA.x = SampleShadowPCF(uv0, d);
//     tapA.y = SampleShadowPCF(uv1, d);
//     tapA.z = SampleShadowPCF(uv2, d);
//
//     tapB.x = SampleShadowPCF(uv3, d);
//     tapB.y = SampleShadowPCF(uv4, d);
//     tapB.z = SampleShadowPCF(uv5, d);
//
//     tapC.x = SampleShadowPCF(uv6, d);
//     tapC.y = SampleShadowPCF(uv7, d);
//     tapC.z = SampleShadowPCF(uv8, d);
//     
//     return dot(tapA, groupWeightsA) + dot(tapB, groupWeightsB) + dot(tapC, groupWeightsC);
// }
//
//
// half CalaulateShadowAttenuation(half3 positionWS, half3 normalWS)
// {
//     half selfShadowMapShadow = 1;
//     // matrix mul is heavy(= 3 dot()), but better than passing from Varyings due to interpolation cost 
//     float4 positionSelfShadowCS = mul(_SelfShadowWorldToClip, float4(positionWS, 1));
//     // ortho camera shadow map can remove /w since positionSelfShadowCS.w is always 1
//     //float3 positionSelfShadowNDC = positionSelfShadowCS.xyz / positionSelfShadowCS.w; // ortho camera no need this line's /w, but we have two types of camera
//     float3 positionSelfShadowNDC = positionSelfShadowCS.xyz / positionSelfShadowCS.w; // this line is enough
//     // convert ndc.xy[-1,1] to uv[0,1]
//     float2 shadowMapUV_XY = positionSelfShadowNDC.xy * 0.5 + 0.5;
//     // calculate SAMPLE_TEXTURE2D_SHADOW(...)'s ndc.z compare value
//     float ndcZCompareValue = positionSelfShadowNDC.z;
//     // if OpenGL, convert ndc.z [-1,1] to shadowmap's [0,1], because shadowmap always within 0~1 range, for any platform
//     // if DirectX, do nothing, it is 0~1 range already
//     ndcZCompareValue = UNITY_NEAR_CLIP_VALUE < 0 ? ndcZCompareValue * 0.5 + 0.5 : ndcZCompareValue;
//     // +z compare bias in ndc.z [0,1] space, also apply DirectX's reverse depth to bias
//     ndcZCompareValue += (_GlobalSelfShadowDepthBias+_SelfShadowMappingDepthBias) * UNITY_NEAR_CLIP_VALUE;
//     // if DirectX, flip uv's y (y = 1-y)
//     // if OpenGL, do nothing
//     #if UNITY_UV_STARTS_AT_TOP
//         shadowMapUV_XY.y = 1 - shadowMapUV_XY.y;
//     #endif
//     float4 selfShadowmapUV = float4(shadowMapUV_XY,ndcZCompareValue,0);
//     // URP's 4 tap(mobile)/ 9 tap(non-mobile) soft shadow, reuse URP's _SHADOWS_SOFT keyword to avoid using more multi_compile, 
//     // but it may be still too costly for mobile even it is just 4 tap
//     #if _SHADOWS_SOFT
//         ShadowSamplingData shadowData;
//         shadowData.shadowOffset0 = float4(+_SelfShadowParam.x,+_SelfShadowParam.y,0,0);
//         shadowData.shadowOffset1 = float4(-_SelfShadowParam.x,+_SelfShadowParam.y,0,0);
//         shadowData.shadowOffset2 = float4(+_SelfShadowParam.x,-_SelfShadowParam.y,0,0);
//         shadowData.shadowOffset3 = float4(-_SelfShadowParam.x,-_SelfShadowParam.y,0,0);
//         shadowData.shadowmapSize = _SelfShadowParam;
//         selfShadowMapShadow = SampleShadowmapFiltered(TEXTURE2D_SHADOW_ARGS(_CustomShadowMapRT, sampler_CustomShadowMapRT),selfShadowmapUV,shadowData);
//         // (optional) sharpen shadow
//         //selfShadowMapShadow = smoothstep(0.25,0.75,selfShadowMapShadow);
//     #else
//      // 1 sample only, let hardware do the 1 tap bilinear filter, which is 0 cost filtering
//      //
// 		#if _EDITOR_HIGH_SOFT_SHADOW
// 			selfShadowMapShadow = SampleShadowPCF5x5_9Tap(float3(shadowMapUV_XY, ndcZCompareValue));
// 		#else
// 		selfShadowMapShadow = SampleShadowPCF3x3_4Tap(float3(shadowMapUV_XY, ndcZCompareValue));
// 		#endif
//     //selfShadowMapShadow = SAMPLE_TEXTURE2D_SHADOW(_CustomShadowMapRT, sampler_CustomShadowMapRT, selfShadowmapUV);
//     #endif
//     // fadeout shadow if reaching the end of shadow distance (always use 2m from start fade to end fade)
//     //float fadeTotalDistance = 2;
//     //float selfLinearEyeDepth = Convert_SV_PositionZ_ToLinearViewSpaceDepth(input.positionCS.z);
//     //selfShadowMapShadow = lerp(selfShadowMapShadow,1, saturate((1/fadeTotalDistance) * (abs(selfLinearEyeDepth)-(_SelfShadowRange-fadeTotalDistance))));  
//      
//      // use additional N dot ShadowLight's L to hide self shadowmap artifact
//     // smoothstep values 0.1,0.2 are based on observation only just to hide the artifact, no meaning   
//     selfShadowMapShadow *= _SelfShadowUseNdotLFix ? smoothstep(0.1,1,saturate(dot(normalWS, _SelfShadowLightDirection))) : 1;
//     // let user control self shadow intensity per material
//     selfShadowMapShadow = lerp(1, selfShadowMapShadow, _CustomSelfShadowIntensity);
//     return selfShadowMapShadow;
// }
//
// #endif