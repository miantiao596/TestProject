// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge

Shader "URP/MoleGame/Effects/Double_Sided_Dissolve" {
    Properties {
        [MainColor]_TintColor ("Main Color", Color) = (0.2058824,0.2058824,0.2058824,1)
        [MainTexture]_MainTex ("Main Texture", 2D) = "white" {}         // 图片纹理
        _Tex_u ("Main Texture Speed U", Float ) = 0
        _Tex_v ("Main Texture Speed V", Float ) = 0
        [DissolveTexture]_noise ("Dissolve Texture", 2D) = "white" {}           // MASK纹理
        _Mask_u ("Dissolve Texture Speed U", Float ) = 0
        _Mask_v ("Dissolve Texture Speed V", Float ) = -1
        _AlphaFactor ("Dissolve Factor", Float) = 0.8
        _PowFactor ("Vertical Factor", Float) = 4
        _inside_add ("Inside Color Intensity", Float ) = 1      // 内部颜色增强系数
        _FinalAlpha ("Final Alpha", Range(0,1)) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0.0, 0.99)) = 0.5
        
        //TAA用的stencil
		[HideInInspector]_SkipTAA("Skip TAA", int) = 0
		//生效的时候这2个都是16
		[HideInInspector]_TAAStencil("TAA Stencil Ref (Default: 0)", Float) = 16
		[HideInInspector]_TAAStencilMask("TAA Stencil Write Mask (Default: 0)", Float) = 16
		//0是keep 2是Replace
		[HideInInspector]_TAAStencilPassOperate("Stencil Operate (Default: 0)", Float) = 2
		
    }

    HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        #pragma prefer_hlslcc gles
        #pragma exclude_renderers d3d11_9x
        #pragma target 2.0

        uniform sampler2D _MainTex;
        uniform sampler2D _noise;

        CBUFFER_START(UnityPerMaterial)
        uniform float4 _MainTex_ST;
        uniform half4 _TintColor;
        uniform half _Tex_u;
        uniform half _Tex_v;

        uniform float4 _noise_ST;
        uniform half _Mask_u;
        uniform half _Mask_v;
        uniform half _AlphaFactor;
        uniform half _PowFactor;
        uniform half _inside_add;
        uniform half _FinalAlpha;
        CBUFFER_END

        struct Attributes {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
            half4 vertexColor : COLOR;
        };
        struct Varyings {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;
            half4 vertexColor : COLOR;
        };

        Varyings vert (Attributes input) {
            Varyings output = (Varyings)0;

            VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
            output.positionCS = vertexInput.positionCS;

            output.uv = input.uv;
            output.vertexColor = input.vertexColor;

            return output;
        }

        half4 frag(Varyings input, half facing : VFACE) : COLOR {
            half isFrontFace = step(0.0, facing);            // 标识正反面，内部颜色增强，step函数替换三目运算
            float uv_time = fmod(_Time.g, 10);                // 计算uv随时间变化

            float2 uv_dist = ((uv_time * float2(_Tex_u,_Tex_v)) + input.uv);
            half4 _MainTex_var = tex2D(_MainTex, TRANSFORM_TEX(uv_dist, _MainTex));
            //float4 _MainTex_var = tex2Dlod(_MainTex, float4(TRANSFORM_TEX(uv_dist, _MainTex), 0.0, isFrontFace));

            float2 uv_dist1 = (input.uv + (uv_time * float2(_Mask_u, _Mask_v)));
            half4 _noise_var = tex2D(_noise, TRANSFORM_TEX(uv_dist1, _noise));

            half original_alpha = _MainTex_var.a * input.vertexColor.a * _TintColor.a;
            half pow_alpha = saturate((_AlphaFactor - input.uv.g - _noise_var.r) + pow(max(0, _AlphaFactor - input.uv.g), _PowFactor));
            clip(original_alpha * pow_alpha - 0.5);

            half3 emissive = (_MainTex_var.rgb * input.vertexColor.rgb * _TintColor.rgb * 2.0 * lerp((_MainTex_var.rgb + _inside_add), _MainTex_var.rgb, isFrontFace));
            return half4(emissive, _FinalAlpha);
        }
    ENDHLSL

    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "StandardLit"
            Tags {
                "LightMode" = "SceneEffect"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            //跳过TAA处理的Mask
            Stencil {
                Ref [_TAAStencil]
                WriteMask [_TAAStencilMask]
                Comp always
                Pass [_TAAStencilPassOperate]
            }
            

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }

        Pass {
            Name "StandardLit"
            Tags {
                "LightMode" = "Effect"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }
    }
    CustomEditor "JTRP.ShaderDrawer.LWGUI" 
}
