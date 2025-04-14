Shader "URP/MoleGame/Effects/FASceneEffect"
{
	Properties
	{
	    //[Toggle(_APPLY_VOLUMETRIC_FOG_COLOR)]_Apply_Volumetric_Fog("Apply Volumetric Fog", Float) = 0
        //[Enum(MoleGame.Editor.TATools.TransparentFogBlendMode)]_Fog_Blend_Mode("Transparent Fog Blend Mode", Float) = 0
         [Preset(GroupPreset,Standard_RenderingPreset)] _RenderMode ("Rendering Mode", Float) = 0
		[Header(Base)]
		[Enum(CullMode)]_Cull("Cull Mode", Int) = 2
		[Enum(MoleGame.Editor.TATools.ZTest)]_ZTest("ZTest (Default: LessEqual)", Float) = 4
		[HideInInspector][MainColor]_Color("Color", Color) = (1,1,1,1)
		[HideInInspector][MainTexture]_MainTex("Main Texture", 2D) = "white" {}
		[HideInInspector][Enum(MoleGame.Editor.TATools.UVType)]_MainTex_UVType("Main Texture UV Type", float) = 0
		[HideInInspector][Toggle] _EnableDFlowMap("Enable DFlowMap", Float) = 0
		
		//MainTextue用FlowMap
		[HideInInspector]_DFlowMap("Flow Map ", 2D) = "grey" {}
		[HideInInspector]_DFlowTiling("Flow Tiling", vector) = (1,1,0,0)
		[HideInInspector]_DFlowSpeed("Flow Speed", float) = 5
		[HideInInspector]_DFlowIntensity("Flow Intensity", float) = 0.1

		[Header(Alpha Clip)]
		_Cutoff("Cutoff (Default: 0.5)", Range(0.0, 0.99)) = 0.5
		[Enum(UnityEngine.Rendering.CompareFunction)]_Comp("Comp",Float) = 8
		[Enum(UnityEngine.Rendering.StencilOp)]_Pass("Pass",Float) = 2
		_StenilRef("Stenil Ref", Float) = 0

		[Header(AO Metal Smoothness)]
		// AO贴图，R通道是AO，G通道是金属度，B通道是光滑度
		_CombinedAO("AO_Metal_Smoothness Texture" , 2D) = "white" {}
		[Enum(MoleGame.Editor.TATools.UVType)]_Smoothness_UVType("Smoothness Texture UV Type", float) = 0
		_SmoothnessTillingAndOffset("Smoothness Tilling And Offset", Vector) = (1,1,0,0)
		_CombinedScaledParams("AO_Metal_Smoothness Scaled", Vector) = (1.0,1.0,1.0,0.0)

		[Header(Ambient)]
		[Toggle] _UseCharacterAmbient("Use Character Ambient Color", Float) = 0
	    
		[HideInInspector]_FogMode("Fog Mode", Float) = 0
		[HideInInspector]_FogIntensity("Fog Intensity", Range(0.0, 1.0)) = 0.5

		// Blending State
		[HideInInspector]_Mode("__mode", Float) = 0.0
		[HideInInspector]_SrcBlend("__src", Float) = 1.0
		[HideInInspector]_DstBlend("__dst", Float) = 0.0
		[HideInInspector]_ZWrite("__zw", Float) = 1.0
		
		// Normals
		[HideInInspector][KeywordEnum(Single,Dual,FlowMap,Facet)]
		_NormalsMode("NormalsMode", Float) = 0

		[HideInInspector]_NormalMapA("Normal Map A", 2D) = "bump" {}
		[HideInInspector]_NormalMapATilings("Normal Map A: Tilings", vector) = (1,1,1,1)
		[HideInInspector]_NormalMapASpeeds("Normal Map A: Speeds", vector) = (1,1,0.5,0.5)
		[HideInInspector]_NormalMapAIntensity("Normal Map A: Intensity", Range(0,1)) = 1

		[HideInInspector]_NormalMapB("Normal Map B", 2D) = "bump" {}
		[HideInInspector]_NormalMapBTilings("Normal Map B: Tilings", vector) = (1,1,1,1)
		[HideInInspector]_NormalMapBSpeeds("Normal Map B: Speeds", vector) = (1,1,1,1)
		[HideInInspector]_NormalMapBIntensity("Normal Map B: Intensity", Range(0,1)) = 1

		[HideInInspector]_FlowMap("Flow Map ", 2D) = "grey" {}
		[HideInInspector]_FlowTiling("Flow Tiling", vector) = (1,1,0,0)
		[HideInInspector]_FlowSpeed("Flow Speed", float) = 5
		[HideInInspector]_FlowIntensity("Flow Intensity", float) = 0.1
		
		[HideInInspector][KeywordEnum(Off,Gerstner)]
		_DisplacementMode("Displacement: Mode", Float) = 0
		[HideInInspector]_WaveAmplitude("Amplitude", Range(0,1)) = 1
		[HideInInspector]_WaveNormal("Wave Normal", Range(0,1)) = 1
		[HideInInspector]_WaveEffectsBoost("Effect Boost", float) = 0
		[HideInInspector]_WaveCount("count", Range(1,3)) = 1
		[HideInInspector]_GerstnerWaveA("Direction, Steepness, WaveLength ", vector) = (1,0,0.05,4)
		[HideInInspector]_GerstnerSpeedA("Speed A", float) = 1
		[HideInInspector]_GerstnerWaveB("Direction, Steepness, WaveLength ", vector) = (0,1,0.05,4)
		[HideInInspector]_GerstnerSpeedB("Speed B", float) = 1
		[HideInInspector]_GerstnerWaveC("Direction, Steepness, WaveLength ", vector) = (1,0,0.05,4)
		[HideInInspector]_GerstnerSpeedC("Speed C", float) = 1
		[HideInInspector]_GerstnerWaveD("Direction, Steepness, WaveLength ", vector) = (1,0,0.05,4)
		[HideInInspector]_GerstnerSpeedD("Speed D", float) = 1
		
		
		
		
		

		[HideInInspector][Toggle(_NORMAL_FAR_ON)] _NormalFar("Enable Far Map", Float) = 0
		[HideInInspector]_NormalMapFar("Normal Map Far", 2D) = "bump" {}
		[HideInInspector]_NormalMapFarTilings("Normal Map Far: Tilings", vector) = (1,1,0.5,0.5)
		[HideInInspector]_NormalMapFarSpeeds("Normal Map Far: Speeds", vector) = (1,1,1,1)
		[HideInInspector]_NormalMapFarIntensity("Normal Map Far: Intensity", Range(0,1)) = 1
		[HideInInspector]_NormalFarDistance("Fade Distance", float) = 200
	    [Main(_URPShadowMappingSettingGroup)]_EnableURPShadowMapping("Can Receive URP Shadow? (Default On)", Float) = 1
	    
	}

	SubShader
	{
		Tags {
			"RenderType" = "Opaque"
			"RenderPipeline" = "UniversalPipeline"
		}
		LOD 300

		Pass
		{
			Name "StandardLit"
			//
			Tags { "LightMode" = "Scene" }

			Cull [_Cull]
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
			ZTest [_ZTest]
			Stencil
			{
				Ref [_StenilRef]
				Comp [_Comp]
				Pass [_Pass]
				//Comp always
				//Pass replace
			}

			HLSLPROGRAM

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0
            
            //#include "Assets/UnityPackages/VolumetricFog2/Shaders/CustomVolumetricFogUtils.hlsl"
            
			//#pragma multi_compile _ TRANSPARENT_FOG_ON
            //#pragma multi_compile_local _ _APPLY_VOLUMETRIC_FOG_COLOR
			// --------------------------------------
			// Material Keywords
			#pragma multi_compile _ _LOW_DETAIL
			#pragma multi_compile_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			// --------------------------------------
			// URP keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			
			#pragma multi_compile _ LIGHTMAP_ON
			
			#pragma shader_feature_local _NORMALSMODE_SINGLE _NORMALSMODE_DUAL _NORMALSMODE_FLOWMAP _NORMALSMODE_FACET
			#pragma shader_feature_local _NORMAL_FAR_ON
			#pragma shader_feature_local _DISPLACEMENTMODE_GERSTNER
			
			#pragma shader_feature _ _FORWARD_PLUS_Z_BINING
			
			#pragma vertex SceneEffectVertex
			#pragma fragment SceneEffectFragment

			#define NO_TPA
			#include "FASceneEffect-Input.hlsl"
			#include "FASceneEffect-Lib.hlsl"
			ENDHLSL
		}

//		Pass
//		{
//			Name "ShadowCaster"
//			Tags{"LightMode" = "ShadowCaster"}
//
//			ZWrite On
//			ZTest LEqual
//			ColorMask 0
//
//			HLSLPROGRAM
//			#pragma prefer_hlslcc gles
//			#pragma exclude_renderers d3d11_9x
//			#pragma target 2.0
//
//			//--------------------------------------
//			// GPU Instancing
//			#pragma multi_compile_instancing
//
//			// -------------------------------------
//			// Material Keywords
//			#pragma shader_feature_local_fragment _ALPHATEST_ON
//			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
//
//			#pragma vertex ShadowPassVertex
//			#pragma fragment ShadowPassFragment
//			#define NO_TPA
//
//			#include "FASceneEffect-Input.hlsl"
//			#include "../Lib/FAShadowCasterPass.hlsl"
//			ENDHLSL
//		}

		Pass
		{
			Name "DepthOnly"
			Tags{"LightMode" = "DepthOnly"}

			ZWrite On
			ColorMask 0

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
			#define NO_TPA

			#include "FASceneEffect-Input.hlsl"
			#include "../FALib/FADepthOnlyPass.hlsl"
			ENDHLSL
		}
	}
	

	 CustomEditor "LWGUI.LWGUI"
}
