#ifndef UT_CLOTH_DYEING_DEPTH_ONLY_PASS_INCLUDED
#define UT_CLOTH_DYEING_DEPTH_ONLY_PASS_INCLUDED

struct Attributes
{
    float4 position     : POSITION;
    float2 texcoord     : TEXCOORD0;
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
    output.positionCS = TransformObjectToHClip(input.position.xyz);
    return output;
}

half DepthOnlyFragment(Varyings input) : SV_TARGET
{
    #if defined(_ALPHATEST_ON)
    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, smp)).a, _Color, _Cutoff);
    #else
    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, smp)).a, _Color, 0);
    #endif

    return 0;
}
#endif //UT_CLOTH_DYEING_DEPTH_ONLY_PASS_INCLUDED
