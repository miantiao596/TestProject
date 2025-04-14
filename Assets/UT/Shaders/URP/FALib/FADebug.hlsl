#ifndef FA_DEBUG_H
#define FA_DEBUG_H
// Global
//float _EnableShadingDebug;
#pragma shader_feature _ _ENABLE_SHADING_DEBUG
float _ShadingDebugCase;

half4 SHADING_DEBUG_RESULT(FASurfaceData surfaceData, FABRDFData brdfData)
{
    switch(_ShadingDebugCase)
    {
        // Metallic     金属度
        case 0:		return half4(surfaceData.metallic, surfaceData.metallic, surfaceData.metallic, 1);
        // Emission     自发光
        case 1:     return half4(surfaceData.emission, 1);
        // Diffuse      漫反射
        case 2:		return half4(brdfData.diffuse, 1);
        // Specular     高光
        case 3:		return half4(brdfData.specular, 1);
        // Roughness    粗糙度
        case 4:		return half4(brdfData.roughness, brdfData.roughness, brdfData.roughness, 1);
        // Occlusion    遮挡
        case 5:     return half4(surfaceData.occlusion, surfaceData.occlusion, surfaceData.occlusion, 1);
        // LightsCount  光源数量
        case 6:
        {
            int lightsCount = unity_LightData.y;
            if (lightsCount > 8) return half4(1, 0, 0, 1);
            return half4(lightsCount, lightsCount, lightsCount, 1) / 8;
        }
        default:    return half4(1, 1, 1, 1);
    }
}

half4 OutputDebugColor(FASurfaceData surfaceData, FABRDFData brdfData)
{
    return SHADING_DEBUG_RESULT(surfaceData, brdfData);
}

#endif