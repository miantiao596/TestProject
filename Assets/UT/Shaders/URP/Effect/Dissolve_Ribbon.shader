Shader "URP/MoleGame/Effects/Dissolve_Ribbon"
{
	Properties
	{
		 [Preset(GroupPreset,Standard_RenderingPreset)] _RenderMode ("Rendering Mode", Float) = 4.0
	    [HideInInspector]_TransparentMode("__mode", Float) = 3.0
		[HideInInspector]_SrcBlend("__src", Float) = 1.0
		[HideInInspector]_DstBlend("__dst", Float) = 10.0
		[HideInInspector]_ZWrite("ZWrite (Default: Off)", Float) = 0.0
		_AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		
        [HDR]_Color("Color", Color) = (1,0.03137255,0.9657804,1)
        _MainTex("MainTex", 2D) = "white" {}
		_MainTex_U_Speed("MainTex_U_Speed", Float) = -0.8
		_MainTex_V_Speed("MainTex_V_Speed", Float) = 0
		
		_CombinedAO("AO_Metallic_Smoothness", 2D) = "white" {}
		_CombinedScaledParams("AO_Metal_Smoothness Scaled", Vector) = (1.0,1.0,1.0,0.0)
		
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_DissolveTex_U_Speed("DissolveTex_U_Speed", Float) = -0.4
		_DissolveTex_V_Speed("DissolveTex_V_Speed", Float) = 0
		
		[HDR]_EdgeColor("EdgeColor", Color) = (0,0.885386,1,1)
		_GridentEdgeTex("GridentEdgeTex", 2D) = "white" {}
		_DissolveAmount("DissolveAmount", Range( 0 , 1)) = 0.5178274
		
		[Toggle]_UseCustomData("UV0.z:DissolveAmount", Float) = 0
		
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
			Tags { "LightMode"="UniversalForward" }
			
			//Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			Blend  [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
			//ZWrite Off
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
			//#define _ALPHATEST_ON 1
			#pragma multi_compile_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

			struct VertexInput
			{
				half4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 uv : TEXCOORD0;
				half4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
			    half4 positionCS : SV_POSITION;
				half4 uv : TEXCOORD0;
				half4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _EdgeColor;
			half _MainTex_U_Speed;
			half _MainTex_V_Speed;
			half _DissolveTex_U_Speed;
			half _DissolveTex_V_Speed;
			half _DissolveAmount;
			half _AlphaCutoff;
			half _UseCustomData;
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _GridentEdgeTex;
			sampler2D _DissolveTex;
			
			VertexOutput vert ( VertexInput v )
			{
				VertexOutput o = (VertexOutput)0;
				o.uv = v.uv;
				o.color = v.color;			
		        half3 positionWS = TransformObjectToWorld( v.positionOS.xyz );
				o.positionCS = TransformWorldToHClip( positionWS);
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
                half time = fmod(_Time.x, 10);
				half2 mainTexUV = (half2(( _MainTex_U_Speed * time) , (time * _MainTex_V_Speed )));
				float4 mainTexColor = tex2D( _MainTex, ( IN.uv.xy + mainTexUV ) );

				half2 dissolveTexUV = (half2(( _DissolveTex_U_Speed * time ) , ( time * _DissolveTex_V_Speed )));
				half dissolveAmout = lerp(_DissolveAmount, IN.uv.z , _UseCustomData);
				half dissolveTexColor = ( tex2D( _DissolveTex, ( IN.uv.xy + dissolveTexUV ) ).r + min( ( IN.uv.x * 7.0 ) , (1.0 + (IN.uv.x - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) + (-1.7 + (dissolveAmout - 0.0) * (1.0 - -1.7) / (1.0 - 0.0)) );
				
				half dissolveColor = clamp( (-3.0 + (dissolveTexColor - 0.0) * (3.0 - -3.0) / (1.0 - 0.0)) , 0.0 , 1.0 );
				
				half2 gridentEdgeTexUV = (half2(dissolveColor , 0.0));
				
				half4 gridentEdge = ( 1.0 - tex2D( _GridentEdgeTex, gridentEdgeTexUV ) );
				
				half4 finalColor = lerp( ( _Color * mainTexColor * IN.color ) , ( _EdgeColor * gridentEdge ) , gridentEdge);
                
				half alpha = saturate( ( mainTexColor.r * dissolveTexColor ) );
                
				#ifdef _ALPHATEST_ON
					clip( alpha - _AlphaCutoff );
				#endif
				return half4( finalColor.rgb, alpha );
			}

			ENDHLSL
		}

	}
    CustomEditor "LWGUI.LWGUI"
}
