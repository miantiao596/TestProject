#ifndef FA_DEPTH_ONLY_PASS_INCLUDED
    #define FA_DEPTH_ONLY_PASS_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "../Lib/Ut-SpaceTransforms.hlsl"

    struct Attributes
    {
        float4 position     : POSITION;
        float2 texcoord     : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float2 uv           : TEXCOORD0;
        float4 positionCS   : SV_POSITION;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings DepthOnlyVertex(Attributes input, uint instanceID : SV_InstanceID)
    {
        Varyings output = (Varyings)0;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

        output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.positionCS = TransformObjectToHClip(input.position.xyz, instanceID);
        return output;
    }

    half4 DepthOnlyFragment(Varyings input) : SV_TARGET
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        #if defined(_ALPHATEST_ON)
            Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, sampler_MainTex)).a, _Color, _Cutoff);
        #else
            Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, sampler_MainTex)).a, _Color, 0);
        #endif
        return 0;
    }
#endif
