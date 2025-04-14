Shader "Hidden/48/CostumeZWrite"
{
    Properties
    {
        _BaseMap("主贴图", 2D) = "white" {}
        _Cutoff ("剔除权重", Range(0.0, 1.0)) = 0.5
        _TransparentZWrite ("半透明深度写入 ", Float) = 1
    }
    SubShader
    {
        LOD 100

        Tags
        {
            "Queue"="Transparent"
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }
        Pass
        {
            Name "CostumeZWrite"
            Tags { "LightMode" = "CostumeZWrite" }
            ZWrite [_TransparentZWrite]
            Blend SrcAlpha OneMinusSrcAlpha
//            ColorMask 0
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float _Cutoff;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                clip(texColor.a - _Cutoff);
                // return texColor;
                return float4(0, 0, 0, 0);
            }
            ENDHLSL
        }

    }
}