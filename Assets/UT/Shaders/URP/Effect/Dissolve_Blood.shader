Shader "URP/MoleGame/Effects/Dissolve_Blood"
{
	Properties
	{
		 [Preset(GroupPreset,Standard_RenderingPreset)] _RenderMode ("Rendering Mode", Float) = 4
		[HideInInspector]_TransparentMode("__mode", Float) = 3.0
		[HideInInspector]_SrcBlend("__src", Float) = 1.0
		[HideInInspector]_DstBlend("__dst", Float) = 10
		[HideInInspector]_ZWrite("ZWrite (Default: Off)", Float) = 0.0
		[HideInInspector]_TPA("__TPA", Float) = 1.0
		_Cutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		
	    _Color ("Main Color", Color) = (1,1,1,1)
	    _MainTex("MainTex", 2D) = "white" {}
	    
	    _BumpMap("NormalTex", 2D) = "bump" {}
	    _BumpScale("NormalScale", Float) = 1
	    _DissolveStrength("Strength", Float) = 20
	    
	    _CombinedAO("AO_Metallic_Smoothness", 2D) = "white" {}
		_CombinedScaledParams("AO_Metal_Smoothness Scaled", Vector) = (1.0,1.0,1.0,0.0)
		
	    _DissolveTex("DissolveTex", 2D) = "white" {}
	    _DissolveUVOffset("DissolveUVOffset", Float) = 0.5
	    _DissolveMin("DissolveMin(0-3)", Range( 0 , 3)) = 0.3487788
	    _DissolveMax("DissolveMax", Float) = 0.1
	    
	    _DetailTex("DetailTex", 2D) = "white" {}
	    _AlphaComplement("Alpha Complement", Range( 0 , 1)) = 0

		[Toggle]_UseCustomData("UV0.Z:DissolveMin; UV0.W:DissolveMax; UV1.Z:AlphaComplement", Float) = 0
		[HideInInspector][Toggle] _IgnoreMainShadowAtten("Ignore MainShadowAtten", Int) = 0
		[HideInInspector]_EnvironmentReflectionIntensity("_Environment Reflection Intensity", Range(0.0, 1.0)) = 1.0
		[HideInInspector]_FogMode("Fog Mode", Float) = 1.0
		[HideInInspector]_FogIntensity("Fog Intensity", Range(0.0,1.0)) = 0.5
		
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
		Cull Off
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 2.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 


		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="SceneEffect" }
			
			//Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			//ZWrite Off
			Blend  [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]

			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			
			//跳过TAA处理的Mask
			Stencil {
				Ref [_TAAStencil]
				WriteMask [_TAAStencilMask]
				Comp always
				Pass [_TAAStencilPassOperate]
			}
			

			HLSLPROGRAM
			//#pragma multi_compile_instancing
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex DissolvBloodVertex
			#pragma fragment DissolveBloodFragment
			
			#include "Dissolve_Blood-Input.hlsl"
            #include "Dissolve_Blood-Lib.hlsl"
            
			ENDHLSL
		}
	}
	
	 CustomEditor "LWGUI.LWGUI"
}
