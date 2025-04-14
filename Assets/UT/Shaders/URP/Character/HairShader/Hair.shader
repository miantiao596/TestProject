Shader "URP/UT/Character/Hair"
{ 
    Properties
    {
        
        [Main(GroupSurfaceOptions, _, on, off)] _HairSurfaceInputs("基础设置(Surface Inputs)", Float) = 1
		[SubEnum(GroupSurfaceOptions, Both, 0, Back, 1, Front, 2)] _Cull("Render Face", Float) = 0
        [Preset(GroupSurfaceOptions, HairBlender)] _RenderMode ("Rendering Mode", Float) = 1

        [Main(GroupHairInputs, _, on, off)] _HairInputs("贴图设置(Surface Inputs)", Float) = 1
        
        [SubToggle(GroupHairInputs)]  _HairColorGradualChange("是否开启渐变", Float) = 0.0
        [Tex(GroupHairInputs)]_BaseMap("主贴图", 2D) = "white" {}
        
        [Tex(GroupHairInputs)][Normal]_NormalMap("法线贴图", 2D) = "bump" {} 

        [Tex(GroupHairInputs)]_HairNosieMap("各项异性噪声贴图", 2D) = "white" {}
        
        [Sub(GroupHairInputs)]_NormalScale("法线强度", Range( 0 ,1)) = 1

        [ShowIf(_HairColorGradualChange, Equal, 0.0)]
        [Sub(GroupHairInputs)]_MainColor("头发颜色", Color) = (0.3,0.3,0.3,1)

        [ShowIf(_HairColorGradualChange, Equal, 1.0)]
        [Sub(GroupHairInputs)]_HairRootColor("发根颜色", Color) = (0,0,0,1)
        [ShowIf(_HairColorGradualChange, Equal, 1.0)]
        [Sub(GroupHairInputs)]_HairMiddleColor("发中颜色", Color) = (0,0,0,1)
        [ShowIf(_HairColorGradualChange, Equal, 1.0)]
        [Sub(GroupHairInputs)]_HairTipColor("发尾颜色", Color) = (0,0,0,1)

        [ShowIf(_HairColorGradualChange, Equal, 1.0)]
        [Sub(GroupHairInputs)]_HairMiddleRadius("发中范围", Range( 0 ,1)) = 0.5
        [ShowIf(_HairColorGradualChange, Equal, 1.0)]
        [Sub(GroupHairInputs)]_HairTipRadius("发梢范围", Range( 0 ,1)) = 0.5
        [ShowIf(_HairColorGradualChange, Equal, 1.0)]
        [Sub(GroupHairInputs)]_HairGradualTranstion("渐变过渡", Range( 0 ,1)) = 0.5
        

        [Sub(GroupHairInputs)][Title(GroupTitle,SpecularLightSettings, 32)] 
        [Sub(GroupHairInputs)]_Noise("打乱各项异性高光", Range( 0,1)) = 0.2
        [Sub(GroupHairInputs)]_NoiseTiling("各项异性高光密集度", Range( 0,5)) = 1
        [Sub(GroupHairInputs)]_Metallic("金属度", Range( 0 ,1)) = 0
        [Sub(GroupHairInputs)]_Roughness("粗糙度", Range( 0 ,1)) = 0.8

        [Sub(GroupHairInputs)][Title(GroupTitle,SpecularLight1, 32)] 
        [AdvancedHeaderProperty][Sub(GroupHairInputs)]_LightColor1("高光颜色", Color) = (0.5,0.5,0.5,1)
        [Advanced][Sub(GroupHairInputs)]_LightStrength1("高光强度", Range( 0 ,5)) = 1
        [Advanced][Sub(GroupHairInputs)]_LightExponent1("高光范围", Range( 0 ,1000)) = 1000
        [Advanced][Sub(GroupHairInputs)]_LightPosition1("高光移动", Range( 0 ,3)) = 0

        [Sub(GroupHairInputs)][Title(GroupTitle,SpecularLight2, 16)] 
        [AdvancedHeaderProperty][Sub(GroupHairInputs)]_LightColor2("高光2颜色", Color) = (0.2,0.2,0.2,1)
        [Advanced][Sub(GroupHairInputs)]_LightStrength2("高光2强度", Range( 0 ,5)) = 1
        [Advanced][Sub(GroupHairInputs)]_LightExponent2("高光2范围", Range( 0 ,1000)) = 600
        [Advanced][Sub(GroupHairInputs)]_LightPosition2("高光2移动", Range( 0 ,3)) = 0

        

        [Sub(GroupHairInputs)][Title(GroupTitle,SSS, 32)] 
        [Sub(GroupHairInputs)]_ScatterIntensity("SSS强度", Range( 0 ,1)) = 0.2
        [Sub(GroupHairInputs)]_ScatterResult("SSS效果", Range( 0 ,1)) = 1

        [Sub(GroupHairInputs)][Title(GroupTitle,Shadow, 32)] 
        [Sub(GroupHairInputs)]_Shadow("接受阴影强度", Range( 0 ,1)) = 0.8
        [Sub(GroupHairInputs)]_SelfShadow("自阴影强度", Range( 0 ,1)) = 1

        [Sub(GroupHairInputs)][Title(GroupTitle,Cutoff, 32)] 
        [Sub(GroupHairInputs)]_Cutoff("头发稀疏", Range( 0 ,5)) = 2.2

        [Main(GroupStencilOptions, _, off, on)] _EnableGroupStencilOptions("模版设置(Stencil Options)", Float) = 0
		[Sub(GroupStencilOptions)] _stencilRef("Stencil Ref", Float) = 0
		[Sub(GroupStencilOptions)] _stencilReadMask("Stencil ReadMask", Float) = 255
		[Sub(GroupStencilOptions)] _stencilWriteMask("Stencil WriteMask", Float) = 255
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 8
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.StencilOp)] _StencilPassOp("Stencil Pass Op", Float) = 0
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.StencilOp)] _StencilFailOp("Stencil Fail Op", Float) = 0
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.StencilOp)] _StencilZFailOp("Stencil ZFail Op", Float) = 0

        [Main(GroupAdvancedOptions, _, off, off)] _EnableGroupAdvancedOptions("进阶设置(Advanced Options)", Float) = 0
        [SubEnum(GroupAdvancedOptions, HeightFog, 0, CustomHeightFog, 1)] _FogMode ("Fog Mode", Float) = 0
		[ShowIf(_FogMode, Equal,1)]
		[Sub(GroupAdvancedOptions)] _FogIntensity ("FogIntensity", Range(0.0, 1.0)) = 0.5

        [SubToggle(GroupAdvancedOptions,_RECEIVE_URP_SHADOW)] _receiveURPShadow("Enable Urp Shadow",Float) = 0
        [SubToggle(GroupAdvancedOptions, _FAKE_SHADOW)] _fakeShadow("接收假阴影(Enable Fake Shadow)", Float) = 0
        [SubToggle(GroupAdvancedOptions, _CHARACTER_AMBIENT_COLOR)] _EnableCharacterAmbientColor("启用角色环境色(CharacterAmbientColor)", Float) = 0

        [HideInInspector] _ZWrite("__zw", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 5.0
        [HideInInspector] _DstBlend("__dst", Float) = 10.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 10.0
        [HideInInspector] _Surface("__surface", Float) = 1.0

    }


    SubShader
    {
        HLSLINCLUDE
    	// UTDefine.hlsl存储了管线的全局定义，用于方便全局切换管线功能及特性
		#include "../../../Lib/UTDefine.hlsl"
    	ENDHLSL
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags
        {
            "Queue"="Transparent"
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }
        LOD 300
      


        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        //第一个pass，用于绘制不透明，写入深度，深度检测为less。
        Pass
        {
            Name "DepthOnlyFirst"
            ZWrite On
            ColorMask 0
            Cull [_Cull]

            Stencil
			{
				Ref [_stencilRef]
				ReadMask  [_stencilReadMask]
				WriteMask [_stencilWriteMask]
				Comp [_StencilComp]
				Pass [_StencilPassOp]
				Fail [_StencilFailOp]
				ZFail [_StencilFailOp]
			}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

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

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(Varyings i) : SV_Target
            {
                float4 texColor = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, i.uv);
                clip(texColor.a - 0.5);
                return float4(0, 0, 0, 0);
            }
            ENDHLSL
        }

        //第二个pass，半透明渲染，，深度写入，深度检测为less，启用深度写入可以防止不正确的深度顺序。
        
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
           
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            // -------------------------------------
            // Render State Commands
            //Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            Blend[_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            ZWrite [_ZWrite]
            ZTest LEqual
            Cull [_Cull]
            AlphaToMask[_AlphaToMask]

            Stencil
			{
				Ref [_stencilRef]
				ReadMask  [_stencilReadMask]
				WriteMask [_stencilWriteMask]
				Comp [_StencilComp]
				Pass [_StencilPassOp]
				Fail [_StencilFailOp]
				ZFail [_StencilFailOp]
			}

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON _ALPHAMODULATE_ON

            // -------------------------------------
            // UT Pipeline keywords
            #if UT_RENDERING
            #pragma multi_compile _ _FAKE_SHADOW
            #pragma shader_feature_local_fragment _CHARACTER_AMBIENT_COLOR
            #pragma multi_compile_fragment _ _CUSTOM_SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ _RECEIVE_SELF_SHADOW _RECEIVE_ADDITIONAL_SELF_SHADOW2
            #pragma multi_compile _ _RECEIVE_ADDITIONAL_SELF_SHADOW
            #else 
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #endif

            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_ON
            

            #include "Assets/UT/Shaders/URP/Character/HairShader/HairLitInput.hlsl"
            #include "Assets/UT/Shaders/URP/Character/HairShader/HairLitForwardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #include "Assets/UT/Shaders/URP/Character/HairShader/HairLitInput.hlsl"
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
            };
            
            struct Varyings
            {
                float2 uv       : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
            };
            
            float4 GetShadowPositionHClip(Attributes input)
            {
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
            
            #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                float3 lightDirectionWS = normalize(_MainLightPosition.xyz - positionWS);
            #else
                float3 lightDirectionWS = _MainLightPosition.xyz;
            #endif
            
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
            
            #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #else
                positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #endif
            
                return positionCS;
            }
            
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
            
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
            
                output.positionCS = GetShadowPositionHClip(input);
                return output;
            }
            
            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                clip(SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).a - 0.5);
            
                #if defined(LOD_FADE_CROSSFADE)
                    LODFadeCrossFade(input.positionCS);
                #endif
            
                return 0;
            }

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ColorMask R
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON

            // -------------------------------------
            // Includes
            #include "Assets/UT/Shaders/URP/Character/HairShader/HairLitInput.hlsl"

            struct Attributes
            {
                float4 position     : POSITION;
                float2 texcoord     : TEXCOORD0;
            };
            
            struct Varyings
            {
                float2 uv       : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
            };
            
            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
            
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                return output;
            }
            
            half DepthOnlyFragment(Varyings input) : SV_TARGET
            {
            
                #if defined(_ALPHATEST_ON)
                    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, 0, _Cutoff);
                #else 
                    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, 0, 0);
                #endif
            
                return 0;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            #pragma shader_feature_local _ALPHATEST_ON

            // -------------------------------------
            // Includes
            #include "Assets/UT/Shaders/URP/Character/HairShader/HairLitInput.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float4 tangentOS    : TANGENT;
                float2 texcoord     : TEXCOORD0;
                float3 normal       : NORMAL;
                float4 uv           : TEXCOORD1;
            };
            
            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float2 uv          : TEXCOORD1;
                half3 normalWS     : TEXCOORD2;
                half4 tangentWS    : TEXCOORD3;    // xyz: tangent, w: sign
                float4 uvBump      : TEXCORRD4;
            };
            
            Varyings DepthNormalsVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
            
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS);
                output.normalWS = half3(normalInput.normalWS);
                float sign = input.tangentOS.w * float(GetOddNegativeScale());
                half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
                output.tangentWS = tangentWS;
                
                output.uvBump.xy = TRANSFORM_TEX(input.uv, _BaseMap);
                
                return output;
            }
            
            void DepthNormalsFragment(Varyings input, out half4 outNormalWS : SV_Target0)
            {
                #if defined(_ALPHATEST_ON)
                    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, smp)).a, _Color, _Cutoff);
                #endif
            
                float sgn = input.tangentWS.w; // should be either +1 or -1
                float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                float4 n = SAMPLE_TEXTURE2D(_NormalMap, smp, input.uvBump.xy);
                float3 normalTS= UnpackNormal(n) ;
                float3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
            
                outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
            }
            ENDHLSL
        }

        Pass
        {
	        Name "SelfShadowCaster"
		    Tags{"LightMode" = "SelfShadowCaster"}
		    
		    // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment SelfShadowPassFragment

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            
            #include "Assets/UT/Shaders/URP/Character/HairShader/HairLitInput.hlsl"
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
            };
            
            struct Varyings
            {
                float2 uv       : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
            };
            
            float4 GetShadowPositionHClip(Attributes input)
            {
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
            
            #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                float3 lightDirectionWS = normalize(_MainLightPosition.xyz - positionWS);
            #else
                float3 lightDirectionWS = _MainLightPosition.xyz;
            #endif
            
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
            
            #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #else
                positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #endif
            
                return positionCS;
            }
            
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
            
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
            
                output.positionCS = GetShadowPositionHClip(input);
                return output;
            }
            
            half4 SelfShadowPassFragment(Varyings input) : SV_TARGET
            {
            
                clip(SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).a - 0.5);

            
                return 0;
            }

            ENDHLSL
        }
        

        
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "LWGUI.LWGUI"
}

