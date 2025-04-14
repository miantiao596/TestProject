Shader "Unlit/FaceNormalMapBlend"
{
    Properties
    {
        [Main(GroupSurfaceInputs, _, on, off)] _EnableGroupSurfaceOptions("主法线贴图设置(Surface Inputs)", Float) = 1
        [Tex(GroupSurfaceInputs)]_MainTex ("主法线帖图", 2D) = "bump" {}

        [Main(GroupEyebrowInputs, _, on, off)] _Eyebrow("眉毛设置(Eyebrow Inputs)", Float) = 1
        [Tex(GroupEyebrowInputs)]_EyebrowMap("眉毛", 2D) = "bump" {}
        [Sub(GroupEyebrowInputs)]_EyebrowMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupEyebrowInputs)]_EyebrowMapAngle("眉毛旋转角度",Float) = 0.0
        [Sub(GroupEyebrowInputs)]_EyebrowMapNormalScale("眉毛法线强度", Range(0,1)) = 1
        
        [Main(GroupEyelidInputs, _, on, off)] _Eyelid("眼皮设置(EyeMake Inputs)", Float) = 1
        [Tex(GroupEyelidInputs)]_EyelidMap("眼皮", 2D) = "bump" {}
        [Sub(GroupEyelidInputs)]_EyelidMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupEyelidInputs)]_EyelidMapAngle("眼皮旋转角度",Float) = 0.0
        [Sub(GroupEyelidInputs)]_EyelidMapNormalScale("眼皮法线强度", Range(0,1)) = 1

        
        [Main(GroupScarInputs, _, on, off)] _Scar("疤痕设置(Tatoo Inputs)", Float) = 1
        [Tex(GroupScarInputs)]_ScarMap("疤痕", 2D) = "bump" {}
        [Sub(GroupScarInputs)]_ScarMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupScarInputs)]_ScarMapAngle("疤痕旋转角度",Float) = 0.0
        [Sub(GroupScarInputs)]_ScarMapNormalScale("疤痕法线强度",Range(0,1)) = 1
        
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

            float4 _EyelidMap_ST;
            half _EyelidMapAngle;
            half _EyelidMapNormalScale;
            half _EyelidMapNormalScalea;

            float4 _EyebrowMap_ST;
            half _EyebrowMapAngle;
            half _EyebrowMapNormalScale;

            float4 _ScarMap_ST;
            half _ScarMapAngle;
            half _ScarMapNormalScale;

            CBUFFER_END
            
            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);  
            TEXTURE2D(_EyelidMap);SAMPLER(sampler_EyelidMap);  
            TEXTURE2D(_EyebrowMap);SAMPLER(sampler_EyebrowMap);  
            TEXTURE2D(_ScarMap);SAMPLER(sampler_ScarMap);  


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

            half3 NormalBlend(half3 n1, half3 n2)
            {
                float3x3 nBasis = float3x3(
                float3(n1.z, n1.y, -n1.x), 
                float3(n1.x, n1.z, -n1.y), 
                float3(n1.x, n1.y,  n1.z));
                half3 r = normalize(n2.x*nBasis[0] + n2.y*nBasis[1] + n2.z*nBasis[2]);
                return r;
            }
            float4 frag(Varyings i) : SV_Target
            {
                half3 normal = UnpackNormalScale(SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv),1);
                
                half3 eyebrowNormal = UnpackNormalScale(SAMPLE_TEXTURE2D(_EyebrowMap,sampler_EyebrowMap, MirrorUV(i.uv, half2(3.33,3.33), half2(1.7,1.64), _EyebrowMap_ST, _EyebrowMapAngle)),_EyebrowMapNormalScale);

                half3 eyelidNormal = UnpackNormalScale(SAMPLE_TEXTURE2D(_EyelidMap,sampler_EyelidMap, MirrorUV(i.uv, half2(2.7,3), half2(1.33,1.16), _EyelidMap_ST, _EyelidMapAngle)),_EyelidMapNormalScale);
                
                half3 scarNormal = UnpackNormalScale(SAMPLE_TEXTURE2D(_ScarMap,sampler_ScarMap, SampleUV(i.uv,1,0, _ScarMap_ST, _ScarMapAngle)),_ScarMapNormalScale);
                
                normal.xyz = NormalBlend(normal.xyz,eyebrowNormal.xyz);
                normal.xyz = NormalBlend(normal.xyz,eyelidNormal.xyz);
                normal.xyz = NormalBlend(normal.xyz,scarNormal.xyz);

                return half4(normal,1);
            }
            ENDHLSL
        }
    }
    
    CustomEditor "LWGUI.LWGUI"
}
