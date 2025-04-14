       // #define _EYE
#ifdef _EYE
void EyeMian(Varyings input,inout SurfaceData surfaceData,inout SurfaceData48 surfaceData48)
{
    #if defined( _DEBUG_PUPILRANGE)||defined( _DEBUG_IRISRANGE)
    _IrisScale=1;
    #endif
    
    _Refringence*=0.1;

    half2 eyeUV = (input.uv01.xy );
    
    //虹膜设定半径
    float irisRadius=_IrisRadius;
    
    float2 RefractedPositionOS;

   float3 viewDirectionWS= GetWorldSpaceNormalizeViewDir(input.positionWS);
    //方案一，依赖于模型的前向量
    // CorneaRefraction(eyeUV, TransformWorldToObjectDir(viewDirectionWS),
    //                  TransformWorldToObjectDir(input.normalWS),BUILTIN_CORNEA_IOR,BUILTIN_IRIS_PLANE_OFFSET,
    //                  _IrisRadius, RefractedPositionOS);

    //方案二，由于模型的局部坐标系是上下反向的，所有采用法线方向的方式绘制
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

    half3 Normal2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uv01.xy), _BumpScale);
    float3 EyeDirection =TransformTangentToWorldDir(Normal2,tangentToWorld,true);

    float2 IrisUV;    
    //虹膜半径缩放
    IrisUVLocation(eyeUV, _IrisScale, IrisUV);
    
    float IrisDepth=(saturate(distance(length(IrisUV-0.5),irisRadius) /irisRadius) )* _Refringence;
    //处理折射
    RefractedPositionOS = EyeRefraction_float(IrisUV, input.normalWS, viewDirectionWS, BUILTIN_CORNEA_IOR,
                                              IrisDepth, EyeDirection,
                                              input.tangentWS);
    
    float IrisLimbalRingFactor;
    IrisLimbalRing(IrisUV,irisRadius, _LimbalRingSizeIris,_LimbalRingFade, IrisLimbalRingFactor);

    
    float2 animatedIrisUV;
    CirclePupilAnimation(RefractedPositionOS,_PupilRadius, _PupilAperture, _PupilApertureMinimal*irisRadius, _PupilApertureMaximal*irisRadius,animatedIrisUV);
    half3 irisMap = SAMPLE_TEXTURE2D(_IrisMap, sampler_IrisMap, animatedIrisUV);
    irisMap*=_IrisColor;  
    half3 irisColor = lerp(irisMap,_LimbalColor,  IrisLimbalRingFactor);
    half3 irisNormal = UnpackNormalScale(SAMPLE_TEXTURE2D(_IrisNormalMap, sampler_IrisNormalMap, animatedIrisUV),_IrisNormalScale);
    
    float ScleraLimbalRingFactor;
    ScleraLimbalRing(IrisUV, irisRadius,_LimbalRingSizeSclera , _LimbalRingFade, ScleraLimbalRingFactor);
    half3 scleraMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, eyeUV);
    scleraMap*=_BaseColor;
    half3 scleraColor = lerp(scleraMap, _LimbalColor,ScleraLimbalRingFactor);
    half3 scleraNormal = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, eyeUV), _BumpScale);

    float3 eyeColor;
    float surfaceMask;
    float3 diffuseNormal;
    float3 specularNormal;
    float eyeSmoothness;

    ScleraIrisBlend(scleraColor, scleraNormal, 0,
                    irisColor, irisNormal, _Smoothness,
                    irisRadius,
                    IrisUV,
                    eyeColor, surfaceMask,
                    diffuseNormal, specularNormal, eyeSmoothness);

    #if defined( _DEBUG_PUPILRANGE)
    eyeColor= SAMPLE_TEXTURE2D(_IrisMap, sampler_IrisMap, eyeUV);
    eyeColor= length(eyeUV-0.5f)<_PupilRadius?half3(1,0,0):eyeColor;//输出设定瞳孔范围
    surfaceData.albedo = eyeColor;
    #elif defined( _DEBUG_IRISRANGE)
    eyeColor= SAMPLE_TEXTURE2D(_IrisMap, sampler_IrisMap, eyeUV);
    eyeColor= length(eyeUV-0.5f)<_IrisRadius?half3(1,0,0):eyeColor;//输出设定虹膜范围
    surfaceData.albedo = eyeColor;
    #else
    surfaceData.albedo = eyeColor;
    surfaceData.normalTS =diffuseNormal;
    surfaceData48.clearCoatNormalTS=specularNormal;
    surfaceData.smoothness=eyeSmoothness;
    surfaceData.metallic=lerp(0,surfaceData.metallic,surfaceMask);
    #endif
    

    // surfaceData.albedo =half3(frac(a),0);
}
#endif