#ifndef MATH_EXTENSION_LIB
#define MATH_EXTENSION_LIB

float Random_Float(float2 seed)
{
	return frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453);
}

float Random_Float(float x, float y)
{
	float2 seed = float2(x, y);
	return Random_Float(seed);
}

float RandomRange_Float(float2 seed, float min, float max)
{
	float randomno =  frac(sin(dot(seed, float2(12.9898, 78.233)))*43758.5453);
	return lerp(min, max, randomno);
}

#endif