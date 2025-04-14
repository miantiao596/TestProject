Shader "URP/MoleGame/Scene/SceneSeaGrass"
{
	Properties
	{
	    //[Toggle(_APPLY_VOLUMETRIC_FOG_COLOR)]_Apply_Volumetric_Fog("Apply Volumetric Fog", Float) = 0
        //[Enum(MoleGame.Editor.TATools.TransparentFogBlendMode)]_Fog_Blend_Mode("Transparent Fog Blend Mode", Float) = 0
        
		[Main(GroupSurfaceOptions, _, on, off)] _EnableGroupSurfaceOptions("基础设置(Surface Options)", Float) = 1
		[Preset(GroupSurfaceOptions, SceneSeaGrassPreset)] _Surface("表面类型(Surface Type)", Float) = 0.0
		[ShowIf(_Surface, Equal, 1.0)]
		[Sub(GroupSurfaceOptions)]_Cutoff("Cutoff (Default: 0.5)", Range(0.0, 0.99)) = 0.5
		[SubEnum(GroupSurfaceOptions, CullMode)]_Cull("Cull Mode", Int) = 0
		[SubEnum(GroupSurfaceOptions, MoleGame.Editor.TATools.ZTest)]_ZTest("ZTest (Default: LessEqual)", Float) = 4
		[SubEnum(GroupSurfaceOptions, UnityEngine.Rendering.CompareFunction)]_Comp("Comp",Float) = 8
		[SubEnum(GroupSurfaceOptions, UnityEngine.Rendering.StencilOp)]_Pass("Pass",Float) = 2
		[Sub(GroupSurfaceOptions)] _StenilRef("Stenil Ref", Float) = 0
		[SubEnum(GroupSurfaceOptions, HeightFog, 0, CustomHeightFog, 1)] _FogMode ("Fog Mode", Float) = 0
		[ShowIf(_FogMode, Equal,1)]
		[Sub(GroupSurfaceOptions)] _FogIntensity ("FogIntensity", Range(0.0, 1.0)) = 0.5
		
		[Space]
		[Main(GroupBaseOptions, _, on, off)] _EnableGroupBaseOptions("Albedo设置(Albedo Options)", Float) = 1
		[Sub(GroupBaseOptions)][MainTexture]_MainTex("Main Texture", 2D) = "white" {}
		[Sub(GroupBaseOptions)][MainColor]_Color("主颜色(Main Color)", Color) = (1,1,1,1)
		[Sub(GroupBaseOptions)][MainColor]_Color_Top("顶部颜色(Top Color)", Color) = (1,1,1,1)
		[Sub(GroupBaseOptions)]_Color_Bottom("底部颜色(Bottom Color)", Color) = (1,1,1,1)
		[Sub(GroupBaseOptions)]_MidPos("底-顶颜色占比(Middle Position)", Range(0,1)) = 0.3
		[Sub(GroupBaseOptions)]_TopColAlpha("顶部颜色和主颜色混合(TopColAlpha)", Range(0,1)) = 1
		[Sub(GroupBaseOptions)]_TopPow("顶部颜色过度(TopPow)", Float) = 1
		[Sub(GroupBaseOptions)]_AOCorrect("AO矫正(AOCorrect)", Range(0.01,1)) = 1
		
		[Header(Global Color(Top))]
		_GlobalColTex("全局颜色贴图(GlobalCol Texture)", 2D) = "white" {}
		_GlobalColBlendAlpha("全局颜色混合比例(GlobalColor BlendAlpha)", Range(0,1)) = 1
		  
//		[Header(Normal)]
//		_BumpMap("Normal Map", 2D) = "bump" {}
//		_BumpScale("Normal Scale", Float) = 1.0
		[Space]
		[Main(GroupHighLightOptions, _, on, off)] _EnableGroupHighLightOptions("高光设置(HighLight Options)", Float) = 1
		[Sub(GroupHighLightOptions)]_SpecularColor("高光颜色(Specular Color)", Color) = (1,1,1,1)
		[Sub(GroupHighLightOptions)]_SpecularStrength("高光强度(Specular Strength)", float) = 0.36
	    [Sub(GroupHighLightOptions)]_SpecularPower("高光聚焦(SpecularPower)", Float) = 10
	    [Sub(GroupHighLightOptions)]_SpecularHeight("受高光高度(Specular Height)", Float) = 0.34
		
		[Space]
		[Main(GroupTranslucencyOptions, _, on, off)] _EnableGroupTranslucencyOptions("透光设置(Translucency Options)", Float) = 1
		[Sub(GroupTranslucencyOptions)]_Translucency("透光度(Translucency)", Float) = 1
		[Sub(GroupTranslucencyOptions)]_TranslucencyStrength("透射强度(TranslucencyStrength)", Float) = 1
		[Sub(GroupTranslucencyOptions)]_TranslucencyContrast("透射对比度(TranslucencyContrast)", Float) = 1
	    
		[Space]
		[Main(GroupWindOptions, _, on, off)] _EnableGroupWindOptions("风场设置(Wind Options)", Float) = 1
		[Sub(GroupWindOptions)]_WindDirection("风场方向(Wind Direction)", float) = 0
		[Sub(GroupWindOptions)]_WindStrength("风场强度(WindStrength)",Range(0, 10)) = 2
		[Sub(GroupWindOptions)]_WindControlMap("风场噪声(Wind Control Map)", 2D) = "red" {}
		[Sub(GroupWindOptions)]_WindWaveSize("风场贴图Tiling(WaveSize)",Range(0, 10)) = 5
		[Sub(GroupWindOptions)]_WindWaveSpeed("麦浪速度(WaveSpeed)",Range(0, 10)) = 1
		[Sub(GroupWindOptions)]_FoliageFlutter("叶片颤动(SwayGrass Flutter)", Float) = 0.08
		[Sub(GroupWindOptions)]_Color_Wind("风吹下伏颜色(Color Wind)", Color) = (1,1,1,1)
		[Sub(GroupWindOptions)]_MinWindFallRemap("下伏颜色最小阈值(MinWindFallRemap)", Range(0, 1)) = 0
		[Sub(GroupWindOptions)]_MaxWindFallRemap("下伏颜色最大阈值(MaxWindFallRemap)", Range(0, 1)) = 1
 
		[Header(Alpha Clip)]
		
	    
		// Blending State
		[HideInInspector]_Mode("__mode", Float) = 0.0
		[HideInInspector]_SrcBlend("__src", Float) = 1.0
		[HideInInspector]_DstBlend("__dst", Float) = 0.0
		[HideInInspector]_ZWrite("__zw", Float) = 1.0
		
		[Space]
		[Main(_URPShadowMappingSettingGroup)]_EnableURPShadowMapping("Can Receive URP Shadow? (Default On)", Float) = 1
		
		[SubToggle(_,_RECEIVE_URP_SHADOW)] _receiveURPShadow("Enable Urp Shadow",Float) = 0
        [SubToggle(_,_FAKE_SHADOW)] _fakeShadow("Enable Fake Shadow",Float) = 0
	}

	SubShader
	{
		Tags {
			"RenderType" = "TransparentCutout"
			"RenderPipeline" = "UniversalPipeline"
			"Queue" = "AlphaTest"
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
			#pragma multi_compile_local _ _ALPHATEST_ON

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
 
			#pragma multi_compile_local _ _ENABLE_EMISSIONTEX_ON	
			// #pragma multi_compile_local _ _REFLECTION_ON _REAL_TIME_REFLECTION_ON
			#pragma multi_compile_local _ _DIRT_ON
			#pragma multi_compile_local _ _TOPDETAIL_ON
			#pragma multi_compile_local _ _DISSOLVE_ON
			#pragma multi_compile_local _ _MASK_UV2_ON
			#pragma multi_compile_local _ _ENABLE_NORMALADD_ON
			#pragma multi_compile_local _ _HEIGHTGRADIENT_ON

			#pragma shader_feature _ _FORWARD_PLUS_Z_BINING
			
			#pragma multi_compile _ _PIXELFOG_ON
			#pragma multi_compile_local _ _UT_INSTANCING_ON
			
			#pragma vertex SceneObjectVertex
			#pragma fragment SceneObjectFragment

			#pragma multi_compile _ _RECEIVE_SELF_SHADOW _RECEIVE_ADDITIONAL_SELF_SHADOW2
            #pragma multi_compile _ _RECEIVE_ADDITIONAL_SELF_SHADOW
            #pragma multi_compile _ _RECEIVE_URP_SHADOW
            #pragma multi_compile _ _FAKE_SHADOW

			#define NO_TPA
			#define TERRAINSIZE 200

			#include "SceneSeaGrass-Input.hlsl"
			#include "SceneSeaGrass-Lib.hlsl"
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

			#include "SceneSeaGrass-Input.hlsl"
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
			#pragma multi_compile_local _ _UT_INSTANCING_ON
			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#define NO_TPA
			#define TERRAINSIZE 200
 
			#include "SceneSeaGrass-Input.hlsl"
			#include "SceneSeaGrassDepthOnlyPass.hlsl"
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
			#pragma multi_compile_local _ _UT_INSTANCING_ON
			//#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			//#pragma multi_compile_instancing
			#define NO_TPA
			#define TERRAINSIZE 200

			#include "SceneSeaGrass-Input.hlsl"
			#include "SceneSeaGrassDepthNormalsPass.hlsl"
			ENDHLSL
		}

	}

	CustomEditor "LWGUI.LWGUI"
}
