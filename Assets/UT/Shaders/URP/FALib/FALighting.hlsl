//#include "Packages/com.mole.forwardplus/Resources/Shader/ForwardPlus/ForwardPlusLib.hlsl"
//#include "Packages/com.mole.forwardplus/Resources/Shader/ForwardPlus/ForwardPlusInput.hlsl"
#ifdef _FORWARD_PLUS_Z_BINING
#include "Packages/com.mole.forwardplus/ShaderLibrary/ForwardPlusWithZBin/ForwardPlusWithZBinInput.hlsl"
#include "Packages/com.mole.forwardplus/ShaderLibrary/ForwardPlusWithZBin/ForwardPlusWithZbinClustering.hlsl"
#endif


#include "FALightingSimple.hlsl"
// 对应官方的SurfaceData
// struct FASurfaceData
// {
// 	half3 albedo;
// 	//half3 specular;
// 	half  metallic;
// 	half  smoothness;
// 	half3 normalTS;
// 	half3 emission;
// 	half  occlusion;
// 	half  alpha;
// //#ifdef _IRIDESCENCE
// //    half iridescenceThickness;
// //    half iridescenceEta2;
// //    half iridescenceEta3;
// //    half iridescenceKappa3;
// //#endif
// };

//对应官方的BRDFData
// struct FABRDFData
// {
//     half3 diffuse;
//     half3 specular;
//     half reflectivity;
//     half perceptualRoughness;
//     half roughness;
//     half roughness2;
//     half grazingTerm;
//
//     // We save some light invariant BRDF terms so we don't have to recompute
//     // them in the light loop. Take a look at DirectBRDF function for detailed explaination.
//     half normalizationTerm;     // roughness * 4.0 + 2.0
//     half roughness2MinusOne;    // roughness² - 1.0
//
// //#ifdef _IRIDESCENCE
// //    half iridescenceThickness;
// //    half iridescenceEta2;
// //    half iridescenceEta3;
// //    half iridescenceKappa3;
// //#endif
// };

/////////////////////////////////////////////////////////////////////////////////////


// Computes the specular term for EnvironmentBRDF
// half3 FAEnvironmentBRDFSpecular(FABRDFData brdfData, half fresnelTerm)
// {
//     float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
//     return surfaceReduction * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm);
// }

// half3 FAEnvironmentBRDF(FABRDFData brdfData, half3 indirectDiffuse, half3 indirectSpecular, half fresnelTerm)
// {
//     half3 c = indirectDiffuse * brdfData.diffuse;
//     c += indirectSpecular * FAEnvironmentBRDFSpecular(brdfData, fresnelTerm);
//     return c;
// }

// Computes the scalar specular term for Minimalist CookTorrance BRDF
// NOTE: needs to be multiplied with reflectance f0, i.e. specular color to complete
// half FADirectBRDFSpecular(FABRDFData brdfData, float3 normalWS, half3 lightDirectionWS, float3 viewDirectionWS)
// {
//     half3 halfDir = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));
//     float NoH = saturate(dot(normalWS, halfDir));
//     half LoH = saturate(dot(lightDirectionWS, halfDir));
//
//     // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
//     // BRDFspec = (D * V * F) / 4.0
//     // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
//     // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
//     // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
//     // https://community.arm.com/events/1155
//
//     // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
//     // We further optimize a few light invariant terms
//     // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
//     float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;
//
//     half LoH2 = LoH * LoH;
//     half specularTerm = brdfData.roughness2 / ((d * d) * max(0.1h, LoH2) * brdfData.normalizationTerm);
//
//     // On platforms where half actually means something, the denominator has a risk of overflow
//     // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
//     // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
// //#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
//     specularTerm = specularTerm - HALF_MIN;
//     specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
// //#endif
// 	return specularTerm;
// }

///////////////////////////////////////////////////////////////////////////////
//                        Iridescence Functions                               /
///////////////////////////////////////////////////////////////////////////////
#ifdef _IRIDESCENCE

//half SampleIridescenceThickness(float2 uv)
//{
//    half iridescenceThickness;
//    iridescenceThickness = SAMPLE_TEXTURE2D(_IridescenceThicknessMap, sampler_IridescenceThicknessMap, uv).r;
//    iridescenceThickness = _IridescenceThicknessRemap.x + iridescenceThickness * (_IridescenceThicknessRemap.y - _IridescenceThicknessRemap.x);
//    return iridescenceThickness;
//}

// XYZ to CIE 1931 RGB color space (using neutral E illuminant)
//static const half3x3 XYZ_TO_RGB = half3x3(2.3706743, -0.5138850, 0.0052982, -0.9000405, 1.4253036, -0.0146949, -0.4706338, 0.0885814, 1.0093968);

//inline float sqr(float x) { return x * x; }
//inline float2 sqr(float2 x) { return x * x; }
// Depolarization functions for natural light
//inline float depol(float2 polV) { return 0.5 * (polV.x + polV.y); }
//inline half3 depolColor(half3 colS, half3 colP) { return 0.5 * (colS + colP); }

// Evaluation XYZ sensitivity curves in Fourier space
//float3 evalSensitivity(float opd, float shift) {

//    // Use Gaussian fits, given by 3 parameters: val, pos and var
//    float phase = 2 * PI * opd * 1.0e-6;
//    float3 val = float3(5.4856e-13, 4.4201e-13, 5.2481e-13);
//    float3 pos = float3(1.6810e+06, 1.7953e+06, 2.2084e+06);
//    float3 var = float3(4.3278e+09, 9.3046e+09, 6.6121e+09);
//    float3 xyz = val * sqrt(2.0 * PI * var) * cos(pos * phase + shift) * exp(-var * phase * phase);
//    xyz.x += 9.7470e-14 * sqrt(2.0 * PI * 4.5282e+09) * cos(2.2399e+06 * phase + shift) * exp(-4.5282e+09 * phase * phase);
//    return xyz / 1.0685e-7;
//}

// GGX distribution function
//float GGX(float NdotH, float a) 
//{
//    float a2 = sqr(a);
//    return a2 / (PI * sqr(sqr(NdotH) * (a2 - 1) + 1));
//}

// Smith GGX geometric functions
//float smithG1_GGX(float NdotV, float a) 
//{
//    float a2 = sqr(a);
//    return 2 / (1 + sqrt(1 + a2 * (1 - sqr(NdotV)) / sqr(NdotV)));
//}

//float smithG_GGX(float NdotL, float NdotV, float a) 
//{
//    return smithG1_GGX(NdotL, a) * smithG1_GGX(NdotV, a);
//}

// Fresnel equations for dielectric/dielectric interfaces.
//void fresnelDielectric(in float ct1, in float n1, in float n2, out float2 R, out float2 phi) 
//{

//    float st1 = (1 - ct1 * ct1); // Sinus theta1 'squared'
//    float nr = n1 / n2;

//    //if (sqr(nr) * st1 > 1) { // Total reflection
//    //    //这段没生效，之前这里代码甚至是错的，走到就变粉
//    //    R = float2(1, 1);
//    //    phi = 2.0 * atan(float2(-sqr(nr) * sqrt(st1 - 1.0 / sqr(nr)) / ct1,
//    //        -sqrt(st1 - 1.0 / sqr(nr)) / ct1));
//    //}
//    //else {   // Transmission & Reflection

//        float ct2 = sqrt(1 - sqr(nr) * st1);
//        float2 r = float2((n2 * ct1 - n1 * ct2) / (n2 * ct1 + n1 * ct2),
//            (n1 * ct1 - n2 * ct2) / (n1 * ct1 + n2 * ct2));
//        phi.x = (r.x < 0.0) ? PI : 0.0;
//        phi.y = (r.y < 0.0) ? PI : 0.0;
//        R = sqr(r);
//    //}
//}

// Fresnel equations for dielectric/conductor interfaces.
//void fresnelConductor(in float ct1, in float n1, in float n2, in float k,
//    out float2 R, out float2 phi) {

//    if (k == 0) { // use dielectric formula to avoid numerical issues
//        fresnelDielectric(ct1, n1, n2, R, phi);
//        return;
//    }

//    float A = sqr(n2) * (1 - sqr(k)) - sqr(n1) * (1 - sqr(ct1));
//    float B = sqrt(sqr(A) + sqr(2 * sqr(n2) * k));
//    float U = sqrt((A + B) / 2.0);
//    float V = sqrt((B - A) / 2.0);

//    R.y = (sqr(n1 * ct1 - U) + sqr(V)) / (sqr(n1 * ct1 + U) + sqr(V));
//    phi.y = atan2(2 * n1 * V * ct1, sqr(U) + sqr(V) - sqr(n1 * ct1)) + PI;

//    R.x = (sqr(sqr(n2) * (1 - sqr(k)) * ct1 - n1 * U) + sqr(2 * sqr(n2) * k * ct1 - n1 * V))
//        / (sqr(sqr(n2) * (1 - sqr(k)) * ct1 + n1 * U) + sqr(2 * sqr(n2) * k * ct1 + n1 * V));
//    phi.x = atan2(2 * n1 * sqr(n2) * ct1 * (2 * k * U - (1 - sqr(k)) * V), sqr(sqr(n2) * (1 + sqr(k)) * ct1) - sqr(n1) * (sqr(U) + sqr(V)));
//}

// half3 EnvironmentBRDFIridescence(FABRDFData brdfData, half3 indirectDiffuse, half3 indirectSpecular, half3 fresnelIridescent)
// {
//     half3 c = indirectDiffuse * brdfData.diffuse;
//     float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
//     c += surfaceReduction * indirectSpecular * lerp(brdfData.specular * fresnelIridescent, brdfData.grazingTerm, fresnelIridescent);
//     return c;
// }
// Evaluate the reflectance for a thin-film layer on top of a dielectric medum
// Based on the paper [LAURENT 2017] A Practical Extension to Microfacet Theory for the Modeling of Varying Iridescence
//half3 ThinFilmIridescence(FABRDFData brdfData, float cosTheta1)
//{
//    float eta_1 = 1.0; // Air on top, no coat.
//    //float eta_2 = brdfData.iridescenceEta2;
//    //float eta_3 = brdfData.iridescenceEta3;
//    //float kappa_3 = brdfData.iridescenceKappa3;

//    // iridescenceThickness unit is micrometer for this equation here. Mean 0.5 is 500nm.
//    //float Dinc = 2 * eta_2 * brdfData.iridescenceThickness;
//    float eta_2 = 0;
//    float eta_3 = 0;
//    float kappa_3 = 0;
//    float Dinc = 0;
    
//    // Force eta_2 -> eta_1 when Dinc -> 0.0
//    eta_2 = lerp(eta_1, eta_2, smoothstep(0.0, 0.03, Dinc));

//    float cosTheta2 = sqrt(1.0 - sqr(eta_1 / eta_2) * (1 - sqr(cosTheta1)));

//    // First interface
//    float2 R12, phi12;
//    fresnelDielectric(cosTheta1, eta_1, eta_2, R12, phi12);
//    float2 R21 = R12;
//    float2 T121 = float2(1.0, 1.0) - R12;
//    float2 phi21 = float2(PI, PI) - phi12;

    // Second interface
//    float2 R23, phi23;
//    fresnelConductor(cosTheta2, eta_2, eta_3, kappa_3, R23, phi23);

    // Phase shift
//    float OPD = Dinc * cosTheta2;
//    float2 phi2 = phi21 + phi23;

    // Compound terms
//    half3 I = half3(0, 0, 0);
//    float2 R123 = clamp(R12 * R23, 1e-5, 0.9999);
//    float2 r123 = sqrt(R123);
//    float2 Rs = sqr(T121) * R23 / (float2(1.0, 1.0) - R123);

    // Reflectance term for m=0 (DC term amplitude)
//    float2 C0 = R12 + Rs;
//    float3 S0 = evalSensitivity(0.0, 0.0);
//    I += depol(C0) * S0;

    // Reflectance term for m>0 (pairs of diracs)
//    float2 Cm = Rs - T121;

//    [unroll(3)]
//    for (int m = 1; m <= 3; ++m)
//    {
//        Cm *= r123;
//        float3 SmS = 2.0 * evalSensitivity(m * OPD, m * phi2.x);
//        float3 SmP = 2.0 * evalSensitivity(m * OPD, m * phi2.y);
//        I += depolColor(Cm.x * SmS, Cm.y * SmP);
//    }

    // Convert back to RGB reflectance
//    I = max(mul(I, XYZ_TO_RGB), half3(0.0, 0.0, 0.0));

//    return I;
//}
//half3 DirectBRDFIridescence(FABRDFData brdfData, half3 lightDirectionWS, half3 normalWS, half3 viewDirectionWS)
//{
    // Compute dot products
//    float NdotL = dot(normalWS, lightDirectionWS);
//    float NdotV = dot(normalWS, viewDirectionWS);

//    half3 halfDir = SafeNormalize(lightDirectionWS + viewDirectionWS);
//    float NdotH = dot(normalWS, halfDir);
//    float cosTheta1 = dot(halfDir, float3(lightDirectionWS));

//    half3 I = ThinFilmIridescence(brdfData, cosTheta1);
    // Microfacet BRDF formula
//    float D = GGX(NdotH, brdfData.perceptualRoughness);
//    float G = smithG_GGX(NdotL, NdotV, brdfData.perceptualRoughness);

//    half3 diffuseTerm = brdfData.diffuse;
//    half3 specularTerm = D * G * I / (4 * NdotL * NdotV);
    
//    half3 color = specularTerm * brdfData.specular + diffuseTerm;

//    return color;
//}

//使用unity优化过的算法，并且限制了高光最大强度
//half3 DirectBRDFIridescence2(FABRDFData brdfData, half3 lightDirectionWS, half3 normalWS, half3 viewDirectionWS)
//{
//    half3 halfDir = SafeNormalize(lightDirectionWS + viewDirectionWS);
//	half LoH = saturate(dot(lightDirectionWS, halfDir));
//	float cosTheta1 = dot(halfDir, float3(lightDirectionWS));

//	half3 specularTerm = FADirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);
//	specularTerm *= LoH;
//	half3 I = ThinFilmIridescence(brdfData, cosTheta1);
//	specularTerm *= I;

	//限制高光不超过7，防止开了bloom的情况下，金属度和光滑度非常高的物体闪烁的情况
//	half3 color = clamp(specularTerm * brdfData.specular,0,7) + brdfData.diffuse;

//    return color;
//}
// half3 DirectBRDFIridescence3(FABRDFData brdfData, half3 lightDirectionWS, half3 normalWS, half3 viewDirectionWS, half3 fresnelIridescenceLight)
// {
//     half3 halfDir = SafeNormalize(lightDirectionWS + viewDirectionWS);
// 	half LoH = saturate(dot(lightDirectionWS, halfDir));
// 	half3 specularTerm = FADirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);
// 	specularTerm *= LoH;
// 	//这里使用的
// 	//float cosTheta1 = dot(halfDir, float3(lightDirectionWS));
// 	//half3 I = ThinFilmIridescence(brdfData, cosTheta1);
// 	//specularTerm *= I;
// 	
// 	specularTerm *= fresnelIridescenceLight;
// 	//限制高光不超过7，防止开了bloom的情况下，金属度和光滑度非常高的物体闪烁的情况
// 	half3 color = clamp(specularTerm * brdfData.specular,0,7) + brdfData.diffuse;
//
//     return color;
// }
#endif

// 对应官方的InitializeSurfaceData
inline FASurfaceData InitializeFASurfaceData(float2 uv)
{
	FASurfaceData outSurfaceData = (FASurfaceData)0;
	half4 ao_m_s_e = SAMPLE_TEXTURE2D(_CombinedAO, sampler_CombinedAO, uv);
	half metallic = saturate(ao_m_s_e.g * _CombinedScaledParams.g);
	half smoothness = saturate((1 - ao_m_s_e.b) * _CombinedScaledParams.b);	//输出的贴图b通道是粗糙度,这里反成光滑度
	half emission = ao_m_s_e.a;

	// 有可能会用额外一套UV来采样AO图。
	half occlusion = saturate(ao_m_s_e.r * _CombinedScaledParams.r);
	//if (UseAnotherUVToSampleAO())
	//{
		//	occlusion = saturate(tex2D(sampler_CombinedAO, i_tex.zw).r * _CombinedScaledParams.r);
	//}

	half4 albedo = _Color * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

	outSurfaceData.albedo = albedo.rgb;
	outSurfaceData.alpha = albedo.a;

	outSurfaceData.metallic = metallic;

	outSurfaceData.smoothness = smoothness;
	half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv);

	outSurfaceData.normalTS = UnpackNormalScale(n, _BumpScale);
	outSurfaceData.occlusion = occlusion;
	outSurfaceData.emission = emission * (albedo + _EmissionColor).rgb * _Emissive_Intensity;
	
	
//#if _IRIDESCENCE
//    outSurfaceData.iridescenceThickness = SampleIridescenceThickness(uv);
//    outSurfaceData.iridescenceEta2 = _IridescneceEta2;
//    outSurfaceData.iridescenceEta3 = _IridescneceEta3;
//    outSurfaceData.iridescenceKappa3 = _IridescneceKappa3;
//#endif
	return outSurfaceData;
}

// 对应官方的InitializeBRDFData
// inline void InitializeFABRDFData(FASurfaceData surfaceData, out FABRDFData outBRDFData)
// {
// 	half oneMinusReflectivity = OneMinusReflectivityMetallic(surfaceData.metallic);
// 	half reflectivity = 1.0 - oneMinusReflectivity;
// 	outBRDFData.diffuse = surfaceData.albedo * oneMinusReflectivity;
// 	outBRDFData.specular = lerp(kDieletricSpec.rgb, surfaceData.albedo, surfaceData.metallic);
//     outBRDFData.reflectivity = reflectivity;
//
//     outBRDFData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surfaceData.smoothness);
//     outBRDFData.roughness           = max(PerceptualRoughnessToRoughness(outBRDFData.perceptualRoughness), HALF_MIN_SQRT);
// 	//outBRDFData.roughness = saturate(outBRDFData.roughness);
//     outBRDFData.roughness2          = max(outBRDFData.roughness * outBRDFData.roughness, HALF_MIN);
//     outBRDFData.grazingTerm         = saturate(surfaceData.smoothness + reflectivity);
//     outBRDFData.normalizationTerm   = outBRDFData.perceptualRoughness * 4.0h + 2.0h;
//     outBRDFData.roughness2MinusOne  = outBRDFData.roughness2 - 1.0h;
//
// //#ifdef _IRIDESCENCE
// //    outBRDFData.iridescenceThickness = surfaceData.iridescenceThickness;
// //    outBRDFData.iridescenceEta2 = surfaceData.iridescenceEta2;
// //    outBRDFData.iridescenceEta3 = surfaceData.iridescenceEta3;
// //    outBRDFData.iridescenceKappa3 = surfaceData.iridescenceKappa3;
// //#endif
//
// #ifdef _ALPHAPREMULTIPLY_ON
// 	outBRDFData.diffuse *= surfaceData.alpha;
// 	surfaceData.alpha = surfaceData.alpha * oneMinusReflectivity + reflectivity;
// #endif
// }

// half3 FADirectBRDF(FABRDFData brdfData, half3 lightDirectionWS, float3 normalWS, float3 viewDirectionWS)
// {
//     half3 halfDir = SafeNormalize(lightDirectionWS + viewDirectionWS);
// 	half LoH = saturate(dot(lightDirectionWS, halfDir));
// 	float cosTheta1 = dot(halfDir, float3(lightDirectionWS));
//
//    half3 specularTerm = FADirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);
//
// 	//限制高光不超过7，防止开了bloom的情况下，金属度和光滑度非常高的物体闪烁的情况
// 	half3 color = clamp(specularTerm * brdfData.specular,0,7) + brdfData.diffuse;
//
//     return color;
// }

// half3 FALightingPhysicallyBased(FABRDFData brdfData, Light light, float3 normalWS, float3 viewDirectionWS)
// {
//     //提高精度，规避移动平台的衰减硬边缘
//     half NdotL = saturate(dot(normalWS, light.direction));
//     half3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation * NdotL);
// //#if _IRIDESCENCE
// //	return DirectBRDFIridescence2(brdfData, light.direction, normalWS, viewDirectionWS) * radiance;
// //#else
// 	return FADirectBRDF(brdfData, light.direction, normalWS, viewDirectionWS) * radiance;
//     //return LightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
// //#endif
// }


// half3 FALightingPhysicallyBasedIridescence(FABRDFData brdfData, Light light, half3 normalWS, half3 viewDirectionWS, half3 fresnelIridescenceLight)
// {
//     //提高精度，规避移动平台的衰减硬边缘
//     half NdotL = saturate(dot(normalWS, light.direction));
//     half3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation * NdotL);
// #if _IRIDESCENCE
// 	return DirectBRDFIridescence3(brdfData, light.direction, normalWS, viewDirectionWS, fresnelIridescenceLight) * radiance;
// #else
//     return FADirectBRDF(brdfData, light.direction, normalWS, viewDirectionWS) * radiance;
// #endif
// }


// half3 FAGlossyEnvironmentReflection(half3 reflectVector, half perceptualRoughness, half occlusion)
// {
// #if !defined(_ENVIRONMENTREFLECTIONS_OFF)
//     half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
// 	#if _IRIDESCENCE
//         half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(_IridescenceReflectionCubeMap, sampler_IridescenceReflectionCubeMap, reflectVector, mip);
//         encodedIrradiance *= _IridescenceReflectionPower;
//     #else
//         
//         #if _ACTOR_USE_REFLECTION_PROBE
//             half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(_ReflectionProbeMap, sampler_ReflectionProbeMap, reflectVector, mip);
//         #else
//             half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip);
//         #endif
//     #endif
//     #if defined(UNITY_USE_NATIVE_HDR) || defined(UNITY_DOTS_INSTANCING_ENABLED) || _IRIDESCENCE
//         half3 irradiance = encodedIrradiance.rgb;
//     #else
//         #if _ACTOR_USE_REFLECTION_PROBE
//             half3 irradiance = DecodeHDREnvironment(encodedIrradiance, _ReflectionProbeMap_HDR);
//         #else
//             half3 irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
//         #endif
//     #endif
//
//     return irradiance * occlusion;
// #endif
//
//     return _GlossyEnvironmentColor.rgb * occlusion;
// }

// half3 FAGlobalIllumination(FABRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS, float2 uvScreen, half atten)
// {
// 	half3 reflectVector = reflect(-viewDirectionWS, normalWS);
//
// 	half3 indirectDiffuse = bakedGI * occlusion;
// 	half3 indirectSpecular = FAGlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion);
//
// 	half atten_power = clamp(atten, 0.35, 1);
// 	indirectSpecular = indirectSpecular * pow(atten_power, 1.5);
//
// //#ifdef _IRIDESCENCE
// //    half3 halfDir = SafeNormalize(reflectVector + viewDirectionWS);
// //    float cosTheta1 = dot(halfDir, float3(reflectVector));
// //    half3 fresnelIridescence = ThinFilmIridescence(brdfData, cosTheta1);
// //    return EnvironmentBRDFIridescence(brdfData, indirectDiffuse, indirectSpecular, fresnelIridescence);
// //#else
//     half NoV = saturate(dot(normalWS, viewDirectionWS));
// 	half fresnelTerm = Pow4(1.0 - NoV);
//     
// // #if _SCREEN_SPACE_PLANAR_REFLECTION
// //         //half4 screenPos = ComputeScreenPos(input.positionCS);
// //         //half2 screenUV = screenPos.xy/screenPos.w;
// //         float4 SSPRResult = SAMPLE_TEXTURE2D(_SSPR_ColorRT, sampler_SSPR_ColorRT, uvScreen);
// //         indirectSpecular = lerp(indirectSpecular, SSPRResult.rgb * _ReflectionIntensity, SSPRResult.a);
// // #endif
//
// 	return FAEnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
// //#endif
// }

// half3 FAGlobalIllumination(FABRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS, float2 uvScreen, half atten, half _EnvironmentReflectionIntensity)
// {
//     half3 reflectVector = reflect(-viewDirectionWS, normalWS);
//
//     half3 indirectDiffuse = bakedGI * occlusion;
//     half3 indirectSpecular = FAGlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion) * _EnvironmentReflectionIntensity;
//
//     half atten_power = clamp(atten, 0.35, 1);
//     indirectSpecular = indirectSpecular * pow(atten_power, 1.5);
//
// //#ifdef _IRIDESCENCE
// //    half3 halfDir = SafeNormalize(reflectVector + viewDirectionWS);
// //    float cosTheta1 = dot(halfDir, float3(reflectVector));
// //    half3 fresnelIridescence = ThinFilmIridescence(brdfData, cosTheta1);
// //    return EnvironmentBRDFIridescence(brdfData, indirectDiffuse, indirectSpecular, fresnelIridescence);
// //#else
//     half NoV = saturate(dot(normalWS, viewDirectionWS));
//     half fresnelTerm = Pow4(1.0 - NoV);
//     
// // #if _SCREEN_SPACE_PLANAR_REFLECTION
// //         //half4 screenPos = ComputeScreenPos(input.positionCS);
// //         //half2 screenUV = screenPos.xy/screenPos.w;
// //         float4 SSPRResult = SAMPLE_TEXTURE2D(_SSPR_ColorRT, sampler_SSPR_ColorRT, uvScreen);
// //         indirectSpecular = lerp(indirectSpecular, SSPRResult.rgb * _ReflectionIntensity, SSPRResult.a);
// // #endif
//
//     return FAEnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
// //#endif
// }

// half3 FAGlobalIlluminationIridescence(FABRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS, float2 uvScreen, half atten, half3 fresnelIridescence)
// {
// 	half3 reflectVector = reflect(-viewDirectionWS, normalWS);
//
// 	half3 indirectDiffuse = bakedGI * occlusion;
// 	half3 indirectSpecular = FAGlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion); //在这个方法里采样了cubemap计算反射
// 	
//
// 	half atten_power = clamp(atten, 0.35, 1);
// 	indirectSpecular = indirectSpecular * pow(atten_power, 1.5);
// #ifdef _IRIDESCENCE
//     //half3 halfDir = SafeNormalize(reflectVector + viewDirectionWS);
//     //float cosTheta1 = dot(halfDir, float3(reflectVector));
//     //half3 fresnelIridescence = ThinFilmIridescence(brdfData, cosTheta1);
//     return EnvironmentBRDFIridescence(brdfData, indirectDiffuse, indirectSpecular, fresnelIridescence);
// #else
//     half NoV = saturate(dot(normalWS, viewDirectionWS));
// 	half fresnelTerm = Pow4(1.0 - NoV);
// 	return FAEnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
// #endif	
// }

//这个函数用来在PC平台（RGBM编码的Lightmap）矫正lightmap的颜色以接近移动平台（dLDR编码的Lightmap）的颜色
// half3 FASampleLightmap(float2 lightmapUV, half3 normalWS)
// {
//     half3 color = SampleLightmap(lightmapUV, normalWS);
// #if defined(UNITY_LIGHTMAP_RGBM_ENCODING)
//     //gamma空间下没测试过，先不管
//     #ifndef UNITY_COLORSPACE_GAMMA
//         color = LinearToSRGB(color);
//         color = clamp(color, 0, 2);
//         color = color / 2 * 4.595f;
//     #endif
// #endif
//     return color;
// }
	
AmbientOcclusionFactor CustomGetScreenSpaceAmbientOcclusion(float2 normalizedScreenSpaceUV)  //搬运自AmbientOcclusion.hlsl
{
    AmbientOcclusionFactor aoFactor;

    #if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION) && !defined(_SURFACE_TYPE_TRANSPARENT)
        float ssao = saturate(SampleAmbientOcclusion(normalizedScreenSpaceUV) + (1.0 - _AmbientOcclusionParam.x));
        aoFactor.indirectAmbientOcclusion = ssao;
        aoFactor.directAmbientOcclusion = lerp(half(1.0), ssao, _AmbientOcclusionParam.w);
    #else
        aoFactor.directAmbientOcclusion = half(1.0);
        aoFactor.indirectAmbientOcclusion = half(1.0);
    #endif

    #if defined(DEBUG_DISPLAY)
    switch(_DebugLightingMode)
    {
        case DEBUGLIGHTINGMODE_LIGHTING_WITHOUT_NORMAL_MAPS:
            aoFactor.directAmbientOcclusion = 0.5;
            aoFactor.indirectAmbientOcclusion = 0.5;
            break;

        case DEBUGLIGHTINGMODE_LIGHTING_WITH_NORMAL_MAPS:
            aoFactor.directAmbientOcclusion *= 0.5;
            aoFactor.indirectAmbientOcclusion *= 0.5;
            break;
    }
    #endif

    return aoFactor;
}

half4 CalculateShadowMask(float2 shadowMaskUV)
{
    // To ensure backward compatibility we have to avoid using shadowMask input, as it is not present in older shaders
    #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    half4 shadowMask = SAMPLE_SHADOWMASK(shadowMaskUV);
    #elif !defined (LIGHTMAP_ON)
    half4 shadowMask = unity_ProbesOcclusion;
    #else
    half4 shadowMask = half4(1, 1, 1, 1);
    #endif

    return shadowMask;
}