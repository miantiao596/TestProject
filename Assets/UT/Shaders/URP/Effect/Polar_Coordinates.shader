Shader "URP/MoleGame/Effects/Polar_Coordinates" {
    Properties {
        [MainColor]_Tex_col ("Main Color", Color) = (0.5,0.5,0.5,1)                   // 主颜色
        [MainTexture]_MainTex ("Main Texture", 2D) = "white" {}                             // 主纹理
        _rot_01 ("Twisting Strength", Range(0, 1)) = 0                             // 扭曲效果强度
        _add_01 ("Color Lightness", Float ) = 1                                  // 颜色明度
        [MaskTexture]_mask ("Mask Texture", 2D) = "white" {}                                 // 遮罩纹理
        _Tex_U ("Main Texture Speed U", Float ) = 0                                    // u速度
        _Tex_V ("Main Texture Speed V", Float ) = 0                                    // v速度
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
        #pragma target 3.0

        uniform sampler2D _MainTex;
        uniform sampler2D _mask;

        CBUFFER_START(UnityPerMaterial)
        uniform float4 _MainTex_ST;
        uniform float4 _mask_ST;
        uniform half _rot_01;
        uniform half _Tex_U;
        uniform half _Tex_V;
        uniform half4 _Tex_col;
        uniform half _add_01;
        CBUFFER_END

        struct Attributes {
            float4 positionOS : POSITION;           // 顶点位置
            float2 uv : TEXCOORD0;       // 纹理坐标
            half4 vertexColor : COLOR;         // 顶点颜色
        };
        struct Varyings {
            float4 positionCS : SV_POSITION;           // 顶点位置
            float2 uv : TEXCOORD0;             // 纹理坐标
            half4 vertexColor : COLOR;         // 顶点颜色
        };

        Varyings vert (Attributes input) {
            // 输出类型
            Varyings output = (Varyings)0;
            VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
            output.positionCS = vertexInput.positionCS;
            // 纹理坐标
            output.uv = input.uv;
            // 顶点颜色
            output.vertexColor = input.vertexColor;
            return output;
        }
        half4 frag(Varyings input, half facing : VFACE) : COLOR {
            half isFrontFace = ( facing >= 0 ? 1 : 0 );
            half faceSign = ( facing >= 0 ? 1 : -1 );

            // 扭曲效果
            // 旋转角度
            half angle = (1.0 - length(input.uv*2.0+-1.0)) * 3.141592654 * 2.0 * _rot_01;
            half spd = 1.0;
            float cos_ang = cos(spd*angle);
            float sin_ang = sin(spd*angle);
            // 旋转的轴心点
            float2 piv = float2(0.5,0.5);
            // 旋转矩阵
            float2x2 rotateM = float2x2(cos_ang, -sin_ang, sin_ang, cos_ang);
            // 旋转后的纹理坐标，将旋转中心恢复到(0,0)乘以旋转矩阵，再移回原来位置
            float2 uv_rotated = mul(input.uv - piv, rotateM) + piv;
            float2 uv_tmp = uv_rotated*2.0+-1.0;
            float2 uv_new = float2(atan2(uv_tmp.r, uv_tmp.g), length(uv_tmp));
            // 纹素（对 _mask遮罩纹理 进行纹理采样）
            half4 mask_var = tex2D(_mask, TRANSFORM_TEX(uv_new, _mask));
            // 随着时间变化的纹理坐标，根据自定义的速度参数计算新的纹理坐标
            float2 uv_01 = uv_new + (_Time.g * float2(_Tex_U, _Tex_V));
            // 纹素（对 _MainTex纹理 进行纹理采样）
            half4 Tex_01_var = tex2D(_MainTex, TRANSFORM_TEX(uv_01, _MainTex));
            // 最终颜色
            // 由主颜色及其a值，顶点颜色的a值，遮罩纹素的r值，自定义倍率，_MainTex纹素的颜色决定。
            half3 finalColor = (_Tex_col.rgb*input.vertexColor.a*mask_var.r*_Tex_col.a*_add_01)*Tex_01_var.rgb;
            // 透明度
            // 由主颜色的a值，顶点颜色的a值，遮罩纹素的r值，遮罩纹素的a值，_MainTex纹素的a值决定。
            half finalColor_a = Tex_01_var.a*input.vertexColor.a*mask_var.a*mask_var.r*_Tex_col.a;

            return half4(finalColor, finalColor_a);
        }
    ENDHLSL

    SubShader {
        Tags {
            "IgnoreProjector"="True"        // 忽略投影机的作用
            "Queue"="Transparent"           // 渲染队列
            "RenderType"="Transparent"      // 渲染类型
        }
        Pass {
            Name "StandardLit"  // Pass块的名字
            Tags {
                "LightMode" = "SceneEffect"		// 光照模式
            }
            Blend SrcAlpha OneMinusSrcAlpha		// 混合效果
            Cull Off        // 不剔除
            ZWrite Off      // 关闭深度写入

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
            Name "StandardLit"  // Pass块的名字
            Tags {
                "LightMode" = "Effect"		// 光照模式
            }
            Blend SrcAlpha OneMinusSrcAlpha		// 混合效果
            Cull Off        // 不剔除
            ZWrite Off      // 关闭深度写入

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }
    }
    CustomEditor "JTRP.ShaderDrawer.LWGUI" 
}
