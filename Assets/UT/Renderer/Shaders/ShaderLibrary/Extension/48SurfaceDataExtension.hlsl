#ifndef UNIVERSAL_SURFACEEXTENSION_INCLUDED
#define UNIVERSAL_SURFACEEXTENSION_INCLUDED

struct SurfaceData48
{
    float Anisotropy;
    half4 sequinSpecular;
    half3 sequinNormalTS;
    half  sequinMask;
    half  sequinBrightness;
    half  smoothnessB;
    half lobeMix;
    half thickness;
    half subsurfaceMask;

    half3 clearCoatNormalTS;
};
#endif