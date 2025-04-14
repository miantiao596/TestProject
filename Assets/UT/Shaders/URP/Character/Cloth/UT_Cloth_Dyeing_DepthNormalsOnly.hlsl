#ifndef UT_CLOTH_DYEING_DEPTH_NORMALS_PASS_INCLUDED
#define UT_CLOTH_DYEING_DEPTH_NORMALS_PASS_INCLUDED

struct Attributes
{
    float4 positionOS   : POSITION;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float3 normal       : NORMAL;
    float4 uv           : TEXCOORD1;
};

struct Varyings
{
    float4 positionCS  : SV_POSITION;
    float2 uv          : TEXCOORD1;
    half3 normalWS     : TEXCOORD2;
    half4 tangentWS    : TEXCOORD3;    // xyz: tangent, w: sign
    float4 uvBump      : TEXCORRD4;
};

Varyings DepthNormalsVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS);
    output.normalWS = half3(normalInput.normalWS);
    float sign = input.tangentOS.w * float(GetOddNegativeScale());
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    output.tangentWS = tangentWS;
    
    output.uvBump.xy = TRANSFORM_TEX(input.uv, _MainTex);
    
    return output;
}

void DepthNormalsFragment(Varyings input, out half4 outNormalWS : SV_Target0)
{
    #if defined(_ALPHATEST_ON)
        Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, smp)).a, _Color, _Cutoff);
    #endif

    float sgn = input.tangentWS.w; // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    float4 n = SAMPLE_TEXTURE2D(_BumpMap, smp, input.uvBump.xy);
    float3 normalTS= UnpackNormal(n) ;
    float3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));

    outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
}

#endif //UT_CLOTH_DYEING_DEPTH_NORMALS_PASS_INCLUDED
