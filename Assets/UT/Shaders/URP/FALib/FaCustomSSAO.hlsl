#ifndef FA_CUSTOM_SSAO
#define FA_CUSTOM_SSAO

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"

// --------- 2021把该方法放在AmbientOcclusion.hlsl中，并被_SCREEN_SPACE_OCCLUSION限制了，所以在这里重写 -------------------- //  
half CustomSampleAmbientOcclusion(float2 normalizedScreenSpaceUV)                                                     //
{                                                                                                                     //
    float2 uv = UnityStereoTransformScreenSpaceTex(normalizedScreenSpaceUV);                                         //
    return SAMPLE_TEXTURE2D_X(_ScreenSpaceOcclusionTexture, sampler_ScreenSpaceOcclusionTexture, uv).x;               //
}                                                                                                                     //
                                                                                                                      //
                                                                                                                   //
// ------------------------------------------------------------------------------------------------------------------ //

#endif