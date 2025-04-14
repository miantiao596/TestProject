Shader "URP/MoleGame/Effects/General"
{
	Properties
	{
//		[Preset(GroupPreset,Standard_RenderingPreset)] _RenderMode ("Rendering Mode", Float) = 4.0
		[Preset(GroupPreset, General_RenderingPreset)] _TransparentMode ("Rendering Mode", Float) = 3.0		 
        [SubEnum(_, HeightFog, 0, CustomHeightFog, 1)] _FogMode ("Fog Mode", Float) = 0
        [ShowIf(_FogMode, Equal,1)]
        [Sub] _FogIntensity ("FogIntensity", Range(0.0, 1.0)) = 0.5
		//[HideInInspector]_TransparentMode("__mode", Float) = 3.0  //_TransparentMode
		[HideInInspector]_SrcBlend2("__src", Float) = 1.0
		[HideInInspector]_DstBlend2("__dst", Float) = 10.0
		//TransparentPremultipliedAlpha 半透明预乘Alpha参数，太长了改个缩写
		[HideInInspector]_TPA("__TPA", Float) = 1.0
		
		//[Toggle(_APPLY_VOLUMETRIC_FOG_COLOR)]_Apply_Volumetric_Fog("Apply Volumetric Fog", Float) = 0
		//[Enum(MoleGame.Editor.TATools.TransparentFogBlendMode)]_Fog_Blend_Mode("Transparent Fog Blend Mode", Float) = 0
		[Header(Base)]
		[LimitedHDRColor]_Color("Main Color", Color) = (1,1,1,1)
		_GAlpha("Alpha", Range(0,1)) = 1
		// BaseTexture主贴图
		[Enum(MoleGame.Editor.TATools.GeneralUVType)]_MainTex_UVType("Main Texture UV Type", float) = 0
		[MainTexture]_MainTex("Main Texture", 2D) = "white" {}
		[Channel(RGBAChannelMaskToVec4)]_MainTex_ChannelMask("Main Texture Channel Mask (Default: RGBA)", Vector) = (1,1,1,1)
		_MainTex_U("Main Texture Speed U", Float) = 0
		_MainTex_V("Main Texture Speed V", Float) = 0
		_MainTex_RotateAngle("Main Texture Rotate Angle", Range(0, 360)) = 0
		[Toggle]_MainTex_UseRotateSpeed("Main Texture Use Rotate Speed", Float) = 0
		_MainTex_RotateSpeed("Main Texture Rotate Speed", Float) = 0
		// Intensity 强度
		_Intensity("Intensity (Default: 1)", Float) = 1
		_Contrast("Contrast (Default: 1)", Range(1, 2)) = 1
		// Desaturate 去色
		[Header(Desaturate)]
		[Toggle]_NotForMainColor("Not For Main Color (Default: 0)", Float) = 0
		_Desaturate("Desaturate (Default: 0)", Range(0, 1)) = 0
		// [Header(Blend State)]
		// [Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("BlendOp (Default: Add)", Float) = 0
		// [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend (Default One for Opaque, Default SrcAlpha for Transparent)", Float) = 5
		// [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend (Default Zero for Opaque, Default OneMinusSrcAlpha for Transparent)", Float) = 10

		[Header(Cull Mode)]
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull (Default: Back)", Float) = 0

		[Toggle]_MainTex_Polar_Coordinates("Main Texture Polar Coordinates", Float) = 0
		_Main_Rot_01 ("Main Texture Twisting Strength", Range(0, 1)) = 0

		[Main(_PBR,_SWITCHPBR)]_Enable_PBR("切换到PBR光照模式		(Default: Off)", Float) = 0
		[Sub(_PBR)]_Smoothness("光滑度", Range(0,1)) = 0.5
		[Sub(_PBR)]_Metallic("金属度", Range(0,1)) = 0
		[SubToggle(_PBR)]_CustomBakeGIColor("启动默认环境色", float) = 1
		[ShowIf(_CustomBakeGIColor, Equal, 0.0)]
		[Sub(_PBR)]_BekeGIColor("环境光颜色", Color) = (0.3,0.3,0.3,1)

		[Main(_NormalGroup)]_Enable_Normal("Normal		(Default: Off)", Float) = 0
		[Sub(_NormalGroup)]_BumpMap("Normal Texture", 2D) = "bump" {}
		[Sub(_NormalGroup)]_BumpScale("Normal Scale", Float) = 1.0

		// Mask遮罩贴图
		[Main(_MaskGroup, _MASK_ON)]_Mask_On("Mask			(Default: Off)", Float) = 0
		[SubToggle(_MaskGroup)]_MaskTex_UVType("Mask Texture UV Type(Off:uv1,On:uv2)", float) = 0
		[Sub(_MaskGroup)]_MaskTex("Mask Texture", 2D) = "white" {}
		[Channel(_MaskGroup)]_MaskTex_ChannelMask("Mask Texture Channel Mask (Default: R)", Vector) = (1,0,0,0)
		[Sub(_MaskGroup)]_MaskTex_U("Mask Texture Speed U", Float) = 0
		[Sub(_MaskGroup)]_MaskTex_V("Mask Texture Speed V", Float) = 0
		[Sub(_MaskGroup)]_MaskTex_RotateAngle("Mask Texture Rotate Angle", Range(0, 360)) = 0
		[SubToggle(_MaskGroup)]_MaskTex_UseRotateSpeed("Mask Texture Use Rotate Speed", Float) = 0
		[Sub(_MaskGroup)]_MaskTex_RotateSpeed("Mask Texture Rotate Speed", Float) = 0
		[SubToggle(_MaskGroup)]_MaskTex_Polar_Coordinates("Mask Texture Polar Coordinates", Float) = 0
		[Sub(_MaskGroup)]_Mask_Rot_01 ("Mask Texture Twisting Strength", Range(0, 1)) = 0
		[Sub(_MaskGroup)]_MaskTex2_UVType("Mask Texture2 UV Type(Off:uv1,On:uv2)", float) = 0
		[Sub(_MaskGroup)]_MaskTex2("Mask Texture2", 2D) = "white" {}
		[Channel(_MaskGroup)]_MaskTex2_ChannelMask("Mask Texture2 Channel Mask (Default: R)", Vector) = (1,0,0,0)
		[Sub(_MaskGroup)]_MaskTex2_U("Mask Texture2 Speed U", Float) = 0
		[Sub(_MaskGroup)]_MaskTex2_V("Mask Texture2 Speed V", Float) = 0
		[Sub(_MaskGroup)]_MaskTex2_RotateAngle("Mask Texture2 Rotate Angle", Range(0, 360)) = 0
		[SubToggle(_MaskGroup)]_MaskTex2_UseRotateSpeed("Mask Texture2 Use Rotate Speed", Float) = 0
		[Sub(_MaskGroup)]_MaskTex2_RotateSpeed("Mask Texture2 Rotate Speed", Float) = 0
		[Sub(_MaskGroup)]_MaskTex3_UVType("Mask Texture3 UV Type(Off:uv1,On:uv2)", float) = 0
		[Sub(_MaskGroup)]_MaskTex3("Mask Texture3", 2D) = "white" {}
		[Channel(_MaskGroup)]_MaskTex3_ChannelMask("Mask Texture3 Channel Mask (Default: R)", Vector) = (1,0,0,0)
		[Sub(_MaskGroup)]_MaskTex3_U("Mask Texture3 Speed U", Float) = 0
		[Sub(_MaskGroup)]_MaskTex3_V("Mask Texture3 Speed V", Float) = 0
		[Sub(_MaskGroup)]_MaskTex3_RotateAngle("Mask Texture3 Rotate Angle", Range(0, 360)) = 0
		[SubToggle(_MaskGroup)]_MaskTex3_UseRotateSpeed("Mask Texture3 Use Rotate Speed", Float) = 0
		[Sub(_MaskGroup)]_MaskTex3_RotateSpeed("Mask Texture3 Rotate Speed", Float) = 0

		// Dissolution溶解贴图
		[Main(_DissolutionGroup, _DISSOLUTION_ON)]_Dissolution_On("Dissolution		(Default: Off)", Float) = 0
		[SubToggle(_DissolutionGroup)]_DissolutionTex_UVType("Dissolution Texture UV Type(Off:uv1,On:uv2)", float) = 0
		[Sub(_DissolutionGroup)]_DissolutionTex("Dissolution Texture", 2D) = "white" {}
		[Channel(_DissolutionGroup)]_DissolutionTex_ChannelMask("Dissolution Texture Channel Mask (Default: R)", Vector) = (1,0,0,0)
		[Sub(_DissolutionGroup)]_DissolutionTex_U("Dissolution Texture Speed U", Float) = 0
		[Sub(_DissolutionGroup)]_DissolutionTex_V("Dissolution Texture Speed V", Float) = 0
		[Sub(_DissolutionGroup)]_DissolutionTex_RotateAngle("Dissolution Texture Rotate Angle", Range(0, 360)) = 0
		[SubToggle(_DissolutionGroup)]_DissolutionTex_UseRotateSpeed("Dissolution Texture Use Rotate Speed", Float) = 0
		[Sub(_DissolutionGroup)]_DissolutionTex_RotateSpeed("Dissolution Texture Rotate Speed", Float) = 0
		[SubToggle(_DissolutionGroup)]_DissolutionReverse("Dissolution Reverse", Float) = 0
		[Sub(_DissolutionGroup)]_DissolutionPercent("Dissolution Percent", Range(0, 1.5)) = 0
		[Sub(_DissolutionGroup)]_DissolutionSoftEdge("Dissolution Soft Edge", Range(0, 1)) = 0
		[LimitedHDRColor(_DissolutionGroup)]_DissolutionEdgeColor("Dissolution Edge Color", Color) = (1,1,1,1)
		[Sub(_DissolutionGroup)]_DissolutionEdgeWidth("Dissolution Edge Width", Range(0, 1)) = 0

		// Distortion扭曲贴图（用于扭曲、顶点动画）
		[Main(_DistortionGroup, _DISTORTION_ON)]_Distortion_On("Distortion		(Default: Off)", Float) = 0
		[SubToggle(_DistortionGroup)]_DistortionTex_UVType("Distortion Texture UV Type(Off:uv1,On:uv2)", float) = 0
		[Sub(_DistortionGroup)]_DistortionTex("Distortion Texture", 2D) = "white" {}
		[Channel(_DistortionGroup)]_DistortionTex_ChannelMask("Distortion Texture Channel Mask (Default: R)", Vector) = (1,0,0,0)
		[Sub(_DistortionGroup)]_DistortionTex_U("Distortion Texture Speed U", Float) = 0
		[Sub(_DistortionGroup)]_DistortionTex_V("Distortion Texture Speed V", Float) = 0
		[Sub(_DistortionGroup)]_DistortionTex_RotateAngle("Distortion Texture Rotate Angle", Range(0, 360)) = 0
		[SubToggle(_DistortionGroup)]_DistortionTex_UseRotateSpeed("Distortion Texture Use Rotate Speed", Float) = 0
		[Sub(_DistortionGroup)]_DistortionTex_RotateSpeed("Distortion Texture Rotate Speed", Float) = 0
		[Sub(_DistortionGroup)]_DistortionIntensity("Distortion Intensity", Float) = 1

		// PointMove顶点动画
		[Main(_VertexGroup, _VERTEX_ON)]_Vertex_On("Vertex			(Default: Off)", Float) = 0
		[SubToggle(_VertexGroup)]_VertexTex_UVType("Vertex Texture UV Type(Off:uv1,On:uv2)", float) = 0
		[Sub(_VertexGroup)]_VertexTex("Vertex Texture", 2D) = "white" {}
		[Channel(_VertexGroup)]_VertexTex_ChannelMask("Vertex Texture Channel Mask (Default: R)", Vector) = (1,0,0,0)
		[Sub(_VertexGroup)]_VertexTex_U("Vertex Texture Speed U", Float) = 0
		[Sub(_VertexGroup)]_VertexTex_V("Vertex Texture Speed V", Float) = 0
		[Sub(_VertexGroup)]_VertexTex_RotateAngle("Vertex Texture Rotate Angle", Range(0, 360)) = 0
		[SubToggle(_VertexGroup)]_VertexTex_UseRotateSpeed("Vertex Texture Use Rotate Speed", Float) = 0
		[Sub(_VertexGroup)]_VertexTex_RotateSpeed("Vertex Texture Rotate Speed", Float) = 0
		[Sub(_VertexGroup)]_VertexIntensity("Vertex Intensity", Float) = 1

		// Fresnel菲尼尔
		[Main(_GeneralFresnelGroup)]_Enable_Fresnel("Fresnel		(Default: Off)", Float) = 0
		[Title(_GeneralFresnelGroup, Fresnel Add)]
		[LimitedHDRColor(_GeneralFresnelGroup)]_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		[Sub(_GeneralFresnelGroup)]_FresnelPower("Fresnel Power (Front)", Float) = 1
		[Sub(_GeneralFresnelGroup)]_FresnelIntensity("Fresnel Intensity (Front)", Float) = 1
		[Sub(_GeneralFresnelGroup)]_FresnelPower2("Fresnel Power2 (Back)", Float) = 1
		[Sub(_GeneralFresnelGroup)]_FresnelIntensity2("Fresnel Intensity2 (Back)", Float) = 1
		[Title(_GeneralFresnelGroup, Fresnel Alpha)]
		[SubToggle(_GeneralFresnelGroup)]_FresnelAlpha("Fresnel Alpha (Off: FresnelAdd; On: FresnelAlpha)", Float) = 0
		[Sub(_GeneralFresnelGroup)]_FresnelAlphaIntensity("Fresnel Alpha Intensity", Float) = 1
		[Sub(_GeneralFresnelGroup)] _GFresnelAlpha("Fresnel Alpha", Range(0, 1)) = 1

		// AlphaClip
		[Main(_AlphaClipGroup, _ALPHATEST_ON)]_AlphaClip_On("Alpha Clip		(Default: Off)", Float) = 0
		[Sub(_AlphaClipGroup)]_Cutoff("Cutoff (Default: 0.5)", Range(0, 0.99)) = 0.5

		// 叠加颜色
		[Main(_DoubleFaceColorGroup)]_Enable_DoubleFaceColor("Double Face Color	(Default: Off)", Float) = 0
		[LimitedHDRColor(_DoubleFaceColorGroup)]_DoubleFaceColor("Front Color", Color) = (1,1,1,1)
		[LimitedHDRColor(_DoubleFaceColorGroup)]_DoubleFaceColor2("Back Color", Color) = (1,1,1,1)

		// 灰色重着色
		[Main(_GrayOverlayGroup)]_Enable_GrayOverlay("Gray Overlay		(Default: Off)", Float) = 0
		[Sub(_GrayOverlayGroup)]_GrayThreshold("Gray Threshold (Default: 1)", Range(0, 1)) = 1
		[Sub(_GrayOverlayGroup)]_GrayHighlightIntensity("Highlight Intensity", Float) = 1
		[LimitedHDRColor(_GrayOverlayGroup)]_GrayOverlayColor("Gray Overlay Color", Color) = (0,0,0,1)
		[Title(_GrayOverlayGroup, 3 Colors)]
		[SubToggle(_GrayOverlayGroup)]_Enable_3Colors("Enable 3 Colors", Float) = 0
		[LimitedHDRColor(_GrayOverlayGroup)]_ColorDark("Dark Color", Color) = (0,0,0,1)
		[LimitedHDRColor(_GrayOverlayGroup)]_ColorMiddle("Middle Color", Color) = (0.5,0.5,0.5,1)
		[LimitedHDRColor(_GrayOverlayGroup)]_ColorLight("Light Color", Color) = (1,1,1,1)

		// DepthFade 切边羽化（交界处透明）
		[Main(_DepthFadeGroup, _DEPTH_FADE_ON)]_Enable_DepthFade("Depth Fade		(Default: Off)", Float) = 0
		[Sub(_DepthFadeGroup)]_DepthFadeOffset("Depth Fade Offset", Float) = 0
		[Sub(_DepthFadeGroup)]_DepthFadeIntensity("Depth Fade Intensity", Float) = 0

		[Main(_DecalGroup)]_Enable_Decal("Decal		(Default: Off)", Float) = 0
		[Title(_DecalGroup, Prevent Side Stretching)]
		[Title(_DecalGroup, (Compare projection direction with scene normal and Discard if needed))]
		[Sub(_DecalGroup)]_ProjectionAngleDiscardThreshold("Projection Angle Discard Threshold", range(-1,1)) = 0
		
		// Flatten
		[Main(_FlattenGroup, _ENABLE_FLATTEN)] _EnableFlatten("Flatten (Default Off)", Float) = 0
		[Sub(_FlattenGroup)] _FlattenWorldOriginPos("Flatten World Origin Pos", Vector) = (0, 0, 0, 0)
		[Sub(_FlattenGroup)] _FlattenPlaneOffset("Flatten Plane Offset", Float) = 0
		[Sub(_FlattenGroup)] _FlattenFactor("Flatten Factor", Float) = 0.1
		
		//[Main(_DofAlphaClipGroup, _DOF_ALPHA_CLIP)]_EnableDofAlphaClip("DOF Alpha Clip", Float) = 1
		_DepthClip("Depth Clip", Range(0.0001, 0)) = 0.0001

		[Header(ZTest)]
		[Enum(MoleGame.Editor.TATools.ZTest)]_ZTest("ZTest (Default: LessEqual)", Float) = 4
		[Header(ZWrite)]
		[Toggle]_ZWrite2("ZWrite (Default: Off)", Float) = 0

		// CustomData
		[Header(CustomData1    x HDR    y Dissolution    z Distortion   w Vertex)]
		[Toggle]_INPUT_CUSTOMDATA("Input Custom Data1 (Default: Off)", Float) = 0

		[Header(CustomData2     xy Mask UV )]
		[Toggle]_INPUT_CUSTOMDATA2("Input Custom Data2 (Default: Off)", Float) = 0

		// IN_UI
		[Header(UI)]
		[Toggle(_IN_UI_ON)]_IN_UI("Used In UI (Default: Off)", Float) = 0

		// 模板测试
		[Header(Stencil)]
		_Stencil("Stencil Ref (Default: 0)", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("Stencil Comparison (Default: Disabled)", Float) = 0

		[Header(Special Factor)]
		// alpha溢出处理（用于FA替换shader时，保持旧的效果）
		[Toggle]_AlphaOverflow("Alpha Overflow (Default: Off) (Used to replace FA old shader)", Float) = 0

		// Polar Coordinates
		[Header(Polar Coordinates)]
		//[Toggle(_POLAR_COORDINATES_ON)]_POLAR_COORDINATES("Used In Polar Coordinates", Float) = 0
		[Toggle]_POLAR_COORDINATES("Used In Polar Coordinates", Float) = 0
		
		//TAA用的stencil
		[HideInInspector]_SkipTAA("Skip TAA", int) = 0
		//生效的时候这2个都是16
		[HideInInspector]_TAAStencil("TAA Stencil Ref (Default: 0)", Float) = 16
		[HideInInspector]_TAAStencilMask("TAA Stencil Write Mask (Default: 0)", Float) = 16
		//0是keep 2是Replace
		[HideInInspector]_TAAStencilPassOperate("Stencil Operate (Default: 0)", Float) = 2

		//[Header(UI Alpha Mask)]
		[HideInInspector]_UIAlphaMaskTex ("UI Mask Texture", 2D) = "white" {}
		[HideInInspector][Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		[HideInInspector]_UIMaskUVLimit ("UI Mask UV Limit",  Vector) = (0,1,0,1)
		[HideInInspector]_UIMaskRange ("UI Mask Range",  Vector) = (0,0,1,1)
		[HideInInspector]_UIMaskTexScaleX ("UI Mask Tex Scale X",  Float) = 1
		[HideInInspector]_UIMaskTexScaleY ("UI Mask Tex Scale Y",  Float) = 1
		
		//[HideInInspector]_FogMode("Fog Mode", Float) = 0
		//[HideInInspector]_FogIntensity("Fog Intensity", Range(0.0, 1.0)) = 0.5
	}


	SubShader
	{
		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderPipeline" = "UniversalPipeline"
			"PreviewType" = "Plane"
		}

		Pass
		{
			Name "StandardLit"
			// Tags { "LightMode" = "Effect" }  // UI渲染的时候用Effect
			
			// BlendOp [_BlendOp]
			Blend [_SrcBlend2] [_DstBlend2]
			ZTest [_ZTest]
			ZWrite [_ZWrite2]
			Cull [_Cull]
			Lighting Off

			Stencil {
				Ref [_Stencil]
				Comp [_StencilComp]
			}

			HLSLPROGRAM
			#pragma multi_compile _ _PIXELFOG_ON
			
			#include "Mole_Effect_General_Lib.hlsl"

			ENDHLSL
		}

		// Pass
		// {
		// 	Name "StandardLit"
		// 	Tags { "LightMode" = "SceneEffect" }
			
		// 	// BlendOp [_BlendOp]
		// 	Blend [_SrcBlend] [_DstBlend]
		// 	ZTest [_ZTest]
		// 	ZWrite [_ZWrite]
		// 	Cull [_Cull]
		// 	Lighting Off
		// 	//跳过TAA处理的Mask
		// 	Stencil {
		// 		Ref [_TAAStencil]
		// 		WriteMask [_TAAStencilMask]
		// 		Comp always
		// 		Pass [_TAAStencilPassOperate]
		// 	}

		// 	HLSLPROGRAM

		// 	#include "Mole_Effect_General_Lib.hlsl"

		// 	ENDHLSL
		// }

		Pass
		{
			Name "DepthOnly"
			Tags{"LightMode" = "DepthOnly"}
			Cull [_Cull]
			ZWrite On
			ColorMask 0

			HLSLPROGRAM
				#define _DOF_ALPHA_CLIP 1
				#include "Mole_Effect_General_Lib.hlsl"
			ENDHLSL
			
		}

	}

	 CustomEditor "LWGUI.LWGUI"
}
