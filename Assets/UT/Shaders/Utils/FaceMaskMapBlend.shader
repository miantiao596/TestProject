Shader "Unlit/FaceMaskMapBlend"
{
    Properties
    {
        [Main(GroupSurfaceInputs, _, on, off)] _EnableGroupSurfaceOptions("OCR贴图设置(Surface Inputs)", Float) = 1
        [Tex(GroupSurfaceInputs)]_MainTex ("OCR帖图", 2D) = "white" {}

        [Sub(GroupSurfaceInputs)]_Smoothness("主帖图光泽度(Smoothness)", Range(0.0, 1.0)) = 0.5

        [Main(GroupLipsInputs, _, on, off)] _Lips("唇妆设置(Lips Inputs)", Float) = 1
        [Tex(GroupLipsInputs)]_LipsMap("唇妆", 2D) = "black" {}
        [Sub(GroupLipsInputs)]_LipsMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupLipsInputs)]_LipsMapAngle("唇妆旋转角度",Float) = 0.0
        [Sub(GroupLipsInputs)]_LipsMapAlpha("唇妆透明度",Range(0,1)) = 1
        [Sub(GroupLipsInputs)]_LipsRoughness("唇妆光泽度",Range(0,1)) = 0.5

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "Blend"

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half _Smoothness;
            
            float4 _LipsMap_ST;
            half _LipsMapAngle;
            half _LipsMapAlpha;
            half _LipsRoughness;

            CBUFFER_END
            
            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);  
            TEXTURE2D(_LipsMap);SAMPLER(sampler_LipsMap);  

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                return o;
            }

            half2 SampleUV(half2 uv,half2 Tiling, half2 offset, half4 MapST, half Angle)
            {    
                uv = uv * Tiling - offset;
                uv = uv - float2(0.5,0.5);
                uv -=  MapST.zw * 0.01;
                uv = uv / MapST.xy;
            	uv = float2(uv.x * cos(radians(Angle))- uv.y * sin(radians(Angle)), uv.y * cos(radians(Angle)) + uv.x * sin(radians(Angle)));
            	uv+= float2(0.5,0.5);
                return uv;
            }
            half2 MirrorUV(half2 uv,half2 Tiling, half2 offset, half4 MapST, half Angle)
            {   
                half2 uv1 = uv * Tiling - offset;
                uv1 = uv1 - float2(0.5,0.5);
                uv1 -=  MapST.zw * 0.01;
                uv1 = uv1 / MapST.xy;
            	uv1 = float2(uv1.x * cos(radians(Angle))- uv1.y * sin(radians(Angle)), uv1.y * cos(radians(Angle)) + uv1.x * sin(radians(Angle)));
            	uv1+= float2(0.5,0.5);

                half2 uv2 = half2(1-uv.x,uv.y) * Tiling - offset;
                uv2 = uv2 - float2(0.5,0.5);
                uv2 -=  MapST.zw * 0.01;
                uv2 = uv2 / MapST.xy;
            	uv2 = float2(uv2.x * cos(radians(Angle))- uv2.y * sin(radians(Angle)), uv2.y * cos(radians(Angle)) + uv2.x * sin(radians(Angle)));
            	uv2+= float2(0.5,0.5);

                uv = lerp(uv1, uv2, step(uv.x,0.5));
                return uv;
            }

            float4 frag(Varyings i) : SV_Target
            {
                // sample the texture
                half4 Rougnhess = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv);
                Rougnhess.b = (1-Rougnhess.b)*_Smoothness*2;
                
                //唇妆粗糙度
                half4 lipsRougnhess = SAMPLE_TEXTURE2D(_LipsMap,sampler_LipsMap ,SampleUV(i.uv, half2(4.3,4.3), half2(1.65,0.85), _LipsMap_ST, _LipsMapAngle));
                
                Rougnhess.b = lerp(Rougnhess.b, _LipsRoughness, lipsRougnhess.r * _LipsMapAlpha);
                return Rougnhess;
            }
            ENDHLSL
        }
    }
    
    CustomEditor "LWGUI.LWGUI"
}
