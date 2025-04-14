#ifndef FA_SHADOW_CASTER_PASS_INCLUDED
    #define FA_SHADOW_CASTER_PASS_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "../Lib/Ut-SpaceTransforms.hlsl"

    float3 _LightDirection;
    float _GlobalShaderNormalBiasMultiplier;
    
    struct Attributes
    {
        float4 positionOS   : POSITION;
        half3 normalOS     : NORMAL;
        float2 texcoord     : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float2 uv           : TEXCOORD0;
        float4 positionCS   : SV_POSITION;
    };

    half4 GetShadowPositionHClip(Attributes input)
    {
        float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
        half3 normalWS = TransformObjectToWorldNormal(input.normalOS);

        float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

        #if UNITY_REVERSED_Z
            positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
        #else
            positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
        #endif

        return positionCS;
    }

    half4 GetShadowPositionHClip(Attributes input, uint instanceID)
    {
        float3 positionWS = TransformObjectToWorld(input.positionOS.xyz, instanceID);
        half3 normalWS = TransformObjectToWorldNormal(input.normalOS, instanceID);

        float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

        #if UNITY_REVERSED_Z
        positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
        #else
        positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
        #endif

        return positionCS;
    }

    Varyings ShadowPassVertex(Attributes input, uint instanceID : SV_InstanceID)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);

        output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.positionCS = GetShadowPositionHClip(input, instanceID);
        
        //#if _RECEIVE_SELF_SHADOW
            // normalBias will produce "holes" in shadowmap, so we add a slider to control it globally
            //float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, vertexNormalInput.normalWS * _GlobalShaderNormalBiasMultiplier, _LightDirection));
        
            //#if UNITY_REVERSED_Z
            //    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
            //#else
            //    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
            //#endif
            //output.positionCS = positionCS;
        //#endif
        return output;
    }

    half4 ShadowPassFragment(Varyings input) : SV_TARGET
    {
        #if defined(_ALPHATEST_ON)
            Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, sampler_MainTex)).a, _Color, _Cutoff);
        #else
            Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, sampler_MainTex)).a, _Color, 0);
        #endif
        return 0;
    }
#endif
