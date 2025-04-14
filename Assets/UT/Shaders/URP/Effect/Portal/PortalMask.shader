
Shader "URP/MoleGame/Effects/PortalMask"
{
Properties {
	_TurbulenceMask ("Turbulence Mask", 2D) = "white" {}
	_NoiseScale("Noize Scale (XYZ) Height (W)", Vector) = (1, 1, 1, 0.2)
}
	SubShader
	{
		Tags { "RenderType"="Tranperent" "Queue"="Geometry-100" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" }
		ColorMask 0
		ZWrite off
		Stencil
		{
			Ref 8
			Comp always
			Pass replace
		}

		Pass
		{
		Name "Portal"
        Tags { "LightMode" = "SceneEffect" }
		HLSLPROGRAM
			#pragma target 2.0
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			CBUFFER_START(UnityPerMaterial)
			float4 _NoiseScale;
			CBUFFER_END

			TEXTURE2D(_TurbulenceMask);
			SAMPLER (sampler_TurbulenceMask);
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				float3 wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float4 coordNoise = float4(wpos * _NoiseScale.xyz, 0);
				float4 tex1 = SAMPLE_TEXTURE2D_LOD (_TurbulenceMask, sampler_TurbulenceMask, (coordNoise + float4(_Time.x*3, _Time.x * 5, _Time.x * 2.5, 0)).xy, 0);
				v.vertex.xyz += v.normal* 0.005 + tex1.rgb * _NoiseScale.w - _NoiseScale.w/2;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				return 0;
			}
		ENDHLSL
		}
	}
}
