#ifndef DISSOLVE_BLOOD_INPUT
    #define DISSOLVE_BLOOD_INPUT
    
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
    
    CBUFFER_START(UnityPerMaterial)
    half4 _CombinedScaledParams;
    half4 _Color;
    half4 _EmissionColor;
    half _Emissive_Intensity;
    float4 _MainTex_ST;
    float4 _CombinedAO_ST;
    half _BumpScale;
    half _Cutoff;
    half _TPA;
        
    half _FogMode;
    half _FogIntensity;

    half4 _DissolveTex_ST;
    half4 _DetailTex_ST;
    half _DissolveMin;
    half _DissolveMax;
    half _DissolveUVOffset;
    half _DissolveStrength;
    half _AlphaComplement;
    half _UseCustomData;

    CBUFFER_END
    
    TEXTURE2D(_MainTex);				SAMPLER(sampler_MainTex);
    TEXTURE2D(_CombinedAO);				SAMPLER(sampler_CombinedAO);
    TEXTURE2D(_EmissionTex);			SAMPLER(sampler_EmissionTex);
    TEXTURE2D(_DissolveTex);				SAMPLER(sampler_DissolveTex);
    TEXTURE2D(_DetailTex);					SAMPLER(sampler_DetailTex);
#endif
