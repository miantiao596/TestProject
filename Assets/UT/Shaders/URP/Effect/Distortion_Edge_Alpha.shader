Shader "URP/MoleGame/Effects/Distortion_Edge_Alpha"
{
    Properties
    {
        [MainTexture]_MainTex ("Main Texture", 2D) = "white" {}
        _Ref ("Parameter", Float) = 0
        _Tex_U ("Main Texture Speed U", Float) = 0
        _Tex_V ("Main Texture Speed V", Float) = 0
        [MaskTexture]_MaskTex ("Mask Texture", 2D) = "white" {}
        _FrenelMul ("Frenel Mul Factor", Float) = 1
        _FrenelPow ("Frenel Pow Factor", Float) = 1

        [HideInInspector] _ZTest_State ("ZTest State", Float) = 0		// 控制ZTest是否关闭
        [HideInInspector] _ZTest("__zt", Float) = 4			// 4:LEqual
        [Header(Cull Mode)]
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull (Default: Back)", Float) = 2
        
        //TAA用的stencil
		[HideInInspector]_SkipTAA("Skip TAA", int) = 0
		//生效的时候这2个都是16
		[HideInInspector]_TAAStencil("TAA Stencil Ref (Default: 0)", Float) = 16
		[HideInInspector]_TAAStencilMask("TAA Stencil Write Mask (Default: 0)", Float) = 16
		//0是keep 2是Replace
		[HideInInspector]_TAAStencilPassOperate("Stencil Operate (Default: 0)", Float) = 2
    }

    SubShader
    {
        Tags {
            "IgnoreProjector" = "True"
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }
			

        HLSLINCLUDE

        #pragma prefer_hlslcc gles
        #pragma exclude_renderers d3d11_9x
        #pragma target 2.0

        #pragma vertex vert
        #pragma fragment frag

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        TEXTURE2D(_MainTex);        SAMPLER(sampler_MainTex);
        TEXTURE2D(_MaskTex);        SAMPLER(sampler_MaskTex);
        TEXTURE2D(_DistortionLastCameraColorTexture);		SAMPLER(sampler_DistortionLastCameraColorTexture);
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float4 _MaskTex_ST;
        half   _Tex_U;
        half   _Tex_V;
        half   _Ref;
        half   _FrenelMul;
        half   _FrenelPow;
        CBUFFER_END

        struct Attributes {
            float4 positionOS   : POSITION;
            half3 normalOS     : NORMAL;
            half4 tangentOS    : TANGENT;
            float2 uv           : TEXCOORD0;
            half4 vertexColor  : COLOR;
        };

        struct Varyings {
            float4 positionCS   : SV_POSITION;
            float2 uv           : TEXCOORD0;
            float3 positionWS   : TEXCOORD1;
            float3 normalWS      : TEXCOORD2;
            float4 positionSC  : TEXCOORD3;
            half4 vertexColor  : COLOR;
        };

        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "Distortion" }

            ZTest [_ZTest]
            ZWrite Off
            //ColorMask RG
            /*Stencil {
                Ref 40
                ReadMask 8
                WriteMask 247
                Comp NotEqual
                Pass Replace
            }*/
            
            //跳过TAA处理的Mask
            Stencil {
                Ref [_TAAStencil]
                WriteMask [_TAAStencilMask]
                Comp always
                Pass [_TAAStencilPassOperate]
            }
        
            Cull [_Cull]
            HLSLPROGRAM

            Varyings vert (Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionWS = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.positionSC = ComputeScreenPos(vertexInput.positionCS);
                output.normalWS = vertexNormalInput.normalWS;

                output.uv = input.uv;
                output.vertexColor = input.vertexColor;

                return output;
            }

            half4 frag(Varyings input, half face:VFACE) : COLOR
            {
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - input.positionWS.xyz);
                float3 normalDirection = normalize(input.normalWS)*face;
                float uv_time = fmod(_Time.y, 10);
                half2 uv_offset = input.uv + uv_time * half2(_Tex_U, _Tex_V);
                half4 _Main_var = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(uv_offset, _MainTex));
                half4 _Mask_var = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, TRANSFORM_TEX(input.uv, _MaskTex));
                half frenel = pow(1.0 - saturate(dot(normalDirection, viewDirection)), _FrenelPow) * _FrenelMul;

                half2 uv = (_Main_var.r * half2(0.2, 0.2)) * _Ref * input.vertexColor.a * _Mask_var.r * (1.0 - frenel);
                float2 sceneUVs = input.uv;//input.positionNDC.xy;
                float2 screenSpaceUV = input.positionSC.xy / input.positionSC.w;
                half4 sceneColor = SAMPLE_TEXTURE2D(_DistortionLastCameraColorTexture, sampler_DistortionLastCameraColorTexture, screenSpaceUV.xy + uv);
                return sceneColor;
            }
            ENDHLSL
        }

        //Pass
        //{
        //    Tags { "LightMode" = "Distortion2" }

        //    ZWrite Off
        //    ColorMask BA
        //    Stencil {
        //        Ref 8
        //        //ReadMask [_StencilReadMask]
        //        Comp Equal
        //    }
        //    Cull [_Cull]
        //    HLSLPROGRAM

        //    Varyings vert (Attributes input)
        //    {
        //        Varyings output = (Varyings)0;

        //        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
        //        VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

        //        output.positionWS = vertexInput.positionWS;
        //        output.positionCS = vertexInput.positionCS;

        //        output.normalWS = vertexNormalInput.normalWS;

        //        output.uv = input.uv;
        //        output.vertexColor = input.vertexColor;

        //        return output;
        //    }

        //    half4 frag(Varyings input) : COLOR
        //    {
        //        half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - input.positionWS.xyz);
        //        half3 normalDirection = normalize(input.normalWS);
        //        float uv_time = fmod(_Time.y, 10);
        //        half2 uv_offset = input.uv + uv_time * half2(_Tex_U, _Tex_V);
        //        half4 _Main_var = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(uv_offset, _MainTex));
        //        half4 _Mask_var = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, TRANSFORM_TEX(input.uv, _MaskTex));
        //        half frenel = pow(1.0 - saturate(dot(normalDirection, viewDirection)), _FrenelPow) * _FrenelMul;

        //        half2 uv = (_Main_var.r * half2(0.2, 0.2)) * _Ref * input.vertexColor.a * _Mask_var.r * (1.0 - frenel);
        //        return half4(0, 0, uv);
        //    }

        //    ENDHLSL
        //}
    }

    CustomEditor "JTRP.ShaderDrawer.LWGUI" 
}