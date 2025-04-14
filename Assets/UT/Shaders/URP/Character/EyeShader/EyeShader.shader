Shader "URP/UT/Character/EyeShader"
{ 
    Properties
    {
        
        [Main(GroupEyeInputs, _, on, off)] _EyeInputs("眼睛设置(Eye Inputs)", Float) = 1
		
        [Sub(GroupEyeInputs)]_EyeSize("大小(EyeSize)", Range( 0 ,1)) = 0.3
		[Sub(GroupEyeInputs)]_IrisContrast("明暗(IrisContrast)", Range( 0 , 1)) = 0.5
		[Sub(GroupEyeInputs)]_IrisSize("瞳孔(IrisSize)", Range( 0.5 , 5)) = 1
		[Sub(GroupEyeInputs)]_IrisMargin("虹膜边缘虚实(IrisMargin)", Range( 0 ,0.8)) = 0.3
		[Sub(GroupEyeInputs)]_IrisExtraColorAmountA("虹膜颜色(IrisExtraColorAmountA)", Color) = (0.08,0.07,0.045,0.6)
		[Sub(GroupEyeInputs)]_IrisMarginColor("虹膜边缘颜色(IrisMarginColor)", Color) = (0.5,0.5,0.5,1)
		[Sub(GroupEyeInputs)]_IrisBaseColor("虹膜底色(IrisBaseColor)", Color) = (0.5,0.5,0.5,1)
		[Sub(GroupEyeInputs)]_EyeBallColor("眼球颜色(EyeBallColor)", Color) = (0.92,0.85,0.85,0.85)
        
        [Main(GroupSurfaceInputs, _, on, off)] _EnableGroupSurfaceOptions("贴图设置(Surface Inputs)", Float) = 1
        [Tex(GroupSurfaceInputs)]_MainTex("虹膜贴图(MainTex)", 2D) = "white" {}
		[Sub(GroupSurfaceInputs)]_IrisPupilMetalness("虹膜瞳孔金属度(IrisPupilMetalness)", Range( 0 , 1)) = 0.15
		[Sub(GroupSurfaceInputs)]_LensGloss("晶状体粗糙度(LensGloss)", Range( 0 , 1)) = 0.98
        [Space(10)]
		[Tex(GroupSurfaceInputs)]_ScleraTex("巩膜贴图(ScleraTex)", 2D) = "white" {}
		[Sub(GroupSurfaceInputs)]_EyeBallMetalness("眼球金属度(EyeBallMetalness)", Range( 0 , 1)) = 0.1
        [Sub(GroupSurfaceInputs)]_EyeBallGloss("眼球粗糙度(EyeBallGloss)", Range( 0 , 1)) = 0.8
        [Space(10)]
        [Tex(GroupSurfaceInputs)]_EyeMask("EyeMask(EyeMask)", 2D) = "white" {}
		[Sub(GroupSurfaceInputs)]_IrisBasePosition("虹膜位置对齐(IrisBasePosition)", Vector) = (0,0,0,0)
        [Space(10)]
		[Tex(GroupSurfaceInputs)]_Normal("法线(Normal)", 2D) = "bump" {}
        [Sub(GroupSurfaceInputs)]_NormalScale("法线强度(NormalScale)", Range( 0 , 4)) = 1
		[Tex(GroupSurfaceInputs)]_Normal2("虹膜平面法线图(Normal2)", 2D) = "bump" {}
        [Sub(GroupSurfaceInputs)]_IrisParallaxPower("虹膜视差强度(IrisParallaxPower)", Range( 0 , 2)) = 1

		[Sub(GroupSurfaceInputs)]_Final_illumination("最终颜色强度(Final_illumination)", Range( 0 , 2)) = 0.25

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

        [SubToggle(GroupAdvancedOptions, _CHARACTER_AMBIENT_COLOR)] _EnableCharacterAmbientColor("启用角色环境色(CharacterAmbientColor)", Float) = 0

        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0

        
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
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }
        LOD 300

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
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
            Blend[_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            ZWrite On
            Cull[_Cull]
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

            
            #if UT_RENDERING
            #pragma shader_feature_local_fragment _CHARACTER_AMBIENT_COLOR
            #pragma multi_compile_fragment _ _CUSTOM_SCREEN_SPACE_OCCLUSION
            
            #else 
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fog
            #endif

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_ON
            //#pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY


            #include "Assets/UT/Shaders/URP/Character/EyeShader/EyeLitInput.hlsl"
            #include "Assets/UT/Shaders/URP/Character/EyeShader/EyeLitForwardPass.hlsl"
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
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
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

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // -------------------------------------
            // Universal Pipeline keywords
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }

        

        
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "LWGUI.LWGUI"
}
