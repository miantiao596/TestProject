
Shader "URP/MoleGame/Effects/TranperentDiffuse" {
Properties {
	[HDR]_TintColor ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_TurbulenceMask ("Turbulence Mask", 2D) = "white" {}
	_TimeVec ("Time (xy)", Vector) = (1, 1, 1, 1)
	_NoiseScale("Noize Scale (XYZ) Height (W)", Vector) = (1, 1, 1, 0.2)
}




	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "RenderPipeline" = "UniversalPipeline"}
		Blend SrcAlpha OneMinusSrcAlpha
		Stencil 
		{
			Ref 8
			Comp equal 
			Pass Keep
			Fail Keep
		}
		Pass {
			Name "Portal"
			Tags { "LightMode" = "SceneEffect" }
			HLSLPROGRAM
			#pragma target 2.0
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			sampler2D _MainTex;
			sampler2D _TurbulenceMask;
			CBUFFER_START(UnityPerMaterial)
			half4 _TintColor;
			float4 _TimeVec;
			float4 _NoiseScale;
			half _ColorStrength;
			CBUFFER_END
			

			struct appdata_t {
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			float4 _MainTex_ST;
			float4 _TurbulenceMask_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				float3 wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float4 coordNoise = float4(wpos * _NoiseScale.xyz, 0);
				float4 tex1 = tex2Dlod (_TurbulenceMask, coordNoise + float4(_Time.x*3, _Time.x * 5, _Time.x * 2.5, 0));
				v.vertex.xyz += v.normal* 0.005 + tex1.rgb * _NoiseScale.w - _NoiseScale.w/2;
				o.vertex = TransformObjectToHClip(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.texcoord1 = TRANSFORM_TEX(v.texcoord,_TurbulenceMask);
				return o;
			}

			half4 frag (v2f i) : SV_Target
			{
				half4 texDef = tex2D(_MainTex, i.texcoord);
				half4 tex1 = tex2D(_MainTex, i.texcoord + _Time.xx * _TimeVec.xy);
				half4 tex2 = tex2D(_MainTex, i.texcoord + _Time.xx * _TimeVec.xy + float2(0, 0.5));
				half3 res = _TintColor.rgb * lerp(texDef.rgb, tex1.rgb*tex1.a + tex2.rgb*tex2.a, _TimeVec.w);
				half alphaRes = saturate(texDef.a*texDef.a);
				return half4(res, alphaRes*_TintColor.a);
			}
			ENDHLSL
		}
	}
}

