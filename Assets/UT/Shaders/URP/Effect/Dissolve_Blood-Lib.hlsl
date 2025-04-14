#ifndef DISSOLVE_BLOOD_INCLUDE
    #define DISSOLVE_BLOOD_INCLUDE
    
    #include "../FALib/FALighting.hlsl"
    #include "../FALib/FACustomFogLib.hlsl"
    
    struct DissolveBloodVertexInput
    {
        half4 positionOS : POSITION;
        half3 normalOS   : NORMAL;
        half4 color      : COLOR;
        half4 uv         : TEXCOORD0;
        half4 uvLM       : TEXCOORD1;
        half4 tangentOS  : TANGENT;
    };

    struct DissolveBloodVertexOutput
    {
        float4 positionCS               : SV_POSITION;
        half4 uv                        : TEXCOORD0;
        half4 uvLM                      : TEXCOORD1;
        half4 positionWSAndFogFactor    : TEXCOORD2; // xyz: positionWS, w: positionOS fog factor
        half3 normalWS                  : TEXCOORD3;
        half3 tangentWS				    : TEXCOORD4;
        half3 bitangentWS			    : TEXCOORD5;				
    #ifdef _MAIN_LIGHT_SHADOWS
        half4 shadowCoord			    : TEXCOORD6; // compute shadow coord per-positionOS for the main light
    #endif
        half4 fogColor               :TEXCOORD7;
    };

    DissolveBloodVertexOutput DissolvBloodVertex ( DissolveBloodVertexInput v )
    {
        DissolveBloodVertexOutput output = (DissolveBloodVertexOutput)0;

        output.uv.xy = v.uv.xy;
        output.uvLM.xy = v.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
        output.positionCS = vertexInput.positionCS;
        //float fogFactor = ComputeFogFactorLinear(vertexInput.positionCS.z);
        output.positionWSAndFogFactor = float4(vertexInput.positionWS, 1);
        
        VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);
        output.normalWS = vertexNormalInput.normalWS;
        output.tangentWS = vertexNormalInput.tangentWS;
        output.bitangentWS = vertexNormalInput.bitangentWS;
        
        #ifdef _MAIN_LIGHT_SHADOWS
            output.shadowCoord = GetShadowCoord(vertexInput);
        #endif
        CustomMixFogColor(vertexInput.positionWS, output.fogColor.xyz, output.fogColor.w);
        return output;
    }
    
    inline FASurfaceData InitializeFASurfaceDataCustom(DissolveBloodVertexOutput input, half facing = 1)
    {
        FASurfaceData outSurfaceData = (FASurfaceData)0;
        half4 albedo = _Color * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));
        half4 ao_m_s_e = SAMPLE_TEXTURE2D(_CombinedAO, sampler_CombinedAO, TRANSFORM_TEX(input.uv, _CombinedAO));
        outSurfaceData.albedo = albedo.rgb;
        outSurfaceData.alpha = albedo.a;
        outSurfaceData.occlusion =  saturate(ao_m_s_e.r * _CombinedScaledParams.r);
        outSurfaceData.metallic = saturate(ao_m_s_e.g * _CombinedScaledParams.g);
        outSurfaceData.smoothness = saturate((1 - ao_m_s_e.b) * _CombinedScaledParams.b);
        outSurfaceData.emission = ao_m_s_e.a * _CombinedScaledParams.a;

        half3 normal = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uv.xy), _BumpScale);
        normal.z = lerp( 1, normal.z, saturate(_BumpScale) );
        
        half2 uvOffset = input.uv.xy * float2( 1,1 ) + float2( 0,0 );
        half dissolveUVOffset = pow( _DissolveUVOffset , 3.0 ) * 0.1;
        half2 dissolveUV = float2(( uvOffset.x + dissolveUVOffset ) , uvOffset.y);
        half4 dissolveColor = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, TRANSFORM_TEX(dissolveUV.xy, _DissolveTex));
        
        half dissolveMin = lerp(_DissolveMin, input.uv.z, _UseCustomData);
        half dissolveMax = lerp(_DissolveMax, input.uv.w, _UseCustomData);
        
        half dissolve = smoothstep( dissolveMin , dissolveMax , dissolveColor.g);
        half4 dissolveColor2 = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, TRANSFORM_TEX(input.uv.xy, _DissolveTex));
        half dissolve2 = smoothstep( dissolveMin , dissolveMax , dissolveColor2.g);
        
        float time = fmod(_Time.x, 10);
        half2 detailUV =( 1.0 * time * float2( 0.1,0.1 ) + uvOffset);
        half4 detailColor = SAMPLE_TEXTURE2D(_DetailTex, sampler_DetailTex, TRANSFORM_TEX(detailUV, _DetailTex));
        
        float3 dissolveCombine = (float3(1.0 , 0.0 , ( ( dissolve - dissolve2 ) * _DissolveStrength * detailColor.r )));
        
        float2 dissolveUV2 = (float2(uvOffset.x , ( uvOffset.y + dissolveUVOffset )));
        half4 dissolveColor3 = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, TRANSFORM_TEX(dissolveUV2.xy, _DissolveTex));
        half dissolve3 = smoothstep( dissolveMin , dissolveMax , dissolveColor3.g);
        float3 finalDissolve = (float3(0.0 , 1.0 , ( ( dissolve3 - dissolve2 ) * _DissolveStrength * detailColor.r )));
        float3 normalizeDissolve = normalize( cross( dissolveCombine , finalDissolve ) );
        
        float3 normalTS = BlendNormal( normalizeDissolve , normal );
        outSurfaceData.normalTS = normalTS * facing;
        
        half alphaComp = lerp(_AlphaComplement, input.uvLM.z, _UseCustomData);
        outSurfaceData.alpha = saturate( ( step( ( _DissolveMin - alphaComp ) , dissolveColor2.g ) + step( _DissolveMin , dissolveColor.g ) + step( _DissolveMin , dissolveColor3.g ) ) );
        return outSurfaceData;
    }
    
    half4 OutputDissolveBloodStandardColor(DissolveBloodVertexOutput input, FASurfaceData surfaceData, half facing = 1)
    {
        #if defined(_ALPHATEST_ON)
        clip(surfaceData.alpha - _Cutoff);
        #endif
        
        FABRDFData brdfData;
        InitializeFABRDFData(surfaceData, brdfData);
        half3 normalWS = TransformTangentToWorld(surfaceData.normalTS, half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
        normalWS = normalize(normalWS) * facing;
        
        float3 positionWS = input.positionWSAndFogFactor.xyz;
        half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
        
        #ifdef LIGHTMAP_ON
            half3 bakedGI = FASampleLightmap(input.uvLM, normalWS);
        #else
            half3 bakedGI = SampleSH(normalWS);
        #endif
        
        #ifdef _MAIN_LIGHT_SHADOWS
            Light mainLight = GetMainLight(input.shadowCoord);
        #else
            Light mainLight = GetMainLight();
        #endif
        
        half atten = clamp(mainLight.shadowAttenuation, 0, 1);
        float2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);
        half3 color = FAGlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS, uvScreen, atten);
        
        color += FALightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);
        
        
        uint pixelLightCount = GetAdditionalLightsCount();
        for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
        {
            Light light = GetAdditionalLight(lightIndex, positionWS);
            #if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
                light.color *= aoFactor.directAmbientOcclusion;
            #endif
            color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
        }
        
        color += surfaceData.emission;
        half alpha = 1.0;
        #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
        alpha = surfaceData.alpha;
        #endif
        return float4(color, alpha);
    }
    
    half4 DissolveBloodFragment ( DissolveBloodVertexOutput input, half facing : VFACE) : SV_Target
    {
        //float fogFactor = ComputeFogFactorLinear(input.positionCS.z * input.positionCS.w);
        FASurfaceData surfaceData = InitializeFASurfaceDataCustom(input);
        half4 color = OutputDissolveBloodStandardColor(input, surfaceData, facing);
        color.rgb = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);
        return color;
    }
#endif			