#ifndef UI_SHADER_LIB
#define UI_SHADER_LIB

// 在范围内，返回1；否则返回0
int InRange1(float x, float min, float max)
{
	return step(min, x) * step(x, max);
}

/**
 * 边缘挤压
 * 以中心(0.5)为界,将值向两侧拉伸
 */
half EdgeCollapse(half value, half scale)
{
	int flag = 1 - 2 * step(0.5, value);	// 左1右-1
	half edge = step(0.5, value);			// 左0右1
	half width = flag * (value - edge);
	value = edge + clamp(width*scale, 0, 0.5) * flag;
	return value;
}

/**
 * MaskRange方案
 * uvLimit：限定UV采样范围，左、右、下、上
 */
half CalcUIMaskAlpha(sampler2D tex, float3 worldPos, float4 maskRange, float4 uvLimit, float scaleX, float scaleY)
{
	float2 maskUV = (worldPos.xy - maskRange.xy) / maskRange.zw;
	half adjust = InRange1(maskUV.x, 0, 1) * InRange1(maskUV.y, 0, 1);
	
	// 修正MaskTexutre缩放的问题
	maskUV.x = EdgeCollapse(maskUV.x, scaleX);
	maskUV.y = EdgeCollapse(maskUV.y, scaleY);

	//通过uvLimit的限定，来决定使用遮罩图的上下限，进而决定遮罩的范围
	maskUV.x = clamp(maskUV.x, uvLimit.x, uvLimit.y);
	maskUV.y = clamp(maskUV.y, uvLimit.z, uvLimit.w);
	// 这里的宏判断反而会导致平台差异，注释掉
	// #if UNITY_UV_STARTS_AT_TOP
	// 	maskUV.y = 1 - maskUV.y;
	// #endif

	half4 maskColor = tex2D(tex, maskUV);
	#ifdef _USEALPHACHANNEL_ON
		return maskColor.a * adjust;
	#else
		return maskColor.r * adjust;
	#endif
}

// Alpha Mask需要的变量参数定义
// _UIMaskUVLimit : 左、右、下、上
// _UIMaskRange : 左下x, y, w, h
#define UI_ALPHA_MASK_DEFINE \
	    sampler2D _UIAlphaMaskTex; \
        float4 _UIMaskUVLimit; \
        float4 _UIMaskRange; \
		float _UIMaskTexScaleX; \
		float _UIMaskTexScaleY;

// UI Mask frag着色器便捷宏
#define UI_ALPHA_MASK_FRAG_COLOR(worldPos) \
	CalcUIMaskAlpha(_UIAlphaMaskTex, worldPos, _UIMaskRange, _UIMaskUVLimit, _UIMaskTexScaleX, _UIMaskTexScaleY)

#endif