Shader "UT-Rendering/InteriorMap"
{
    Properties
    {
        [SubEnum(_, HeightFog, 0, CustomHeightFog, 1)] _FogMode ("Fog Mode", Float) = 0
		[ShowIf(_FogMode, Equal,1)]
		[Sub] _FogIntensity ("FogIntensity", Range(0.0, 1.0)) = 0.5
        [HideInInspector]_Cull("__cull", Float) = 2.0
        [HideInInspector]_Comp("Comp",Float) = 3
		[HideInInspector]_Pass("Pass",Float) = 0
		[HideInInspector]_StenilRef("Stenil Ref", Float) = 0
        _InteriorMap ("InteriorMap", 2D) = "white" {}
        _Roomdepth("Room Depth", Range(0.1, 10)) = 1
        _AspectRatio("Aspect Ratio", Range(0.1, 10)) = 1
        _furniture1Depth("Furniture1 Depth", Range(0, 1)) = 0.8
        _furniture1Alpha("Furniture1 Alpha", Range(0, 1)) = 1
        _furniture2Depth("Furniture2 Depth", Range(0, 1)) = 0.5
        _furniture2Alpha("Furniture2 Alpha", Range(0, 1)) = 1
        _furniture3Depth("Furniture3 Depth", Range(0, 1)) = 0.2
        _furniture3Alpha("Furniture3 Alpha", Range(0, 1)) = 1
        _CurtainAlpha("Curtain Alpha", Range(0, 1)) = 1
        _Brightness("Brightness", float) = 1
        _SkyCube("SkyCube",Cube) = "white"{}
        _ExponentIn("ExponentIn", float) = 1
        _TOD_MinBrightness("TOD_MinBrightness", float) = 0.15
        _TOD_MaxBrightness("TOD_MaxBrightness", float) = 0.4
        _SkyRefInensityNight("SkyRefInensityNight", float) = 0.07
        _SkyRefInensityDay("SkyRefInensityDay", float) = 1
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry"}
            LOD 100

            HLSLPROGRAM
            #pragma multi_compile _ _PIXELFOG_ON
            #pragma multi_compile_fragment _ _CUSTOM_SCREEN_SPACE_OCCLUSION
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"



          
			struct VertexInput
			{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};

            struct VertexOutput
            {
                float2 uv            :   TEXCOORD0;
                float4 pos           : SV_POSITION;
                float3 worldPos      :   TEXCOORD1;
                float3 worldNormal   :   TEXCOORD2;
                float3 worldTangent  :   TEXCOORD3;
                float3 worldBinormal :   TEXCOORD4;
                half4 fogColor               : TEXCOORD5;
            };

            CBUFFER_START(UnityPerMaterial)
            float _Roomdepth;
            float _AspectRatio;
            Texture2D _InteriorMap;
            sampler sampler_InteriorMap;
            float4 _InteriorMap_ST;
            float _furniture1Depth;
            float _furniture1Alpha;
            float _furniture2Depth;
            float _furniture2Alpha;
            float _furniture3Depth;
            float _furniture3Alpha;
            float _CurtainAlpha;
            float _Brightness;
            TextureCube _SkyCube;
            SamplerState sampler_SkyCube;
            float _ExponentIn;
            float _TOD_MinBrightness;
            float _TOD_MaxBrightness;
            float _SkyRefInensityDay;
            float _SkyRefInensityNight;     
    	    half _FogMode;
	        half _FogIntensity;
            half Occlusion;
            CBUFFER_END

            #define oneThird 0.33333333
            #define twoThird 0.66666667
              #include "Assets/UT/Shaders/URP/FALib/FACustomFogLib.hlsl"
              // #include "G:/unity project/UT-Graphics/ut-graphics/Packages/com.ut.rendering/Shaders/URP/FALib/FALighting.hlsl"
              	
                                    	
AmbientOcclusionFactor CustomGetScreenSpaceAmbientOcclusion(float2 normalizedScreenSpaceUV)  //搬运自FALighting.hlsl
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
float3 AOMultiBounce( float3 BaseColor, float AO )
{
	float3 a =  2.0404 * BaseColor - 0.3324;
	float3 b = -4.7951 * BaseColor + 0.6417;
	float3 c =  2.7552 * BaseColor + 0.6903;
	return max( AO, ( ( AO * a + b ) * AO + c ) * AO );
}



            VertexOutput vert (VertexInput input)
            {
                VertexOutput output;
                output.uv = input.uv;
                output.pos = TransformObjectToHClip(input.vertex);
                output.worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
                output.worldNormal = TransformObjectToWorldNormal(input.normal);
                output.worldTangent = TransformObjectToWorldDir(input.tangent.xyz);
                output.worldBinormal = cross(output.worldNormal, output.worldTangent) * input.tangent.w;
                //Fog
                #ifndef _PIXELFOG_ON
		        CustomMixFogColor( output.worldPos, output.fogColor.xyz, output.fogColor.w);
                #endif
				return output;
            }

            half4 frag (VertexOutput input) : SV_Target
            {
                //-------- Global Variable Remaping ------

                float3 viewDirWorld = normalize(_WorldSpaceCameraPos - input.worldPos);
                // 构建切线空间矩阵
                float3x3 tangentSpaceMatrix = float3x3(input.worldTangent, input.worldBinormal, input.worldNormal);
                // 将视图方向转换到切线空间
                float3 viewDirTangent = mul(tangentSpaceMatrix, viewDirWorld);
                float3 objI = -viewDirTangent * float3(1 / _AspectRatio, 1, 1);
                float3 uv2Center = float3(input.uv, 0.5f) * 2 - 1;
                float3 objP = uv2Center * 0.5f + 0.5f;

                //-------- Bases for width height depth -------
                float3 sections = step(float3(0,0,0), objI);
                float3 baseDepth = (objP - sections) / (_Roomdepth * (-objI));
                float3 baseBack = (objP - sections) / (-objI);
                float3 baseWidth = baseDepth * _Roomdepth;

                //-------- Depth width ramps -------
                float3 baseDepthX = baseDepth.y * objI + objP + 1;
                float3 baseDepthY = baseDepth.x * objI + objP + 1;
                float3 baseWidthX = baseWidth.y * objI + objP + 1;
                float3 baseWidthY = baseWidth.x * objI + objP + 1;

                float horizonU = baseDepthY.z - 0.5f;
                float verticleU = baseWidthX.x - 1;
                float horizonV = baseWidthY.y - 1;
                float verticleV = baseDepthX.z -0.5f;


                //-------- Floor Ceiling -------
                float floorCeilMask = step(0, 1 - max(1 - verticleU, verticleU)) * step(0, verticleV);
                float3 floorCeil_uv = float3(verticleU, verticleV, 0) / 3;
                float3 ceil_uv = (floorCeil_uv + float3(oneThird, twoThird, 0)) * floorCeilMask * sections.y;
                float3 floor_uv = (floorCeil_uv + float3(oneThird, 0, 0)) * floorCeilMask * (1 - sections.y);
                floor_uv.y = (oneThird - floor_uv.y) * floorCeilMask * (1 - sections.y);
                floorCeil_uv = ceil_uv + floor_uv;

                //-------- Side Walls -------
                float sideWallsMask = step(0, 1 - max(1 - horizonV, horizonV)) * step(0, horizonU);
                float3 sideWalls_uv = float3(horizonU, horizonV, 0) / 3;
                float3 rightWall_uv = (sideWalls_uv + float3(twoThird, oneThird, 0)) * sideWallsMask * sections.x;
                float3 leftwall_uv = (sideWalls_uv + float3(0, oneThird, 0)) * sideWallsMask * (1 - sections.x);
                leftwall_uv.x = ((oneThird) - leftwall_uv.x) * sideWallsMask * (1 - sections.x);
                sideWalls_uv = rightWall_uv + leftwall_uv;

                //-------- Back Wall --------
                float3 backWall_uv = baseBack.z * objI + objP * 0.5 / _Roomdepth;
                backWall_uv = backWall_uv * _Roomdepth * 2 / 3 + float3(oneThird, oneThird, 0);
                backWall_uv *= 1 - max(step(0, horizonU), step(0, verticleV));

                //-------- Background --------
                float3 wall_UV = max(max(floorCeil_uv, sideWalls_uv), backWall_uv);
                half4 wallCol = SAMPLE_TEXTURE2D(_InteriorMap, sampler_InteriorMap, wall_UV.xy);

                //-------- Furniture1 --------
                _furniture1Depth *= _Roomdepth;
                float3 furniture1_uv = ((baseBack.z * objI + objP / (_furniture1Depth * 2)) * (_furniture1Depth * 2)) / 3;
                float furniture1HorizMask = step(0, ((furniture1_uv.y - 0.003) * 3.03) * (1 - (furniture1_uv.y + 0.003) * 3.03));
                float furniture1VertMask = step(0, (furniture1_uv.x - 0.003) * (0.333 - furniture1_uv.x - 0.003));
                float furniture1Mask = furniture1HorizMask * furniture1VertMask;
                furniture1_uv *= furniture1Mask;
                float2 furniture1_uvFinal = float2(furniture1_uv.x, furniture1_uv.y + twoThird);
                half4 furniture1Col = SAMPLE_TEXTURE2D(_InteriorMap, sampler_InteriorMap, furniture1_uvFinal);
                furniture1Col *= furniture1Mask;
                
                //-------- Furniture2 --------
                _furniture2Depth *= _Roomdepth;
                float3 furniture2_uv = ((baseBack.z * objI + objP / (_furniture2Depth * 2)) * (_furniture2Depth * 2)) / 3;
                furniture2_uv = 0.333f - furniture2_uv;
                float furniture2HorizMaskButtom = (furniture2_uv.y + 0.003) * 3.01;
                float furniture2HorizMask = step(0, furniture2HorizMaskButtom * (1 - furniture2HorizMaskButtom));
                float furniture2VertMask = step(0, (furniture2_uv.x - 0.003) * (0.333 - furniture2_uv.x - 0.003));
                float furniture2Mask = furniture2HorizMask * furniture2VertMask;
                furniture2_uv *= furniture2Mask;
                float2 furniture2_uvFinal = float2(1 - furniture2_uv.x, 1 - furniture2_uv.y);
                half4 furniture2Col = SAMPLE_TEXTURE2D(_InteriorMap, sampler_InteriorMap, furniture2_uvFinal);
                furniture2Col *= furniture2Mask;
                
                //-------- Furniture3 --------
                _furniture3Depth *= _Roomdepth;
                float3 furniture3_uv = ((baseBack.z * objI + objP / (_furniture3Depth * 2)) * (_furniture3Depth * 2)) / 3;
                furniture3_uv = 0.3333f - furniture3_uv;
                float furniture3HorizMaskButtom = (furniture3_uv.y - 0.003) * 3.03;
                float furniture3HorizMask = step(0, furniture3HorizMaskButtom * (1 - furniture3HorizMaskButtom)) ;
                float furniture3VertMask = step(0, (furniture3_uv.x - 0.003) * (0.3333 - furniture3_uv.x - 0.003));
                float furniture3Mask = furniture3HorizMask * furniture3VertMask;
                furniture3_uv *= furniture3Mask;
                float2 furniture3_uvFinal = float2((1 - furniture3_uv.x), (1 - (furniture3_uv.y + 0.3333 * 2)));
                half4 furniture3Col = SAMPLE_TEXTURE2D(_InteriorMap, sampler_InteriorMap, furniture3_uvFinal);
                furniture3Col *= furniture3Mask;

                //-------- Curtain --------
                float3 curtain_uv = (uv2Center * 0.5 + 0.5) * float3(oneThird, oneThird, 1) - 0.333;
                float2 curtain_uvFinal = float2(curtain_uv.x + 0.333, curtain_uv.y - 0.333 * 2);
                half4 curtainCol = SAMPLE_TEXTURE2D(_InteriorMap, sampler_InteriorMap, curtain_uvFinal);


                //-------- FrontGround Merge ---------
                half furnitue1Alpha = furniture1Col.w * _furniture1Alpha;
                half furnitue2Alpha = furniture2Col.w * _furniture2Alpha;
                half furnitue3Alpha = furniture3Col.w * _furniture3Alpha;
                half curtainAlpha = curtainCol.w * _CurtainAlpha;
                half3 furniture1stMerge = lerp(furniture1Col.xyz, furniture2Col.xyz, furnitue2Alpha);
                half3 furniture2ndMerge = lerp(furniture1stMerge.xyz, furniture3Col.xyz, furnitue3Alpha);
                half3 furniture3rdMerge = lerp(furniture2ndMerge.xyz, curtainCol.xyz, curtainAlpha);
                half mergeAlpha = max(max(max(furnitue1Alpha, furnitue2Alpha), furnitue3Alpha), curtainAlpha);

                //-------- Final InteriorMap --------
                half3 interiorCol = lerp(wallCol.xyz, furniture3rdMerge, mergeAlpha) * _Brightness;

                //-------- Glass -----------
                float3 viewDir = normalize(_WorldSpaceCameraPos - input.worldPos);
                float3 reflectDir = reflect(-viewDir, input.worldNormal);
                float4 cubeColor = _SkyCube.Sample(sampler_SkyCube, reflectDir);
                viewDir = normalize(GetWorldSpaceViewDir(input.worldPos));
                float fresnelEffect = pow(1.0 - saturate(dot(normalize(input.worldNormal), viewDir)), _ExponentIn);
                float3 refColor = interiorCol + lerp(interiorCol, cubeColor.xyz, fresnelEffect);
                Light mainLight = GetMainLight();
                float3 mainLightDir = -mainLight.direction;
                float brightAdj = clamp(lerp(_TOD_MinBrightness, _TOD_MaxBrightness, mainLightDir.z), _SkyRefInensityNight, _SkyRefInensityDay);
                float3 col = lerp(0, refColor, brightAdj);

                //SSAO
                float2 ScreenUV = GetNormalizedScreenSpaceUV(input.pos);
                #if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
                    AmbientOcclusionFactor aoFactor = CustomGetScreenSpaceAmbientOcclusion(ScreenUV);
                     Occlusion =aoFactor.indirectAmbientOcclusion; 
                     col *= Occlusion;
                #endif 
              
                //Fog
		        #ifdef _PIXELFOG_ON
		        CustomMixFogColor(input.worldPos, input.fogColor.xyz, input.fogColor.w);
		        #endif
               // Occlusion =  lerp(1,Occlusion,ceil(Occlusion));
              
		        col = lerp(input.fogColor.xyz, col.rgb, input.fogColor.w);
               // return half4(Occlusion,Occlusion,Occlusion,Occlusion);
      
           
             
            
               return half4(col,1);
            }
            ENDHLSL
        }
           Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }

          Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

          Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Universal Pipeline keywords

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }


	

    }
    FallBack "Diffuse"
    CustomEditor "LWGUI.LWGUI"
}