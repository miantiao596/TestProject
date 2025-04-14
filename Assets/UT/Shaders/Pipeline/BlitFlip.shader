Shader "Hidden/MoleGame/Pipeline/BlitFlip"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            ZWrite off
            ZTest Always
            Blend One Zero
            Cull off

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #pragma vertex Vert
            #pragma fragment frag

            TEXTURE2D(_LastCameraColorTexture);		SAMPLER(sampler_LastCameraColorTexture);

            half4 frag(Varyings input) : SV_Target
            {
                float2 flipUV = float2(1 - input.texcoord.x,input.texcoord.y);
                half4 color = SAMPLE_TEXTURE2D(_LastCameraColorTexture, sampler_LastCameraColorTexture, flipUV);
                return color;
            }
            ENDHLSL
        }
    }
}
