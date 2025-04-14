//这个Shader是从Shader Forge里Copy，然后做了一些稍微修改的，后期需要将里面的Shader变量
//名进行调整，变更为方便阅读的变量名
Shader "URP/MoleGame/Effects/Tornado" {
    Properties {
        [MainColor][HDR]_TintColor ("Main Color", Color) = (1,1,1,1)
        [MainTexture]_MainTex ("Main Texture", 2D) = "white" {}
        _Tex01_u ("Main Texture Speed U", Float ) = 0
        _Tex01_v ("Main Texture Speed V", Float ) = 0
        [SecondTexture]_Tex_02 ("Second Texture", 2D) = "white" {}
        [MaskTexture]_mask_01 ("Mask Texture", 2D) = "white" {}
        _mask_u ("Mask Texture Speed U", Float ) = 0
        _mask_v ("Mask Texture Speed V", Float ) = 0
        _vertex_ ("Vertex Parameter", Float ) = 0
        [VertexTexture]_tex_vertex ("Vertex Texture", 2D) = "white" {}
        _diff_add ("Diffuse Add Parameter", Float ) = 1
        _fresnel_01 ("Fresnel Parameter 1", Float ) = 1
        _fresnel_02 ("Fresnel Parameter 2", Float ) = 1.5
        _UV_Rot_01 ("UV Rotate Parameter", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0.0, 0.99)) = 0.2
        
        //TAA用的stencil
		[HideInInspector]_SkipTAA("Skip TAA", int) = 0
		//生效的时候这2个都是16
		[HideInInspector]_TAAStencil("TAA Stencil Ref (Default: 0)", Float) = 16
		[HideInInspector]_TAAStencilMask("TAA Stencil Write Mask (Default: 0)", Float) = 16
		//0是keep 2是Replace
		[HideInInspector]_TAAStencilPassOperate("Stencil Operate (Default: 0)", Float) = 2
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            uniform sampler2D _MainTex;
            uniform sampler2D _Tex_02;
            uniform sampler2D _mask_01;
            uniform sampler2D _tex_vertex;

            CBUFFER_START(UnityPerMaterial)
            uniform float4 _MainTex_ST;
            uniform float4 _mask_01_ST;
            uniform float4 _tex_vertex_ST;
            uniform float4 _Tex_02_ST;

            uniform half4 _TintColor;
            uniform half _Tex01_u;
            uniform half _Tex01_v;

            uniform half _mask_u;
            uniform half _mask_v;
            uniform half _vertex_;

            uniform half _diff_add;
            uniform half _fresnel_01;
            uniform half _fresnel_02;
            uniform half _UV_Rot_01;
            CBUFFER_END

            struct Attributes {
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                half4 tangentOS    : TANGENT;
                float2 uv : TEXCOORD0;
                half4 vertexColor : COLOR;
            };
            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                half3 normalWS : TEXCOORD2;
                half4 vertexColor : COLOR;
            };
            Varyings vert (Attributes input) {
                Varyings output = (Varyings)0;

                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);


                output.uv = input.uv;
                output.vertexColor = input.vertexColor;

                output.normalWS = vertexNormalInput.normalWS;

                float4 node_7285 = _Time;
                half node_793_ang = _UV_Rot_01;
                half node_793_spd = 1.0;
                float node_793_cos = cos(node_793_spd*node_793_ang);
                float node_793_sin = sin(node_793_spd*node_793_ang);
                half2 node_793_piv = half2(0.5,0.5);
                float2 node_793 = (mul(output.uv-node_793_piv,float2x2( node_793_cos, -node_793_sin, node_793_sin, node_793_cos))+node_793_piv);
                float2 node_9876 = ((node_7285.g*float2(_Tex01_u,_Tex01_v))+output.uv+node_793);
                half4 _tex_vertex_var = tex2Dlod(_tex_vertex,float4(TRANSFORM_TEX(node_9876, _tex_vertex),0.0,0));
                input.positionOS.xyz += (_tex_vertex_var.r*_vertex_*input.normalOS*_tex_vertex_var.a);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionWS = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                return output;
            }
            half4 frag(Varyings input, half facing : VFACE) : COLOR {
                half isFrontFace = ( facing >= 0 ? 1 : 0 );
                half faceSign = ( facing >= 0 ? 1 : -1 );
                input.normalWS = normalize(input.normalWS);
                input.normalWS *= faceSign;
                half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - input.positionWS.xyz);
                half3 normalDirection = input.normalWS;
////// Lighting:
////// Emissive:
                float4 node_7285 = _Time;
                half node_793_ang = _UV_Rot_01;
                half node_793_spd = 1.0;
                float node_793_cos = cos(node_793_spd*node_793_ang);
                float node_793_sin = sin(node_793_spd*node_793_ang);
                half2 node_793_piv = half2(0.5,0.5);
                float2 node_793 = (mul(input.uv-node_793_piv,float2x2( node_793_cos, -node_793_sin, node_793_sin, node_793_cos))+node_793_piv);
                float2 node_9876 = ((node_7285.g*float2(_Tex01_u,_Tex01_v))+input.uv+node_793);
                half4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_9876, _MainTex));
                half3 emissive = (_MainTex_var.rgb*input.vertexColor.rgb*_TintColor.rgb*2.0*_diff_add);
                half3 finalColor = emissive;
                half4 _Tex_02_var = tex2D(_Tex_02,TRANSFORM_TEX(node_793, _Tex_02));
                float4 node_5859 = _Time;
                float2 node_8975 = (input.uv+(node_5859.g*float2(_mask_u,_mask_v))+node_793);
                half4 _mask_01_var = tex2D(_mask_01,TRANSFORM_TEX(node_8975, _mask_01));
                return half4(finalColor,saturate(((1.0 - (_fresnel_02*pow(1.0-saturate(dot(normalDirection, viewDirection)),_fresnel_01)))*(((_Tex_02_var.r*_MainTex_var.r*_Tex_02_var.a*_MainTex_var.a)*input.vertexColor.a*_TintColor.a)*_mask_01_var.r))));
            }
        ENDHLSL

        Pass {
            Name "StandardLit"
            Tags {
                "LightMode" = "SceneEffect"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off

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
            ZWrite Off

            HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
            ENDHLSL
        }
    }
    CustomEditor "JTRP.ShaderDrawer.LWGUI" 
}
