Shader "URP/UT/Character/Cloth_Dyeing_Lit"
{
    Properties
    {
        // Surface Options
        [Main(GroupSurfaceOptions, _, on, off)] _EnableGroupSurfaceOptions("基础设置(Surface Options)", Float) = 1
    	[SubEnum(GroupSurfaceOptions, Basic, 0, Advanced, 100, Developer, 500, ShowAll, 1000)] _UIDisplayMode("UI模式(UI Display Mode)", Float) = 0
        [Preset(GroupSurfaceOptions, UT_Character_Cloth_Dyeing_SurfacePreset)] _Surface("表面类型(Surface Type)", Float) = 0.0

        // Blending state
        [ShowIf(_Surface, Equal, 1.0)]
        [Preset(GroupSurfaceOptions, UT_Character_Cloth_Dyeing_BlendingPreset)] _Blend("混合模式(Blending Mode)", Float) = 0.0

        [SubToggle(GroupSurfaceOptions, _ALPHAPREMULTIPLY_ON)] [Hidden] _BlendModePreserveSpecular("    Preserve Specular", Float) = 1.0

        [ShowIf(_Surface, Equal, 1.0)]
        [ShowIf(And, _Blend, Equal, 6)]
        [SubEnum(GroupSurfaceOptions, UnityEngine.Rendering.BlendMode)] _SrcBlend("    Src", Float) = 1.0

        [ShowIf(_Surface, Equal, 1.0)]
        [ShowIf(And, _Blend, Equal, 6)]
        [SubEnum(GroupSurfaceOptions, UnityEngine.Rendering.BlendMode)] _DstBlend("    Dst", Float) = 0.0

        [ShowIf(_Surface, Equal, 1.0)]
        [ShowIf(And, _Blend, Equal, 6)]
        [SubEnum(GroupSurfaceOptions, UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("    Src Alpha", Float) = 0.0

        [ShowIf(_Surface, Equal, 1.0)]
        [ShowIf(And, _Blend, Equal, 6)]
        [SubEnum(GroupSurfaceOptions, UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("    Dst Alpha", Float) = 0.0

        [ShowIf(_Surface, Equal, 1.0)]
        [ShowIf(And, _Blend, Equal, 6)]
        [SubToggle(GroupSurfaceOptions, _)] _ZWrite("    Depth Write", Float) = 1.0

        // Alpha Clipping: 0, 1
        [ShowIf(_Surface, Greater, 0)]
        [SubToggle(GroupSurfaceOptions, _ALPHATEST_ON)] _AlphaClipping("透明裁切(Alpha Clipping)", Float) = 0.0
        //     Alpha Cutoff: 0 ~ 1
        [ShowIf(_Surface, Greater, 0)]
        [ShowIf(And, _AlphaClipping, Equal, 1)]
        [Sub(GroupSurfaceOptions)] _Cutoff ("    裁切阈值(Alpha Cutoff)", Range(0.0, 1.0)) = 0.5
        //     Alpha To Mask
        [ShowIf(_Surface, Equal, 2.0)]
        [ShowIf(And, _AlphaClipping, Equal, 1)]
        [SubToggle(GroupSurfaceOptions, _)] _AlphaToMask("    AlphaToMask", Float) = 1.0

        // Render Face: Both, Back, Front
        [SubEnum(GroupSurfaceOptions, Both, 0, Back, 1, Front, 2)] _Cull("渲染面向(Render Face)", Float) = 2.0

        // Cast Shadows
        [PassSwitch(ShadowCaster)] [SubToggle(GroupSurfaceOptions, _)] _CastShadows("投射阴影(Cast Shadows)", Float) = 1.0
        
	    [SubEnum(GroupSurfaceOptions, HeightFog, 0, CustomHeightFog, 1)] _FogMode("雾效模式(Fog Mode)", Float) = 0.0
        [ShowIf(_FogMode, Equal, 1.0)]
		[Sub(GroupSurfaceOptions)] _FogIntensity("雾效强度(Fog Intensity)", Range(0.0, 1.0)) = 0.5

        [Space]
        
        // Surface Inputs
        [Main(GroupSurfaceInputs, _, on, off)] _EnableGroupSurfaceInputs("贴图设置(Surface Inputs)", Float) = 1
        
        [Tex(GroupSurfaceInputs, _Color)] _MainTex("主贴图(Albedo)", 2D) = "white" {}
        [Hidden] _Color(" ", Color) = (1, 1, 1, 1)
        [Sub(GroupSurfaceInputs)] _MainTex_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        
        [Space]
        [Tex(GroupSurfaceInputs)][Normal] _BumpMap("法线贴图(Normal Map)", 2D) = "bump" {}
        [Sub(GroupSurfaceInputs)] _BumpScale("法线强度(Normal Scale)", Float) = 1.0

        [Space]
        [Tex(GroupSurfaceInputs)] _OMREMap("AO(R)、金属(G)、粗糙(B)、自发光(A)", 2D) = "white" {} 
        [Sub(GroupSurfaceInputs)] _OcclusionStrength("AO强度(Occlusion Strength)", Range(0.0, 2.0)) = 1.0
        [Sub(GroupSurfaceInputs)] _Metallic("金属度(Metallic)", Range(0.0, 2.0)) = 1.0
        [Sub(GroupSurfaceInputs)] _Roughness("粗糙度(Roughness)", Range(0.0, 2.0)) = 1.0
        [LimitedHDRColor(GroupSurfaceInputs)]
        _EmissionColor("自发光颜色(EmissionColor)", Color) = (0,0,0)
        [Sub(GroupSurfaceInputs)] _EmissionStrength("自发光强度(EmissionStrength)", Range(0.0, 10.0)) = 0.0
        
        [Space]
        // Custom: Four masks
        [Main(GroupDetails, _ENABLE_DETAIL_OPTION, on, on)] _EnableGroupDetails("区域材质设置(Detail Options)", Float) = 0
        [Tex(GroupDetails)] _Mask("遮罩(Mask)", 2D) = "black" {}
        [SubToggle(GroupDetails, _ENABLE_GLOBAL_METALLIC_ROUGHNESS)] _EnableGlobalMR("染色区域使用全局金属、粗糙度(EnableGlobalMR)", Float) = 0
        
        [Space]
        [Tex(GroupDetails)][Normal] _Mask1DetailNormalMap("遮罩1_细节法线(Mask1 Detail Normal Map)", 2D) = "bump" {}
        [Sub(GroupDetails)] _Mask1DetailNormalMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupDetails)] _Mask1DetailNormalStrength("遮罩1_细节法线强度(Mask1 Detail Normal Strength)", Float) = 1.0
        [Sub(GroupDetails)] _Mask1Color("遮罩1_颜色(Mask1 Color)", Color) = (1, 1, 1, 1)
        [Sub(GroupDetails)] _Mask1Roughness("遮罩1_粗糙度(Mask1 Roughness)", Range(0.0, 1.0)) = 0.0
        [Sub(GroupDetails)] _Mask1Metallic("遮罩1_金属度(Mask1 Metallic)", Range(0.0, 1.0)) = 0.0
        
        [Space]
        [Tex(GroupDetails)][Normal] _Mask2DetailNormalMap("遮罩2_细节法线(Mask2 Detail Normal Map)", 2D) = "bump" {}
        [Sub(GroupDetails)] _Mask2DetailNormalMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupDetails)] _Mask2DetailNormalStrength("遮罩2_细节法线强度(Mask2 Detail Normal Strength)", Float) = 1.0
        [Sub(GroupDetails)] _Mask2Color("遮罩2_颜色(Mask2 Color)", Color) = (1, 1, 1, 1)
        [Sub(GroupDetails)] _Mask2Roughness("遮罩2_粗糙度(Mask2 Roughness)", Range(0.0, 1.0)) = 0.0
        [Sub(GroupDetails)] _Mask2Metallic("遮罩2_金属度(Mask2 Metallic)", Range(0.0, 1.0)) = 0.0
        
        [Space]
        [Tex(GroupDetails)][Normal] _Mask3DetailNormalMap("遮罩3_细节法线(Mask3 Detail Normal Map)", 2D) = "bump" {}
        [Sub(GroupDetails)] _Mask3DetailNormalMap_ST("UV Tiling and Offset", Vector) = (1, 1, 0, 0)
        [Sub(GroupDetails)] _Mask3DetailNormalStrength("遮罩3_细节法线强度(Mask3 Detail Normal Strength)", Float) = 1.0
        [Sub(GroupDetails)] _Mask3Color("遮罩3_颜色(Mask3 Color)", Color) = (1, 1, 1, 1)
        [Sub(GroupDetails)] _Mask3Roughness("遮罩3_粗糙度(Mask3 Roughness)", Range(0.0, 1.0)) = 0.0
        [Sub(GroupDetails)] _Mask3Metallic("遮罩3_金属度(Mask3 Metallic)", Range(0.0, 1.0)) = 0.0
        
        // [?] Stencil Options
    	[ShowIf(_UIDisplayMode, GEqual, 500)]
        [Main(GroupStencilOptions, _, off, on)] _EnableGroupStencilOptions("模版设置(Stencil Options)", Float) = 0
		[Sub(GroupStencilOptions)] _stencilRef("Stencil Ref", Float) = 0
		[Sub(GroupStencilOptions)] _stencilReadMask("Stencil ReadMask", Float) = 255
		[Sub(GroupStencilOptions)] _stencilWriteMask("Stencil WriteMask", Float) = 255
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 8
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.StencilOp)] _StencilPassOp("Stencil Pass Op", Float) = 0
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.StencilOp)] _StencilFailOp("Stencil Fail Op", Float) = 0
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.StencilOp)] _StencilZFailOp("Stencil ZFail Op", Float) = 0
        
        // [?] Advanced Options
    	[ShowIf(_UIDisplayMode, GEqual, 100)]
        [Main(GroupAdvancedOptions, _, off, off)] _EnableGroupAdvancedOptions("进阶设置(Advanced Options)", Float) = 0
        [SubToggle(GroupAdvancedOptions, _FAKE_SHADOW)] _fakeShadow("接收假阴影(Enable Fake Shadow)", Float) = 0
        [SubToggle(GroupAdvancedOptions, _CHARACTER_AMBIENT_COLOR)] _EnableCharacterAmbientColor("启用角色环境色(CharacterAmbientColor)", Float) = 0
    }

    SubShader
    {
    	HLSLINCLUDE
    	// UTDefine.hlsl存储了管线的全局定义，用于方便全局切换管线功能及特性
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
            Blend [_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            ZWrite [_ZWrite]
            Cull [_Cull]
            AlphaToMask [_AlphaToMask]
            
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
            
            #pragma shader_feature_local_fragment _ENABLE_DETAIL_OPTION
            #pragma shader_feature_local_fragment _ENABLE_GLOBAL_METALLIC_ROUGHNESS
            
            // -------------------------------------
            // UT Pipeline keywords
            #if UT_RENDERING
            #pragma shader_feature_local_fragment _CHARACTER_AMBIENT_COLOR
            
            // Shadow Keywords
            #pragma shader_feature_local_fragment _FAKE_SHADOW
            #pragma multi_compile _ _RECEIVE_SELF_SHADOW _RECEIVE_ADDITIONAL_SELF_SHADOW2
            #pragma multi_compile _ _RECEIVE_ADDITIONAL_SELF_SHADOW
			#pragma multi_compile_fragment _ _CUSTOM_SCREEN_SPACE_OCCLUSION
            #else
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fog
            #endif
            
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_ON

            #include "Assets/UT/Shaders/URP/Character/Cloth/UT_Cloth_Dyeing_Lit_Input.hlsl"
            #include "Assets/UT/Shaders/URP/Character/Cloth/UT_Cloth_Dyeing_Lit_ForwardPass.hlsl"
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

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "Assets/UT/Shaders/URP/Character/Cloth/UT_Cloth_Dyeing_Lit_Input.hlsl"
            #include "Assets/UT/Shaders/URP/Character/Cloth/UT_Cloth_Dyeing_ShadowCaster.hlsl"
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
            #include "Assets/UT/Shaders/URP/Character/Cloth/UT_Cloth_Dyeing_Lit_Input.hlsl"
            #include "Assets/UT/Shaders/URP/Character/Cloth/UT_Cloth_Dyeing_DepthOnly.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
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
            #pragma shader_feature_local _ALPHATEST_ON

            // -------------------------------------
            // Includes
            #include "Assets/UT/Shaders/URP/Character/Cloth/UT_Cloth_Dyeing_Lit_Input.hlsl"
            #include "Assets/UT/Shaders/URP/Character/Cloth/UT_Cloth_Dyeing_DepthNormalsOnly.hlsl"
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
            #include "Assets/UT/Shaders/URP/Character/Cloth/UT_Cloth_Dyeing_Lit_Input.hlsl"
            #include "Assets/UT/Shaders/URP/Character/Cloth/UT_Cloth_Dyeing_Lit_ForwardPass.hlsl"

		    void SelfShadowPassFragment()
		    {
		    }
			
		    ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "LWGUI.LWGUI"
}
