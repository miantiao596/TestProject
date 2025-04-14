Shader "Unlit/FaceDiffuseMapBlend"
{
    Properties
    {
        [Main(GroupSurfaceInputs, _, on, off)] _EnableGroupSurfaceOptions("主贴图设置(Surface Inputs)", Float) = 1
        [Tex(GroupSurfaceInputs)]_MainTex ("主帖图", 2D) = "white" {}
        
        [Sub(GroupSurfaceInputs)]_Color ("主颜色", Color) = (0.95,0.8328,0.76,1)
        [Sub(GroupSurfaceInputs)]_Spot ("斑痕保留量", Range(0,1)) = 0.5
        [Sub(GroupSurfaceInputs)]_SpotSaturation ("斑痕饱和度", Range(0,1)) = 0.5

        [Main(GroupEyeMakeupInputs, _, on, off)] _EyeMakeup("眼妆设置(EyeMake Inputs)", Float) = 1
        [Tex(GroupEyeMakeupInputs)]_EyeMakeupMap("眼妆", 2D) = "black" {}
        
        [Sub(GroupEyeMakeupInputs)]_EyeMakeupMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupEyeMakeupInputs)]_EyeMakeupMapAngle("眼妆旋转角度",Float) = 0.0
        [Sub(GroupEyeMakeupInputs)]_EyeMakeup1Alpha("眼妆1透明度", Range(0,1)) = 1
        [Sub(GroupEyeMakeupInputs)]_EyeMakeup2Alpha("眼妆2透明度", Range(0,1)) = 1
        [Sub(GroupEyeMakeupInputs)]_EyeMakeup3Alpha("眼妆3透明度", Range(0,1)) = 1
        [Sub(GroupEyeMakeupInputs)]_EyeMakeup1Color("眼妆1颜色", Color) = (1,1,1,1)
        [Sub(GroupEyeMakeupInputs)]_EyeMakeup2Color("眼妆2颜色", Color) = (1,1,1,1)
        [Sub(GroupEyeMakeupInputs)]_EyeMakeup3Color("眼妆3颜色", Color) = (1,1,1,1)

        
        [Main(GroupEyebrowInputs, _, on, off)] _Eyebrow("眉毛设置(Eyebrow Inputs)", Float) = 1
        [Tex(GroupEyebrowInputs)]_EyebrowMap("眉毛", 2D) = "black" {}
        [Sub(GroupEyebrowInputs)]_EyebrowMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupEyebrowInputs)]_EyebrowMapAngle("眉毛旋转角度",Float) = 0.0
        [Sub(GroupEyebrowInputs)]_EyebrowMapColor("眉毛颜色", Color) = (1,1,1,1)
        [Sub(GroupEyebrowInputs)]_EyebrowMapAlpha("眉毛透明度", Range(0,2)) = 1
        
        
        [Main(GroupBlushInputs, _, on, off)] _Blush("腮红设置(Blush Inputs)", Float) = 1
        [Tex(GroupBlushInputs)]_BlushMap("腮红", 2D) = "black" {}
        [Sub(GroupBlushInputs)]_BlushMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupBlushInputs)]_BlushMapAngle("腮红旋转角度",Float) = 0.0
        [Sub(GroupBlushInputs)]_BlushMap1Color("腮红1颜色", Color) = (0.8,0,0,1)
        [Sub(GroupBlushInputs)]_BlushMap2Color("腮红2颜色", Color) = (0,0.2,0,1)
        [Sub(GroupBlushInputs)]_BlushMap3Color("腮红3颜色", Color) = (0,0,0.6,1)
        [Sub(GroupBlushInputs)]_BlushMapAlpha("腮红透明度", Range(0,1)) = 1
        
        [Main(GroupLipsInputs, _, on, off)] _Lips("唇妆设置(Lips Inputs)", Float) = 1
        [Tex(GroupLipsInputs)]_LipsMap("唇妆", 2D) = "black" {}
        [Sub(GroupLipsInputs)]_LipsMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupLipsInputs)]_LipsMapAngle("唇妆旋转角度",Float) = 0.0
        [Sub(GroupLipsInputs)]_LipsMapColor("唇妆颜色", Color) = (1,1,1,1)
        [Sub(GroupLipsInputs)]_LipsMapAlpha("唇妆透明度",Range(0,1)) = 1
        
        [Main(GroupTatooInputs, _, on, off)] _Tatoo("面纹设置(Tatoo Inputs)", Float) = 1
        [Tex(GroupTatooInputs)]_TatooMap("面纹", 2D) = "black" {}
        [Sub(GroupTatooInputs)]_TatooMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupTatooInputs)]_TatooMapAngle("面纹旋转角度",Float) = 0.0
        [Sub(GroupTatooInputs)]_TatooMapColor("面纹颜色", Color) = (1,1,1,1)
        [Sub(GroupTatooInputs)]_TatooMapAlpha("面纹透明度",Range(0,1)) = 1
        

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
            half4 _Color;

            half _Spot;
            half _SpotSaturation;

            float4 _EyeMakeupMap_ST;
            half _EyeMakeupMapAngle;
            half _EyeMakeup1Alpha;
            half _EyeMakeup2Alpha;
            half _EyeMakeup3Alpha;
            half4 _EyeMakeup1Color;
            half4 _EyeMakeup2Color;
            half4 _EyeMakeup3Color;

            float4 _EyebrowMap_ST;
            half _EyebrowMapAngle;
            half4 _EyebrowMapColor;
            half _EyebrowMapAlpha;

            float4 _BlushMap_ST;
            half _BlushMapAngle;
            half4 _BlushMap1Color;
            half4 _BlushMap2Color;
            half4 _BlushMap3Color;
            half _BlushMapAlpha;

            float4 _LipsMap_ST;
            half _LipsMapAngle;
            half4 _LipsMapColor;
            half _LipsMapAlpha;

            float4 _TatooMap_ST;
            half _TatooMapAngle;
            half4 _TatooMapColor;
            half _TatooMapAlpha;

            CBUFFER_END
            
            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);  
            TEXTURE2D(_EyeMakeupMap);SAMPLER(sampler_EyeMakeupMap);  
            TEXTURE2D(_EyebrowMap);SAMPLER(sampler_EyebrowMap);  
            TEXTURE2D(_LipsMap);SAMPLER(sampler_LipsMap);  
            TEXTURE2D(_BlushMap);SAMPLER(sampler_BlushMap);  
            TEXTURE2D(_TatooMap);SAMPLER(sampler_TatooMap);  


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
                half4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv);

                half thickness = col.a;
                thickness = thickness*0.5 ;
                //将颜色转换为灰度图
                half grayscale = saturate(smoothstep(0.0, _Spot * 0.4 + 0.6,dot(col.rgb, float3(0.299, 0.587, 0.114))));
                //将 原图 和 灰度图+原图(使得暗处区域不至于因为灰度不足导致偏色) 进行lerp(灰度与厚度)，颜色越暗沉就越保留,最后将得到带有原图信息的白图进行染色
                col.rgb = lerp(col.rgb, saturate(grayscale.rrr+col.rgb*_SpotSaturation), saturate(grayscale-thickness))*_Color;

                half2 uv = i.uv;
                half4 eyeMakeupCol = SAMPLE_TEXTURE2D(_EyeMakeupMap,sampler_EyeMakeupMap, MirrorUV(uv, half2(2.7,3), half2(1.33,1.16), _EyeMakeupMap_ST, _EyeMakeupMapAngle));
                
                col.rgb = lerp(col.rgb, _EyeMakeup2Color, eyeMakeupCol.g * _EyeMakeup2Alpha);
                col.rgb = lerp(col.rgb, _EyeMakeup3Color, eyeMakeupCol.b * _EyeMakeup3Alpha);
                col.rgb = lerp(col.rgb, _EyeMakeup1Color, eyeMakeupCol.r * _EyeMakeup1Alpha);
                
                half4 lipsCol = SAMPLE_TEXTURE2D(_LipsMap,sampler_LipsMap ,SampleUV(uv, half2(4.3,4.3), half2(1.65,0.85), _LipsMap_ST, _LipsMapAngle));
                col.rgb = lerp(col.rgb, _LipsMapColor, lipsCol.r * _LipsMapAlpha);
                
                half4 blushCol = SAMPLE_TEXTURE2D(_BlushMap, sampler_BlushMap,MirrorUV(uv, half2(2.5,2.5), half2(1.2,0.4), _BlushMap_ST, _BlushMapAngle));
                
                col.rgb = lerp(col.rgb,  _BlushMap1Color, blushCol.r * _BlushMapAlpha);
                col.rgb = lerp(col.rgb,  _BlushMap2Color, blushCol.g * _BlushMapAlpha);
                col.rgb = lerp(col.rgb, _BlushMap3Color , blushCol.b * _BlushMapAlpha);
                
                half4 eyebrowCol = SAMPLE_TEXTURE2D(_EyebrowMap,sampler_EyebrowMap, MirrorUV(uv, half2(3.33,3.33), half2(1.7,1.64), _EyebrowMap_ST, _EyebrowMapAngle));
                col.rgb = lerp(col.rgb, eyebrowCol.r * _EyebrowMapColor, eyebrowCol.r * _EyebrowMapAlpha);
                
                half4 tatooCol = SAMPLE_TEXTURE2D(_TatooMap,sampler_TatooMap, SampleUV(uv,1,0, _TatooMap_ST, _TatooMapAngle));
                col.rgb = lerp(col.rgb, tatooCol.rgb * _TatooMapColor, tatooCol.a * _TatooMapAlpha);

                return col;
            }
            ENDHLSL
        }
    }
    
    CustomEditor "LWGUI.LWGUI"
}
