Shader "URP/MoleGame/Effects/Liquid"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _MainTex_Speed_U("Main Texture Speed U", Float) = 0
        _MainTex_Speed_V("Main Texture Speed V", Float) = 0
        
        _FillHeight("Fill Height", Range(-1.2, 1.0)) = 0.5
        [HDR]_TopColor("Top Color", Color) = (1,1,1,1)
        [HDR]_SideColor("Side Color", Color) = (1,1,1,1)
        
        // Wave
        _Amplitude("Wave Amplitude", Range(0, 0.1)) = 0        // 振幅
        _AngularVelocity("Wave Angular Velocity", Float) = 0   // 角速度
        _Frequency("Wave Frequency", Float) = 0                // 频率
        
        // Parallax
        _ParallaxTex("Parallax Texture A", 2D) = "white"{}
        [HDR]_ParallaxColor("Parallax Color", Color) = (1,1,1,1)
        _ParallaxScale("Parallax Scale", Float) = 1
        _ParallaxHeight("Parallax Height", Float) = 0
        _ParallaxVector("[xy]UV Scale, [zw]UV Speed", vector) = (1,1,0,0)
        
        // Refraction
        _RefractionTex("Parallax Texture B", 2D) = "white"{}
        [HDR]_RefractionColor("Refraction Color", Color) = (1,1,1,1)
        _RefractionRatio("Refraction Ratio", Float) = 0
        _RefractionVector("[xy]UV Scale, [zw]UV Speed", vector) = (1,1,0,0)

        
        // 菲尼尔
        [HDR]_LFresnelColor("Fresnel Color", Color) = (1,1,1,1)
        _LFresnelScale("Fresnel Scale", Float) = 0
        _LFresnelPower("Fresnel Power", Float) = 5
        _TopFresnelRatio("Top Fresnel Ratio", Float) = 1
        

        _WobbleX("Wobble X", Float) = 0
        _WobbleZ("Wobble Z", Float) = 0
        [HideInInspector]_WorldPosition("Object World Position", vector) = (0,0,0,0)
        
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
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType"="Transparent" "Queue" = "Transparent" }

        Pass
        {
            Name "Liquid"
            Tags { "LightMode" = "SceneEffect" }
            
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
            #pragma vertex LiquidVertex
            #pragma fragment LiquidFragment
  
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "../FALib/FaPublicFunction.hlsl"
            
            TEXTURE2D(_MainTex);				    SAMPLER(sampler_MainTex);
            TEXTURE2D(_ParallaxTex);				SAMPLER(sampler_ParallaxTex);
            TEXTURE2D(_RefractionTex);				SAMPLER(sampler_RefractionTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half _MainTex_Speed_U;
            half _MainTex_Speed_V;
            
            half _FillHeight;
            half4 _TopColor;
            half4 _SideColor;
            half _WobbleX;
            half _WobbleZ;
            float3 _WorldPosition;
            
            // Wave
            half _Amplitude;
            half _AngularVelocity;
            half _Frequency;
            
            // Parallax
            float4 _ParallaxTex_ST;
            float4 _RefractionTex_ST;
            half _ParallaxScale;
            half _ParallaxHeight;
            half _ParallaxRatio;
            half4 _ParallaxColor;
            half _ParallaxTex_Speed_U;
            half _ParallaxTex_Speed_V;
            half4 _ParallaxVector;
            
            // Refraction 
            half _RefractionRatio;
            half4 _RefractionVector;
            half4 _RefractionColor;
            
            // Fresnel
            half4 _LFresnelColor;
            half _LFresnelScale;
            half _LFresnelPower;
            half _TopFresnelRatio;
            CBUFFER_END
           
            
            struct Attributes
            {
                float4 positionOS : POSITION;   
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                float3 positionOS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 viewDirTan : TEXCOORD3;
                float3 normalWS   : TEXCOORD4;
            };
            
            Varyings LiquidVertex (Attributes input)
            {
                Varyings output = (Varyings)0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                float3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - vertexInput.positionWS);  
                float3 tanToWorldX = float3(vertexNormalInput.tangentWS.x, vertexNormalInput.bitangentWS.x, vertexNormalInput.normalWS.x);
                float3 tanToWorldY = float3(vertexNormalInput.tangentWS.y, vertexNormalInput.bitangentWS.y, vertexNormalInput.normalWS.y);
                float3 tanToWorldZ = float3(vertexNormalInput.tangentWS.z, vertexNormalInput.bitangentWS.z, vertexNormalInput.normalWS.z); 
                float3 viewDirTan = SafeNormalize(tanToWorldX * viewDirectionWS.x + tanToWorldY * viewDirectionWS.y + tanToWorldZ * viewDirectionWS.z);
                
                output.positionCS = vertexInput.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.positionOS = input.positionOS.xyz;
                output.positionWS = vertexInput.positionWS;
                output.viewDirTan = viewDirTan;
                output.normalWS = vertexNormalInput.normalWS;
                return output;
            }

            half4 LiquidFragment (Varyings input, half facing : VFACE) : SV_Target
            {
                float time = fmod(_Time.x, 10);
                half4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv + time * half2(_MainTex_Speed_U, _MainTex_Speed_V));
                float3 viewDirWS = SafeNormalize(GetCameraPositionWS() - input.positionWS); 
                                
                // Parallax
                half2 parallax_offset = ParallaxOffset(_ParallaxScale, _ParallaxHeight, input.viewDirTan.xyz);
                half2 parallax_uv = TRANSFORM_TEX(input.uv * _ParallaxVector.xy + time *_ParallaxVector.zw + parallax_offset, _ParallaxTex);
                
                half4 parallax = SAMPLE_TEXTURE2D(_ParallaxTex, sampler_ParallaxTex, parallax_uv) * _ParallaxColor * 1.5;
                
                // Refraction TODO：可以采样另一张视差贴图来替换折射效果，减少计算
                float3 refractWS = refract(-normalize(viewDirWS), normalize(input.normalWS), _RefractionRatio);
                half2 refraction_offset = refractWS.xy;
                half2 refraction_uv = TRANSFORM_TEX(input.uv * _RefractionVector.xy + time * _RefractionVector.zw + refraction_offset, _RefractionTex);
                half4 refraction = SAMPLE_TEXTURE2D(_RefractionTex, sampler_RefractionTex, refraction_uv) * _RefractionColor;
                
                
                // Fresnel
                half fresnel = _LFresnelScale * pow(1 - saturate(dot(input.normalWS, viewDirWS)), _LFresnelPower);
                half4 fresnelColor = fresnel * _LFresnelColor;
                
                
                half4 sideColor = _SideColor * mainTex;
                sideColor = lerp(sideColor, sideColor * parallax, _ParallaxColor.a);
                sideColor = lerp(sideColor, sideColor * refraction, _RefractionColor.a);
                sideColor += fresnelColor;
                
                sideColor.a = _SideColor.a;
                
                half4 topColor = _TopColor * mainTex + fresnelColor * _TopFresnelRatio;// + fresnelColor * 0.65;
                topColor.a = _TopColor.a;
                
                half faceSign = saturate(-facing);
                half4 color = lerp(sideColor, topColor, faceSign);

                
                half3 axis_x = half3(1, 0, 0);
                half3 axis_z = half3(0, 0, 1);
                
                float3 pos_x = DegreesRotateAboutAxis(input.positionOS, axis_x, 90) * _WobbleX;
                float3 pos_z = DegreesRotateAboutAxis(input.positionOS, axis_z, 90) * _WobbleZ;
                float3 pos = pos_x + pos_z + (input.positionWS - _WorldPosition.xyz);
                float offset_y = _Amplitude * sin(_AngularVelocity * pos.x + _Frequency * time);
                half y = step(pos.y + offset_y, _FillHeight);
                clip(y - 0.5);
                return color;
            }
            ENDHLSL
        }
    }
    CustomEditor "JTRP.ShaderDrawer.LWGUI" 
}
