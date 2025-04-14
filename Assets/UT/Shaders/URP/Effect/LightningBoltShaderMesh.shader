Shader "URP/MoleGame/Effects/LightningBoltShaderMesh"
{
	Properties
	{
		[PerRendererData] _MainTex ("Main Texture (RGBA)", 2D) = "white" {}
		[PerRendererData][HDR] _TintColor ("Tint Color (RGB)", Color) = (1, 1, 1, 1)
		[PerRendererData] _InvFade ("Soft Particles Factor", Range(0.01, 100.0)) = 1.0
		[PerRendererData] _JitterMultiplier ("Jitter Multiplier (Float)", Float) = 0.0
		[PerRendererData] _Turbulence ("Turbulence (Float)", Float) = 0.0
		[PerRendererData] _TurbulenceVelocity ("Turbulence Velocity (Vector)", Vector) = (0, 0, 0, 0)
		[PerRendererData] _IntensityFlicker("Intensity flicker (Vector)", Vector) = (0, 0, 0, 0)
		[PerRendererData] _SrcBlendMode("SrcBlendMode (Source Blend Mode)", Int) = 5 // SrcAlpha
		[PerRendererData] _DstBlendMode("DstBlendMode (Destination Blend Mode)", Int) = 1 // One, change to 10 for alpha blend instead of additive blend
    }

    SubShader
	{
		Tags { "Queue" = "Transparent" }
		Cull Off
		Lighting Off
		ZWrite Off
		ZTest LEqual
		ColorMask RGBA
		Blend [_SrcBlendMode] [_DstBlendMode]

		CGINCLUDE
		
		#include "LightningShader.cginc"

		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma glsl_no_auto_normalization
		#pragma multi_compile_particles
		#pragma multi_compile_instancing

		ENDCG

		// glow pass
		Pass
		{
			Name "GlowPass"
			LOD 400

            CGPROGRAM

            v2f vert(appdata_t v)
            {
                WM_INSTANCE_VERT(v, v2f, o);

				float dirModifier = (v.texcoord.x - 0.5) + (v.texcoord.x - 0.5);
				float absRadius = abs(v.dir.w);
				float lineWidth = absRadius + absRadius;
				float jitter = 1.0 + (rand3(v.vertex) * _JitterMultiplier * 0.05);
				float t = _LightningTime.y;
				float glowWidthMultiplier = v.texcoord.z;
				float glowIntensity = v.texcoord.w;
				float elapsed = (t - v.fadeLifetime.r) / (v.fadeLifetime.a - v.fadeLifetime.r);
				float lineMultiplier = glowWidthMultiplier * lineWidth;
				float turbulence = lerp(0.0f, _Turbulence / max(0.5, absRadius), elapsed);
				float4 turbulenceVelocity = lerp(float4(0, 0, 0, 0), _TurbulenceVelocity, elapsed);
	
				float4 turbulenceDirection = turbulenceVelocity + (float4(normalize(v.dir.xyz), 0) * turbulence);
                float3 directionBackwardsNormalized = normalize(v.dir2.xyz);
                float4 directionBackwards = float4(directionBackwardsNormalized * dirModifier * lineMultiplier * 1.5, 0);
                float3 directionToCamera = normalize(_WorldSpaceCameraPos - v.vertex);
                float4 tangent = float4(cross(directionBackwardsNormalized, directionToCamera), 0);
                dirModifier = v.dir.w / absRadius;
                float4 directionSideways = (tangent * lineMultiplier * dirModifier * jitter);
                o.pos = UnityObjectToClipPos(v.vertex + directionBackwards + directionSideways + turbulenceDirection);

				o.color = (lerpColor(v.fadeLifetime) * _TintColor * fixed4(v.color.rgb, 1.0));
				o.color.a *= glowIntensity;
				o.texcoord = v.texcoord.xy;
				
#if defined(SOFTPARTICLES_ON)

                o.projPos = ComputeScreenPos(o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);

#endif

                return o;
            }
			
            ENDCG
        }
    }
 
    Fallback Off
}