#pragma shader_feature _ _ENABLE_HEIGHT_FOG_SHADING_DEBUG

float4 OutputHeightFogColor(float3 fogColor, float fogFactor)
{
    return float4(fogColor * (1 - fogFactor), 1);
}