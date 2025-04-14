#ifndef UNIVERSAL_FORWARD_LIT_PASS_INCLUDED
#define UNIVERSAL_FORWARD_LIT_PASS_INCLUDED

#include "Assets/UT/Shaders/URP/Character/EyeShader/EyeLighting.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

#if UT_RENDERING
    #include "../../FALib/FAHeightFogDebug.hlsl"
    #include "../../FALib/FACustomFogLib.hlsl"
#endif


struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float3 positionWS               : TEXCOORD1;
    float3 normalWS                 : TEXCOORD2;
    half4 tangentWS                 : TEXCOORD3; 
#if UT_RENDERING
	half4 fogColor                  : TEXCOORD4;
#endif
    half  fogFactor                 : TEXCOORD5;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD6;
#endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);

    float4 positionCS               : SV_POSITION;
};

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;

    inputData.positionWS = input.positionWS;
    inputData.positionCS = input.positionCS;

    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
    
    inputData.tangentToWorld = tangentToWorld;
    inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = viewDirWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif

#if UT_RENDERING
    #if defined(_CHARACTER_AMBIENT_COLOR)
		inputData.bakedGI = max(0, _CharacterAmbientColor.rgb);
	#else
        inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
	#endif
#else
        inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
        inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
#endif

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

    #if defined(DEBUG_DISPLAY)
    #if defined(LIGHTMAP_ON)
    inputData.staticLightmapUV = input.staticLightmapUV;
    #else
    inputData.vertexSH = input.vertexSH;
    #endif
    #endif
}

half2 ScaleUVFromCircle(half2 UV,half Scale)
{
    half2 UVcentered = UV - half2(0.5f, 0.5f);
    half UVlength = length(UVcentered);
    // UV on circle at distance 0.5 from the center, in direction of original UV
    half2 UVmax = normalize(UVcentered)*0.5f;

    half2 UVscaled = lerp(UVmax, half2(0.f, 0.f), saturate((1.f - UVlength*2.f)*Scale));
    return UVscaled + half2(0.5f, 0.5f);
}

half2 ScaleUVsByCenter(half2 UVs,half Scale)
{
    return (UVs / Scale + (0.5).xx) - (0.5 / Scale).xx;
}

half3 RefractDirection(half internalIoR,half3 WorldNormal,half3 incidentVector)
{
    half airIoR = 1.00029;

    half n = airIoR / internalIoR;

    half facing = dot(WorldNormal, incidentVector);

    half w = n * facing;

    half k = sqrt(1+(w-n)*(w+n));

    half3 t = -normalize((w - k) * WorldNormal - n * incidentVector);
    return t;
}

half2 EyeRefraction_float(half2 UV,half3 NormalDir,half3 ViewDir,half IOR,
                        half IrisDepth,half3 EyeDirection,half4 WorldTangent)
{

    // 模拟视线通过角膜后被折射
    float3 RefractedViewDir = RefractDirection(IOR,NormalDir,ViewDir);
    float cosAlpha = dot(ViewDir,EyeDirection);    // EyeDirection是眼睛正前方方向
    cosAlpha = lerp(0.325,1,cosAlpha * cosAlpha);//视线与眼球方向的夹角
    RefractedViewDir = RefractedViewDir * (IrisDepth / cosAlpha);//虹膜深度越大，折射越强；视线与眼球方向夹角越大，折射越强。

    //根据WorldTangent求出与EyeDirection垂直的向量，也就是虹膜平面的Tangent和BiTangent方向,也就是UV的偏移方向
    float3 TangentDerive = normalize(WorldTangent.xyz - dot(WorldTangent.xyz,EyeDirection) * EyeDirection);
    float3 BiTangentDerive = -WorldTangent.w * normalize(cross(EyeDirection,TangentDerive));
    float RefractUVOffsetX = dot(RefractedViewDir,TangentDerive);
    float RefractUVOffsetY = dot(RefractedViewDir,BiTangentDerive);
    float2 RefractUVOffset = float2(-RefractUVOffsetX,RefractUVOffsetY);
    float2 UVRefract = UV +  RefractUVOffset;

    return UVRefract;
}

inline void InitializeStandardLitSurfaceData(Varyings input,out SurfaceData outSurfaceData)
{
    _EyeSize = max(0.0001,_EyeSize);

    half2 eyesizeUVs = ScaleUVsByCenter(ScaleUVsByCenter(input.uv,_EyeSize),_IrisBasePosition.x*0.1+1.84);

    half4 EyeMask = SAMPLE_TEXTURE2D(_EyeMask, sampler_EyeMask, eyesizeUVs);
    half4 Sclera = SAMPLE_TEXTURE2D(_ScleraTex, sampler_ScleraTex, input.uv);


    half3 Normal2 = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal2, sampler_Normal2, input.uv ), 1.0f );
    float3 bitangent = input.tangentWS.w * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
    //float3 EyeDirection = TransformTangentToWorld(half3(EyeMask.rg,sqrt(1-EyeMask.r*EyeMask.r-EyeMask.g*EyeMask.g)), tangentToWorld);
    float3 EyeDirection = normalize(mul(half3(Normal2.rg,1-Normal2.r*Normal2.r-Normal2.g*Normal2.g), tangentToWorld));

    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    
    half IrisDepth = EyeMask.g * _IrisParallaxPower*(_EyeSize);

    //////虹膜折射采样//////
    //折射
    float2 ParallaxUV = EyeRefraction_float(input.uv, input.normalWS, viewDirWS, 1, IrisDepth, EyeDirection,input.tangentWS);

    ParallaxUV = ScaleUVFromCircle(ScaleUVsByCenter(ParallaxUV,_EyeSize),_IrisSize);

    half4 IrisExtraDetail = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, ParallaxUV);

    //虹膜瞳孔遮罩
    half IrisOverlay= saturate(smoothstep(0.485-_IrisBasePosition.y*0.1,0.5,length(ParallaxUV - 0.5)));

    //虹膜边缘虚实遮罩
    half IrisMargin = saturate(smoothstep(_IrisMargin,1,EyeMask.r));

    //////颜色//////
    //眼球颜色
    //将颜色转换为灰度图
    half grayscale = smoothstep(0.05,0.4,dot(Sclera.rgb, float3(0.299, 0.587, 0.114)));

    half4 SubSurfaceArea = lerp(Sclera*2,_EyeBallColor,grayscale) * IrisOverlay;

    //虹膜白色区域
    half Irismask = lerp(0,_IrisContrast*4.5+0.5,IrisExtraDetail);

    half4 BaseirisColors = Irismask * _IrisBaseColor* (1-IrisOverlay);

    
    ////Final////
    half4 albedo = SubSurfaceArea * _Final_illumination;

    half3 normal = UnpackNormalScale(SAMPLE_TEXTURE2D(_Normal, sampler_Normal, input.uv),_NormalScale);

    half4 emission = BaseirisColors * _Final_illumination;

    half metallic = saturate( _EyeBallMetalness * IrisOverlay + (1-IrisOverlay) * _IrisPupilMetalness);
                    
    half smoothness = lerp(_EyeBallGloss,_LensGloss, (1-IrisOverlay));

    albedo = (albedo+emission)*(1-IrisMargin*_IrisMarginColor.a)+IrisMargin*_IrisMarginColor.rgba;

    outSurfaceData.alpha =  1;

    outSurfaceData.albedo =  albedo;
    outSurfaceData.albedo = AlphaModulate(outSurfaceData.albedo, outSurfaceData.alpha);

    outSurfaceData.metallic = metallic;
    outSurfaceData.specular = 0;

    outSurfaceData.smoothness = smoothness;
    outSurfaceData.normalTS   = normal;
    outSurfaceData.occlusion  = 1;
    outSurfaceData.emission   = 0;

    outSurfaceData.clearCoatMask       = half(0.0);
    outSurfaceData.clearCoatSmoothness = half(0.0);

}
///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half fogFactor = 0;
    #if !defined(_FOG_FRAGMENT)
        fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    #endif
    
    output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);

    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    output.tangentWS = tangentWS;

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    output.fogFactor = fogFactor;
    output.positionWS = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
#endif

#if UT_RENDERING
    #ifndef _PIXELFOG_ON
    		CustomMixFogColor(vertexInput.positionWS, output.fogColor.xyz, output.fogColor.w);
    #endif
#endif

    return output;
}

// Used in Standard (Physically Based) shader
void LitPassFragment(Varyings input, out half4 outColor : SV_Target0)
{
    SurfaceData surfaceData;

    InitializeStandardLitSurfaceData(input,surfaceData);

    InputData inputData;

    InitializeInputData(input, surfaceData.normalTS, inputData);

    #if defined(DEBUG_DISPLAY)
    SetupDebugDataTexture(inputData, input.uv, _MainTex_TexelSize, _MainTex_MipInfo, GetMipCount(TEXTURE2D_ARGS(_MainTex, smp)));
    #endif

    half4 color = UniversalFragmentPBR(inputData, surfaceData);

#if UT_RENDERING
    #ifdef _PIXELFOG_ON
	CustomMixFogColor(input.positionWS.xyz, input.fogColor.xyz, input.fogColor.w);
	#endif
    color.rgb = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);
#else
    color.rgb = MixFog(color.rgb, inputData.fogCoord);
#endif
    color.a = OutputAlpha(color.a, IsSurfaceTypeTransparent(_Surface));

    outColor = color;
}

#endif
