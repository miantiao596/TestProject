Shader "URP/MoleGame/Effects/Glass"
{
	Properties
	{
		 [Preset(GroupPreset,Standard_RenderingPreset)] _RenderMode ("Rendering Mode", Float) = 0
		[Header(Albedo)]
		_Cutoff("Alpha Cutoff", Range(0.0, 0.99)) = 0.5
		[MainColor]_Color("Color", Color) = (1,1,1,1)
		[MainTexture]_MainTex("Main Texture", 2D) = "white" {}
		//[Toggle]_ALPHAPREMULTIPLY_ON("Alpha Premultiply(Default:Off)", float) = 0

		[Header(AO METAL SMOOTHNESS)]
		// AO贴图，R通道是AO，G通道是金属度，B通道是光滑度
		_CombinedAO("AO_Metal_Smoothness Texture" , 2D) = "white" {}
		_CombinedScaledParams("AO_Metal_Smoothness Scaled", Vector) = (1.0,1.0,1.0,0.0)
        
        [Header(THICKNESS)]
        _ThicknessTex("Thickness Texture", 2D) = "white"{}
        _EdgeThickness("Edge Thickness", range(0,1.0)) = 0.2
		_RefIntensity("Reflection Intensity", range(0,1.0))=0.1
        
        [Header(NORMAL)]
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Float) = 1.0

		// Blending State
		[HideInInspector]_Mode("__mode", Float) = 0.0
		[HideInInspector]_SrcBlend("__src", Float) = 1.0
		[HideInInspector]_DstBlend("__dst", Float) = 0.0
		[HideInInspector]_ZWrite("__zw", Float) = 1.0
		
		//[HideInInspector]_ReflectionTex("Internal Reflection", 2D) = "" {}
		//[HideInInspector]_Reflection("__refl", Float) = 0.0
		//[HideInInspector]_ReflPower("Reflection Power", Range(0, 1)) = 0
		
		[HideInInspector]_DitherOpacity("Dither Opacity", Range(0, 1)) = 1

		// For SRP Batcher compatibility only

		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		_Emissive_Intensity("Emissive Intensity", Range(0.0,100.0)) = 0.0
		[HideInInspector]_FogMode("Fog Mode", Float) = 1.0
		[HideInInspector]_FogIntensity("Fog Intensity", Range(0.0,1.0)) = 0.5
//		// 自阴影设置
//		[HideInInspector][Main(_SelfShadowMappingSettingGroup,_)]_EnableSelfShadowMapping("Can Receive Self Shadow? (Default On)", Float) = 0
//		[HideInInspector][Sub(_SelfShadowMappingSettingGroup)]_SelfShadowIntensity("_SelfShadowIntensity(Default 1)", Range(0,1)) = 0.85
//		[HideInInspector][Sub(_SelfShadowMappingSettingGroup)]_SelfShadowMappingDepthBias("_SelfShadowMappingDepthBias(Default 0)", Range(0,0.2)) = 0
//	    [HideInInspector][Main(_URPShadowMappingSettingGroup)]_EnableURPShadowMapping("Can Receive URP Shadow? (Default On)", Float) = 1
//	    
	    // 菲尼尔
//		[HideInnspector] _EnableFresnel("Fresnel (Default Off)", Float) = 0
//        [HideInInspector][HDR] _FresnelOriginalColor("Fresnel Color", Color) = (0,0,0,1) 
//        [HideInInspector] _FresnelOriginalPower("Fresnel Power", Float) = 0
//        [HideInInspector]_FresnelOriginalScale("Fresnel Scale", Float) = 0
//		
//		[HideInInspector][Toggle] _IgnoreMainShadowAtten("Ignore MainShadowAtten", Int) = 0
//		[HideInInspector]_EnvironmentReflectionIntensity("_Environment Reflection Intensity", Range(0.0, 1.0)) = 1.0

        // for srp Batcher
        [HideInInspector]_TPA("__TPA", Float) = 1.0
        
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
		Tags {
			"RenderType" = "Opaque"
			"RenderPipeline" = "UniversalPipeline"
		}
		LOD 300

		HLSLINCLUDE

		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
		TEXTURE2D(_MainTex);				SAMPLER(sampler_MainTex);
		TEXTURE2D(_CombinedAO);				SAMPLER(sampler_CombinedAO);
		CBUFFER_START(UnityPerMaterial)
		float4 _BumpMap_ST;
	    half _BumpScale;
	        
	    half _FogMode;
		half _FogIntensity;
    
		half _Cutoff;
		sampler2D _ThicknessTex;
		float4 _ThicknessTex_ST;
		half _EdgeThickness;
		half _RefIntensity;
		half _DitherOpacity;
		float4 _MainTex_ST;
	    float4 _CombinedAO_ST;
	    half4 _CombinedScaledParams;
	    half4 _Color;
		half4 _EmissionColor;
		half _Emissive_Intensity;
		CBUFFER_END

		ENDHLSL

		Pass
		{
			Name "StandardLit"
			Tags { "LightMode" = "Scene" }

			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
			
			//跳过TAA处理的Mask
            Stencil {
                Ref [_TAAStencil]
                WriteMask [_TAAStencilMask]
                Comp always
                Pass [_TAAStencilPassOperate]
            }

			HLSLPROGRAM

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			// --------------------------------------
			// Material Keywords
			#pragma multi_compile_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			// --------------------------------------
			// URP keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			//#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			//#pragma multi_compile _ _ADDITIONAL_LIGHTS
			//#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			//#pragma multi_compile _ _CUSTOM_SCREEN_SPACE_OCCLUSION
			//#pragma multi_compile _ _FORWARD_PLUS

			// -------------------------------------
			// Unity defined keywords
			//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			// #pragma multi_compile_fog

			//#pragma multi_compile_local _ USE_EXTRA_EMISSION_TEXTURE
			//#pragma multi_compile _ _REFLECTION_ON _REAL_TIME_REFLECTION_ON
			#pragma shader_feature _ _FORWARD_PLUS_Z_BINING


			#pragma vertex LitPassVertexCustom
			#pragma fragment LitPassFragmentCustom

			#include "Glass.hlsl"

			ENDHLSL
		}

		Pass
		{
			Name "DepthOnly"
			Tags{"LightMode" = "DepthOnly"}

			ZWrite On
			ColorMask 0
			Cull[_Cull]

			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			//--------------------------------------
			// GPU Instancing
			//#pragma multi_compile_instancing

			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			#include "../FALib/FADepthOnlyPass.hlsl"
			ENDHLSL
		}

		Pass
		{
			Name "DepthNormals"
			Tags{"LightMode" = "DepthNormals"}

			ZWrite On
			Cull[_Cull]

			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			#pragma vertex DepthNormalsVertex
			#pragma fragment DepthNormalsFragment

			// -------------------------------------
			// Material Keywords
			//#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			//#pragma multi_compile_instancing

			#include "../FALib/FADepthNormalsPass.hlsl"
			ENDHLSL
		}
	}

 CustomEditor "LWGUI.LWGUI"

}