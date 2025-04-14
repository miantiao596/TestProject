#ifndef FAEFFECTLIB_INCLUDED
	#define FAEFFECTLIB_INCLUDED

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

	#if _IN_UI_ON
		#define PARTICLE_COLOR(color) color = FastLinearToSRGB(color);
	#else
		#define PARTICLE_COLOR(color)
	#endif

	half4 PARTILE_TEXTURE2D(Texture2D tex, SamplerState samplerTex, float2 uv, half4 channelMask = half4(1,1,1,1))
	{
		half4 varTex = SAMPLE_TEXTURE2D(tex, samplerTex, uv);
		half4 varTex1 = dot(varTex, channelMask);	// 单通道
		half4 varTex2 = varTex;						// RGBA需要做UI处理
		PARTICLE_COLOR(varTex2)
		half isRGBA = step(1, (channelMask.x + channelMask.y + channelMask.z + channelMask.w)/4);
		varTex = lerp(varTex1, varTex2, isRGBA);
		return varTex;
	}


	// 溶解
	#ifdef _DISSOLUTION_ON
		half4 GetDissolutionColor(half4 colorSource, float2 uvTex, half customPercent = 0)
		{
			//if (customPercent > 0)
			{
				half soft = clamp(_DissolutionSoftEdge, 0.0001, 1);
				half4 varDissolutionTex = SAMPLE_TEXTURE2D(_DissolutionTex, sampler_DissolutionTex, uvTex);
				float factor = dot(varDissolutionTex, _DissolutionTex_ChannelMask);
				factor = clamp(factor, 0, 1);
				factor = lerp(factor, 1-factor, _DissolutionReverse);
				factor -= customPercent;

				float factor1 = 1 + clamp(factor / soft, -1, 1);
				colorSource.a *= factor1;
				clip(colorSource.a - 0.01);

				float factor2 = (factor - _DissolutionEdgeWidth) * (1 - step(_DissolutionEdgeWidth, 0));
				factor2 = saturate(1 +  factor2 / soft);
				half4 edgeColor = _DissolutionEdgeColor;
				PARTICLE_COLOR(edgeColor)
				colorSource.rgb = lerp(edgeColor.rgb, colorSource.rgb, factor2);
			}

			return colorSource;
		}
#endif
	// 扭曲
	#ifdef _DISTORTION_ON
		float2 GetDistortionUV(float2 uvSource,  float2 uvTex, half customdata )
		{
			half4 varDistortionTex = SAMPLE_TEXTURE2D(_DistortionTex, sampler_DistortionTex, uvTex);
			float distortion = dot(varDistortionTex, _DistortionTex_ChannelMask) * customdata;
			float2 uv = uvSource + distortion.xx;
			return uv;
		}
	#endif
#endif