Shader "URP/UT/Character/SkinShader"
{
    Properties
    {
        [Main(GroupSurfaceInputs, _, on, off)] _EnableGroupSurfaceOptions("贴图设置(Surface Inputs)", Float) = 1
        
        [SubToggle(GroupSurfaceInputs, _)] _isFace("是否关闭染色 (Is Face)", Float) = 0.0
        
        [Tex(GroupSurfaceInputs)] _BaseMap("主贴图(BaseMap)", 2D) = "white" {}

        [ShowIf(_isFace, Equal, 0.0)]
        [Sub(GroupSurfaceInputs)] _BaseColor("主颜色", Color) = (0.95,0.8328,0.76,1)
        
        [Space(10)]
        [Tex(GroupSurfaceInputs, _Color)] _MaskMap("OCR贴图(MaskMap)", 2D) = "white" {}
        
        [SubToggle(GroupSurfaceInputs, _)] _MaskBlend("Mask贴图是否经过合成 (MaskBlend)", Float) = 0.0
        [Sub(GroupSurfaceInputs)]_OcclusionStrength("AO强度(OcclusionStrength)", Range(0.0, 1.0)) = 0.8
        [Sub(GroupSurfaceInputs)]_Metallic("金属度(Metallic)", Range(0.0, 1.0)) = 0.0
        [ShowIf(_MaskBlend, Equal, 0.0)][Sub(GroupSurfaceInputs)]_Smoothness("光泽度(Smoothness)", Range(0.0, 1.0)) = 0.5
  
        [Space(10)]
        [Tex(GroupSurfaceInputs, _Color)] _BumpMap("法线贴图(BumpMap)", 2D) = "bump" {}
        [SubToggle(GroupSurfaceInputs, _)] _NormalBlend("法线是否经过合成 (NormalBlend)", Float) = 0.0
        [ShowIf(_NormalBlend, Equal, 0.0)][Sub(GroupSurfaceInputs)]_BumpScale("法线强度(BumpScale)", Range(0.0, 1.0)) = 1.0
        
        [Space(10)]
        [Tex(GroupSurfaceInputs, _Color)] _SSSMap("SSS贴图(SSS Map)", 2D) = "white" {}
        
        [Sub(GroupSurfaceInputs)]_SSSIntensity("SSS强度(SSS Intensity)", Range(0.0, 1.0)) = 0.8
        [Sub(GroupSurfaceInputs)]_SkinThickness("皮肤厚度控制(Skin Thickness)", Range(0.0, 1)) = 0.5
        [Sub(GroupSurfaceInputs)]_SkinCurvature("皮肤曲率控制(Skin Curvature)", Range(0.0, 1)) = 0.15
        
        [ShowIf(_isFace, Equal, 0.0)][Sub(GroupSurfaceInputs)]_Spot("斑痕保留量(Spot)", Range(0.0, 1.0)) = 0.5
        [ShowIf(_isFace, Equal, 0.0)][Sub(GroupSurfaceInputs)]_SpotSaturation("斑痕饱和度(Spot Saturation)", Range(0.0, 1.0)) = 0.5


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
        // Blending state
        [HideInInspector]_Surface("__surface", Float) = 0.0
        [HideInInspector][ToggleUI] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0

        // Editmode props
        [HideInInspector]_QueueOffset("Queue offset", Float) = 0.0
    }


    SubShader
    {
        HLSLINCLUDE
    	// UT_Define.hlsl存储了管线的全局定义，用于方便全局切换管线功能及特性
		#include "../../../Lib/UTDefine.hlsl"
    	ENDHLSL

        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // -------------------------------------
            // Render State Commands
            Blend[_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            ZWrite[_ZWrite]
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


            #include "Assets/UT/Shaders/URP/Character/SkinShader/SkinLitInput.hlsl"
            #include "Assets/UT/Shaders/URP/Character/SkinShader/SkinLitForwardPass.hlsl"
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

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Universal Pipeline keywords

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
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

        Pass
        {
	        Name "SelfShadowCaster"
		    Tags{"LightMode" = "SelfShadowCaster"}
		    
		    ZWrite On
		    ZTest LEqual
		    ColorMask 0
		    
		    HLSLPROGRAM
			
			//#pragma multi_compile_local _ _EVOLVE2_ON _ALPHATEST_ON
		    #pragma vertex LitPassVertex
            #pragma fragment SelfShadowPassFragment // we only need to do Clip(), no need color shading
            //#pragma enable_d3d11_debug_symbols
            #define CharSelfShadowCasterPass 1
			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitForwardPass.hlsl"
			void SelfShadowPassFragment()
	        {
            }
		    ENDHLSL
        }


    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "LWGUI.LWGUI"
}


