#ifndef FA_PUBLIC_FUNCTION
#define FA_PUBLIC_FUNCTION

float3 RotateAroundAxis(float3 center, float3 original, float3 axis, float angle)
{
    original -= center;
    float C = cos( angle );
    float S = sin( angle );
    float t = 1 - C;
    axis = normalize(axis);
    
    float m00 = t * axis.x * axis.x + C;
    float m01 = t * axis.x * axis.y - S * axis.z;
    float m02 = t * axis.x * axis.z + S * axis.y;
    float m10 = t * axis.x * axis.y + S * axis.z;
    float m11 = t * axis.y * axis.y + C;
    float m12 = t * axis.y * axis.z - S * axis.x;
    float m20 = t * axis.x * axis.z - S * axis.y;
    float m21 = t * axis.y * axis.z + S * axis.x;
    float m22 = t * axis.z * axis.z + C;
    float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
    return mul( finalMatrix, original ) + center;
}

// 绕轴旋转-角度
float3 DegreesRotateAboutAxis(float3 position, float3 axis, float3 rotation)
{
    rotation = radians(rotation);
    //float s = sin(rotation);
    //float c = cos(rotation);
    //float one_minus_c = 1.0 - c;
    
    //axis = normalize(axis);
    //float3x3 rotate_matrix = {
    //    one_minus_c * axis.x * axis.x + c, one_minus_c * axis.x * axis.y - axis.z * s, one_minus_c * axis.z * axis.x + axis.y * s,
    //    one_minus_c * axis.x * axis.y + axis.z * s, one_minus_c * axis.y * axis.y + c, one_minus_c * axis.y * axis.z - axis.x * s,
    //    one_minus_c * axis.z * axis.x - axis.y * s, one_minus_c * axis.y * axis.z + axis.x * s, one_minus_c * axis.z * axis.z + c
    //};
    //return mul(rotate_matrix, position);
    return RotateAroundAxis(half3(0, 0, 0), position, axis, rotation);
}

// 视差偏移-切线空间
float2 ParallaxOffset(half h, half height, half3 viewDirTan)
{
    h = h * height - height / 2.0;
    float3 v = normalize(viewDirTan);
    v.z += 0.42;
    return h * (v.xy / v.z);
}

float2 ParallaxMapping(half2 uv, half height, half scale, half3 viewDirTS)
{
    return uv + (height - 1) * (viewDirTS.xy / viewDirTS.z) * scale;
}

// remap
float4 Remap(float4 input, float2 inMinMax, float2 outMinMax)
{
    return outMinMax.x + (input - inMinMax.x) * (outMinMax.y - outMinMax.x) / (inMinMax.y - inMinMax.x);
}

// 菲尼尔
float Fresnel(float3 normal, float3 viewDir, float bias, float scale = 1, float power = 5)
{
    return bias + scale * pow(1.0 - saturate(dot(normalize(normal), normalize(viewDir))), power);
}

// Blend Multiply
float4 Blend_Multiply(float4 base, float4 blend, float opacity)
{
    float4 result = base * blend;
    result = lerp(base, result, opacity);
    return result;
}

// Overlay
float4 Blend_Overlay(float4 base, float4 blend, float opacity)
{
    float4 result1 = 1.0 - 2.0 * (1.0 - base) * (1.0 - blend);
    float4 result2 = 2.0 * base * blend;
    float4 zeroOrOne = step(base, 0.5);
    float4 result = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    result = lerp(base, result, opacity);
    return result;
}
#endif