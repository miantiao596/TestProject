#define _EYE

// CBUFFER_START(UnityPerMaterial)
float4 _IrisMap_ST;
float _IrisNormalScale;
float _PupilRadius;
float _PupilAperture;
float _PupilApertureMinimal;
float _PupilApertureMaximal;
float _IrisScale;
float _IrisRadius;
float _LimbalRingSizeIris;
float _LimbalRingSizeSclera;
float _LimbalRingFade;

float4 _IrisColor;
float4 _LimbalColor;
float _Refringence;

// CBUFFER_END

TEXTURE2D(_IrisMap);
SAMPLER(sampler_IrisMap);

TEXTURE2D(_IrisNormalMap);
SAMPLER(sampler_IrisNormalMap);

#define BUILTIN_CORNEA_IOR 1.3333
#define BUILTIN_IRIS_PLANE_OFFSET 0.02

half PositivePow(half base, half power)
{
    return pow(abs(base), power);
}

void CorneaRefraction(float2 uv, float3 ViewDirectionOS, float3 CorneaNormalOS, float CorneaIOR, float IrisPlaneOffset,
                      float irisRadius, out float2 RefractedPositionOS)
{
    float eta = 1.0 / (CorneaIOR);
    CorneaNormalOS = normalize(CorneaNormalOS);
    ViewDirectionOS = -normalize(ViewDirectionOS);
    float3 refractedViewDirectionOS = refract(ViewDirectionOS, CorneaNormalOS, eta);

    // Find the distance to intersection point
    float t = (length(uv) + IrisPlaneOffset) / refractedViewDirectionOS.z;
    //t*=step(length(uv)*2,irisRadius);
    // Output the refracted point in OS
    refractedViewDirectionOS.y = -refractedViewDirectionOS.y;
    RefractedPositionOS = uv.xy + refractedViewDirectionOS.xy * pow((1 - length(uv)), 2) * 0.2;
    // RefractedPositionOS = float2(refractedViewDirectionOS.z < 0 ? uv.xy + refractedViewDirectionOS.xy * t: float2(1.5, 1.5));
    // RefractedPositionOS=refractedViewDirectionOS.xy;
}

real2 CenterScale(real2 uv, real2 scale)
{
    real2 center = real2(0.5, 0.5);
    uv -= center;
    uv /= scale;
    uv += center;
    return uv;
}

void IrisUVLocation(float2 uv, float IrisRadius, out float2 IrisUV)
{
    IrisUV = CenterScale(uv, IrisRadius);
}

void IrisLimbalRing(float2 IrisUV,float IrisRadius, float LimbalRingSize,
                    float LimbalRingIntensity, out float LimbalRingFactor)
{
    float2 irisUVCentered = IrisUV- float2(0.5f, 0.5f);
    float localIrisRadius = length(irisUVCentered);
    
    LimbalRingFactor = localIrisRadius > IrisRadius
                           ? 0
                           :1-saturate( (IrisRadius-localIrisRadius)/LimbalRingSize);
     LimbalRingFactor =saturate( PositivePow(LimbalRingFactor, LimbalRingIntensity));
}

//极缩放UV
half2 ScaleUVFromCircle(half2 UV, float Scale)
{
    float2 UVcentered = UV - float2(0.5f, 0.5f);
    float UVlength = length(UVcentered);
    // UV on circle at distance 0.5 from the center, in direction of original UV
    float2 UVmax = normalize(UVcentered) * 0.5f;

    float2 UVscaled = lerp(UVmax, float2(0.f, 0.f), saturate((1.f - UVlength * 2.f) * Scale));
    return UVscaled + float2(0.5f, 0.5f);
}

float remap(float target, float oldMin, float oldMax, float newMin, float newMax)
{
    return (target - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
}

void CirclePupilAnimation(float2 irusUV,float pupilRadius, float pupilAperture,
                          float minimalPupilAperture,float maximalPupilAperture, out float2 animatedIrisUV)
{
    real2 center = real2(0.5, 0.5);

    animatedIrisUV = irusUV;
    animatedIrisUV -= center;

    half newRadius = lerp(minimalPupilAperture, maximalPupilAperture, pupilAperture); //目标形变瞳孔半径
    
    half a = saturate((maximalPupilAperture - length(animatedIrisUV)) / (maximalPupilAperture - newRadius));//当前坐标基于（瞳孔边缘到最大半径）的比例
    animatedIrisUV = animatedIrisUV / lerp(1, max(newRadius / pupilRadius, 0), a);//lerp用于极坐标缩放

    
    animatedIrisUV += center;
    animatedIrisUV=saturate(animatedIrisUV);
}

void IrisOffset(float2 irisUV, float2 irisOffset, out float2 displacedIrisUV)
{
    displacedIrisUV = (irisUV + irisOffset);
}

void IrisOutOfBoundColorClamp(float2 irisUV, float3 irisColor, float3 colorClamp, out float3 outputColor)
{
    outputColor = (irisUV.x < 0.0 || irisUV.y < 0.0 || irisUV.x > 1.0 || irisUV.y > 1.0) ? colorClamp : irisColor;
}

void ScleraLimbalRing(float2 irisUV, float irisRadius, float limbalRingSize,
                      float limbalRingItensity, out float limbalRingFactor)
{
    float2 irisUVCentered = irisUV- float2(0.5f, 0.5f);
    float localIrisRadius = length(irisUVCentered);
    
    limbalRingFactor = localIrisRadius < irisRadius
                           ? 0
                           :1-saturate( (localIrisRadius-irisRadius)/limbalRingSize);
    limbalRingFactor =saturate( PositivePow(limbalRingFactor, limbalRingItensity));
}

void ScleraIrisBlend(float3 scleraColor, float3 scleraNormal, float scleraSmoothness,
                     float3 irisColor, float3 irisNormal, float corneaSmoothness,
                     float irisRadius,
                     float2 irisUV,
                     // float diffusionProfileSclera, float diffusionProfileIris,
                     out float3 eyeColor, out float surfaceMask,
                     out float3 diffuseNormal, out float3 specularNormal, out float eyeSmoothness)
{
    half2 uv=irisUV-0.5;
    float osRadius = length(uv);
    float blendLerpFactor = 1.0 - (osRadius - irisRadius) / (0.04);
    blendLerpFactor = pow(blendLerpFactor, 8.0);
    blendLerpFactor = 1.0 - blendLerpFactor;
    surfaceMask = (osRadius > irisRadius)
                      ? 0.0
                      : ((osRadius < irisRadius) ? 1.0 : (lerp(1.0, 0.0, blendLerpFactor)));
    eyeColor = lerp(scleraColor, irisColor, surfaceMask);
    diffuseNormal = irisNormal;
    specularNormal = scleraNormal;
    eyeSmoothness = lerp(scleraSmoothness, corneaSmoothness, surfaceMask);
}


////方案2
half3 RefractDirection(half internalIoR, half3 WorldNormal, half3 incidentVector)
{
    half airIoR = 1.00029;

    half n = airIoR / internalIoR;

    half facing = dot(WorldNormal, incidentVector);

    half w = n * facing;

    half k = sqrt(1 + (w - n) * (w + n));

    half3 t = -normalize((w - k) * WorldNormal - n * incidentVector);
    return t;
}

half2 EyeRefraction_float(half2 UV, half3 NormalDir, half3 ViewDir, half IOR,
                          half IrisDepth, half3 EyeDirection, half4 WorldTangent)
{
    // 模拟视线通过角膜后被折射
    float3 RefractedViewDir = RefractDirection(IOR, NormalDir, ViewDir);
    float cosAlpha = dot(ViewDir, EyeDirection); // EyeDirection是眼睛正前方方向
    cosAlpha = lerp(0.325, 1, cosAlpha * cosAlpha); //视线与眼球方向的夹角
    RefractedViewDir = RefractedViewDir * (IrisDepth / cosAlpha); //虹膜深度越大，折射越强；视线与眼球方向夹角越大，折射越强。

    //根据WorldTangent求出与EyeDirection垂直的向量，也就是虹膜平面的Tangent和BiTangent方向,也就是UV的偏移方向
    float3 TangentDerive = normalize(WorldTangent.xyz - dot(WorldTangent.xyz, EyeDirection) * EyeDirection);
    float3 BiTangentDerive = -WorldTangent.w * normalize(cross(EyeDirection, TangentDerive));
    float RefractUVOffsetX = dot(RefractedViewDir, TangentDerive);
    float RefractUVOffsetY = dot(RefractedViewDir, BiTangentDerive);
    float2 RefractUVOffset = float2(-RefractUVOffsetX, RefractUVOffsetY);
    float2 UVRefract = UV + RefractUVOffset;

    return UVRefract;
}

/////
