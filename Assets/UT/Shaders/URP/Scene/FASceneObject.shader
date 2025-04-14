Shader "URP/MoleGame/Scene/FASceneObject"
{
	Properties
	{
	    //[Toggle(_APPLY_VOLUMETRIC_FOG_COLOR)]_Apply_Volumetric_Fog("Apply Volumetric Fog", Float) = 0
        //[Enum(MoleGame.Editor.TATools.TransparentFogBlendMode)]_Fog_Blend_Mode("Transparent Fog Blend Mode", Float) = 0
        [Preset(GroupPreset,FASceneObjectPreset)] _Mode ("Rendering Mode", Float) = 0	
        //所有参数在TestPreset里，仅引用		
        [SubEnum(_, HeightFog, 0, CustomHeightFog, 1)] _FogMode ("Fog Mode", Float) = 0
		[ShowIf(_FogMode, Equal,1)]
		[Sub] _FogIntensity ("FogIntensity", Range(0.0, 1.0)) = 0.5
		//根据UniversalShaderGUI改写，_FogMode=0的时候用计算的强度，_FogMode=1的时候用设置的强度
		//_FogMode=0  _FogIntensity不显示
		
		[Header(Base)]
		[Enum(CullMode)]_Cull("Cull Mode", Int) = 2
		[Enum(MoleGame.Editor.TATools.ZTest)]_ZTest("ZTest (Default: LessEqual)", Float) = 4
		[MainColor]_Color("Color", Color) = (1,1,1,1)
		[MainTexture]_MainTex("Main Texture", 2D) = "white" {}
	    [Preset(_,UVType)] _UVType ("MainTex&Smoothness  UV Type", Float) = 0	
		[ShowIf(_UVType, Equal, 3)]
	    [Sub(_HeightGradientGroup)][Enum(MoleGame.Editor.TATools.Direction)]_WorldPos_Dir2("MainTex&Smoothness Texture  Direction", float) = 0	
		[ShowIf(_UVType, Equal, 3)]
		_PositionWSUV_ST("PositionWSUV ST", Vector) = (1.0,1.0,0.0,0.0)//世界空间的UV的总偏移缩放
		//[Enum(MoleGame.Editor.TATools.UVType)]_MainTex_UVType("Main Texture UV Type", float) = 0
		//_MainTex_UVType  _Smoothness_UVType
		[Header(Alpha Clip)]
		_Cutoff("Cutoff (Default: 0.5)", Range(0.0, 0.99)) = 0.5
		[Enum(UnityEngine.Rendering.CompareFunction)]_Comp("Comp",Float) = 8
		[Enum(UnityEngine.Rendering.StencilOp)]_Pass("Pass",Float) = 2
		_StenilRef("Stenil Ref", Float) = 0

		[Header(AO Metal Smoothness)]
		// AO贴图，R通道是AO，G通道是金属度，B通道是光滑度
		_CombinedAO("AO_Metal_Smoothness Texture" , 2D) = "white" {}
		//[Enum(MoleGame.Editor.TATools.UVType)]_Smoothness_UVType("Smoothness Texture UV Type", float) = 0
		//[Preset(_,SmoothnessUVType)] _Smoothness_UVType ("Smoothness Texture UV Type", Float) = 0	
		_SmoothnessTillingAndOffset("Smoothness Tilling And Offset", Vector) = (1,1,0,0)
		_CombinedScaledParams("AO_Metal_Smoothness Scaled", Vector) = (1.0,1.0,1.0,0.0)

		[Header(Ambient)]
		[Toggle] _UseCharacterAmbient("Use Character Ambient Color", Float) = 0

		[Header(BakeGI)]
		[Main(_ShadowMaskGroup)]_DIASBLESHADOWMASK("Use Realtime Shadowmap After Baking", Float) = 0

		[Header(Emission)]
		[Toggle]_MainTexAsEmissionTex("Main Texture As Emission Texture", Float) = 0
		_Emissive_Intensity("Emissive Intensity", Range(0.0,100.0)) = 0.0
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		[Main(_EmissionTextureGroup)]_Enable_EmissionTex("自发光/Mask调色		(Default: Off)", Float) = 0
		[Sub(_EmissionTextureGroup)]_EmissionTexture("Emission Texture", 2D) = "black" {}
		[SubToggle(_EmissionTextureGroup)]_UseEmissionAlphaMask("Use Emission Alpha Mask", float) = 0
		[Sub(_EmissionTextureGroup)]_EmissionMaskColor("Emission Mask Color", Color) = (1,1,1,1)
		[Sub(_EmissionTextureGroup)]_EmissionMaskColorIntensity("Emission Mask Color Intensity", Float) = 1

		[Header(Normal)]
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Normal Scale", Float) = 1.0
		[Main(_Normal2Group)]_Enable_NormalAdd("Normal Add			(Default: Off)", Float) = 0
		[Sub(_Normal2Group)]_BumpMap2("Normal2 Map", 2D) = "bump" {}
		[Sub(_Normal2Group)]_BumpScale2("Normal2 Scale", Float) = 1.0


	    //[HideInInspector]_FogMode("Fog Mode", Float) = 0
		//[HideInInspector]_FogIntensity("Fog Intensity", Range(0.0, 1.0)) = 0.5

		// Blending State
		//[HideInInspector]_Mode("__mode", Float) = 0.0
		[HideInInspector]_SrcBlend("__src", Float) = 1.0
		[HideInInspector]_DstBlend("__dst", Float) = 0.0
		[HideInInspector]_ZWrite("__zw", Float) = 1.0

		// 镜面反射
		//[HideInInspector]_ReflectionTex("Internal Reflection", 2D) = "" {}
		//[HideInInspector]_Reflection("__refl", Float) = 0.0
		//[HideInInspector]_ReflPower("Reflection Power", Range(0, 1)) = 0

		// 脏迹	
		[Main(_DirtGroup)]_Dirt("Dirt				(Default: Off)", Float) = 0
		[Sub(_DirtGroup)]_DirtColor("Dirt Color", Color) = (1,1,1,1)
		[Sub(_DirtGroup)]_DirtTex("Dirt Texture", 2D) = "white" {}
		// [Sub(_DirtGroup)]_DirtCombinedScaledParams("Dirt Scaled_AO_Metal_Smooth", Vector) = (1.0,1.0,1.0,0.2)
		// [Sub(_DirtGroup)]_DirtCombinedAO("Dirt AO_Metal_Smoothness", 2D) = "white" {}
		[Sub(_DirtGroup)]_DirtMetal("Dirt Metal", Float) = 1.0
		[Sub(_DirtGroup)]_DirtSmoothness("Dirt Smoothness", Float) = 1.0
		[Sub(_DirtGroup)]_DirtBumpMap("Dirt Normal Map", 2D) = "bump" {}
		[Sub(_DirtGroup)]_DirtBumpScale("Dirt Normal Scale", Float) = 1.0
		// [Sub(_DirtGroup)]_DirtMaskTex("Dirt Mask Texture", 2D) = "white" {}

		// 顶部细节
		[Main(_TopDetailGroup, _TOPDETAIL_ON)]_TopDetail_On("Top Detail			(Default: Off)", Float) = 0
		[Sub(_TopDetailGroup)]_TopColor("Top Color", Color) = (1,1,1,1)
		[Sub(_TopDetailGroup)]_TopTex("Top Texture", 2D) = "white" {}
		// [Sub(_TopDetailGroup)]_TopCombinedScaledParams("Top Scaled_AO_Metal_Smooth", Vector) = (1.0,1.0,1.0,0.2)
		// [Sub(_TopDetailGroup)][NoScaleOffset]_TopCombinedAO("Top AO_Metal_Smoothess" , 2D) = "white" {}
		[Sub(_TopDetailGroup)]_TopMetal("Top Metal", Float) = 1.0
		[Sub(_TopDetailGroup)]_TopSmoothness("Top Smoothness", Float) = 1.0
		[Sub(_TopDetailGroup)][NoScaleOffset]_TopBumpMap("Top Normal Map", 2D) = "bump" {}
		[Sub(_TopDetailGroup)]_TopBumpScale("Top Normal Scale", Float) = 1.0
		// [Sub(_TopDetailGroup)]_TopMaskTex("Top Mask Texture", 2D) = "white" {}
		[SubToggle(_TopDetailGroup)]_TopMaskTex_UseUV2("Top Mask Texture 2 With UV2", float) = 0

		[Sub(_TopDetailGroup)]_TopIntensity("Top Intensity", Range(0, 1)) = 0
		[Sub(_TopDetailGroup)]_TopPower("Top Power", Float) = 1
		[Sub(_TopDetailGroup)]_TopOffset("Top Offset", Range(0, 1)) = 0

		// 溶解
		[Main(_DissolveGroup)]_DISSOLVE("Dissolve			(Default: Off)", Float) = 0
		[Sub(_DissolveGroup)]_DissolvePercent("Dissolve Percent", Range(0,1)) = 0
		[Sub(_DissolveGroup)]_DissolveMask("Dissolve Mask", 2D) = "white" {}
		[Sub(_DissolveGroup)][Enum(MoleGame.Editor.TATools.ColorChannel)]_DissolveMask_ChannelMask("Dissolve Texture Channel Mask (Default: R)", Float) = 0
		[Sub(_DissolveGroup)]_DissolveMaskTex_UseUV2("Dissolve Mask UV Type[UV1:0, UV2:1, WorldPosition:2] ", float) = 0
		[Sub(_DissolveGroup)][Enum(MoleGame.Editor.TATools.Direction)]_DissolveMaskTex_Dir("Main Texture Sample Direction", float) = 0
        //[Sub(_DissolveGroup)]_DissolveMaskTex_Range("W_Start-W_End-H_Start-H_End", Vector) = (0,0,0,0)
		[Sub(_DissolveGroup)]_DissolveMaskTex_Range_X("Dissolve Mask Texture Range X Start", Float) = 0
		[Sub(_DissolveGroup)]_DissolveMaskTex_Range_Y("Dissolve Mask Texture Range Y Start", Float) = 0
		[Sub(_DissolveGroup)]_DissolveMaskTex_Range_Z("Dissolve Mask Texture Range Z Start", Float) = 0
		[Sub(_DissolveGroup)]_DissolveMaskTex_Range_W("Dissolve Mask Texture Range W Start", Float) = 0
		[Sub(_DissolveGroup)]_RampMask("Ramp Mask", 2D) = "white" {}
		[RGBAChannelMaskToVec4(_DissolveGroup)]_RampMask_ChannelMask("Ramp Texture Channel Mask (Default: RGB)", Vector) = (1,1,1,0)
		[Sub(_DissolveGroup)]_EdgeColorLength("EdgeColor Length", Range(0,1)) = 0.079
		[Sub(_DissolveGroup)][HDR]_EdgeColor("Edge Color", Color) = (1.8588,0.3698,0.2628,1)
		//[SubToggle(_DissolveGroup)]_SoftDissolve("Soft Dissolve", float) = 0

		// Mask UV2
		[Main(_MaskUV2Group)]_MASK_UV2("Mask UV2			(Default: Off)", Float) = 0
		[Sub(_MaskUV2Group)]_UV2Mask("UV2 Mask", 2D) = "white" {}
        [Sub(_MaskUV2Group)][Enum(MoleGame.Editor.TATools.ColorChannel)]_MASK_UV2_ChannelMask("Mask UV2 Texture Channel Mask (Default: R)", Float) = 0

	    // 菲尼尔
//	    [HideInnspector] _EnableFresnel("Fresnel (Default Off)", Float) = 0
//        [HideInInspector][HDR] _FresnelOriginalColor("Fresnel Color", Color) = (0,0,0,1) 
//        [HideInInspector] _FresnelOriginalPower("Fresnel Power", Float) = 0
//        [HideInInspector] _FresnelOriginalScale("Fresnel Scale", Float) = 0
        
		// Height Gradient
		[Main(_HeightGradientGroup, _HEIGHTGRADIENT_ON)]_HeightGradient_On("Height Gradient			(Default: Off)", Float) = 0
		[SubToggle(_HeightGradientGroup)][Enum(MoleGame.Editor.TATools.UVType)]_HeightGradientUVType("Height Gradient UVType", Float) = 1 
		[SubToggle(_HeightGradientGroup)][Enum(MoleGame.Editor.TATools.Direction)]_WorldPos_Dir("Height Gradient Texture Sample Direction", float) = 0
		[SubToggle(_HeightGradientGroup)]_CoordinateRange("W_Start-W_End-H_Start-H_End", Vector) = (0,0,0,0)
        [Sub(_HeightGradientGroup)]_HeightGradientColor("Height Gradient Color", Color) = (1,1,1,1)
        [Sub(_HeightGradientGroup)]_HeightGradientMaskTex("Height Gradient Mask Texture", 2D) = "white"{}
        [RGBAChannelMaskToVec4(_HeightGradientGroup)]_HeightGradientMaskTex_ChannelMask("Hight Gradient Texture Channel Mask (Default: RGBA)", Vector) = (1,1,1,1)
        [Sub(_HeightGradientGroup)]_HeightGradientIntensity("Height Gradient Intensity", Float) = 0
		
		// 自阴影设置
//		[HideInInspector][Main(_SelfShadowMappingSettingGroup,_)]_EnableSelfShadowMapping("Can Receive Self Shadow? (Default On)", Float) = 0
//		[HideInInspector][Sub(_SelfShadowMappingSettingGroup)]_SelfShadowIntensity("_SelfShadowIntensity(Default 1)", Range(0,1)) = 0.85
//		[HideInInspector][Sub(_SelfShadowMappingSettingGroup)]_SelfShadowMappingDepthBias("_SelfShadowMappingDepthBias(Default 0)", Range(0,0.2)) = 0
	    [Main(_URPShadowMappingSettingGroup)]_EnableURPShadowMapping("Can Receive URP Shadow? (Default On)", Float) = 1

//		[HideInInspector][Toggle] _IgnoreMainShadowAtten("Ignore MainShadowAtten", Int) = 0
//		[HideInInspector]_EnvironmentReflectionIntensity("_Environment Reflection Intensity", Range(0.0, 1.0)) = 1.0
		
		// for srp Batcher
		//[HideInInspector]_TPA("__TPA", Float) = 1.0

		[Main(_PlanarReflectionGroup, _PLANARREFLECTION)]_Enable_PlanarReflection("平面反射(Default: Off)", Float) = 0
		[Sub(_PlanarReflectionGroup)]_DistortionIntensity_U("Reflection DistortionIntensity_U", Float) = 0
		[Sub(_PlanarReflectionGroup)]_DistortionIntensity_V("Reflection DistortionIntensity_V", Float) = 0
		[Sub(_PlanarReflectionGroup)][HDR]_ReflectionColor("Reflection Color", Color) = (1,1,1,1)
		[Sub(_PlanarReflectionGroup)]_ReflectionIntensity("Reflection Intensity", Float) = 1
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
			// Tags { "LightMode" = "Scene" }

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
            
			//#pragma multi_compile _ TRANSPARENT_FOG_ON
            //#pragma multi_compile_local _ _APPLY_VOLUMETRIC_FOG_COLOR
			// --------------------------------------
			// Material Keywords
			#pragma multi_compile _ _LOW_DETAIL
			#pragma multi_compile_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			#pragma shader_feature_local_fragment _ _PLANARREFLECTION
			#pragma multi_compile_local_fragment _ _DIASBLESHADOWMASK_ON
			
			// --------------------------------------
			// URP keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _RECEIVE_SELF_SHADOW _RECEIVE_ADDITIONAL_SELF_SHADOW2
            #pragma multi_compile _ _RECEIVE_ADDITIONAL_SELF_SHADOW
			//#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			//#pragma multi_compile _ _ADDITIONAL_LIGHTS
			//#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _CUSTOM_SCREEN_SPACE_OCCLUSION
			//#pragma multi_compile _ _FORWARD_PLUS
			
			// -------------------------------------
			// Unity defined keywords
			//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			// #pragma multi_compile_fog

			#pragma multi_compile_local _ _ENABLE_EMISSIONTEX_ON	
			// #pragma multi_compile_local _ _REFLECTION_ON _REAL_TIME_REFLECTION_ON
			#pragma multi_compile_local _ _DIRT_ON
			#pragma multi_compile_local _ _TOPDETAIL_ON
			#pragma multi_compile_local _ _DISSOLVE_ON
			#pragma multi_compile_local _ _MASK_UV2_ON
			#pragma multi_compile_local _ _ENABLE_NORMALADD_ON
			#pragma multi_compile_local _ _HEIGHTGRADIENT_ON
			#pragma multi_compile _ _PIXELFOG_ON
			#pragma shader_feature _ _FORWARD_PLUS_Z_BINING

			#pragma shader_feature _ _POSWSUV_ON


			#pragma multi_compile_local _ _UT_INSTANCING_ON

			#pragma vertex SceneObjectVertex
			#pragma fragment SceneObjectFragment

			#define NO_TPA

			#include "FASceneObject-Input.hlsl"
			#include "FASceneObject-Lib.hlsl"
			ENDHLSL
		}

		Pass
		{
			Name "ShadowCaster"
			Tags{"LightMode" = "ShadowCaster"}

			ZWrite On
			ZTest LEqual
			ColorMask 0

			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			//--------------------------------------
			// GPU Instancing
			//#pragma multi_compile_instancing

			// -------------------------------------
			// Material Keywords
			#pragma multi_compile_local _ _UT_INSTANCING_ON
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			
			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment
			#define NO_TPA

			#include "FASceneObject-Input.hlsl"
			#include "../FALib/FAShadowCasterPass.hlsl"
			ENDHLSL
		}

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
			#pragma multi_compile_local _ _UT_INSTANCING_ON
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#define NO_TPA

			#include "FASceneObject-Input.hlsl"
			#include "../FALib/FADepthOnlyPass.hlsl"
			ENDHLSL
		}

		Pass
		{
			Name "DepthNormals"
			Tags{"LightMode" = "DepthNormals"}

			ZWrite On

			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			#pragma vertex DepthNormalsVertex
			#pragma fragment DepthNormalsFragment

			// -------------------------------------
			// Material Keywords
			#pragma multi_compile_local _ _UT_INSTANCING_ON
			#pragma shader_feature_local _NORMALMAP ON
			
			//#pragma multi_compile _NORMALMAP_NONE _NORMALMAP_ADD _NORMALMAP_MULTIPLY
			#pragma multi_compile_local _ _ENABLE_NORMALADD_ON

			#pragma shader_feature_local_fragment _ALPHATEST_ON
			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			//#pragma multi_compile_instancing
			#define NO_TPA

			#include "FASceneObject-Input.hlsl"
			#include "../FALib/FADepthNormalsPass.hlsl"

			ENDHLSL
		}

	}

	CustomEditor "LWGUI.LWGUI"
}
