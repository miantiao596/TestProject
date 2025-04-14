Shader "URP/UT/Character/eyelash"
{
    Properties
    {
        [Main(GroupSurfaceInputs, _, on, off)] _EnableGroupSurfaceInputs("贴图设置(Surface Inputs)", Float) = 1
        [Tex(GroupSurfaceInputs)]_MainTex("主贴图(MainTex)", 2D) = "white" {}
        [Sub(GroupSurfaceInputs)]_Cutoff("Alpha剔除(Cutoff)", Range(0.0, 1.0)) = 000.0

        [Main(GroupStencilOptions, _, off, on)] _EnableGroupStencilOptions("模版设置(Stencil Options)", Float) = 0
		[Sub(GroupStencilOptions)] _stencilRef("Stencil Ref", Float) = 0
		[Sub(GroupStencilOptions)] _stencilReadMask("Stencil ReadMask", Float) = 255
		[Sub(GroupStencilOptions)] _stencilWriteMask("Stencil WriteMask", Float) = 255
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 8
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.StencilOp)] _StencilPassOp("Stencil Pass Op", Float) = 0
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.StencilOp)] _StencilFailOp("Stencil Fail Op", Float) = 0
		[SubEnum(GroupStencilOptions, UnityEngine.Rendering.StencilOp)] _StencilZFailOp("Stencil ZFail Op", Float) = 0

        [SubEnum(_, HeightFog, 0, CustomHeightFog, 1)] _FogMode ("Fog Mode", Float) = 1
		[ShowIf(_FogMode, Equal,1)]
		[Sub] _FogIntensity ("FogIntensity", Range(0.0, 1.0)) = 0.5
    }

    SubShader
    {
        HLSLINCLUDE
    	// UT_Define.hlsl存储了管线的全局定义，用于方便全局切换管线功能及特性
		#include "../../../Lib/UTDefine.hlsl"
    	ENDHLSL

        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
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

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

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
            #if !UT_RENDERING
            #pragma multi_compile_fog
            #endif
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
 
 
            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
            };
 
            struct Varyings
            {
                float4 positionCS       : SV_POSITION;
                float2 uv               : TEXCOORD0;
                float4 fogColor         : TEXCOORD1;
                half3 positionWS        : TEXCOORD2;
                half  fogFactor         : TEXCOORD3;
            };
 
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half _Cutoff;

	        half _FogMode;
	        half _FogIntensity;
            CBUFFER_END

            TEXTURE2D (_MainTex);SAMPLER(sampler_MainTex);

	        #include "Assets/UT/Shaders/URP/FALib/FaHeightFogDebug.hlsl"
	        #include "Assets/UT/Shaders/URP/FALib/FACustomFogLib.hlsl"
            
            half AlphaClip(half alpha, half cutoff)
            {
                half alphaToCoverageAlpha =  SharpenAlpha(alpha, cutoff);
                alpha = alphaToCoverageAlpha;
                clip(alpha - 1);
            
                return alpha;
            }

            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;
 
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.positionWS = mul( unity_ObjectToWorld, float4( v.positionOS.xyz, 1 ) ).xyz;

                #ifndef _PIXELFOG_ON
                		CustomMixFogColor(o.positionWS, o.fogColor.xyz, o.fogColor.w);
                #endif
                o.fogFactor = ComputeFogFactor(o.positionCS.z);
                return o;
            }
 
            half4 frag(Varyings i) : SV_Target
            {
                half4 c;
                half4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                c.rgb = baseMap.rgb;
                c.a = AlphaClip(baseMap.a, _Cutoff) * baseMap.a;
                //c.rgb = MixFog(c.rgb, i.fogCoord);
            #if UT_RENDERING
                #ifdef _PIXELFOG_ON
	            CustomMixFogColor(i.positionWS.xyz, i.fogColor.xyz, i.fogColor.w);
	            #endif
                c.rgb = lerp(i.fogColor.xyz, c.rgb, i.fogColor.w);
            #else
                half4 fogCoord = InitializeInputDataFog(float4(i.positionWS, 1.0), i.fogFactor);
                c.rgb = MixFog(c.rgb, fogCoord);
            #endif
                
                return half4(c.rgb,c.a);
            }
            ENDHLSL
        }

    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "LWGUI.LWGUI"
}

