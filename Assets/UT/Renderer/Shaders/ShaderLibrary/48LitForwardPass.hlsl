#ifndef UNIVERSAL_FORWARD_LIT_PASS_INCLUDED
#define UNIVERSAL_FORWARD_LIT_PASS_INCLUDED

#include "Extension/48InputeDataExtension.hlsl"
#include "48Lighting.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

// GLES2 has limited amount of interpolators
#if defined(_PARALLAXMAP) && !defined(SHADER_API_GLES)
#define REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR
#endif

#if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))) || defined(_DETAIL)
#define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

// keep this file in sync with LitGBufferPass.hlsl

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    //=============================================================================//
    //=================================48Change Start=================================//
    // float2 staticLightmapUV   : TEXCOORD1;
    // float2 dynamicLightmapUV  : TEXCOORD2;
    float2 uv1  : TEXCOORD1;
    float2 uv2  : TEXCOORD2;
    float2 uv3  : TEXCOORD3;
    float2 staticLightmapUV   : TEXCOORD4;
    float2 dynamicLightmapUV  : TEXCOORD5;
    float4 color : COLOR;
    //==================================48Change End==================================//
    //=============================================================================//
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 uv01                       : TEXCOORD0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    float3 positionWS               : TEXCOORD1;
#endif

    float3 normalWS                 : TEXCOORD2;
// #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign
// #endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    half4 fogFactorAndVertexLight   : TEXCOORD5; // x: fogFactor, yzw: vertex light
#else
    half  fogFactor                 : TEXCOORD5;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD6;
#endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS                : TEXCOORD7;
#endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
#ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV : TEXCOORD9; // Dynamic lightmap UVs
#endif

    float4 positionCS               : SV_POSITION;

//=============================================================================//
//=================================48Add Start=================================//
    float4 uv23                       : TEXCOORD9;
#ifdef  _FUR
    float FurLayer                        : TEXCOORD10;
#endif
    float4 vertexColor                    : TEXCOORD11;
//==================================48Add End==================================//
//=============================================================================//
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};
//=============================================================================//
//=================================48Add Start=================================//
#include "FeatureContext.hlsl"

void InitializeInputData48(Varyings input, InputData inputData,float3 clearCoatNormalTS, out InputData48 inputData48)
{
    inputData48 = (InputData48)0;
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    // inputData48.tangentWS = input.tangentWS.xyz;
    inputData48.tangentWS = TransformTangentToWorld(input.tangentWS.xyz,inputData.tangentToWorld);
    inputData48.tangentWS = Orthonormalize( inputData48.tangentWS, inputData.normalWS );
    inputData48.bitangentWS= cross(inputData.normalWS, inputData48.tangentWS);
    #endif
    inputData48.clearCoatNormalWS = TransformTangentToWorld(clearCoatNormalTS, inputData.tangentToWorld);
}
void SequinInputDataProcessing(inout SurfaceData surfaceData,inout SurfaceData48 surfaceData48,inout InputData inputData,inout InputData48 inputData48)
{
    float3 normalWS= TransformTangentToWorld(surfaceData48.sequinNormalTS,inputData.tangentToWorld,true);
    inputData48.sequinNormalWS=normalWS;
}

void CustomSH()
{
    unity_SHAr=_SHAr;
    unity_SHAb= _SHAb;
    unity_SHAg= _SHAg;
    unity_SHBr= _SHBr;
    unity_SHBg= _SHBg;
    unity_SHBb= _SHBb;
    unity_SHC= _SHC;
}

//广告牌顶点偏移，该方案需要模型UV打散平铺
void BillboardPositionOffset(half2 uv, inout float3 positionOS)
{
    half3 uvDir = half3(uv * 2 - 1, 0);
    uvDir = TransformViewToWorldNormal(uvDir, true);
    uvDir = TransformWorldToObjectNormal(uvDir, true);
    uvDir = lerp(0, uvDir, _BillBoardScale);
    positionOS += uvDir;
}

//用于广告牌模式下的球形法线、切线映射
void BillboardShphereNormal(inout float3 normalOS, inout float3 tangentOS)
{
    //1.构建视口空间下的旋转矩阵 2.模式切换
    //UNITY_MATRIX_V[1].xyz == world space camera Up unit vector
    float3 upCamVec = lerp(normalize(UNITY_MATRIX_V._m10_m11_m12), float3(0, 1, 0), 0);
    //UNITY_MATRIX_V[2].xyz == -1 * world space camera Forward unit vector
    float3 forwardCamVec = -normalize(UNITY_MATRIX_V._m20_m21_m22);
    //UNITY_MATRIX_V[0].xyz == world space camera Right unit vector
    float3 rightCamVec = normalize(UNITY_MATRIX_V._m00_m01_m02);
    float4x4 rotationCamMatrix = float4x4(rightCamVec, 0, upCamVec, 0, forwardCamVec, 0, 0, 0, 0, 1);
    //转换法线和切线
    // normalOS = normalize(mul(float4(normalOS, 0), rotationCamMatrix)).xyz;
    // tangentOS =normalize(mul(tangentOS, rotationCamMatrix)).xyz;
    //以闪模型法线不太正常，这里强制修改赋值
    normalOS = normalize(mul(float4(0, 0, 1, 0), rotationCamMatrix)).xyz;
    tangentOS = normalize(mul(float4(1, 0, 0, 0), rotationCamMatrix)).xyz;
}
//==================================48Add End==================================//
//=============================================================================//
void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    inputData.positionWS = input.positionWS;
#endif

    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
#if defined(_NORMALMAP) || defined(_DETAIL)
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

    #if defined(_NORMALMAP)
    inputData.tangentToWorld = tangentToWorld;
    #endif
    inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
#else
    inputData.normalWS = input.normalWS;
#endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = viewDirWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif
#ifdef _ADDITIONAL_LIGHTS_VERTEX
    inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
#else
    inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
#endif
//=============================================================================//
//=================================48Add Start=================================//
    #ifdef _CUSTOMSH
    CustomSH();
    #endif
//==================================48Add End==================================//
//=============================================================================//
#if defined(DYNAMICLIGHTMAP_ON)
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
#else
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
#endif

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

    #if defined(DEBUG_DISPLAY)
    #if defined(DYNAMICLIGHTMAP_ON)
    inputData.dynamicLightmapUV = input.dynamicLightmapUV;
    #endif
    #if defined(LIGHTMAP_ON)
    inputData.staticLightmapUV = input.staticLightmapUV;
    #else
    inputData.vertexSH = input.vertexSH;
    #endif
    #endif
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    //=============================================================================//
    //=================================48Add Start=================================//
    #ifdef _BILLBOARD
    BillboardShphereNormal(input.normalOS.xyz,input.tangentOS.xyz);
    BillboardPositionOffset(input.texcoord,input.positionOS.xyz);
    #endif
    //==================================48Add End==================================//
    //=============================================================================//
    
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

    half fogFactor = 0;
    #if !defined(_FOG_FRAGMENT)
        fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    #endif
    
    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
#endif
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    output.tangentWS = tangentWS;
#endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
    half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
    output.viewDirTS = viewDirTS;
#endif

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
#ifdef DYNAMICLIGHTMAP_ON
    output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
#ifdef _ADDITIONAL_LIGHTS_VERTEX
    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
#else
    output.fogFactor = fogFactor;
#endif

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    output.positionWS = vertexInput.positionWS;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
#endif

    output.positionCS = vertexInput.positionCS;

//=============================================================================//
//=================================48Add Start=================================//
    output.uv01.xy = input.texcoord;
    output.uv01.zw = input.uv1;
    output.uv23.xy = input.uv2;
    output.uv23.zw = input.uv3;
    output.vertexColor=input.color;
//==================================48Add End==================================//
//=============================================================================//
    
    return output;
}

// Used in Standard (Physically Based) shader
void LitPassFragment(
    Varyings input
    #ifdef _DOUBLESIDED
    , half Vface : VFACE
    #endif    
    , out half4 outColor : SV_Target0
#ifdef _WRITE_RENDERING_LAYERS
    , out float4 outRenderingLayers : SV_Target1
#endif
)
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

#if defined(_PARALLAXMAP)
#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS = input.viewDirTS;
#else
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, viewDirWS);
#endif
    ApplyPerPixelDisplacement(viewDirTS, input.uv01.xy);
#endif

    //=============================================================================//
    //=================================48Change Start=================================//
    half faceSign=0;
    #ifdef _DOUBLESIDED
    faceSign=Vface;
    #endif

    half furLayer=0;
    #ifdef _FUR
    furLayer=input.FurLayer;
    #endif
    
    SurfaceData surfaceData;
    SurfaceData48 surfaceData48;
    InitializeStandardLitSurfaceData(input.uv01,input.uv23,input.vertexColor,faceSign,furLayer,surfaceData,surfaceData48);


    #ifdef _EYE
    EyeMian(input,surfaceData,surfaceData48);
    #endif
    //==================================48Change End==================================//
    //=============================================================================//
#ifdef LOD_FADE_CROSSFADE
    LODFadeCrossFade(input.positionCS);
#endif
    
    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv01.xy, _BaseMap);

    //=============================================================================//
    //=================================48Add Start=================================//
    InputData48 inputData48;
    InitializeInputData48(input,inputData,surfaceData48.clearCoatNormalTS,inputData48);
    
    #ifdef _SEQUIN
    SequinInputDataProcessing(surfaceData,surfaceData48,inputData,inputData48);
    #endif
    //==================================48Add End==================================//
    //=============================================================================//
    
#ifdef _DBUFFER
    ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
#endif

    half4 color = UniversalFragmentPBR(inputData,inputData48, surfaceData,surfaceData48);
    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    color.a = OutputAlpha(color.a, IsSurfaceTypeTransparent(_Surface));

    //=============================================================================//
    //=================================48Add Start=================================//
    #ifdef _MATCAP
    half3 normalVS = TransformWorldToViewDir(inputData.normalWS, true);
    half2 matcapUV = (normalVS.xy + 1) * 0.5;
    half4 matCapMap_TX = SAMPLE_TEXTURE2D(_MatCapMap, sampler_MatCapMap, matcapUV);
    color.rgb+= matCapMap_TX.rgb;
    #endif

    #ifdef _HIGHLIGHT
    half ratio = _HighlightMap_TexelSize.z / _HighlightMap_TexelSize.w;
    half2 samplerUV = MirrorUV(input.uv01.xy, _HighlightMap_ST, ratio, _HighlightUVMirror, _HighlightUVRotate);
    half4 highlight = SAMPLE_TEXTURE2D(_HighlightMap, sampler_LinearClamp, samplerUV);
    half l=highlight.a*_HighlightIntensity;
    color.rgb=lerp(color.rgb,highlight.rgb,l);
    #endif

    #if defined(_DEBUG_VCOLOR_RGB)
    color=input.vertexColor;
    #elif defined(_DEBUG_VCOLOR_R)
    color.rgb=input.vertexColor.r.xxx;
    #elif defined(_DEBUG_VCOLOR_G)
    color.rgb=input.vertexColor.g.xxx;
    #elif defined(_DEBUG_VCOLOR_B)
    color.rgb=input.vertexColor.b.xxx;
    #endif
    //==================================48Add End==================================//
    //=============================================================================//
    // color.rgb=input.vertexColor.b.xxx;
    outColor = color;
    // outColor.rgb=surfaceData.alpha;
#ifdef _WRITE_RENDERING_LAYERS
    uint renderingLayers = GetMeshRenderingLayer();
    outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
#endif
}

#endif
