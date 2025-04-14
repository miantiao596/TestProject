#ifndef FA_SHADER_UTILS
	#define FA_SHADER_UTILS

	// 围绕贴图中心旋转贴图UV一定的角度
	inline half2 RotateUV(half2 sourceUV, float angle, float speed)
	{
		half2 pivot = half2(0.5, 0.5);
		float rotate = speed * angle * 0.0174444;
		float sinAngle = sin(rotate);
		float cosAngle = cos(rotate);
		float2x2 rotateMat = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
		half2 rotUV = sourceUV - pivot;
		half2 result = mul(rotUV, rotateMat) + pivot;
		return result;
	}
	// 围绕贴图中心以一定速度旋转贴图
    inline half2 RotateUVBySpeed(half2 sourceUV, float speed, float time)
    {             
        float2 uv = sourceUV.xy - float2(0.5, 0.5);
        float2 rotate = float2(cos(speed * time), sin(speed * time));
        uv = float2(uv.x * rotate.x - uv.y * rotate.y, uv.x * rotate.y + uv.y * rotate.x);
        uv += float2(0.5, 0.5);
        return uv;
    }

	// 返回一个PingPong的函数。。取值范围是[0,2]
	float PingPong(float input){
		float v = fmod(input, 2);
		float v2 = fmod(input, 4);
		float t = step(v2, 2);
		return t > 0.5 ? v : 2 - v;
	}

	// >>> 噪声函数
	float noise(float2 co)
	{
		return frac(sin(dot(co.xy, float2(12.9898,78.233))) * 43758.5453);
	}

	float2 hash22(float2 p)
	{
		p = float2(dot(p, float2(127.1, 311.7)),
		dot(p, float2(269.5, 183.3)));

		return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
	}

	float perlin_noise(float2 p)
	{
		float2 pi = floor(p);
		float2 pf = p - pi;

		float2 w = pf * pf * (3.0 - 2.0 * pf);

		return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
		dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x),
		lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
		dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x),
		w.y);
	}
	// <<<

	// 视差函数
	float2 ParallaxOffset( half h, half height, half3 viewDir )
	{
		h = h * height - height/2.0;
		float3 v = normalize( viewDir );
		v.z += 0.42;
		return h* (v.xy / v.z);
	}
#endif