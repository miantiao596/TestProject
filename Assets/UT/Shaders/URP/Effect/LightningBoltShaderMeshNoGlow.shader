Shader "URP/MoleGame/Effects/LightningBoltShaderMeshNoGlow"
{
	Properties
	{
		[PerRendererData] _MainTex ("Main Texture (RGBA)", 2D) = "white" {}
		[PerRendererData][HDR] _TintColor ("Tint Color (RGB)", Color) = (1, 1, 1, 1)
		[PerRendererData] _InvFade ("Soft Particles Factor", Range(0.01, 100.0)) = 1.0
		[PerRendererData] _JitterMultiplier ("Jitter Multiplier (Float)", Float) = 0.0
		[PerRendererData] _Turbulence ("Turbulence (Float)", Float) = 0.0
		[PerRendererData] _TurbulenceVelocity ("Turbulence Velocity (Vector)", Vector) = (0, 0, 0, 0)
		[PerRendererData] _IntensityFlicker ("Intensity flicker (Vector)", Vector) = (0, 0, 0, 0)
		[PerRendererData] _SrcBlendMode("SrcBlendMode (Source Blend Mode)", Int) = 5 // SrcAlpha
		[PerRendererData] _DstBlendMode("DstBlendMode (Destination Blend Mode)", Int) = 1 // One, change to 10 for alpha blend instead of additive blend
    }

    SubShader
	{
		Tags { "Queue" = "Transparent+1" }
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

		// line pass
		Pass
		{
			Name "LinePass"
			LOD 100

            CGPROGRAM

            v2f vert(appdata_t v)
            {
                WM_INSTANCE_VERT(v, v2f, o);

				// face the camera
				float4 worldPos = v.vertex;
				float dirModifier = (v.texcoord.x - 0.5) + (v.texcoord.x - 0.5);
				float jitter = 1.0 + (rand3(worldPos) * _JitterMultiplier);
				float t = _LightningTime.y;
				float elapsed = (t - v.fadeLifetime.r) / (v.fadeLifetime.a - v.fadeLifetime.r);
				float turbulence = lerp(0.0f, _Turbulence / max(0.5, abs(v.dir.w)), elapsed);
				float4 turbulenceVelocity = lerp(float4(0, 0, 0, 0), _TurbulenceVelocity, elapsed);
				
				float4 turbulenceDirection = turbulenceVelocity + (float4(normalize(v.dir.xyz), 0) * turbulence);
                float3 directionToCamera = (_WorldSpaceCameraPos - worldPos);
                float3 tangent = cross(v.dir.xyz, directionToCamera);
                float4 offset = float4(normalize(tangent) * v.dir.w, 0);
                o.pos = UnityObjectToClipPos(worldPos + (offset * jitter) + turbulenceDirection);
				o.texcoord = v.texcoord.xy;
				o.color = (lerpColor(v.fadeLifetime) * _TintColor * fixed4(v.color.rgb, 1.0));

#if defined(SOFTPARTICLES_ON)

                o.projPos = ComputeScreenPos(o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);

#endif

				// intensity is divided by 10 when passed in
				o.color.a *= v.color.a * 10.0;
                return o; 
            }
			
            ENDCG
        }
    }
 
    Fallback Off
}