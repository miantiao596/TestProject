
Shader "URP/MoleGame/Effects/UberParticle"
{
	Properties
	{
		[Header(Main Settings)]
		[Space]
		[PerRendererData][HDR]_TintColor("Tint Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}

		[Header(Fading)]
		[Space]
		[Main(_FadingGroup,_FADING_ON)] _UseSoft("Use Soft Particles", Int) = 0
		[Sub(_FadingGroup)]_InvFade("Soft Particles Factor", Float) = 1
		[Sub(_FadingGroup)]_SoftInverted("Inverted Soft Particles", Range(0, 1)) = 0
		[Main(_FresnelFadeGroup,USE_FRESNEL_FADING)] _UseFresnelFading("Use Fresnel Fading", Int) = 0
		[Sub(_FresnelFadeGroup)]_FresnelFadeFactor("Fresnel Fade Factor", Float) = 3
		[Space]
		[Header(Light)]
		[Space]
		[Header(Noise Distortion)]
		[Main(_NoiseGroup,USE_NOISE_DISTORTION)] _UseNoiseDistortion("Use Noise Distortion", Int) = 0
		[Sub(_NoiseGroup)]_NoiseTex("Noise Texture (RG)", 2D) = "black" {}
	    [Sub(_NoiseGroup)]_DistortionSpeedScale("Speed (XY) Scale(XY)", Vector) = (1, -1, .15, .15)
		[Sub(_NoiseGroup)]_UseVertexStreamRandom("Use Vertex Stream Random", Int) = 0
		[Space]
		[Header(Fresnel)]
		[Main(_FersnelGroup,USE_FRESNEL)] _UseFresnel("Use Fresnel", Int) = 0
		[Sub(_FersnelGroup)][HDR]_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		[Sub(_FersnelGroup)]_FresnelPow("Fresnel Pow", Float) = 5
		[Sub(_FersnelGroup)]_FresnelR0("Fresnel R0", Float) = 0.04
		[Space]
		[Header(Cutout)]
		[Main(_CutoutGroup,USE_CUTOUT)] _UseCutout("Use Cutout", Int) = 0
		[Sub(_CutoutGroup)][PerRendererData]	_Cutout("Cutout", Range(0, 1)) = 1
		[Sub(_CutoutGroup)]_UseSoftCutout("Use Soft Cutout", Int) = 0
		[Sub(_CutoutGroup)]_UseParticlesAlphaCutout("Use Particles Alpha", Int) = 0
		[Main(_CutoutTextureGroup,USE_CUTOUT_TEX)] _UseCutoutTex("Use Cutout Texture", Int) = 0
		[Sub(_CutoutTextureGroup)]_CutoutTex("Cutout Tex", 2D) = "white" {}
		[Main(_CutoutThresholdGroup,USE_CUTOUT_THRESHOLD)] _UseCutoutThreshold("Use Cutout Threshold", Int) = 0
		[Sub(_CutoutThresholdGroup)][HDR]_CutoutColor("Cutout Color", Color) = (1,1,1,1)
		[Sub(_CutoutThresholdGroup)]_CutoutThreshold("Cutout Threshold", Range(0, 1)) = 0.015
		[Space]
		[Header(Rendering)]
		[Toggle(_FLIPBOOK_BLENDING)] _UseFrameBlending("Use Frame Blending", Int) = 0
		[Toggle] _ZWriteMode("ZWrite On?", Int) = 0
		[Enum(Cull Off,0, Cull Front,1, Cull Back,2)] _CullMode("Culling", Float) = 0 //0 = off, 2=back
		[KeywordEnum(Add, Blend, Mul)] _BlendMode("Blend Mode", Float) = 1
		[HideInInspector]_SrcMode("SrcMode", int) = 5
		[HideInInspector]_DstMode("DstMode", int) = 10
	}
		SubShader{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline"}
		
		Pass{
		Blend[_SrcMode][_DstMode]
		Cull[_CullMode]
		ZWrite[_ZWriteMode]
		Name "Portal"
        Tags { "LightMode" = "SceneEffect" }
		HLSLPROGRAM
		#pragma target 2.0
		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x
		#pragma vertex vert
		#pragma fragment frag
				//#pragma target 3.0

		#pragma multi_compile_fog
		#pragma shader_feature USE_NOISE_DISTORTION
		#pragma shader_feature USE_FRESNEL
		#pragma shader_feature USE_CUTOUT
		#pragma shader_feature USE_CUTOUT_TEX
		#pragma shader_feature USE_CUTOUT_THRESHOLD

		#pragma shader_feature USE_FRESNEL_FADING
		#pragma shader_feature _FLIPBOOK_BLENDING
		#pragma shader_feature USE_SCRIPT_FRAMEBLENDING
		#pragma shader_feature _FADING_ON

		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		sampler2D _MainTex;
		sampler2D _NoiseTex;
		sampler2D _CutoutTex;
		CBUFFER_START(UnityPerMaterial)
			float4 _TintColor;
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			float4 _CutoutTex_ST;
			float4 _MainTex_NextFrame;
			half4 _CutoutColor;
			half4 _FresnelColor;
			half4 _DistortionSpeedScale;
			half _InvFade;
			half _SoftInverted;
			//half _LightTranslucent;
			half _FresnelFadeFactor;
			half _FresnelPow;
			half _FresnelR0;
			half _CutoutThreshold;
			half InterpolationValue;
			half _UseSoftCutout;
			half _UseParticlesAlphaCutout;
			half _UseVertexStreamRandom;
			half _Cutout;
		CBUFFER_END
		float4x4 unity_Projector;
		float4x4 unity_ProjectorClip;
		struct appdata_t {
		float4 vertex : POSITION;
		float4 normal : NORMAL;
		half4 color : COLOR;
#ifdef _FLIPBOOK_BLENDING
		float2 texcoord : TEXCOORD0;
		float4 texcoordBlendFrame : TEXCOORD1;
#ifdef USE_NOISE_DISTORTION
		float4 randomID : TEXCOORD2;
#endif
#else
		float2 texcoord : TEXCOORD0;
#ifdef USE_NOISE_DISTORTION
		float4 randomID : TEXCOORD1;
#endif
#endif

		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f {
		float4 vertex : SV_POSITION;
		half4 color : COLOR;

#ifdef _FLIPBOOK_BLENDING
		float4 texcoord : TEXCOORD0;
		half blend : TEXCOORD1;
#else
		float2 texcoord : TEXCOORD0;
#endif

#if defined (USE_NOISE_DISTORTION) || defined (USE_CUTOUT_TEX)
		float4 noiseCutoutTexcoord : TEXCOORD2;
#endif
#ifdef USE_NOISE_DISTORTION
		float randomID : TEXCOORD3;
#endif

#ifdef _FADING_ON

			float4 projPos : TEXCOORD5;

#endif

#if defined (USE_FRESNEL_FADING) || defined (USE_FRESNEL)
		float fresnel : TEXCOORD6;
#endif

#ifdef USE_SCRIPT_FRAMEBLENDING
		float2 scriptTexcoord : TEXCOORD9;
#endif

		UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
	};


	v2f vert(appdata_t v)
	{
		v2f o;
		VertexPositionInputs positionInputs = GetVertexPositionInputs(v.vertex.xyz);
		o.vertex = positionInputs.positionCS;
#ifdef _FADING_ON

		o.projPos = ComputeScreenPos(o.vertex);
		o.projPos.z = -positionInputs.positionVS.z;

#endif
		o.color = v.color;

		o.texcoord.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
#ifdef _FLIPBOOK_BLENDING
		o.texcoord.zw = TRANSFORM_TEX(v.texcoordBlendFrame.xy, _MainTex);
		o.blend = v.texcoordBlendFrame.z;
#endif

#ifdef USE_SCRIPT_FRAMEBLENDING
		o.scriptTexcoord = v.texcoord.xy * _MainTex_NextFrame.xy + _MainTex_NextFrame.zw;
#endif

#if defined (USE_NOISE_DISTORTION) || defined (USE_CUTOUT_TEX)
		o.noiseCutoutTexcoord = 0;
#endif

#ifdef USE_NOISE_DISTORTION
		o.noiseCutoutTexcoord.xy = TRANSFORM_TEX(v.texcoord, _NoiseTex);
#endif

#ifdef USE_CUTOUT_TEX
		o.noiseCutoutTexcoord.zw = TRANSFORM_TEX(v.texcoord, _CutoutTex);
#endif

#ifdef USE_NOISE_DISTORTION
		o.randomID = dot(v.randomID, 255) * _UseVertexStreamRandom;
#endif

#if defined (USE_FRESNEL_FADING) || defined (USE_FRESNEL)
        float3 objSapceCameraPos = TransformWorldToObject(_WorldSpaceCameraPos);
		half fresnel = abs(dot(normalize(v.normal.xyz), normalize(objSapceCameraPos - v.vertex.xyz)));
#ifdef USE_FRESNEL_FADING
		o.fresnel = saturate(pow(fresnel, _FresnelFadeFactor) * _FresnelFadeFactor);
#endif
#ifdef USE_FRESNEL
		o.fresnel = 1 - fresnel;
		o.fresnel = pow(o.fresnel, _FresnelPow);
		o.fresnel = saturate(_FresnelR0 + (1.0 - _FresnelR0) * o.fresnel);
#endif
#endif
			return o;
	}


	half4 frag(v2f i) : SV_Target
	{


#ifdef _FADING_ON

		float z = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,sampler_CameraDepthTexture, i.projPos.xy/ i.projPos.w).r;
		float sceneZ = LinearEyeDepth(z,_ZBufferParams);
		float partZ = i.projPos.z;
		float fade = saturate(_InvFade * (sceneZ - partZ));
		fade = lerp(fade, 1 - fade, _SoftInverted);
		i.color.a *= fade;

#endif

#ifdef USE_NOISE_DISTORTION
	half2 noiseMask;
	float time = _Time.x;

	time += i.randomID;

	half2 mask1 = tex2D(_NoiseTex, i.noiseCutoutTexcoord.xy + _DistortionSpeedScale.x * time) * 2 - 1;
	half2 mask2 = tex2D(_NoiseTex, i.noiseCutoutTexcoord.xy - _DistortionSpeedScale.x * time * 1.4 + float2(0.4, 0.6)) * 2 - 1;
	half2 mask3 = tex2D(_NoiseTex, i.noiseCutoutTexcoord.xy * 3 + _DistortionSpeedScale.y * time) * 2 - 1;
	half2 mask4 = tex2D(_NoiseTex, i.noiseCutoutTexcoord.xy * 3 - _DistortionSpeedScale.y * time * 1.25 + float2(0.3, 0.7)) * 2 - 1;
	noiseMask = (mask1 + mask2) * _DistortionSpeedScale.z + (mask3 + mask4) * _DistortionSpeedScale.w;

	i.texcoord.xy += noiseMask;
#ifdef _FLIPBOOK_BLENDING
	i.texcoord.zw += noiseMask;
#endif
#ifdef USE_CUTOUT_TEX
	i.noiseCutoutTexcoord.zw += noiseMask;
#endif

#endif

	half4 tex = tex2D(_MainTex, i.texcoord);

#ifdef _FLIPBOOK_BLENDING
	half4 tex2 = tex2D(_MainTex, i.texcoord.zw);
	tex = lerp(tex, tex2, i.blend);
#endif

#ifdef USE_SCRIPT_FRAMEBLENDING
	half4 tex3 = tex2D(_MainTex, i.scriptTexcoord);
	tex = lerp(tex, tex3, InterpolationValue);
#endif

	half4 tintColor = UNITY_ACCESS_INSTANCED_PROP(_TintColor_arr, _TintColor);
	tintColor.rgb = tintColor.rgb * tintColor.rgb * 2;
	half4 res = 2 * tex *  tintColor;

#ifdef USE_CUTOUT
	half cutout = lerp(_Cutout, (1.001 - i.color.a + _Cutout), _UseParticlesAlphaCutout);

#ifdef USE_CUTOUT_TEX
	half mask = tex2D(_CutoutTex, i.noiseCutoutTexcoord.zw);
#else
	half mask = tex.a;
#endif

	half diffMask = mask - cutout;
	half alphaMask = lerp(saturate(diffMask * 10000) * res.a, saturate(diffMask * 2) * res.a, _UseSoftCutout);

#ifdef USE_CUTOUT_THRESHOLD
	half alphaMaskThreshold = saturate((diffMask - _CutoutThreshold) * 10000) * res.a;
	res.rgb = lerp(res.rgb, _CutoutColor.rgb * _CutoutColor.rgb * 2, saturate((1 - alphaMaskThreshold) * alphaMask));
	res.a = alphaMask;
#else
	res.a = alphaMask;
#endif

#endif

	res *= i.color;


#ifdef USE_FRESNEL_FADING
	res.a *= i.fresnel;
#endif

#ifdef USE_FRESNEL
	res.rgb += i.fresnel *  _FresnelColor.rgb * _FresnelColor.rgb * 2;
#endif

	res.a = saturate(res.a);
		return res;
	}
		ENDHLSL
	}
	}
		CustomEditor "JTRP.ShaderDrawer.LWGUI"
}
