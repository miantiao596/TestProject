#ifndef FA_LIGHTING_SIMPLE
    #define FA_LIGHTING_SIMPLE

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

    struct FASurfaceData
    {
        half3 albedo;
        half  metallic;
        half  smoothness;
        half3 normalTS;
        half3 emission;
        half  occlusion;
        half  alpha;
    };
    
    struct FABRDFData
    {
        half3 diffuse;
        half3 specular;
        half reflectivity;
        half perceptualRoughness;
        half roughness;
        half roughness2;
        half grazingTerm;
        half normalizationTerm;     // roughness * 4.0 + 2.0
        half roughness2MinusOne;    // roughness² - 1.0
    };
    
    
    // Computes the specular term for EnvironmentBRDF
    half3 FAEnvironmentBRDFSpecular(FABRDFData brdfData, half fresnelTerm)
    {
        float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
        return surfaceReduction * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm);
    }
    
    half3 FAEnvironmentBRDF(FABRDFData brdfData, half3 indirectDiffuse, half3 indirectSpecular, half fresnelTerm)
    {
        half3 c = indirectDiffuse * brdfData.diffuse;
        c += indirectSpecular * FAEnvironmentBRDFSpecular(brdfData, fresnelTerm);
        return c;
    }
    
    // Computes the scalar specular term for Minimalist CookTorrance BRDF
    // NOTE: needs to be multiplied with reflectance f0, i.e. specular color to complete
    half FADirectBRDFSpecular(FABRDFData brdfData, float3 normalWS, half3 lightDirectionWS, float3 viewDirectionWS)
    {
        half3 halfDir = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));
    
        float NoH = saturate(dot(normalWS, halfDir));
        half LoH = saturate(dot(lightDirectionWS, halfDir));
    
        // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
        // BRDFspec = (D * V * F) / 4.0
        // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
        // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
        // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
        // https://community.arm.com/events/1155
    
        // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
        // We further optimize a few light invariant terms
        // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
        float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;
    
        half LoH2 = LoH * LoH;
        half specularTerm = brdfData.roughness2 / ((d * d) * max(0.1h, LoH2) * brdfData.normalizationTerm);
    
        // On platforms where half actually means something, the denominator has a risk of overflow
        // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
        // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
    //#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
        specularTerm = specularTerm - HALF_MIN;
        specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
    //#endif
    
        return specularTerm;
    }
    
    inline void InitializeFABRDFData(FASurfaceData surfaceData, out FABRDFData outBRDFData)
    {
        half oneMinusReflectivity = OneMinusReflectivityMetallic(surfaceData.metallic);
        half reflectivity = 1.0 - oneMinusReflectivity;
        outBRDFData.diffuse = surfaceData.albedo * oneMinusReflectivity;
        outBRDFData.specular = lerp(kDieletricSpec.rgb, surfaceData.albedo, surfaceData.metallic);
        outBRDFData.reflectivity = reflectivity;
        outBRDFData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surfaceData.smoothness);
        outBRDFData.roughness           = max(PerceptualRoughnessToRoughness(outBRDFData.perceptualRoughness), HALF_MIN_SQRT);
        outBRDFData.roughness2          = max(outBRDFData.roughness * outBRDFData.roughness, HALF_MIN);
        outBRDFData.grazingTerm         = saturate(surfaceData.smoothness + reflectivity);
        outBRDFData.normalizationTerm   = outBRDFData.perceptualRoughness * 4.0h + 2.0h;
        outBRDFData.roughness2MinusOne  = outBRDFData.roughness2 - 1.0h;
    
    #ifdef _ALPHAPREMULTIPLY_ON
        outBRDFData.diffuse *= surfaceData.alpha;
        surfaceData.alpha = surfaceData.alpha * oneMinusReflectivity + reflectivity;
    #endif
    }
    
    half3 FADirectBRDF(FABRDFData brdfData, half3 lightDirectionWS, float3 normalWS, float3 viewDirectionWS)
    {
        half3 halfDir = SafeNormalize(lightDirectionWS + viewDirectionWS);
        half LoH = saturate(dot(lightDirectionWS, halfDir));
        float cosTheta1 = dot(halfDir, float3(lightDirectionWS));
    
        half3 specularTerm = FADirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);
    
        //限制高光不超过7，防止开了bloom的情况下，金属度和光滑度非常高的物体闪烁的情况
        half3 color = clamp(specularTerm * brdfData.specular,0,7) + brdfData.diffuse;
    
        return color;
    }
    
    half3  FALightingPhysicallyBased(FABRDFData brdfData, Light light, float3 normalWS, float3 viewDirectionWS)
    {
        //提高精度，规避移动平台的衰减硬边缘
        half NdotL = saturate(dot(normalWS, light.direction));
        half3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation * NdotL);
    //#if _IRIDESCENCE
    //	return DirectBRDFIridescence2(brdfData, light.direction, normalWS, viewDirectionWS) * radiance;
    //#else
        return FADirectBRDF(brdfData, light.direction, normalWS, viewDirectionWS) * radiance;
        //return LightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
    //#endif
    }
    
    
    // half3 FALightingPhysicallyBasedIridescence(FABRDFData brdfData, Light light, half3 normalWS, half3 viewDirectionWS, half3 fresnelIridescenceLight)
    // {
    //     //提高精度，规避移动平台的衰减硬边缘
    //     half NdotL = saturate(dot(normalWS, light.direction));
    //     half3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation * NdotL);
    // #if _IRIDESCENCE
    //     return DirectBRDFIridescence3(brdfData, light.direction, normalWS, viewDirectionWS, fresnelIridescenceLight) * radiance;
    // #else
    //     return FADirectBRDF(brdfData, light.direction, normalWS, viewDirectionWS) * radiance;
    // #endif
    // }


    
    half3 FAGlossyEnvironmentReflection(half3 reflectVector, half perceptualRoughness, half occlusion, half3 normalWS, float2 uvScreen)
    {
    #if !defined(_ENVIRONMENTREFLECTIONS_OFF)

        #ifdef _PLANARREFLECTION

             uvScreen.x = 1 - uvScreen.x;
             //uvScreen += float2(normalWS.x, normalWS.y) * float2(0.05, 0);
             //uvScreen += float2(( normalWS.x * 0.25 ) , -abs( normalWS.y )) * _DistortionIntensity;
             float4 reflection = SAMPLE_TEXTURE2D(_PlanarReflectionTex, sampler_PlanarReflectionTex, uvScreen + half2(_DistortionIntensity_U,_DistortionIntensity_V));

           half3 irradiance = reflection * _ReflectionColor * _ReflectionIntensity;

        #else

           half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
            // #if _IRIDESCENCE
            //     half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(_IridescenceReflectionCubeMap, sampler_IridescenceReflectionCubeMap, reflectVector, mip);
            //     //encodedIrradiance *= _IridescenceReflectionPower;
            // #else
                
                // #if _ACTOR_USE_REFLECTION_PROBE
                //     half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(_ReflectionProbeMap, sampler_ReflectionProbeMap, reflectVector, mip);
                // #else
                    half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip);
                // #endif
            // #endif
            #if defined(UNITY_USE_NATIVE_HDR) || defined(UNITY_DOTS_INSTANCING_ENABLED) //|| _IRIDESCENCE
                half3 irradiance = encodedIrradiance.rgb;
            #else
                // #if _ACTOR_USE_REFLECTION_PROBE
                //     half3 irradiance = DecodeHDREnvironment(encodedIrradiance, _ReflectionProbeMap_HDR);
                // #else
                    half3 irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
                // #endif
            #endif

        #endif

        return irradiance * occlusion;
    #endif
    
        return _GlossyEnvironmentColor.rgb * occlusion;
    }
    
    half3 FAGlobalIllumination(FABRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS, float2 uvScreen, half atten)
    {
        half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    
        half3 indirectDiffuse = bakedGI * occlusion;
        half3 indirectSpecular = FAGlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion, normalWS, uvScreen);
    
        half atten_power = clamp(atten, 0.35, 1);
        indirectSpecular = indirectSpecular * pow(atten_power, 1.5);
    
        half NoV = saturate(dot(normalWS, viewDirectionWS));
        half fresnelTerm = Pow4(1.0 - NoV);
        
    // #if _SCREEN_SPACE_PLANAR_REFLECTION
    //         float4 SSPRResult = SAMPLE_TEXTURE2D(_SSPR_ColorRT, LinearClampSampler, uvScreen);
    //         indirectSpecular = lerp(indirectSpecular, SSPRResult.rgb * _ReflectionIntensity, SSPRResult.a);
    // #endif
    
        return FAEnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
    }
    
    half3 FAGlobalIllumination(FABRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS, float2 uvScreen, half atten, half _EnvironmentReflectionIntensity)
    {
        half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    
        half3 indirectDiffuse = bakedGI * occlusion;
        half3 indirectSpecular = FAGlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion, normalWS, uvScreen) * _EnvironmentReflectionIntensity;
    
        half atten_power = clamp(atten, 0.35, 1);
        indirectSpecular = indirectSpecular * pow(atten_power, 1.5);
    
        half NoV = saturate(dot(normalWS, viewDirectionWS));
        half fresnelTerm = Pow4(1.0 - NoV);
        
    // #if _SCREEN_SPACE_PLANAR_REFLECTION
    //         //half4 screenPos = ComputeScreenPos(input.positionCS);
    //         //half2 screenUV = screenPos.xy/screenPos.w;
    //         float4 SSPRResult = SAMPLE_TEXTURE2D(_SSPR_ColorRT, LinearClampSampler, uvScreen);
    //         indirectSpecular = lerp(indirectSpecular, SSPRResult.rgb * _ReflectionIntensity, SSPRResult.a);
    // #endif
    
        return FAEnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
    }
    
    // half3 FAGlobalIlluminationIridescence(FABRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS, float2 uvScreen, half atten, half3 fresnelIridescence)
    // {
    //     half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    //
    //     half3 indirectDiffuse = bakedGI * occlusion;
    //     half3 indirectSpecular = FAGlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion); //在这个方法里采样了cubemap计算反射
    //
    //     half atten_power = clamp(atten, 0.35, 1);
    //     indirectSpecular = indirectSpecular * pow(atten_power, 1.5);
    // #ifdef _IRIDESCENCE
    //     return EnvironmentBRDFIridescence(brdfData, indirectDiffuse, indirectSpecular, fresnelIridescence);
    // #else
    //     half NoV = saturate(dot(normalWS, viewDirectionWS));
    //     half fresnelTerm = Pow4(1.0 - NoV);
    //     return FAEnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
    // #endif	
    // }
    
    //这个函数用来在PC平台（RGBM编码的Lightmap）矫正lightmap的颜色以接近移动平台（dLDR编码的Lightmap）的颜色
    half3 FASampleLightmap(float2 lightmapUV, half3 normalWS)
    {
        half3 color = SampleLightmap(lightmapUV, normalWS);
        return color;
    #if defined(UNITY_LIGHTMAP_RGBM_ENCODING)
        //gamma空间下没测试过，先不管
        #ifndef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
            color = clamp(color, 0, 2);
            color = color / 2 * 4.595f;
        #endif
    #endif
        return color;
    }

    #include "../FALib/FADebug.hlsl"

#endif