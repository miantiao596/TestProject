#ifndef FAFOGLIB_INCLUDED
#define FAFOGLIB_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//#include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

//#pragma enable_d3d11_debug_symbols
int  _UseFog;
float _FogDensity;
float _fogDensityMax;
half _FogOpacity;
half _FogOpacityTop;
half _FogOpacityBottom;


float _FogHeight;
float _HeightFalloff;
float _FogStartDistance;
float4 _FogTopColor;
float4 _FogBottomColor;
float _GradientTop;
float _GradientBottom;
float _InscatteringExponent;
float _InscatteringStartDistance;


float CalculateLineIntegralShared(float heightFalloff, float rayDirectionY, float rayOriginTerms)
{
    //-127是UE源码的经验值，UE中的注释“if it's lower than -127.0, then exp2() goes crazy in OpenGL's GLSL.”
    float falloff = max(-127, heightFalloff * rayDirectionY);
    float lineIntegral = (1 - exp2(-falloff)) / falloff;
    float lineIntegralTaylor = log(2.0) - (0.5 * pow(2, log(2.0))) * falloff;		// Taylor expansion around 0

    return rayOriginTerms * (abs(falloff) > 0.01 ? lineIntegral : lineIntegralTaylor);
}

void CustomMixFogColor(float3 positionWS, out half3 finalColor, out half fogFactor)
{
    float3 cameraToReceiver = positionWS.xyz - _WorldSpaceCameraPos;
    //Length的平方，因为夹角为0，cos为1
    float cameraToReceiverLengthSqr = dot(cameraToReceiver, cameraToReceiver);
    //Length的倒数,rsqrt作用是返回平方根的倒数，输入模的平方，则返回模的倒数
    float cameraToReceiverLengthInv = rsqrt(max(cameraToReceiverLengthSqr, 0.00001f));
    //Length的平方乘以模的倒数 = 模
    float cameraToReceiverLength = cameraToReceiverLengthSqr * cameraToReceiverLengthInv;//如果直接用这个变量当作rayLength(高度距离和雾效的衰减关系会没有)
    // half3 cameraToReceiverNormalized = cameraToReceiver * cameraToReceiverLengthInv;

    float excludeIntersectionTime = saturate(_FogStartDistance * cameraToReceiverLengthInv);//_FogStartDistance * cameraToReceiverLengthInv;
    float cameraToExclusionIntersectionY = excludeIntersectionTime * cameraToReceiver.y;
    float exclusionIntersectionY = _WorldSpaceCameraPos.y + cameraToExclusionIntersectionY;
    float exclusionIntersectionToReceiverY = cameraToReceiver.y - cameraToExclusionIntersectionY;

    // Calculate fog off of the ray starting from the exclusion distance, instead of starting from the camera
    float rayLength = (1.0f - excludeIntersectionTime) * cameraToReceiverLength;
    float rayDirectionY = exclusionIntersectionToReceiverY;

    float exponent = max(-127, _HeightFalloff * (exclusionIntersectionY - _FogHeight));
    //ue里不知道在哪浓度除了1000.再加上ue单位是厘米要*100，最终结果是ue的浓度系数是这里的1/10，所以要/10。
    _FogDensity = min(_FogDensity,_fogDensityMax);
    float rayOriginalTerms = _FogDensity/10.0f * exp2(-exponent);

    float exponentialHeightLineIntegralShared = CalculateLineIntegralShared(_HeightFalloff, rayDirectionY, rayOriginalTerms);
    float exponentialHeightLineIntegral = exponentialHeightLineIntegralShared * rayLength;
    //half expFogFactor = saturate(exp2(-exponentialHeightLineIntegral));
    half expFogFactor1 = max(saturate(exp2(-exponentialHeightLineIntegral)), _FogOpacityBottom);
    half expFogFactor2 = max(saturate(exp2(-exponentialHeightLineIntegral)),  _FogOpacityTop);

    ////Inscattered
    //float dirExponentialHeightLineIntegral = exponentialHeightLineIntegralShared * max(rayLength - _InscatteringStartDistance, 0);
    //half  dirInscatteringFogFactor = saturate(exp2(-dirExponentialHeightLineIntegral));
    //half3 directionalLightInscattering = pow(saturate(dot(cameraToReceiverNormalized, _MainLightPosition.xyz)), _InscatteringExponent);
    //half3 directionalInscattering = directionalLightInscattering * (1 - dirInscatteringFogFactor);
    //反插值 rayDirectionY = bottom+x*(top-bottom)
    //x = (rayDirectionY-bottom)/top-bottom)
    half x = saturate((positionWS.y - _GradientBottom) / max((_GradientTop - _GradientBottom), 0.0001f));

    half3 fogColor = lerp(_FogBottomColor, _FogTopColor, x);
    half expFogFactor = lerp( expFogFactor1, expFogFactor2, x);
    //fogColor = fogColor * (1 - expFogFactor) +directionalInscattering;

    //_FogMode=0的时候用计算的强度，_FogMode=1的时候用设置的强度
   expFogFactor = lerp(expFogFactor, 1 - _FogIntensity, _FogMode); 

   expFogFactor = lerp( 1,expFogFactor, _UseFog); 
   
    // expFogFactor = lerp(expFogFactor, lerp( 1, 1-_FogIntensity,ceil(_FogDensity)), _FogMode);   
    finalColor = fogColor;
    fogFactor = expFogFactor;
    //half3 finalColor = expFogFactor + fogColor * (1 - expFogFactor);

   //return finalColor;
}

// float3 MixFogColorFrag(float3 positionWS, float3 color)
// {
//     float3 cameraToReceiver = positionWS.xyz - _WorldSpaceCameraPos;
//     //Length的平方，因为夹角为0，cos为1
//     float cameraToReceiverLengthSqr = dot(cameraToReceiver, cameraToReceiver);
//     //Length的倒数,rsqrt作用是返回平方根的倒数，输入模的平方，则返回模的倒数
//     float cameraToReceiverLengthInv = rsqrt(max(cameraToReceiverLengthSqr, 0.00001f));
//     //Length的平方乘以模的倒数 = 模
//     float cameraToReceiverLength = cameraToReceiverLengthSqr * cameraToReceiverLengthInv;//如果直接用这个变量当作rayLength(高度距离和雾效的衰减关系会没有)
//     half3 cameraToReceiverNormalized = cameraToReceiver * cameraToReceiverLengthInv;
//
//     float excludeIntersectionTime = _FogStartDistance * cameraToReceiverLengthInv;
//     float cameraToExclusionIntersectionY = excludeIntersectionTime * cameraToReceiver.y;
//     float exclusionIntersectionY = _WorldSpaceCameraPos.y + cameraToExclusionIntersectionY;
//     float exclusionIntersectionToReceiverY = cameraToReceiver.y - cameraToExclusionIntersectionY;
//
//     // Calculate fog off of the ray starting from the exclusion distance, instead of starting from the camera
//     float rayLength = (1.0f - excludeIntersectionTime) * cameraToReceiverLength;
//     float rayDirectionY = exclusionIntersectionToReceiverY;
//
//     float exponent = max(-127, _HeightFalloff * (exclusionIntersectionY - _FogHeight));
//     //ue里不知道在哪浓度除了1000.再加上ue单位是厘米要*100，最终结果是ue的浓度系数是这里的1/10，所以要/10。
//     float rayOriginalTerms = _FogDensity/10.0f * exp2(-exponent);
//     float exponentialHeightLineIntegralShared = CalculateLineIntegralShared(_HeightFalloff, rayDirectionY, rayOriginalTerms);
//     float exponentialHeightLineIntegral = exponentialHeightLineIntegralShared * rayLength;
//     //half expFogFactor = saturate(exp2(-exponentialHeightLineIntegral));
//     half expFogFactor = max(saturate(exp2(-exponentialHeightLineIntegral)), _FogOpacity);
//
//     ////Inscattered
//     //float dirExponentialHeightLineIntegral = exponentialHeightLineIntegralShared * max(rayLength - _InscatteringStartDistance, 0);
//     //half  dirInscatteringFogFactor = saturate(exp2(-dirExponentialHeightLineIntegral));
//     //half3 directionalLightInscattering = pow(saturate(dot(cameraToReceiverNormalized, _MainLightPosition.xyz)), _InscatteringExponent);
//     //half3 directionalInscattering = directionalLightInscattering * (1 - dirInscatteringFogFactor);
//     //反插值 rayDirectionY = bottom+x*(top-bottom)
//     //x = (rayDirectionY-bottom)/top-bottom)
//     half x = saturate((positionWS.y - _GradientBottom) / max((_GradientTop - _GradientBottom), 0.0001f));
//
//     half4 fogColor = lerp(_FogBottomColor, _FogTopColor, x);
//
//     //fogColor = fogColor * (1 - expFogFactor) +directionalInscattering;
//
//     //_FogMode=0的时候用计算的强度，_FogMode=1的时候用设置的强度
//     expFogFactor = lerp(expFogFactor, 1 - _FogIntensity, _FogMode);
//
//     half3 finalColor = lerp(fogColor, color, expFogFactor);//color.rgb * expFogFactor + fogColor * (1 - expFogFactor);
//
    
// }

#endif