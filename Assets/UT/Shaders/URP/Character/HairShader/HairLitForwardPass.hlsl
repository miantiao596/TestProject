#ifndef UNIVERSAL_FORWARD_LIT_PASS_INCLUDED
#define UNIVERSAL_FORWARD_LIT_PASS_INCLUDED

#include "Assets/UT/Shaders/URP/Character/HairShader/HairLighting.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

#if UT_RENDERING
	#include "Assets/UT/Shaders/URP/FALib/FaHeightFogDebug.hlsl"
	#include "Assets/UT/Shaders/URP/FALib/FACustomFogLib.hlsl"
#endif


struct Attributes
{  
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 texcoord2    : TEXCOORD2;
    float2 staticLightmapUV   : TEXCOORD1;
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float2 uv2                      : TEXCOORD7;
    float3 positionWS               : TEXCOORD1;
    float3 normalWS                 : TEXCOORD2;
    half4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign
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

//half Dither4x4Bayer( int x, int y )
//{
//    const half dither[ 16 ] = {
//            1,  9,  3, 11,
//            13,  5, 15,  7,
//            4, 12,  2, 10,
//            16,  8, 14,  6 };
//        int r = y * 4 + x;
//    return dither[r] / 16; 
//}

//half Dither(half4 screenPos, half alpha)
//{
//    half4 screenPosNorm = screenPos / screenPos.w;
//    screenPosNorm.z = screenPosNorm.z ;
//    half2 clipScreen = screenPosNorm.xy * _ScreenParams.xy;
//    half dither = Dither4x4Bayer( fmod(clipScreen.x, 4), fmod(clipScreen.y, 4) );
//    return dither = step(dither, alpha );
//}

inline void InitializeStandardLitSurfaceData(Varyings input,out SurfaceData outSurfaceData)
{

    
    half4 BaseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    half alpha = min(BaseColor.a*_Cutoff,1);

    //渐变染色计算
    _HairGradualTranstion +=0.2;
    half Radius1 = saturate(smoothstep(-_HairGradualTranstion,_HairGradualTranstion,(input.uv2.y-_HairTipRadius*0.4-0.15)*10));

    half Radius2 = saturate(smoothstep(-_HairGradualTranstion,_HairGradualTranstion,(input.uv2.y-_HairMiddleRadius*0.4-0.55)*10));

    half4 Color = half4(lerp(_HairTipColor,_HairMiddleColor,Radius1),0);

    Color = lerp(Color,half4(_HairRootColor,0),Radius2);
    //染色切换
    half4 color = lerp(_MainColor,Color,_HairColorGradualChange) * BaseColor;

    half3 Normal = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv),_NormalScale);

    ////Final////
    outSurfaceData.alpha = alpha;

    outSurfaceData.albedo = color;
    outSurfaceData.albedo = AlphaModulate(outSurfaceData.albedo, outSurfaceData.alpha);

    outSurfaceData.metallic = _Metallic;
    outSurfaceData.specular = 1;

    outSurfaceData.smoothness = 1 - _Roughness;
    outSurfaceData.normalTS   = Normal;
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
    
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.uv2 = TRANSFORM_TEX(input.texcoord2, _BaseMap);

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

    //点阵半透顶点数据
    //float4 ase_clipPos = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0)));
    //float4 screenPos = ComputeScreenPos(ase_clipPos);
    //output.screenPos = screenPos;

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
    SetupDebugDataTexture(inputData, input.uv, _BaseMap_TexelSize, _BaseMap_MipInfo, GetMipCount(TEXTURE2D_ARGS(_BaseMap, smp)));
    #endif
    
    half hairnoise = SAMPLE_TEXTURE2D(_HairNosieMap, sampler_HairNosieMap, half2(input.uv.x*(1+_NoiseTiling),input.uv.y)).r;

    half3 BiTangent = half3(0, 1, 0) + lerp(half3(0, 0, -1), half3(0, 0, 1), hairnoise) * _Noise;

    
    float vertexTangentSign = input.tangentWS.w * unity_WorldTransformParams.w;
    float3 worldBitangent = cross( input.normalWS, input.tangentWS ) * vertexTangentSign;

    float3x3 tangentToWorldFast = float3x3(
                            input.tangentWS.x,worldBitangent.x,input.normalWS.x,
                            input.tangentWS.y,worldBitangent.y,input.normalWS.y,
                            input.tangentWS.z,worldBitangent.z,input.normalWS.z);

    half3 BiTangentWS = normalize(mul(tangentToWorldFast, BiTangent));
    half4 Scatter = half4(_ScatterIntensity,_ScatterResult, _Shadow, _SelfShadow);
    half3 SpecularAdjust = half3(_LightStrength1,_LightExponent1,_LightPosition1);
    half3 SpecularAdjust2 = half3(_LightStrength2,_LightExponent2,_LightPosition2);
    half4 color = HairUniversalFragmentPBR(inputData, surfaceData, Scatter, BiTangentWS, _LightColor1, SpecularAdjust,_LightColor2,SpecularAdjust2);

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