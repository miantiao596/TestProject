#ifndef SELF_SHADOW_LIB
#define SELF_SHADOW_LIB
#include "SelfShadow-Input.hlsl"
#include "SelfShadow-TentFilter.hlsl"


half CalaulateShadowAttenuation(Texture2D tex,SamplerComparisonState smp, float4x4 shadowWorldToCLip,half4 shadowParam, half3 lightDirection, half3 positionWS, half3 normalWS,half shadowIntensity)
{
    half selfShadowMapShadow = 1;
    // matrix mul is heavy(= 3 dot()), but better than passing from Varyings due to interpolation cost 
    float4 positionSelfShadowCS = mul(shadowWorldToCLip, float4(positionWS, 1));
    // ortho camera shadow map can remove /w since positionSelfShadowCS.w is always 1
    //float3 positionSelfShadowNDC = positionSelfShadowCS.xyz / positionSelfShadowCS.w; // ortho camera no need this line's /w, but we have two types of camera
    float3 positionSelfShadowNDC = positionSelfShadowCS.xyz / positionSelfShadowCS.w; // this line is enough
    // convert ndc.xy[-1,1] to uv[0,1]
    float2 shadowMapUV_XY = positionSelfShadowNDC.xy * 0.5 + 0.5;
    // calculate SAMPLE_TEXTURE2D_SHADOW(...)'s ndc.z compare value
    float ndcZCompareValue = positionSelfShadowNDC.z;
    // if OpenGL, convert ndc.z [-1,1] to shadowmap's [0,1], because shadowmap always within 0~1 range, for any platform
    // if DirectX, do nothing, it is 0~1 range already
    ndcZCompareValue = UNITY_NEAR_CLIP_VALUE < 0 ? ndcZCompareValue * 0.5 + 0.5 : ndcZCompareValue;
    ndcZCompareValue = saturate(ndcZCompareValue);
    // +z compare bias in ndc.z [0,1] space, also apply DirectX's reverse depth to bias
    ndcZCompareValue += (_GlobalSelfShadowDepthBias+_SelfShadowMappingDepthBias) * UNITY_NEAR_CLIP_VALUE;

    //float ret = SAMPLE_TEXTURE2D(tex,smp,shadowMapUV_XY).r;
    // if DirectX, flip uv's y (y = 1-y)
    // if OpenGL, do nothing
    #if UNITY_UV_STARTS_AT_TOP
        shadowMapUV_XY.y = 1 - shadowMapUV_XY.y;
    #endif
    //selfShadowMapShadow = lerp(1,SampleShadowPCF3x3_4Tap(tex,shadowParam, smp,float3(shadowMapUV_XY, ndcZCompareValue)),step(0,ndcZCompareValue));
    selfShadowMapShadow = SampleShadowPCF3x3_4Tap(tex,shadowParam, smp,float3(shadowMapUV_XY, ndcZCompareValue));
    // use additional N dot ShadowLight's L to hide self shadowmap artifact
    // smoothstep values 0.1,0.2 are based on observation only just to hide the artifact, no meaning   
    //selfShadowMapShadow *= _SelfShadowUseNdotLFix ? smoothstep(0.1,1,saturate(dot(normalWS, lightDirection))) : 1;

    selfShadowMapShadow = lerp(1,selfShadowMapShadow,step(0,shadowMapUV_XY.x));
    selfShadowMapShadow = lerp(1,selfShadowMapShadow,step(shadowMapUV_XY.x,1));
    selfShadowMapShadow = lerp(1,selfShadowMapShadow,step(0,shadowMapUV_XY.y));
    selfShadowMapShadow = lerp(1,selfShadowMapShadow,step(shadowMapUV_XY.y,1));


    half nDotL = smoothstep(0,1,saturate(dot(normalWS, lightDirection)));
    half nDotLShadow = lerp(nDotL,1,selfShadowMapShadow);
    selfShadowMapShadow *= lerp(1,nDotLShadow,_SelfShadowUseNdotLFix);

    //selfShadowMapShadow *= smoothstep(0.1,1,saturate(dot(normalWS, _SelfShadowLightDirection)));
    // let user control self shadow intensity per material
    selfShadowMapShadow = lerp(1, selfShadowMapShadow, shadowIntensity);
    return selfShadowMapShadow;
}

half SpotLightAttenuation(half4 attenuation,half3 lightPosition, half3 lightDirection, half3 positionWS)
{

    half3 cDir = normalize(positionWS - lightPosition);
    half cCosAngle = abs(dot(normalize(lightDirection),cDir));

    half cAttenuation = cCosAngle * attenuation.z + attenuation.w;

    return max(0,cAttenuation);
}
#endif