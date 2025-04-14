#ifndef CRACK_PLANE_LIB
#define CRACK_PLANE_LIB

#include "../FALib/FALighting.hlsl"
#include "../FALib/FAEffectLib.hlsl"
#include "../FALib/FACustomFogLib.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    half3 normalOS     : NORMAL;
    half4 tangentOS    : TANGENT;
    float4 uv           : TEXCOORD0;
    float4 uvLM         : TEXCOORD1;
};

struct GeneralEffectPBRVaryings
{
    float4 positionCS               : SV_POSITION;
    float2 uv                       : TEXCOORD0;
    float2 uvLM                     : TEXCOORD1;
    float4 positionWSAndFogFactor   : TEXCOORD2; // xyz: positionWS, w: vertex fog factor
    half3  normalWS                 : TEXCOORD3;
    half3 tangentWS				: TEXCOORD4;
    half3 bitangentWS			: TEXCOORD5;
    half4 fogColor               : TEXCOORD6;
    half4 customData           : TEXCOORD7;
    #ifdef _MAIN_LIGHT_SHADOWS
    float4 shadowCoord			: TEXCOORD8; // compute shadow coord per-vertex for the main light
    #endif
    
};

GeneralEffectPBRVaryings PBRGeneralEffectVertex(Attributes input)
{
    GeneralEffectPBRVaryings output = (GeneralEffectPBRVaryings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    // 和VertexPositionInputs差不多，包含了world space中的normal, tangent and bitangent
    // 如果没使用到会被剔除
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    // TRANSFORM_TEX is the same as the old shader library.
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    output.uvLM = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;

    // 目前就使用vertex input中的clip space position
    output.positionCS = vertexInput.positionCS;

    // Computes fog factor per-vertex.
    //float fogFactor = ComputeFogFactorLinear(vertexInput.positionCS.z);
    output.positionWSAndFogFactor = float4(vertexInput.positionWS, 1);

    output.normalWS = vertexNormalInput.normalWS;

    // 上面所说的新的Input结构灵活性在这里可以体现出来
    // 当一个没有定义normal map的变种存在时，tangentWS和bitangentWS不会被引用
    // 而GetVertexNormalInputs只是把normal从object转换到world space中
    // #ifdef _NORMALMAP
    output.tangentWS = vertexNormalInput.tangentWS;
    output.bitangentWS = vertexNormalInput.bitangentWS;
    // #endif

    #ifdef _MAIN_LIGHT_SHADOWS
    // main light的shadow coord在vertex里计算
    // 如果应用了cascades, URP会在screen space里重构
    // 其他情况下URP会在light space(没有 depth pre-pass and shadow collect pass)里重构shadow
    output.shadowCoord = GetShadowCoord(vertexInput);
    #endif
    
    output.customData.xy = input.uv.zw;
    output.customData.zw = input.uvLM.zw;
    CustomMixFogColor(vertexInput.positionWS, output.fogColor.xyz, output.fogColor.w);
    return output;
}

inline float2 GetParallaxUV( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
{
    float3 result = 0;
    int stepIndex = 0;
    int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
    float layerHeight = 1.0 / numSteps;
    float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
    uvs.xy += refPlane * plane;
    float2 deltaTex = -plane * layerHeight;
    float2 prevTexOffset = 0;
    float prevRayZ = 1.0f;
    float prevHeight = 0.0f;
    float2 currTexOffset = deltaTex;
    float currRayZ = 1.0f - layerHeight;
    float currHeight = 0.0f;
    float intersection = 0;
    float2 finalTexOffset = 0;
    while ( stepIndex < numSteps + 1 )
    {
        currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).r;
        currHeight = lerp(currHeight, 1-currHeight, _InvertedColor);
        if ( currHeight > currRayZ )
        {
            stepIndex = numSteps + 1;
        }
        else
        {
            stepIndex++;
            prevTexOffset = currTexOffset;
            prevRayZ = currRayZ;
            prevHeight = currHeight;
            currTexOffset += deltaTex;
            currRayZ -= layerHeight;
        }
    }
    int sectionSteps = 10;
    int sectionIndex = 0;
    float newZ = 0;
    float newHeight = 0;
    while ( sectionIndex < sectionSteps )
    {
        intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
        finalTexOffset = prevTexOffset + intersection * deltaTex;
        newZ = prevRayZ - intersection * layerHeight;
        newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).r;
        newHeight = lerp(newHeight, 1-newHeight, _InvertedColor);
        if ( newHeight > newZ )
        {
            currTexOffset = finalTexOffset;
            currHeight = newHeight;
            currRayZ = newZ;
            deltaTex = intersection * deltaTex;
            layerHeight = intersection * layerHeight;
        }
        else
        {
            prevTexOffset = finalTexOffset;
            prevHeight = newHeight;
            prevRayZ = newZ;
            deltaTex = ( 1 - intersection ) * deltaTex;
            layerHeight = ( 1 - intersection ) * layerHeight;
        }
        sectionIndex++;
    }
    result.xy = uvs.xy + finalTexOffset;

    if ( result.x < 0 )
        clip( -1 );
    if ( result.x > tilling.x )
        clip( -1 );
    if ( result.y < 0 )
        clip( -1 );
    if ( result.y > tilling.y )
        clip( -1 );

    return result.xy;
}

half4 GetDissolutionColor(half4 colorSource, float2 uvTex, half percent)
{
    half soft = clamp(_DissolutionSoftEdge, 0.0001, 1);
    half4 varDissolutionTex = SAMPLE_TEXTURE2D(_DissolutionTex, sampler_DissolutionTex, uvTex);
    float factor = dot(varDissolutionTex, _DissolutionTex_ChannelMask);
    factor = clamp(factor, 0, 1);
    //factor = lerp(factor, 1-factor, _DissolutionReverse);
    factor -= percent;

    float factor1 = 1 + clamp(factor / soft, -1, 1);
    colorSource.a *= factor1;
    clip(colorSource.a - 0.01);

    float factor2 = (factor - _DissolutionEdgeWidth) * (1 - step(_DissolutionEdgeWidth, 0));
    factor2 = saturate(1 +  factor2 / soft);
    half4 edgeColor = _DissolutionEdgeColor;
    colorSource.rgb = lerp(edgeColor.rgb, colorSource.rgb, factor2);
    colorSource.a = saturate(colorSource.a);

    return colorSource;
}

FASurfaceData InitializePBRGeneralEffectSurfaceData(GeneralEffectPBRVaryings input, half time, half2 uv, float3 positionWS, float3 viewDirWS, half facing = 1)
{
	FASurfaceData outSurfaceData = (FASurfaceData)0;
    
	//half4 albedo = _Color * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
	half2 mainTexUV = uv + time * half2(_MainTex_U, _MainTex_V);
	half4 albedo = _Color * PARTILE_TEXTURE2D(_MainTex, sampler_MainTex, mainTexUV, _MainTex_ChannelMask);
	half4 ao_m_s_e = SAMPLE_TEXTURE2D(_CombinedAO, sampler_CombinedAO, uv);
    half occlusion = saturate(ao_m_s_e.r * _CombinedScaledParams.r);
    half metallic = saturate(ao_m_s_e.g * _CombinedScaledParams.g);
    half smoothness = saturate((1 - ao_m_s_e.b) * _CombinedScaledParams.b);	//输出的贴图b通道是粗糙度,这里反成光滑度
	half emission = ao_m_s_e.a;
	
	float4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv);
	float3 normalTS = UnpackNormalScale(n, _BumpScale) * facing;
	
	outSurfaceData.albedo = albedo.rgb;
	outSurfaceData.alpha = albedo.a;
	outSurfaceData.occlusion = occlusion;
	outSurfaceData.metallic = metallic;
	outSurfaceData.smoothness = smoothness;
	
	half emissionIntensity = lerp(_Emissive_Intensity, input.customData.y, useCustomData);
//#ifdef _EMISSION_ON
    half4 emission_sample = SAMPLE_TEXTURE2D(_EmissionTex, sampler_EmissionTex, uv);
    outSurfaceData.emission = emission_sample.rgb * _EmissionColor.rgb * emissionIntensity;
//#else
//    outSurfaceData.emission = ((albedo + _EmissionColor) * emissionIntensity).rgb;
//#endif
	outSurfaceData.normalTS = normalTS;
	return outSurfaceData;
}

half4 OutputPBRGeneralEffectColor(GeneralEffectPBRVaryings input, FASurfaceData surfaceData, half2 uv, float time, float3 positionWS, float3 viewDirectionWS, half facing = 1)
{
#if defined(_ALPHATEST_ON)
    clip(surfaceData.alpha - _Cutoff);
#endif
    
    float3 normalWS = TransformTangentToWorld(surfaceData.normalTS, half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
    normalWS = normalize(normalWS) * facing;

    FABRDFData brdfData;
	InitializeFABRDFData(surfaceData, brdfData);

    half3 bakedGI = SampleSH(normalWS);
#ifdef _MAIN_LIGHT_SHADOWS
    Light mainLight = GetMainLight(input.shadowCoord);
#else
    Light mainLight = GetMainLight();
#endif
    half2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);
	half atten = clamp(mainLight.shadowAttenuation, _CombinedScaledParams.w, 1);
	half3 color = FAGlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS, uvScreen, atten);
	
	color += FALightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);
	
	uint pixelLightCount = GetAdditionalLightsCount();
	for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
    {
        Light light = GetAdditionalLight(lightIndex, positionWS);
        color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
    }	
    
    half3 emission = surfaceData.emission; 	

//#ifdef _POLAR_COORDINATE_ON
    half2 center = uv - float2(0.5,0.5);
    float2 angle = (float2(( length( center ) * 1.0 * 2.0 ) , ( atan2( center.x , center.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
    half2 speed = (half2(_Polar_Speed_U , _Polar_Speed_V));
    half2 polarUV = angle + (speed * time);
    half4 polarColor = SAMPLE_TEXTURE2D(_PolarTex, sampler_PolarTex, polarUV) * _PolarColor * _PolarColorIntensity;
    emission += polarColor.rgb;
//#endif 
    color += emission;	

    half alpha = 1.0;
#if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
    alpha = surfaceData.alpha;
#endif
    
    half4 finalColor = half4(color, alpha);
//#ifdef _MASK_ON
    half2 maskTexUV = uv + time * half2(_MaskTex_U, _MaskTex_V);
    half4 maskTexColor = PARTILE_TEXTURE2D(_MaskTex, sampler_MaskTex,  maskTexUV, _MaskTex_ChannelMask);
    finalColor *= maskTexColor;
    //half maskValue = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, TRANSFORM_TEX(uv, _MaskTex)).r;
    //finalColor *= maskValue;
//#endif 

//#ifdef _DISSOLUTION_ON
    half2 dissolveTexUV = uv + time * half2(_DissolutionTex_U, _DissolutionTex_V);
    half dissolvePercent = lerp(_DissolutionPercent, input.customData.x, useCustomData);
    finalColor = GetDissolutionColor(finalColor, dissolveTexUV, dissolvePercent);
    finalColor.a = saturate(finalColor.a);
    //half clipValue = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, TRANSFORM_TEX(uv, _DissolveTex)).r;
    //half dissolve = smoothstep(( 1.0 - _DissolveSoft ), _DissolveSoft, clipValue + 1.0 + ( _DissolveIntensity * -2.0 ));
    //alpha = saturate(alpha * dissolve);
//#endif

#ifdef _ALPHAPREMULTIPLY_ON
    finalColor.rgb *= finalColor.a;
#endif
    finalColor.a *= _TPA;

	return finalColor;
}

half4 PBRGeneralEffectFragment(GeneralEffectPBRVaryings input, half facing : VFACE) : SV_Target
{
    //half fogFactor = ComputeFogFactorLinear(input.positionCS.z * input.positionCS.w);
    
    half time = fmod(_Time.x, 10);
    
    half3 positionWS = input.positionWSAndFogFactor.xyz;
    half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
    
    half2 uv = input.uv.xy;    
//#ifdef _PARALLAX_ON
    float3 normalWS = normalize(input.normalWS);
	float3 tangentWS = input.tangentWS;
	float3 bitangentWS = input.bitangentWS;
	
	float3 tanToWorldX = float3(tangentWS.x, bitangentWS.x, normalWS.x);
	float3 tanToWorldY = float3(tangentWS.y, bitangentWS.y, normalWS.y);
	float3 tanToWorldZ = float3(tangentWS.z, bitangentWS.z, normalWS.z);
	
	float3 tanViewDir = normalize(tanToWorldX * viewDirectionWS.x + tanToWorldY * viewDirectionWS.y + tanToWorldZ * viewDirectionWS.z);
	half parallaxScale = lerp(_ParallaxScale, input.customData.z, useCustomData);
    uv = GetParallaxUV(_ParallaxTex, input.uv.xy, ddx(input.uv.xy), ddy(input.uv.xy), positionWS, viewDirectionWS, tanViewDir, 128, 128, parallaxScale, _PlaneHeight, _ParallaxTex_ST.xy, float2(0,0), 0 );
//#endif	
    
    FASurfaceData surfaceData = InitializePBRGeneralEffectSurfaceData(input, time, uv, positionWS, viewDirectionWS);
    half4 color = OutputPBRGeneralEffectColor(input, surfaceData, uv, time, positionWS, viewDirectionWS, facing);
    color.rgb = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);
    return color;
}
	
#endif