#ifndef XPOSTPROCESSING_LIB
#define XPOSTPROCESSING_LIB

/*-------------------------------DigitalStripe------------------------------------*/
half2 DigitalStripe_GetShiftedUV(half indensity,
								half threshold,
								half4 stripNoise)
{
	half uvShift = step(threshold, pow(abs(stripNoise.x), 3));
	half2 final_UVShift = stripNoise.yz * uvShift;
	return final_UVShift;
}

half4 AdjustStripColor(
					half4 source,
					half4 stripColorAdjustColor,
					half stripColorAdjustIndensity,
					half threshold,
					half indensityFactor)
{
	half stripIndensity = step(threshold, pow(abs(indensityFactor), 3)) * stripColorAdjustIndensity;
	half3 desColor = lerp(source, stripColorAdjustColor, stripIndensity).rgb;
	return float4(desColor, source.a);
}

//@param indensity DigitalStripe的强度
//@param mainTexture 颜色贴图
//@param mainUV 用于采集mainTexture的uv
//@param noiseTexture 噪声贴图
//@param noiseUV 用于采集noiseTexture的uv
//@param stripColorAdjustColor 偏移色块目标颜色
//@param stripColorAdjustIndensity 原本颜色到色块目标颜色的插值系数，若=1，则偏移色块为stripColorAdjustColor，若为0,则等于原本颜色
//@return 最终颜色(一般用于偏移_MainTex的采集UV)
half4 DigitalStripe(half indensity,
					sampler2D mainTexture,half2 mainUV,
					sampler2D noiseTexture,half2 noiseUV,
					half4 stripColorAdjustColor,
					half stripColorAdjustIndensity)
{
	half4 stripNoise = tex2D(noiseTexture, noiseUV);
	half threshold = 1.001 - indensity * 1.001;

	half2 finalShiftedUV = DigitalStripe_GetShiftedUV(indensity,threshold,stripNoise);
	half4 source = tex2D(mainTexture,frac(mainUV + finalShiftedUV));
//#ifndef NEED_TRASH_FRAME
//		return source;
//#endif
	half4 finalColor = AdjustStripColor(source,stripColorAdjustColor,stripColorAdjustIndensity,threshold,stripNoise.w);
	return finalColor;
}

/*------------ScanLineJitter Start--------------*/
half2 ScanLineJitter_GetShiftedUV(float2 uv,float direction,float amount,float threshold ,float frequency)
{
	float strength = 0;
	strength = 0.5 + 0.5 * cos(_Time.y * frequency);
	float horizontal_jitter = Random_Float(uv.y, _Time.x) * 2 - 1;
	float vertical_jitter = Random_Float(uv.x, _Time.x) * 2 - 1;

	float jitter = lerp(horizontal_jitter,vertical_jitter,direction);
	jitter *= step(threshold, abs(jitter)) * amount * strength;

	float2 shiftedUV = lerp(float2(jitter, 0),float2(0, jitter),direction);
	return shiftedUV;
}
/*-------------LineBlock--------------------------*/
float trunc(float x, float num_levels)
{
	return floor(x * num_levels) / num_levels;
}
	
float2 trunc(float2 x, float2 num_levels)
{
	return floor(x * num_levels) / num_levels;
}
#endif