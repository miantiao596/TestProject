Shader "URP/MoleGame/Scene/AtomSphere_A_Transparent"
{
	Properties
	{
		[MainColor]_Color("Main Color", Color) = (1,1,1,1)
		[MainTexture]_MainTex("Main Texture", 2D) = "white" {}
		[RGBAChannelMaskToVec4]_MainTex_ChannelMask("Main Texture Channel Mask (Default: RGBA)", Vector) = (1,0,0,0)
		_MainTex_U("Main Texture Speed U", float) = 0
		_MainTex_V("Main Texture Speed V", float) = 0
		_MainTex_Rotate_Speed("Main Texture Rotate Speed", float) = 0
		[Enum(MoleGame.Editor.TATools.UVType)]_MainTex_UVType("Main Texture UV Type", float) = 0
		[Enum(MoleGame.Editor.TATools.Direction)]_MainTex_Dir("Main Texture Sample Direction", float) = 0
        _MainTex_Range("W_Start-W_End-H_Start-H_End", vector) = (0,0,0,0)
		
		
		[MaskTexture]_MaskTex("Mask Texture 1", 2D) = "white" {}
		[RGBAChannelMaskToVec4]_MaskTex_ChannelMask("Mask Texture Channel Mask (Default: R)", Vector) = (1,0,0,0)
		_MaskTex_U("Mask Texture 1 Speed U", float) = 0
		_MaskTex_V("Mask Texture 1 Speed V", float) = 0
		_MaskTex_Rotate_Speed("Main Texture Rotate Speed", float) = 0
		[Enum(MoleGame.Editor.TATools.UVType)]_MaskTex_UVType("Mask Texture UV Type", float) = 0
		[Enum(MoleGame.Editor.TATools.Direction)]_MaskTex_Dir("Mask Texture Sample Direction", float) = 0
        _MaskTex_Range("W_Start-W_End-H_Start-H_End", vector) = (0,0,0,0)
		
		[MaskTexture2]_MaskTex2("Mask Texture 2", 2D) = "white" {}
		[RGBAChannelMaskToVec4]_MaskTex2_ChannelMask("Mask Texture2 Channel Mask (Default: R)", Vector) = (1,0,0,0)
		_MaskTex2_U("Mask Texture 2 Speed U", float) = 0
		_MaskTex2_V("Mask Texture 2 Speed V", float) = 0
		_MaskTex2_Rotate_Speed("Main Texture Rotate Speed", float) = 0
		
		[Enum(MoleGame.Editor.TATools.UVType)]_MaskTex2_UVType("Mask Texture 2 UV Type", float) = 1
		_Intensity("Intensity", Range(0, 100)) = 1.0
		
	}

	SubShader
	{
		Tags {
			"Queue" = "Transparent-10"
			"RenderPipeline" = "UniversalPipeline"
			"IgnoreProjector" = "True"
		}
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off
		Fog { Mode Off }
        HLSLINCLUDE

        ENDHLSL
		Pass
		{
			Name "StandardLit"
			Tags { "LightMode" = "Scene" }

			HLSLPROGRAM

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			#pragma vertex vert
			#pragma fragment frag
            #include "AtomSphereTransparentLib.hlsl"
			ENDHLSL
		}

	}
	CustomEditor "JTRP.ShaderDrawer.LWGUI" 
}