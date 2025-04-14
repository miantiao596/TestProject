#ifndef UNIVERSAL_FORWARD_LIT_PASS_INCLUDED
#define UNIVERSAL_FORWARD_LIT_PASS_INCLUDED

#include "Assets/UT/Shaders/URP/Character/SkinShader/SkinLighting.hlsl"
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
    float2 staticLightmapUV   : TEXCOORD1;
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float3 positionWS               : TEXCOORD1;
    float3 normalWS                 : TEXCOORD2;
    half4 tangentWS                 : TEXCOORD3;    // xyz: tangent, w: sign
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


inline void InitializeStandardLitSurfaceData(Varyings input, out SurfaceData outSurfaceData, out half SSS)
{
    half4 skinAlbedo      = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    
    outSurfaceData.alpha = 1;

    half4 OCRMask = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, input.uv);

    half thickness = skinAlbedo.a;
    thickness = thickness*0.5;
    //将颜色转换为灰度图
    half grayscale = saturate(smoothstep(0.0, _Spot * 0.4 + 0.6,dot(skinAlbedo.rgb, float3(0.299, 0.587, 0.114))));
    //将 原图 和 灰度图+原图(使得暗处区域不至于因为灰度不足导致偏色) 进行lerp(灰度与厚度)，颜色越暗沉就越保留,最后将得到带有原图信息的白图进行染色
    half3 faceAlbedo  = lerp(skinAlbedo.rgb, saturate(grayscale.rrr+skinAlbedo.rgb*_SpotSaturation), saturate(grayscale-thickness))*_BaseColor;

    outSurfaceData.albedo = lerp(faceAlbedo.rgb, skinAlbedo.rgb,_isFace);
    outSurfaceData.albedo = AlphaModulate(outSurfaceData.albedo, outSurfaceData.alpha);

    outSurfaceData.metallic =  _Metallic;
    outSurfaceData.specular =  0.5;

    // outSurfaceData.smoothness = specGloss.a;
    outSurfaceData.smoothness = lerp((1-OCRMask.b) * _Smoothness*2,OCRMask.b,_MaskBlend);
    half4 normalTS  = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uv);
    outSurfaceData.normalTS   = lerp(UnpackNormalScale(normalTS, _BumpScale),normalTS,_NormalBlend);

    outSurfaceData.occlusion = LerpWhiteTo(OCRMask.r, _OcclusionStrength);
    outSurfaceData.emission  = 0;

    outSurfaceData.clearCoatMask       = half(0.0);
    outSurfaceData.clearCoatSmoothness = half(0.0);

    SSS = clamp(saturate(saturate((abs(OCRMask.g - 0.5)+0.1) * 2 * _SkinCurvature)
                  + (1-skinAlbedo.a) * _SkinThickness),0.01,0.99);

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

    half SSS;

    InitializeStandardLitSurfaceData(input, surfaceData, SSS);

    InputData inputData;
    
    InitializeInputData(input, surfaceData.normalTS, inputData);

    #if defined(DEBUG_DISPLAY)
    SetupDebugDataTexture(inputData, input.uv, _BaseMap_TexelSize, _BaseMap_MipInfo, GetMipCount(TEXTURE2D_ARGS(_BaseMap, smp)));
    #endif

    half4 color = UniversalFragmentPBR(inputData, surfaceData, SSS);

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
