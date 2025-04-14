// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Hidden/MoleGame/Pipeline/Blit" {
     Properties
    {
        _MainTex ("_MainTex", 2D) = "" {}
        //_SceneTexture("Scene Texture", 2D) = "black" {}
        _Color("Multiplicative color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader {
        Pass {
            ZTest Always Cull Off ZWrite Off
			Blend One Zero

            CGPROGRAM
            #pragma multi_compile_local_fragment _ _BLIT_BACK_BUFFER
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float4 _Color;

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);

                o.vertex = UnityObjectToClipPos(v.vertex.xyz);
                o.texcoord = v.texcoord;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
//#ifdef _BLIT_BACK_BUFFER
//#if UNITY_UV_STARTS_AT_TOP
//                i.texcoord.y = 1 - i.texcoord.y;
//#endif
//#endif
                fixed4 col = tex2D(_MainTex, i.texcoord) * _Color;

//#ifdef _BLIT_BACK_BUFFER
//                col.rgb = LinearToGammaSpace(col.rgb);
//#endif

                return col;
            }
            ENDCG

        }
    }
    Fallback Off
}