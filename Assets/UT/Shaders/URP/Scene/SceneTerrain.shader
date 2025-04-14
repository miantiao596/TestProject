Shader "URP/MoleGame/Scene/SceneTerrain"
{
	Properties
	{
	    //[Toggle(_APPLY_VOLUMETRIC_FOG_COLOR)]_Apply_Volumetric_Fog("Apply Volumetric Fog", Float) = 0
        //[Enum(MoleGame.Editor.TATools.TransparentFogBlendMode)]_Fog_Blend_Mode("Transparent Fog Blend Mode", Float) = 0
        
		[Main(GroupSurfaceOptions, _, on, off)] _EnableGroupSurfaceOptions("基础设置(Surface Options)", Float) = 1
		[SubEnum(GroupSurfaceOptions, Both, 0, Back, 1, Front, 2)] _Cull("Render Face", Int) = 2
		[Sub(GroupSurfaceOptions)]_Cutoff("Cutoff (Default: 0.5)", Range(0.0, 0.99)) = 0.5
		[SubEnum(GroupSurfaceOptions, UnityEngine.Rendering.CompareFunction)] _Comp("Comp",Float) = 8
		[SubEnum(GroupSurfaceOptions, UnityEngine.Rendering.StencilOp)] _Pass("Pass",Float) = 2
		[Sub(GroupSurfaceOptions)] _StenilRef("Stenil Ref", Float) = 0
		[SubEnum(_, HeightFog, 0, CustomHeightFog, 1)] _FogMode ("Fog Mode", Float) = 0
		[ShowIf(_FogMode, Equal,1)]
		[Sub] _FogIntensity ("FogIntensity", Range(0.0, 1.0)) = 0.5
		
		//待去掉
		[HideInInspector]_Color("Color", Color) = (1,1,1,1)
		[HideInInspector]_MainTex("Main Texture", 2D) = "white" {}
		[HideInInspector]_MainTex_UVType("Main Texture UV Type", float) = 0
		
		[Space]
		[Main(GroupSurfaceInputs, _, on, off)] _EnableGroupSurfaceInputs("贴图设置(Surface Inputs)", Float) = 1
		[Sub(GroupSurfaceInputs)]_BaseMapArray("BaseMap Array", 2DArray) = "" {}
		[Sub(GroupSurfaceInputs)]_BumpMapArray("BumpMap Array", 2DArray) = "" {} 
		[Sub(GroupSurfaceInputs)]_IDSplat("ID Splat", 2D) = "black" {}
		[Sub(GroupSurfaceInputs)]_WeightSplat("Weight Splat", 2D) = "black" {}
		[Sub(GroupSurfaceInputs)]_BaseMapSize("BaseMap Size", int) = 1024
		[Sub(GroupSurfaceInputs)]_IDSplatTexSize("ID Splat Size", int) = 512
  
		//待去掉
		// AO贴图，R通道是AO，G通道是金属度，B通道是光滑度
		[HideInInspector]_CombinedAO("AO_Metal_Smoothness Texture" , 2D) = "white" {}
		[HideInInspector][Enum(MoleGame.Editor.TATools.UVType)]_Smoothness_UVType("Smoothness Texture UV Type", float) = 0
		[HideInInspector]_SmoothnessTillingAndOffset("Smoothness Tilling And Offset", Vector) = (1,1,0,0)
		[HideInInspector]_CombinedScaledParams("AO_Metal_Smoothness Scaled", Vector) = (1.0,1.0,1.0,0.0)

		[Header(Ambient)]
		[Toggle] _UseCharacterAmbient("Use Character Ambient Color", Float) = 0
	    
		//待去掉
		[HideInInspector][Toggle]_MainTexAsEmissionTex("Main Texture As Emission Texture", Float) = 0
		[HideInInspector]_Emissive_Intensity("Emissive Intensity", Range(0.0,100.0)) = 0.0
		[HideInInspector][HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		[HideInInspector][Main(_EmissionTextureGroup)]_Enable_EmissionTex("自发光/Mask调色		(Default: Off)", Float) = 0
		[HideInInspector][Sub(_EmissionTextureGroup)]_EmissionTexture("Emission Texture", 2D) = "black" {}
		[HideInInspector][SubToggle(_EmissionTextureGroup)]_UseEmissionAlphaMask("Use Emission Alpha Mask", float) = 0
		[HideInInspector][Sub(_EmissionTextureGroup)]_EmissionMaskColor("Emission Mask Color", Color) = (1,1,1,1)
		[HideInInspector][Sub(_EmissionTextureGroup)]_EmissionMaskColorIntensity("Emission Mask Color Intensity", Float) = 1

		//待去掉
		[HideInInspector]_BumpMap("Normal Map", 2D) = "bump" {}
		[HideInInspector]_BumpScale("Normal Scale", Float) = 1.0
		[HideInInspector][Main(_Normal2Group)]_Enable_NormalAdd("Normal Add			(Default: Off)", Float) = 0
		[HideInInspector][Sub(_Normal2Group)]_BumpMap2("Normal2 Map", 2D) = "bump" {}
		[HideInInspector][Sub(_Normal2Group)]_BumpScale2("Normal2 Scale", Float) = 1.0

		

		// Blending State
		[HideInInspector]_Mode("__mode", Float) = 0.0
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
		[Space]
		[Main(LayerProp, _, on, off)] _EnableLayerProp("图层属性设置(Layer Options)", Float) = 0
		
		[Advanced(Layer_1)][Sub(LayerProp)]_LayerTilingAndOffset1("图层1_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_1)][Sub(LayerProp)]_LayerBumpScale1("图层1_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_1)][Sub(LayerProp)]_LayerSmoothness1("图层1_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
		
		[Advanced(Layer_2)][Sub(LayerProp)]_LayerTilingAndOffset2("图层2_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_2)][Sub(LayerProp)]_LayerBumpScale2("图层2_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_2)][Sub(LayerProp)]_LayerSmoothness2("图层2_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
		
		[Advanced(Layer_3)][Sub(LayerProp)]_LayerTilingAndOffset3("图层3_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_3)][Sub(LayerProp)]_LayerBumpScale3("图层3_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_3)][Sub(LayerProp)]_LayerSmoothness3("图层3_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
	    
		[Advanced(Layer_4)][Sub(LayerProp)]_LayerTilingAndOffset4("图层4_平铺((TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_4)][Sub(LayerProp)]_LayerBumpScale4("图层4_法线强度((BumpScale)", Float) = 1
		[Advanced(Layer_4)][Sub(LayerProp)]_LayerSmoothness4("图层4_粗糙度((Smoothness)", Range(0.0,1.0)) = 0.5
	    
		[Advanced(Layer_5)][Sub(LayerProp)]_LayerTilingAndOffset5("图层5_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_5)][Sub(LayerProp)]_LayerBumpScale5("图层5_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_5)][Sub(LayerProp)]_LayerSmoothness5("图层5_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
	    
		[Advanced(Layer_6)][Sub(LayerProp)]_LayerTilingAndOffset6("图层6_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_6)][Sub(LayerProp)]_LayerBumpScale6("图层6_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_6)][Sub(LayerProp)]_LayerSmoothness6("图层6_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
		
		[Advanced(Layer_7)][Sub(LayerProp)]_LayerTilingAndOffset7("图层7_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_7)][Sub(LayerProp)]_LayerBumpScale7("图层7_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_7)][Sub(LayerProp)]_LayerSmoothness7("图层7_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
		
		[Advanced(Layer_8)][Sub(LayerProp)]_LayerTilingAndOffset8("图层8_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_8)][Sub(LayerProp)]_LayerBumpScale8("图层8_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_8)][Sub(LayerProp)]_LayerSmoothness8("图层8_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
		
		[Advanced(Layer_9)][Sub(LayerProp)]_LayerTilingAndOffset9("图层9_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_9)][Sub(LayerProp)]_LayerBumpScale9("图层9_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_9)][Sub(LayerProp)]_LayerSmoothness9("图层9_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
		
		[Advanced(Layer_10)][Sub(LayerProp)]_LayerTilingAndOffset10("图层10_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_10)][Sub(LayerProp)]_LayerBumpScale10("图层10_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_10)][Sub(LayerProp)]_LayerSmoothness10("图层10_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
	    
		[Advanced(Layer_11)][Sub(LayerProp)]_LayerTilingAndOffset11("图层11_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_11)][Sub(LayerProp)]_LayerBumpScale11("图层11_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_11)][Sub(LayerProp)]_LayerSmoothness11("图层11_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
		
		[Advanced(Layer_12)][Sub(LayerProp)]_LayerTilingAndOffset12("图层12_平铺(TilingAndOffset)", Vector) = (1,1,0,0)
		[Advanced(Layer_12)][Sub(LayerProp)]_LayerBumpScale12("图层12_法线强度(BumpScale)", Float) = 1
		[Advanced(Layer_12)][Sub(LayerProp)]_LayerSmoothness12("图层12_粗糙度(Smoothness)", Range(0.0,1.0)) = 0.5
		
		[Space]
		[Main(GroupSeaGrassShadowOptions, _, on, off)] _EnableGroupSeaGrassShadowOptions("草海阴影设置(SeaGrassShadow Options)", Float) = 1
        [Sub(GroupSeaGrassShadowOptions)]_SeaGrassDistrobutionMask("草海阴影分布图(SeaGrass Distrobution Mask)(工具生成)", 2D) = "black" {}
        [Sub(GroupSeaGrassShadowOptions)]_MinBoundX("草海范围最小UVX值(Min SeaGrass BoundX)(工具生成)", Float) = 0
        [Sub(GroupSeaGrassShadowOptions)]_MinBoundY("草海范围最小UVY值(Min SeaGrass BoundY)(工具生成)", Float) = 0
        [Sub(GroupSeaGrassShadowOptions)]_BoundSize("草海范围大小(SeaGrass Bound Range)(工具生成)", Float) = 1
		[Sub(GroupSeaGrassShadowOptions)]_SeaGrassShadowDark("草海阴影颜色深度(ShadowDark)", Float) = 0.7
		[Sub(GroupSeaGrassShadowOptions)]_SeaGrassShadowOffset("草海阴影偏移(ShadowOffset)", Float) = 0
        [Sub(GroupSeaGrassShadowOptions)]_SeaGrassShadowFadeDis("草海渐隐距离(SeaGrassShadow Fade Distance)", Float) = 30
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
			ZTest LEqual
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

			// --------------------------------------
			// URP keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			//#pragma multi_compile _ _ADDITIONAL_LIGHTS
			//#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			//#pragma multi_compile_fragment _ _CUSTOM_SCREEN_SPACE_OCCLUSION
			//#pragma multi_compile _ _FORWARD_PLUS

			// -------------------------------------
			// Unity defined keywords
			//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			// #pragma multi_compile_fog
			#pragma multi_compile _ _PIXELFOG_ON

			#pragma multi_compile_local _ _ENABLE_EMISSIONTEX_ON	
			// #pragma multi_compile_local _ _REFLECTION_ON _REAL_TIME_REFLECTION_ON
			#pragma multi_compile_local _ _DIRT_ON
			#pragma multi_compile_local _ _TOPDETAIL_ON
			#pragma multi_compile_local _ _DISSOLVE_ON
			#pragma multi_compile_local _ _MASK_UV2_ON
			#pragma multi_compile_local _ _ENABLE_NORMALADD_ON
			#pragma multi_compile_local _ _HEIGHTGRADIENT_ON

			#pragma shader_feature _ _FORWARD_PLUS_Z_BINING

			#pragma vertex SceneObjectVertex
			#pragma fragment SceneObjectFragment

			#define NO_TPA

			#include "SceneTerrain-Input.hlsl"
			#include "SceneTerrain-Lib.hlsl"
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
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment
			#define NO_TPA

			#include "SceneTerrain-Input.hlsl"
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
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#define NO_TPA

			#include "SceneTerrain-Input.hlsl"
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
			//#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			//#pragma multi_compile_instancing
			#define NO_TPA

			#include "SceneTerrain-Input.hlsl"
			#include "../FALib/FADepthNormalsPass.hlsl"
			ENDHLSL
		}

	}

	CustomEditor "LWGUI.LWGUI"
}
