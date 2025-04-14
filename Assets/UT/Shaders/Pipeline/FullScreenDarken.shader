// 现仅用于摄像机黑屏（BlackCamera）渲染，需要TintColor属性，由RenderFeature控制（详见FullScreenDarkenPass.cs）
Shader "Hidden/UT/Pipeline/FullScreenDarken"
{
    Properties
    {
        [MainColor][HDR]_TintColor("Tint Color", Color) = (1,1,1,1)
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull (Default: Back)", Float) = 0
        [Enum(MoleGame.Editor.TATools.ZTest)]_ZTest("ZTest (Default: LessEqual)", Float) = 8
        [Enum(UnityEngine.Rendering.CompareFunction)]_Comp("Comp",Float) = 8
        [Enum(UnityEngine.Rendering.StencilOp)]_Pass("Pass",Float) = 0
        _StencilRef("Stenil Ref", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalRenderPipeline"
        }

        Pass
        {
            Name "StandardLit"
            Tags
            {
                "LightMode" = "Darken"
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZTest [_ZTest]
            Cull [_Cull]
            ZWrite Off

            Stencil
            {
                //notequal
                Ref [_StencilRef]
                Comp [_Comp]
                Pass [_Pass]
            }

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START (UnityPerMaterial)
            half4 _TintColor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return _TintColor;
            }
            ENDHLSL
        }
    }
}