Shader "URP/MoleGame/Effects/CrackPlane"
{
    Properties
    {
         [Preset(GroupPreset,Standard_RenderingPreset)] _RenderMode ("Rendering Mode", Float) = 1.0
        [HDR]_Color("Color", Color) = (1,1,1,1)
        _MainTex("MainTex", 2D) = "white" {}
        [RGBAChannelMaskToVec4]_MainTex_ChannelMask("Main Texture Channel Mask (Default: RGBA)", Vector) = (1,1,1,1)
        _MainTex_U("Main Texture Speed U", Float) = 0
		_MainTex_V("Main Texture Speed V", Float) = 0
		
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Float) = 1
        
        _CombinedAO("AO_Metal_Smoothness Texture", 2D) = "white" {}
        _CombinedScaledParams("AO_Metal_Smoothness Scale", Vector) = (1.0,1.0,1.0,0)

        _Cutoff("Alpha Clip (Default: 0.5)", Range(0.0, 0.99)) = 0.5
        
        [HDR]_EmissionColor("Enission Color", Color) = (1,1,1,0)
        _Emissive_Intensity("Emission Intensity", Range(0.0,100.0)) = 0.0
        
        // Mask遮罩
        //[Main(_MaskGroup, _MASK_ON)] _Mask_On("Mask			(Default: Off)", Float) = 0
        [Sub(_MaskGroup)]_MaskTex("Mask Texture", 2D) = "white" {}
        [RGBAChannelMaskToVec4(_MaskGroup)]_MaskTex_ChannelMask("Mask Texture Channel Mask (Default: R)", Vector) = (1,0,0,0)
		[Sub(_MaskGroup)]_MaskTex_U("Mask Texture Speed U", Float) = 0
		[Sub(_MaskGroup)]_MaskTex_V("Mask Texture Speed V", Float) = 0
		[Sub(_MaskGroup)]_MaskTex_RotateAngle("Mask Texture Rotate Angle", Range(0, 360)) = 0
		[SubToggle(_MaskGroup)]_MaskTex_UseRotateSpeed("Mask Texture Use Rotate Speed", Float) = 0
		[Sub(_MaskGroup)]_MaskTex_RotateSpeed("Mask Texture Rotate Speed", Float) = 0
		
		
        // 自发光
        //[Main(_EmissionGroup, _EMISSION_ON)] _Emission_On("Emission			(Default: Off)", Float) = 0
        _EmissionTex("Emission Texture", 2D) = "white" {}

        
        // 视差
        //[Main(_ParallaxGroup, _PARALLAX_ON)] _Parallax_On("Parallax			(Default: Off)", Float) = 0
        _ParallaxTex("Parallax Texture", 2D) = "white" {}
        _ParallaxScale("Parallax Scale", Range( 0 , 0.5)) = 0
        _PlaneHeight("Plane Height", Float) = 0.5
        _InvertedColor("Inverted Color", Float) = 0

        // 溶解
        //[Main(_DissolveGroup, _DISSOLUTION_ON)] _Dissolution_On("Dissolve			(Default: Off)", Float) = 0
        _DissolutionTex("Dissolve Texture", 2D) = "white" {}
        [Channel(RGBASingleChannelMaskToVec4)]_DissolutionTex_ChannelMask("Dissolve Texture Channel Mask (Default: R)", Vector) = (1,0,0,0)
		_DissolutionTex_U("Dissolve Texture Speed U", Float) = 0
		_DissolutionTex_V("Dissolve Texture Speed V", Float) = 0
		_DissolutionReverse("Dissolve Reverse", Float) = 0
		_DissolutionPercent("Dissolve Percent", Range(0, 1)) = 0
		_DissolutionSoftEdge("Dissolve Soft Edge", Range(0, 1)) = 0
		[Gamma][HDR]_DissolutionEdgeColor("Dissolve Edge Color", Color) = (1,1,1,1)
		_DissolutionEdgeWidth("Dissolve Edge Width", Range(0, 1)) = 0
        
        // 极坐标
        //[Main(_PolarCoordinateGroup, _POLAR_COORDINATE_ON)] _Polar_Coordinate_On("Polar Coordinate			(Default: Off)", Float) = 0
        [HDR]_PolarColor("Polar Color", Color) = (1,1,1,1)
        _PolarColorIntensity("Polar Color Intensity", Float) = 0
        _PolarTex("PolarTex", 2D) = "white" {}
        _Polar_Speed_U("Speed U", Float) = 0
        _Polar_Speed_V("Speed V", Float) = 0
        
        [Toggle]useCustomData("Use Custom Data(t0.z:DissolvePercent, t0.w:EmissionIntensity, t1.z:ParallaxScale)", Float) = 0
        
        [HideInInspector]_TransparentMode("__mode", Float) = 0.0
		[HideInInspector]_SrcBlend("__src", Float) = 1.0
		[HideInInspector]_DstBlend("__dst", Float) = 0.0
		[HideInInspector]_ZWrite("__zw", Float) = 1.0
		
		[HideInInspector]_TPA("__TPA", Float) = 1.0
		
		[HideInInspector]_FogMode("Fog Mode", Float) = 1.0
		[HideInInspector]_FogIntensity("Fog Intensity", Range(0.0, 1.0)) = 0.5
        [HideInInspector][Toggle] _IgnoreMainShadowAtten("Ignore MainShadowAtten", Int) = 0
        [HideInInspector]_EnvironmentReflectionIntensity("_Environment Reflection Intensity", Range(0.0, 1.0)) = 1.0

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
        LOD 0

        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Cull Back

        HLSLINCLUDE
        #pragma target 2.0

        #pragma prefer_hlslcc gles
        #pragma exclude_renderers d3d11_9x 
        
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        
        ENDHLSL

        Pass
        {
            
            Name "GeneralEffectPBR"
            Tags { "LightMode" = "SceneEffect" }
            
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
            ZTest LEqual
			//跳过TAA处理的Mask
			Stencil {
				Ref [_TAAStencil]
				WriteMask [_TAAStencilMask]
				Comp always
				Pass [_TAAStencilPassOperate]
			}

            HLSLPROGRAM
            #pragma multi_compile_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            #pragma vertex PBRGeneralEffectVertex
            #pragma fragment PBRGeneralEffectFragment
            
            #include "CrackPlane-Input.hlsl"
            #include "CrackPlane-Lib.hlsl"
                   
            ENDHLSL
        }
    }
   CustomEditor "LWGUI.LWGUI"
}
