Shader "URP/MoleGame/Effects/Galaxy"
{
    Properties
    {
        _FinalPower("Final Power", Float) = 4
        _NormalTex("Normal Texture", 2D) = "bump"{}
        _NormalAmount("Normal Amount", Range( 0 , 1)) = 1
        
        // Rim
        _RimAddOrMultiply("Rim Add Or Multiply", Range(0, 1)) = 0
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimEmissionPower("Rim Emission Power", Float) = 1
        _RimExp("Rim Exp", Range(0.2, 10)) = 4
        _RimExp2("Rim Exp 2", Range(0.2, 10)) = 2
        _RimNoiseTex("Rim Noise Texture", 2D) = "white"{}  
        _RimNoiseTilingSpeedAmount("Rim Noise Tiling U_V_Speed_Amount", Vector) = (1, 1, 0.1, -2.5)
        _RimNoiseRefraction("Rim Noise Refraction", Range(0, 1)) = 0
        _RimNoiseTwistAmount("Rim Noise Twist Amount", Range(0, 2)) = 0
        
        // Rim Noise CA
        _RimNoiseCAAmount("Rim Noise CA Amount", Range(0, 0.1)) = 0.1
        _RimNoiseCAU("Rim Noise CA U", Range(0, 1)) = 1
        _RimNoiseCAV("Rim Noise CA V", Range(0, 1)) = 0
        _RimNoiseCARimMaskExp("Rim Noise CA Rim Mask Exp", Range(0.2, 8)) = 4
        _RimNoiseDistortionTex("Rim Noise Distortion Texture", 2D) = "white"{}
        _RimNoiseDistortionTilingAndAmount("Rim Noise Distortion Tiling U_V_Amount", Vector) = (2, 4, 0, 0)        
        _RimNoiseSpherize("Rim Noise Spherize", Range(0, 1)) = 0       
        _RimNoiseSpherizePosition("Rim Noise Spherize Position", Vector) = (0, 0, 0, 0)
  
        _Eta("Eta", Range(-1.0, 0)) = -0.1
        _EtaFresnelExp("Eta Fresnel Exp", Range(1, 8)) = 3
        _EtaFresnelExp2("Eta Fresnel Exp2", Range(1, 8)) = 1
        _EtaAAEdgeFix("Eta AA Edges Fix", Range(0, 0.5)) = 0
        
        _RotationAxis("Rotation Axis", Vector) = (0, 1, 0, 0)        
        _Rotation("Stars_Clouds_DarkClouds Rotation", Vector) = (0,0,0,0)
        _RotationSpeed("Stars_Clouds_DarkClouds Rotation Speed", Vector) = (0.1, 0.1, 0.1, 0)
        _StarsTexture("Stars Texture", Cube) = "skybox"{}
        _StarsEmissionPower("Stars Emission Power", Float) = 4
        _CloudsTexture("Clouds Texture", Cube) = "skybox"{}
        _CloudsOpacityPower("Clouds Opacity Power", Float) = 1
        _CloudsOpacityExp("Clouds Opacity Exp", Range(0.2, 4)) = 1        
        _CloudsEmissionPower("Clouds Emission Power", Float) = 1
        _CloudsRampTex("Clouds Ramp Texture", 2D) = "white"{}
        _CloudsRampColor("Clouds Ramp Color", Color) = (1,1,1,1)
        _CloudsRampOffsetExp("Clouds Ramp Offset Exp", Range(0.2, 8)) = 1
        _CloudsRampOffsetExp2("Clouds Ramp Offset Exp2", Range(0.2, 8)) = 1
        
        // Dark Clouds      
        _DarkCloudsTexture("Dark Clouds Texture", Cube) = "skybox"{}
        _DarkCloudsLighten("Dark Clouds Lighten", Range(1, 10)) = 1
        _DarkCloudsThicker("Dark Clouds Thicker", Range(0.2, 4)) = 1
        
        // Dark Clouds Edges Glow Style
        [Toggle]_DarkCloudsEdgesGlowStyle("Dark Clouds Edges Glow Style", Float) = 0
        _DarkCloudsEdgesGlowPower("Dark Clouds Edges Glow Power", Float) = 50
        _DarkCloudsEdgesGlowExp("Dark Clouds Edges Glow Exp", Range(0.2, 4)) = 1
        _DarkCloudsEdgesGlowClamp("Dark Clouds Edges Glow Clamp", Range(1, 4)) = 2  
        
        [Toggle]_RimEnabled("Enable Rim", Float) = 1  
        [Toggle]_RimNoiseCAEnabled("Rim Noise CA Enabled", Float) = 0   
        [Toggle]_DarkCloudsEnabled("Enable Dark Clouds", Float) = 0  
        
        //TAA用的stencil
		[HideInInspector]_SkipTAA("Skip TAA", int) = 0
		//生效的时候这2个都是16
		[HideInInspector]_TAAStencil("TAA Stencil Ref (Default: 0)", Float) = 16
		[HideInInspector]_TAAStencilMask("TAA Stencil Write Mask (Default: 0)", Float) = 16
		//0是keep 2是Replace
		[HideInInspector]_TAAStencilPassOperate("Stencil Operate (Default: 0)", Float) = 2

    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque" "Queue" = "Geometry" }
        
        Pass
        {
            Name "Galaxy"
            Tags { "LightMode" = "SceneEffect" }
            Cull Back
            
            //跳过TAA处理的Mask
            Stencil {
                Ref [_TAAStencil]
                WriteMask [_TAAStencilMask]
                Comp always
                Pass [_TAAStencilPassOperate]
            }
            
            HLSLPROGRAM
            #pragma vertex GalaxyVertex
            #pragma fragment GalaxyFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "../FALib/FaPublicFunction.hlsl"
            
            TEXTURE2D(_NormalTex);				        SAMPLER(sampler_NormalTex);
            TEXTURECUBE(_StarsTexture);				    SAMPLER(sampler_StarsTexture);
            TEXTURECUBE(_CloudsTexture);				SAMPLER(sampler_CloudsTexture);
            TEXTURE2D(_CloudsRampTex);				    SAMPLER(sampler_CloudsRampTex);
            TEXTURECUBE(_DarkCloudsTexture);			SAMPLER(sampler_DarkCloudsTexture);
            TEXTURE2D(_RimNoiseDistortionTex);          SAMPLER(sampler_RimNoiseDistortionTex);
            TEXTURE2D(_RimNoiseTex);                    SAMPLER(sampler_RimNoiseTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _NormalTex_ST;
            half _NormalAmount;
            
            half4 _RotationSpeed;
            half4 _Rotation;
            
            // eta
            half _Eta;
            half _EtaFresnelExp;
            half _EtaFresnelExp2;
            half _EtaAAEdgeFix;
            half4 _RotationAxis;
            
            half _RimNoiseRefraction;
            half _RimAddOrMultiply;
            
            float4 _StarsTexture_ST;
            float4 _CloudsTexture_ST;
            float4 _CloudsRampTex_ST;
            half4 _CloudsRampColor;
            float4 _DarkCloudsTexture_ST;
            half _CloudsRampOffsetExp;
            half _CloudsRampOffsetExp2;
            half _StarsEmissionPower;
            half _CloudsEmissionPower;
            half _CloudsOpacityExp;
            half _CloudsOpacityPower;
            half _DarkCloudsThicker;
            half _DarkCloudsLighten;
            half _DarkCloudsEdgesGlowStyle;
            half _DarkCloudsEdgesGlowExp;
            half _DarkCloudsEdgesGlowPower;
            half _DarkCloudsEdgesGlowClamp;
            half _DarkCloudsEnabled;
           
            
            half _FinalPower;
            
            // Rim
            half _RimEnabled;
            half4 _RimNoiseSpherizePosition;
            half4 _RimNoiseTilingSpeedAmount;
            half _RimNoiseTwistAmount;
            half _RimNoiseCAU;
            half _RimNoiseCAV;
            half _RimNoiseCAAmount;
            half4 _RimNoiseDistortionTilingAndAmount;
            float4 _RimNoiseDistortionTex_ST;
            float4 _RimNoiseTex_ST;
            half _RimExp;
            half _RimExp2;
            
            half _RimNoiseCAEnabled;
            half _RimEmissionPower;
            half4 _RimColor;
            half _RimNoiseSpherize;
            half _RimNoiseCARimMaskExp;
            
            CBUFFER_END
            
            struct Attributes
            {
                float4 positionOS : POSITION; 
                float3 normalOS   : NORMAL;  
                float4 tangentOS  : TANGENT;
                float2 uv         : TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 tangentWS  : TEXCOORD3;
                float3 bitangentWS: TEXCOORD4;
  
            };
            
            float3 CustomRefraction(float3 viewDirWS, float3 normalWS, float eta, float param)
            {
                float d = -abs(dot(normalWS, viewDirWS) + param);
                float k = 1.0 - eta * eta * (1.0 - d * d);
                float3 r = eta * viewDirWS - (eta * d + sqrt(k)) * normalWS;
                return r;
            }
            
            Varyings GalaxyVertex(Attributes input)
            {
                Varyings output = (Varyings) 0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.positionWS = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.normalWS = vertexNormalInput.normalWS;
                output.tangentWS = vertexNormalInput.tangentWS;
                output.bitangentWS = vertexNormalInput.bitangentWS;
                output.uv = input.uv.xy;
                return output;
            }
            
            half4 GalaxyFragment(Varyings input, half facing : VFACE) : SV_Target
            {
                // Base
                float time = fmod(_Time.x, 10); 
                float3 viewDirWS = SafeNormalize(GetCameraPositionWS() - input.positionWS); 
                
                float3 tanToWorldX = float3(input.tangentWS.x, input.bitangentWS.x, input.normalWS.x);
                float3 tanToWorldY = float3(input.tangentWS.y, input.bitangentWS.y, input.normalWS.y);
                float3 tanToWorldZ = float3(input.tangentWS.z, input.bitangentWS.z, input.normalWS.z); 
                
                float4 normal = SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, TRANSFORM_TEX(input.uv, _NormalTex));
                float3 normalTS = lerp(half3(0,0,1), UnpackNormalScale(normal, 1.0), _NormalAmount);
                
                float3 normalWS = float3(dot(tanToWorldX, normalTS), dot(tanToWorldY, normalTS), dot(tanToWorldZ, normalTS));
                
                // Rim
                float fresnel_eta = Fresnel(input.normalWS, viewDirWS, 0, 1, _EtaFresnelExp);//pow(1.0 - dot(input.normalWS, viewDirWS), _EtaFresnelExp);
                float fresnel = Fresnel(input.positionWS, viewDirWS, 0, 1, 1);
                float fresnel_v = _RimNoiseTwistAmount * fresnel * _RimNoiseTilingSpeedAmount.y; // first multiply
                float fresnel_u = fresnel * _RimNoiseTilingSpeedAmount.x;  // third multiply

                // uv
                float3 position_world = normalize(input.positionWS - TransformObjectToWorld(_RimNoiseSpherizePosition.xyz));  // _RimNoiseSpherizePosition.w = 1
                float3 rim_noise_position_world = lerp(input.normalWS, position_world, _RimNoiseSpherize);
                float3 rim_noise_position_view = TransformWorldToView(rim_noise_position_world);  //rim_noise_position_world.w = 0
                float theta = atan2(rim_noise_position_view.x, rim_noise_position_view.y);  
                theta = 0.0 + (theta - -1 * PI) * (1.0 - 0.0) / (PI - (-1.0 * PI));
                theta = 0.0 + (max(1 - theta, theta) - 0.5) * (1.0 - 0.0) / (1 - 0.5);
                float theta_v = theta * _RimNoiseTilingSpeedAmount.y; // second multiply
                float offset = time * _RimNoiseTilingSpeedAmount.z;    // fourth multiply
                float u = fresnel_u + offset;   // 2-1 Add
                float v = fresnel_v + theta_v;  // 1-1 Add
                float2 uv_append = float2(v, u);  // first append
                
                // Rim UV
                float fresnel_mask = Fresnel(input.positionWS, viewDirWS, 0, 1, _RimNoiseCARimMaskExp);
                float rim_u = _RimNoiseCAU * _RimNoiseCAAmount * fresnel_mask; // 1-1 multiply
                float rim_v = _RimNoiseCAV * _RimNoiseCAAmount * fresnel_mask; // 2-1 multiply
                float rim_u_add = fresnel_v + theta_v + rim_u;  // 1-2 Add
                float rim_v_add = u + rim_v;                    // 2-2 Add
                float2 rim_uv_append = float2(rim_u_add, rim_v_add); // second append
                
                // Rim UV * 2
                float rim_u_double = rim_u * 2;  // 1-2 multiply
                float rim_v_double = rim_v * 2;  // 2-2 multiply
                float2 rim_uv_double_append = float2(fresnel_v + theta_v + rim_u_double, rim_v_add + rim_v_double); // 1-3 Add // 2-3 Add  //third append
                
                
                // Rim Noise Distortion
                float2 rim_distortion_uv = _RimNoiseDistortionTilingAndAmount.xy * float2(theta, u);
                float4 rim_distortion_tex = SAMPLE_TEXTURE2D(_RimNoiseDistortionTex, sampler_RimNoiseDistortionTex, TRANSFORM_TEX(rim_distortion_uv, _RimNoiseDistortionTex));
                float fresnel_distortion = Fresnel(normalWS, viewDirWS, 0, 1, 1);
                float3 normal_view = TransformWorldToView(normalWS) * rim_distortion_tex.r * _RimNoiseDistortionTilingAndAmount.z * fresnel_distortion;
                
                float rim_noise_tex_uv = SAMPLE_TEXTURE2D(_RimNoiseTex, sampler_RimNoiseTex, TRANSFORM_TEX(uv_append + normal_view, _RimNoiseTex)).r * _RimNoiseTilingSpeedAmount.w; // distortion first Add
                float rim_noise_tex_rimUV = SAMPLE_TEXTURE2D(_RimNoiseTex, sampler_RimNoiseTex, TRANSFORM_TEX(rim_uv_append + normal_view, _RimNoiseTex)).r * _RimNoiseTilingSpeedAmount.w; 
                float rim_noise_tex_rimUV2 = SAMPLE_TEXTURE2D(_RimNoiseTex, sampler_RimNoiseTex, TRANSFORM_TEX(rim_uv_double_append + normal_view, _RimNoiseTex)).r * _RimNoiseTilingSpeedAmount.w;
                
                float3 normal_world_uv = normalize(lerp(normalWS, viewDirWS, rim_noise_tex_uv));
                float3 normal_world_rimUV = normalize(lerp(normalWS, viewDirWS, rim_noise_tex_rimUV));
                float3 normal_world_rimUV2 = normalize(lerp(normalWS, viewDirWS, rim_noise_tex_rimUV2));
                
                float normal_fresnel_uv = Fresnel(normal_world_uv, viewDirWS, 0, 1, 1);
                float normal_fresnel_rimUV = Fresnel(normal_world_rimUV, viewDirWS, 0, 1, 1);
                float normal_fresnel_rimUV2 = Fresnel(normal_world_rimUV2, viewDirWS, 0, 1, 1);
                
                float rim_noise_x = 1 - pow(1 - clamp(pow(normal_fresnel_uv, _RimExp), 0, 1), _RimExp2);
                float rim_noise_y = 1 - pow(1 - clamp(pow(normal_fresnel_rimUV, _RimExp), 0, 1), _RimExp2);
                float rim_noise_z = 1 - pow(1 - clamp(pow(normal_fresnel_rimUV2, _RimExp), 0, 1), _RimExp2);
                
                float3 rim_noise_ca = lerp(rim_noise_x, float3(rim_noise_x, rim_noise_y, rim_noise_z), _RimNoiseCAEnabled);
                
                // Rim Color
                float4 rim_color = float4(rim_noise_ca, 1) * _RimEmissionPower.xxxx * _RimColor;
                rim_color = lerp(0, rim_color, _RimEnabled);
                half4 rim_mul_add = rim_color * lerp(0, 1, _RimAddOrMultiply) + 1.0;
                half4 rim_mul_min = rim_color * (1.0 - lerp(0, 1, _RimAddOrMultiply)); 
                
                // Rim Noise Refraction
                float rim_noise_refraction = rim_noise_x * -_RimNoiseRefraction;
                //float fresnel_eta = pow(1.0 - dot(input.normalWS, viewDirWS), _EtaFresnelExp);
                float eta = 1.0 + _Eta * clamp(1.0 - pow(1.0 - clamp(fresnel_eta, 0, 1), _EtaFresnelExp2), 0.0, 1.0) + rim_noise_refraction;
                
                // Stars - Clouds - Dark Clouds
                float4 ratation = time * _RotationSpeed + _Rotation;
               
                // [1] Stars  
                float3 rotate_norwalWS_stars = RotateAroundAxis(half3(0,0,0), normalWS, normalize(_RotationAxis.xyz), ratation.x);
                float3 rotate_viewDirWS_stars = RotateAroundAxis(half3(0,0,0), -viewDirWS, _RotationAxis.xyz, ratation.x);
                float3 refraction_stars = CustomRefraction(rotate_viewDirWS_stars, rotate_norwalWS_stars, eta, _EtaAAEdgeFix);
                half4 stars_tex = SAMPLE_TEXTURECUBE_LOD(_StarsTexture, sampler_StarsTexture, refraction_stars, 0);
                half4 stars_color = stars_tex * _StarsEmissionPower * rim_mul_add;  
                
                // [2] Clouds
                float3 rotate_norwalWS_clouds = RotateAroundAxis(half3(0,0,0), normalWS, normalize(_RotationAxis.xyz), ratation.y);
                float3 rotate_viewDirWS_clouds = RotateAroundAxis(half3(0,0,0), -viewDirWS, _RotationAxis.xyz, ratation.y);
                float3 refraction_clouds = CustomRefraction(rotate_viewDirWS_clouds, rotate_norwalWS_clouds, eta, _EtaAAEdgeFix);
                half4 clouds_tex = SAMPLE_TEXTURECUBE_LOD(_CloudsTexture, sampler_CloudsTexture, refraction_clouds, 0);
                half clouds_clamp = clamp(pow(clouds_tex.r, _CloudsOpacityExp) * _CloudsOpacityPower, 0.0, 1.0);
                
                // [3] Dark Clouds
                float3 rotate_norwalWS_darkClouds = RotateAroundAxis(half3(0,0,0), normalWS, normalize(_RotationAxis.xyz), ratation.z);
                float3 rotate_viewDirWS_darkClouds = RotateAroundAxis(half3(0,0,0), -viewDirWS, _RotationAxis.xyz, ratation.z);
                float3 refraction_darkClouds = CustomRefraction(rotate_viewDirWS_darkClouds, rotate_norwalWS_darkClouds, eta, _EtaAAEdgeFix);
                half4 darkClouds_tex = SAMPLE_TEXTURECUBE_LOD(_DarkCloudsTexture, sampler_DarkCloudsTexture, refraction_darkClouds, 0);
               
                // Clouds Ramp              
                half2 clouds_ramp_uv = half2(1 - pow(1 - clamp(pow(clouds_tex.r, _CloudsRampOffsetExp), 0, 1), _CloudsRampOffsetExp2), 0);
                half4 clouds_ramp_tex = SAMPLE_TEXTURE2D(_CloudsRampTex, sampler_CloudsRampTex, TRANSFORM_TEX(clouds_ramp_uv, _CloudsRampTex));
                half4 clouds_ramp = clouds_ramp_tex * _CloudsEmissionPower * _CloudsRampColor * rim_mul_add;
                   
                
                half4 satrs_clouds_blend = lerp(stars_color, clouds_ramp, clouds_clamp);
                
                half dark_clouds_clamp_r = clamp(pow(_DarkCloudsThicker, darkClouds_tex.r) * _DarkCloudsLighten, 0, 1);
                
                // Dark Clouds Edge Glow Style
                half glow_style = lerp(darkClouds_tex.g, darkClouds_tex.b, _DarkCloudsEdgesGlowStyle);
                half dark_clouds_clamp_gb = clamp(pow(glow_style, _DarkCloudsEdgesGlowExp) * _DarkCloudsEdgesGlowPower + 1.0, 0.0, _DarkCloudsEdgesGlowClamp);
                
                half4 stars_color_2 = stars_tex * _StarsEmissionPower * dark_clouds_clamp_gb * rim_mul_add;
                half4 clouds_ramp_color = clouds_ramp_tex * _CloudsEmissionPower * _CloudsRampColor * dark_clouds_clamp_gb * rim_mul_add;
                half4 stars_cloudsRamp_blend = lerp(stars_color_2, clouds_ramp_color, clouds_clamp);
                stars_cloudsRamp_blend = lerp(0, stars_cloudsRamp_blend, dark_clouds_clamp_r);
                
                half4 main_color = _FinalPower * lerp(satrs_clouds_blend, stars_cloudsRamp_blend, _DarkCloudsEnabled);
                
                half4 color = main_color + rim_mul_min;
                return color;
            }
            
            ENDHLSL
        }
    }
    CustomEditor "JTRP.ShaderDrawer.LWGUI" 
}
