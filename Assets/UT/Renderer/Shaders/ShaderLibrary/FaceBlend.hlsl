#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/CustomRenderTexture/CustomTexture.hlsl"
// #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/CustomRenderTexture/CustomTextureGraph.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
CBUFFER_START(UnityPerMaterial)
    float4 _FaceMap_ST;
    half4 _FaceColor;

    half _BlushUVMirror;
    half _BlushUVRotate;
    half4 _BlushMap_ST;
    half4 _BlushTintColor1;
    half4 _BlushTintColor2;
    half4 _BlushTintColor3;

    half _EyeShadowUVMirror;
    half _EyeShadowUVRotate;
    half4 _EyeShadowMap_ST;
    half4 _EyeShadowTintColor1;
    half4 _EyeShadowTintColor2;
    half4 _EyeShadowTintColor3;

    half _EyeLinerUVMirror;
    half _EyeLinerUVRotate;
    half4 _EyeLinerMap_ST;
    half4 _EyeLinerTintColor1;
    half4 _EyeLinerTintColor2;
    half4 _EyeLinerTintColor3;

    half _EyeBrowUVMirror;
    half _EyeBrowUVRotate;
    half4 _EyeBrowMap_ST;
    half4 _EyeBrowTintColor1;
    half4 _EyeBrowTintColor2;
    half4 _EyeBrowTintColor3;

    half _LipUVMirror;
    half _LipUVRotate;
    half4 _LipMap_ST;
    half4 _LipTintColor1;
    half4 _LipTintColor2;
    half4 _LipTintColor3;
    half _LipNormalScale;
    half _LipSmoothness;

    half _TattooUVMirror;
    half _TattooUVRotate;
    half4 _TattooMap_ST;
    half4 _TattooTintColor1;
    half4 _TattooTintColor2;
    half4 _TattooTintColor3;
CBUFFER_END

TEXTURE2D(_FaceMap);
SAMPLER(sampler_FaceMap);
float4 _FaceMap_TexelSize;
TEXTURE2D(_FaceNormalMap);
TEXTURE2D(_FaceRMASMap);
TEXTURE2D(_BlushMap);
SAMPLER(sampler_BlushMap);
float4 _BlushMap_TexelSize;
TEXTURE2D(_BlushNormalMap);
TEXTURE2D(_BlushRMASMap);
TEXTURE2D(_BlushTintMap);
TEXTURE2D(_EyeLinerMap);
SAMPLER(sampler_EyeLinerMap);
float4 _EyeLinerMap_TexelSize;
TEXTURE2D(_EyeLinerNormalMap);
TEXTURE2D(_EyeLinerRMASMap);
TEXTURE2D(_EyeLinerTintMap);
TEXTURE2D(_EyeShadowMap);
SAMPLER(sampler_EyeShadowMap);
float4 _EyeShadowMap_TexelSize;
TEXTURE2D(_EyeShadowNormalMap);
TEXTURE2D(_EyeShadowRMASMap);
TEXTURE2D(_EyeShadowTintMap);
TEXTURE2D(_EyeBrowMap);
SAMPLER(sampler_EyeBrowMap);
float4 _EyeBrowMap_TexelSize;
TEXTURE2D(_EyeBrowNormalMap);
TEXTURE2D(_EyeBrowRMASMap);
TEXTURE2D(_EyeBrowTintMap);
TEXTURE2D(_LipMap);
SAMPLER(sampler_LipMap);
float4 _LipMap_TexelSize;
TEXTURE2D(_LipNormalMap);
TEXTURE2D(_LipRMASMap);
TEXTURE2D(_LipTintMap);
TEXTURE2D(_TattooMap);
SAMPLER(sampler_TattooMap);
float4 _TattooMap_TexelSize;
TEXTURE2D(_TattooNormalMap);
TEXTURE2D(_TattooRMASMap);
TEXTURE2D(_TattooTintMap);

half2 SampleUV(half2 uv, half4 tilingOffset, half ratio, half rotate)
{
    half angle = rotate * 180;
    uv = uv - float2(0.5, 0.5);
    uv.y = uv.y * ratio;
    uv = (uv + tilingOffset.zw) / tilingOffset.xy;
    uv = float2(uv.x * cos(radians(angle)) - uv.y * sin(radians(angle)),
                uv.y * cos(radians(angle)) + uv.x * sin(radians(angle)));
    uv += float2(0.5, 0.5);
    return uv;
}

half2 MirrorUV(half2 uv, half4 tilingOffset, half ratio, half mirror, half rotate)
{
    tilingOffset.zw*=0.5;
    half2 uv1 = SampleUV(uv, tilingOffset, ratio, rotate);
    half2 uv2 = SampleUV(half2(1 - uv.x, uv.y), tilingOffset, ratio, rotate);
    uv = lerp(uv2, uv1, step(uv.x, 0.5));
    return mirror == 1 ? uv : uv1;
}

half3 ColorBlend(half3 SrcColor, half SrcAlpha, half3 DstColor)
{
    return SrcAlpha * SrcColor + (1 - SrcAlpha) * DstColor;
}

void BlendTexture(
    half2 uv, half mirror, half rotate, half4 texelSize, half4 scaleOffset,
    TEXTURE2D (BaseColorMap), TEXTURE2D (NormalMap), TEXTURE2D (RMASMap), TEXTURE2D (TintMap),
    half4 color1, half4 color2, half4 color3,half normalScale,half smoothness,
    inout half4 baseColor, inout half4 smoMap, inout half3 nromalMap)
{
    half ratio = texelSize.z / texelSize.w;
    half2 samplerUV = MirrorUV(uv, scaleOffset, ratio, mirror, rotate);
    half4 baseColorMap = SAMPLE_TEXTURE2D(BaseColorMap, sampler_LinearClamp, samplerUV);
    half4 tintMap = SAMPLE_TEXTURE2D(TintMap, sampler_LinearClamp, samplerUV);
    half3 newNormalMap = UnpackNormalScale(SAMPLE_TEXTURE2D(NormalMap, sampler_LinearClamp, samplerUV),normalScale);
    half4 rmasMap = SAMPLE_TEXTURE2D(RMASMap, sampler_LinearClamp, samplerUV);
    rmasMap.r*=saturate(rmasMap.r + (smoothness * 2 - 1));
    rmasMap.b*=smoMap.b;
    
    // half3 color=0;
    // float3 Ac=color1.rgb*baseColorMap.rgb;
    // half Aa=saturate((color1.a*2-1)+tintMap.r);
    // float3 Bc=color2.rgb*baseColorMap.rgb;
    // half Ba=saturate((color2.a*2-1)+tintMap.r);
    // color =lerp(Bc,Ac,saturate(Aa/(Aa+Ba)));//色号插值，saturate是必要的
    // color=color*saturate(Aa+Ba);//Alpha溢出处理
    // color=lerp(color ,baseColorMap,tintMap.a);//贴图颜色
    // baseColor=lerp(baseColor,baseColor+color,baseColorMap.a);

    half3 color = baseColor.rgb;
    color = ColorBlend(color1.rgb, saturate(tintMap.r + (color1.a * 2 - 1)), color);
    color = ColorBlend(color2.rgb, saturate(tintMap.g + (color2.a * 2 - 1)), color);
    color = ColorBlend(color3.rgb, saturate(tintMap.b + (color3.a * 2 - 1)), color);
     // color=lerp(color,color1,saturate(tintMap.r*(color1.a*2-1)));
     // color=lerp(color,color2,saturate(tintMap.g*(color2.a*2-1)));
     // color=lerp(color,color3,saturate(tintMap.b*(color3.a*2-1)));

    color = lerp(baseColorMap, color, tintMap.a);
    
    half alpha=Max3(color1.a,color2.a,color3.a)*baseColorMap.a;
    baseColor.rgb = lerp(baseColor, color, alpha);
    baseColor.a = lerp(baseColor.a, 1, alpha);
    smoMap = lerp(smoMap, rmasMap, alpha);
    nromalMap = lerp(nromalMap, newNormalMap, alpha);
}

void OutColor(half2 uv,out half4 BaseColor,out half4 Normal,out half4 SMO)
{    
    half4 texColor = SAMPLE_TEXTURE2D(_FaceMap, sampler_PointClamp, uv);
    half4 color =half4( texColor.rgb * _FaceColor.rgb,0);

    half3 nromalMap = UnpackNormal(SAMPLE_TEXTURE2D(_FaceNormalMap, sampler_PointClamp, uv));
    half4 smoMap = SAMPLE_TEXTURE2D(_FaceRMASMap, sampler_PointClamp, uv);

    #ifdef _BLUSH
    BlendTexture(
        uv, _BlushUVMirror, _BlushUVRotate, _BlushMap_TexelSize, _BlushMap_ST,
        _BlushMap, _BlushNormalMap, _BlushRMASMap, _BlushTintMap,
        _BlushTintColor1, _BlushTintColor2, _BlushTintColor3,1,0.5,
        color, smoMap, nromalMap
    );
    #endif

    #ifdef _EYESHADOW
    BlendTexture(
        uv, _EyeShadowUVMirror, _EyeShadowUVRotate, _EyeShadowMap_TexelSize, _EyeShadowMap_ST,
        _EyeShadowMap, _EyeShadowNormalMap, _EyeShadowRMASMap, _EyeShadowTintMap,
        _EyeShadowTintColor1, _EyeShadowTintColor2, _EyeShadowTintColor3,1,0.5,
        color, smoMap, nromalMap
    );
    #endif

    #ifdef _EYELINER
    BlendTexture(
        uv, _EyeLinerUVMirror, _EyeLinerUVRotate, _EyeLinerMap_TexelSize, _EyeLinerMap_ST,
        _EyeLinerMap, _EyeLinerNormalMap, _EyeLinerRMASMap, _EyeLinerTintMap,
        _EyeLinerTintColor1, _EyeLinerTintColor2, _EyeLinerTintColor3,1,0.5,
        color, smoMap, nromalMap
    );
    #endif

    #ifdef _EYEBROW
    BlendTexture(
        uv, _EyeBrowUVMirror, _EyeBrowUVRotate, _EyeBrowMap_TexelSize, _EyeBrowMap_ST,
        _EyeBrowMap, _EyeBrowNormalMap, _EyeBrowRMASMap, _EyeBrowTintMap,
        _EyeBrowTintColor1, _EyeBrowTintColor2, _EyeBrowTintColor3,1,0.5,
        color, smoMap, nromalMap
    );
    #endif

    #ifdef _LIP
    BlendTexture(
        uv, _LipUVMirror, _LipUVRotate, _LipMap_TexelSize, _LipMap_ST,
        _LipMap, _LipNormalMap, _LipRMASMap, _LipTintMap,
        _LipTintColor1, _LipTintColor2, _LipTintColor3,_LipNormalScale,_LipSmoothness,
        color, smoMap, nromalMap
    );
    #endif

    #ifdef _TATTOO
    BlendTexture(
        uv, _TattooUVMirror, _TattooUVRotate, _TattooMap_TexelSize, _TattooMap_ST,
        _TattooMap, _TattooNormalMap, _TattooRMASMap, _TattooTintMap,
        _TattooTintColor1, _TattooTintColor2, _TattooTintColor3,1,0.5,
        color, smoMap, nromalMap
    );
    #endif

    BaseColor = color;
    BaseColor.a =1-BaseColor.a;
    Normal=half4(nromalMap*0.5+0.5,1);
    SMO=smoMap;
}

half4 Frag_BaseColor(v2f_customrendertexture i) : SV_Target
{
    half4 BaseColor;
    half4 Normal;
    half4 SMO;
    OutColor(i.localTexcoord,  BaseColor, Normal,SMO);
    return BaseColor;    
}
half4 Frag_Normal(v2f_customrendertexture i) : SV_Target
{
    half4 BaseColor;
    half4 Normal;
    half4 SMO;
    OutColor(i.localTexcoord,  BaseColor, Normal,SMO);
    return Normal;    
}
half4 Frag_SMO(v2f_customrendertexture i) : SV_Target
{
    half4 BaseColor;
    half4 Normal;
    half4 SMO;
    OutColor(i.localTexcoord,  BaseColor, Normal,SMO);
    return SMO;    
}

struct Attributes
{
    uint vertexID : SV_VertexID;
};
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 texcoord   : TEXCOORD0;
};
struct PrefilterOutput
{
    half4 BaseColor : SV_Target0;
    half4 Normal : SV_Target1;
    half4 SMO : SV_Target2;
};
Varyings VertQuad(Attributes input)
{
    Varyings output;

    #if SHADER_API_GLES
    float4 pos = input.positionOS;
    float2 uv  = input.uv;
    #else
    float4 pos = GetFullScreenTriangleVertexPosition(input.vertexID);
    float2 uv  = GetFullScreenTriangleTexCoord(input.vertexID);
    #endif

    output.positionCS = pos;
    output.texcoord   = uv ;
    return output;
}
PrefilterOutput Frag_All(Varyings i)
{
    PrefilterOutput output;
    OutColor(i.texcoord,  output.BaseColor, output.Normal,output.SMO);
    return output;    
}