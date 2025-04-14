#include "../Extension/48InputeDataExtension.hlsl"
// #include "../48Lighting.hlsl"

//================================================================
//================================================================
//================================================================
#define DEFAULT_HAIR_SPECULAR_VALUE 0.0465 // Hair is IOR 1.55

float GetAbsorptionDenominator(float azimuthalRoughness)
{
	const float beta = azimuthalRoughness;

	#if 0
	float beta2 = beta  * beta;
	float beta3 = beta2 * beta;
	float beta4 = beta3 * beta;
	float beta5 = beta4 * beta;

	// Least squares fit of an inverse mapping between scattering parameters and scattering albedo.
	return 5.969 - (0.215 * beta) + (2.532 * beta2) - (10.73 * beta3) + (5.574 * beta4) + (0.245 * beta5);
	#else
	// Simplified version of the above.
	return (((((0.245f * beta) + 5.574f) * beta - 10.73f) * beta + 2.532f) * beta - 0.215f) * beta + 5.969f;
	#endif
}

// Ref: A Practical and Controllable Hair and Fur Model for Production Path Tracing Eq. 9
float3 AbsorptionFromReflectance(float3 diffuseColor, float azimuthalRoughness)
{
	// Enforce a minimum value to prevent NaNs.
	diffuseColor = max(diffuseColor, 1e-3);

	return Sq(log(diffuseColor) / GetAbsorptionDenominator(azimuthalRoughness));
}

void ConvertSurfaceDataToBSDFData(inout BRDFData bsdfData)
{
    // // Enforce a maximum smoothness to prevent NaNs.
    // bsdfData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(min(1.0 - 1e-2, surfaceData.perceptualSmoothness));

    // This value will be override by the value in diffusion profile
    bsdfData.fresnel0                 = DEFAULT_HAIR_SPECULAR_VALUE;

    // This is the hair tangent (which represents the hair strand direction, root to tip).
    // bsdfData.hairStrandDirectionWS = surfaceData.hairStrandDirectionWS;
    {
        // Cuticle Angle
    	//Cuticle Angle, shift highlight, 3 degree is good for human hair
        const float cuticleAngle = radians(3);
        // bsdfData.cuticleAngle    = -cuticleAngle;
        bsdfData.cuticleAngleR   = -cuticleAngle;
        bsdfData.cuticleAngleTT  =  cuticleAngle * 0.5;
        bsdfData.cuticleAngleTRT =  cuticleAngle * 1.5;

        // Longitudinal Roughness
        const float roughnessL = bsdfData.perceptualRoughness;
        bsdfData.roughnessR    = PerceptualRoughnessToRoughness(roughnessL);
        bsdfData.roughnessTT   = PerceptualRoughnessToRoughness(roughnessL * 0.5);
        bsdfData.roughnessTRT  = PerceptualRoughnessToRoughness(roughnessL * 2.0);

        // Azimuthal Roughness
    	//Radial Smoothness, constant internal quality of the fiber, 0.7 is good for human hair, animal fur would be lower
        bsdfData.perceptualRoughnessRadial = PerceptualSmoothnessToPerceptualRoughness(min(1.0 - 1e-2, 0.7));
    	
        bsdfData.absorption   = AbsorptionFromReflectance(bsdfData.diffuse, bsdfData.perceptualRoughnessRadial);
    	
        // By default the normalization factor should be 1 and overridden by area lights.
        bsdfData.distributionNormalizationFactor = 1;

        // Only necesarry for reference.
        // bsdfData.h = -1 + 2 * InterleavedGradientNoise(positionSS, _TaaFrameInfo.z);
    }
}

//================================================================
//================================================================

#define HAIR_H_TT  0.0f
#define HAIR_H_TRT 0.86602540378f

half3 Gaussian(half3 thetaH, half3 beta)
{
	beta = max(beta, 1e-5); // zero-div guard

	// NOTE: This gaussian assumes that beta is already squared.
	return rcp(sqrt(TWO_PI * beta)) * exp(-Sq(thetaH) / (2 * beta));
}
TEXTURE3D(_HairAzimuthalScattering);

// Returns the roughened azimuthal scattering distribution term for all three lobes.
float3 GetRoughenedAzimuthalScatteringDistribution(float phi, float cosThetaD, float beta)
{
	const float X = (phi + TWO_PI) / FOUR_PI;
	const float Y = cosThetaD;
	const float Z = beta;

	// TODO: It should be possible to reduce the domain of the integration to 0 -> HALF/PI as it repeats. This will save memory.
	return SAMPLE_TEXTURE3D_LOD(_HairAzimuthalScattering, sampler_LinearClamp, float3(X, Y, Z), 0).xyz;
}
struct HairAngle
{
	half sinThetaI;
	half sinThetaO;
	half cosThetaI;
	half cosThetaO;
	half cosThetaD;
	half thetaH;
	half phiI;
	half phiO;
	half phi;
	half cosPhi;
	half sinThetaT;
	half cosThetaT;
};

void GetHairAngleWorld(float3 V, float3 L, float3 T, inout HairAngle angles)
{
	angles.sinThetaO = dot(T, V);
	angles.sinThetaI = dot(T, L);

	half thetaO = FastASin(angles.sinThetaO);
	half thetaI = FastASin(angles.sinThetaI);
	angles.thetaH = (thetaI + thetaO) * 0.5;

	angles.cosThetaD = cos((thetaO - thetaI) * 0.5);
	angles.cosThetaO = cos(thetaO);
	angles.cosThetaI = cos(thetaI);

	// Projection onto the normal plane, and since phi is the relative angle, we take the cosine in this projection.
	half3 VProj = V - angles.sinThetaO * T;
	half3 LProj = L - angles.sinThetaI * T;
	angles.cosPhi = dot(LProj, VProj) * rsqrt(dot(LProj, LProj) * dot(VProj, VProj) + 1e-5); // zero-div guard
	angles.phi = FastACos(angles.cosPhi);

	// Fixed for approximate human hair IOR
	angles.sinThetaT = angles.sinThetaO / 1.55;
	angles.cosThetaT = SafeSqrt(1 - Sq(angles.sinThetaT));
}

float ModifiedRefractionIndex(float cosThetaD)
{
	// Original derivation of modified refraction index for arbitrary IOR.
	// float sinThetaD = sqrt(1 - Sq(cosThetaD));
	// return sqrt(Sq(eta) - Sq(sinThetaD)) / cosThetaD;

	// Karis approximation for the modified refraction index for human hair (1.55)
	return 1.19 / cosThetaD + (0.36 * cosThetaD);
}

float3 KajiyaKayDiffuseAttenuation(half3 baseColor, float3 L, float3 V, half3 N, float Shadow,float Scatter)
{
	// Use soft Kajiya Kay diffuse attenuation
	float KajiyaDiffuse = 1 - abs(dot(N, L));

	float3 FakeNormal = normalize(V - N * dot(V, N));
	//N = normalize( DiffuseN + FakeNormal * 2 );
	N = FakeNormal;

	// Hack approximation for multiple scattering.
	float MinValue = 0.0001f;
	float Wrap = 1;
	float NoL = saturate((dot(N, L) + Wrap) / ((1 + Wrap)*(1 + Wrap)));
	float DiffuseScatter = (1 / PI) * lerp(NoL, KajiyaDiffuse, 0.33) * Scatter;
	float Luma = Luminance(baseColor);
	float3 BaseOverLuma = abs(baseColor / max(Luma, MinValue));
	float3 ScatterTint = Shadow < 1 ? pow(BaseOverLuma, 1 - Shadow) : 1;
	return sqrt(abs(baseColor)) * DiffuseScatter * ScatterTint;
}

CBSDF EvaluateBSDF(float3 V, float3 L, BRDFData bsdfData)
{
    CBSDF cbsdf;
    ZERO_INITIALIZE(CBSDF, cbsdf);

     half3 T =normalize(cross( bsdfData.tangentWS,bsdfData.normalWS));
	 //half3 T = normalize( cross( bsdfData.normalWS,bsdfData.tangentWS));
	//half3 T =half3(0,-1,0);
    half3 N = bsdfData.normalWS;

    // The Kajiya-Kay model has a "built-in" transmission, and the 'NdotL' is always positive.
    half cosTL = dot(T, L);
    half sinTL = sqrt(saturate(1.0 - cosTL * cosTL));
    half NdotL = sinTL; // Corresponds to the cosine w.r.t. the light-facing normal


    half NdotV = bsdfData.NdotV;
    half clampedNdotV = ClampNdotV(NdotV);
    half clampedNdotL = saturate(NdotL);
	
    {
        // Approximation of the three primary paths in a hair fiber (R, TT, TRT), with concepts from:
        // "Strand-Based Hair Rendering in Frostbite" (Tafuri 2019)
        // "A Practical and Controllable Hair and Fur Model for Production Path Tracing" (Chiang 2016)
        // "Physically Based Hair Shading in Unreal" (Karis 2016)
        // "An Energy-Conserving Hair Reflectance Model" (d'Eon 2011)
        // "Light Scattering from Human Hair Fibers" (Marschner 2003)

        // Reminder: All of these flags are known at compile time and the compiler will strip away the unused paths.

        // Retrieve angles via spherical coordinates in the hair shading space.
        HairAngle angles;
        ZERO_INITIALIZE(HairAngle, angles);
        GetHairAngleWorld(V, L, T, angles);

        const half3 alpha = half3(
            bsdfData.cuticleAngleR,
            bsdfData.cuticleAngleTT,
            bsdfData.cuticleAngleTRT
        );

        const half3 beta = half3(
            bsdfData.roughnessR,
            bsdfData.roughnessTT,
            bsdfData.roughnessTRT
        );

        // The index of refraction that can be used to analyze scattering in the normal plane (Bravais' Law).
        const half etaPrime = ModifiedRefractionIndex(angles.cosThetaD);

        // Reduced absorption coefficient.
        const half3 mu = bsdfData.absorption;

        // Various misc. terms reused between lobe evaluation.
        half3 F, Tr, S = 0;

        // Per-path attenuations.
        half3 A[3];
    	
            // For non-cinematic hair shading, use a cheaper gaussian for longitudinal scattering.
         half3   M = Gaussian(angles.thetaH - alpha, beta) * bsdfData.distributionNormalizationFactor;

        // Fetch the preintegrated azimuthal distributions for each path
        const half3 N = GetRoughenedAzimuthalScatteringDistribution(angles.phi, angles.cosThetaD, bsdfData.perceptualRoughnessRadial);

        // Solve the first three lobes (R, TT, TRT).

        // R
        {
            // Attenuation for this path as proposed by d'Eon et al, replaced with a trig identity for cos half phi.
            A[0] = F_Schlick(bsdfData.fresnel0, sqrt(0.5 + 0.5 * dot(L, V)));
            S += M[0] * A[0] * N[0];
        }

        // TT
        {
            // Attenutation (Simplified for H = 0)
            half cosGammaO = SafeSqrt(1 - Sq(HAIR_H_TT));
            half cosTheta  = angles.cosThetaO * cosGammaO;
            F = F_Schlick(bsdfData.fresnel0, cosTheta);

            half sinGammaT = HAIR_H_TT / etaPrime;
            half cosGammaT = SafeSqrt(1 - Sq(sinGammaT));
            Tr = exp(-mu * (2 * cosGammaT / angles.cosThetaT));

            A[1] = Sq(1 - F) * Tr;

            S += M[1] * A[1] * N[1];
        }

        // TRT
        {
            // Attenutation (Simplified for H = √3/2)
            half cosGammaO = SafeSqrt(1 - Sq(HAIR_H_TRT));
            half cosTheta  = angles.cosThetaO * cosGammaO;
            F = F_Schlick(bsdfData.fresnel0, cosTheta);

            half sinGammaT = HAIR_H_TRT / etaPrime;
            half cosGammaT = SafeSqrt(1 - Sq(sinGammaT));
            Tr = exp(-mu * (2 * cosGammaT / angles.cosThetaT));
        	
            A[2] = Sq(1 - F) * F * Sq(Tr);
        
        	S +=  M[2] * A[2] * N[2];
        }

    	// {
    	// 	S += max(KajiyaKayDiffuseAttenuation(bsdfData.albedo, L, V, N, NdotL,0.1), 0.0);//一定要加Max，坑
    	// }
    	
        // TODO: Residual TRRT+ Lobe. (accounts for ~15% energy otherwise lost by the first three lobes).
        // Transmission event is built into the model.
        // Some stubborn NaNs have cropped up due to the angle optimization, we suppress them here with a max for now.
        cbsdf.specR = max(S, 0);
    	
    	// cbsdf.diffR = rcp(PI * PI) * clampedNdotL;
    	cbsdf.diffR = Lambert() * clampedNdotL;
    }

    return cbsdf;
}