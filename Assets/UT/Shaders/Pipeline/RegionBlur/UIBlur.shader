Shader "UT/CustomEffect/UIBlur"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0

        _ColorMask ("Color Mask", Float) = 15
    }
    SubShader
    {
        Tags 
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]
        Pass
        {

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment fragment
            #pragma target 2.0
            #include "UnityCG.cginc"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float4 screenUV : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 screenUV : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _BlurBuffer;
            float4 _MainTex_ST;
            half4 _Color;

            v2f vert (Attributes IN)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(IN.position);
                o.uv = IN.uv;
                o.screenUV = ComputeScreenPos(o.pos);
                return o;
            }

            half4 fragment (v2f IN) : SV_Target
            {
                float2 UV = IN.uv;
                float2 finalScreenUV = IN.screenUV.xy / IN.screenUV.w;
                half4 col = tex2D(_MainTex, UV);
                half3 blurCol = tex2D(_BlurBuffer, finalScreenUV);
                col.xyz = col.xyz * blurCol * _Color.xyz;
                //col.xyz = blurCol;
                //col.w = 1;
                return col;
            }
            ENDHLSL
        }
    }
    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}
