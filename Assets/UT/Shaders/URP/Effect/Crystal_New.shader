Shader "URP/MoleGame/Effects/Crystal_New"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_AlbedoTransparency("AlbedoTransparency", 2D) = "white" {}
		_AlbedoColorTint("AlbedoColorTint", Color) = (1,1,1,1)
		[Normal]_Normal("Normal", 2D) = "bump" {}
		_MetallicSmoothness("MetallicSmoothness", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_FinalColor("FinalColor", Color) = (1,1,1,1)
		_FinalPower("FinalPower", Range( 2 , 90)) = 2
		_Ramp("Ramp", 2D) = "white" {}
		_RampColorTint("RampColorTint", Color) = (1,1,1,1)
		_RempRemapMax("RempRemapMax", Range( 0 , 1)) = 0.33
		_RempOffsetExp("RempOffsetExp", Range( 0.2 , 8)) = 1
		_InnerRimHackNormals("InnerRimHackNormals", Range( 0 , 1)) = 1
		_InnerRimExp("InnerRimExp", Range( 0 , 16)) = 4
		_InnerRimMask("InnerRimMask", 2D) = "white" {}
		[Toggle]_InnerRimMaskFlip("InnerRimMaskFlip", Float) = 0
		_InnerRimMaskExp("InnerRimMaskExp", Range( 0.1 , 4)) = 1
		_InnerRimMaskNegate("InnerRimMaskNegate", Range( 0 , 1)) = 0
		_InnerRimProfile("InnerRimProfile", 2D) = "white" {}
		[Toggle]_VerticalGradientWorldPosition("VerticalGradientWorldPosition", Float) = 0
		_VerticalGradientFlipSwitch("VerticalGradientFlipSwitch", Range( 0 , 1)) = 0
		_VerticalGradientRemapMax("VerticalGradientRemapMax", Float) = 0
		_VerticalGradientOffset("VerticalGradientOffset", Float) = 0
		_VerticalGradientExp("VerticalGradientExp", Range( 0.1 , 12)) = 1
		_AppearGradientFlipSwitch("AppearGradientFlipSwitch", Range( 0 , 1)) = 1
		_AppearGradientAbsSwitch("AppearGradientAbsSwitch", Range( 0 , 1)) = 1
		_AppearGradientRemapMax("AppearGradientRemapMax", Float) = 4
		_AppearGradientOffset("AppearGradientOffset", Float) = 1.25
		_AppearGradientExp("AppearGradientExp", Range( 0 , 12)) = 4
		_AppearGradientPower("AppearGradientPower", Range( 0 , 10)) = 1
		_AppearVertexYOffset("AppearVertexYOffset", Float) = 0
		_ParallaxNoise("ParallaxNoise", 2D) = "white" {}
		_ParallaxNoiseScaleU("ParallaxNoiseScaleU", Float) = 1
		_ParallaxNoiseScaleV("ParallaxNoiseScaleV", Float) = 1
		_ParallaxNoiseDepth("ParallaxNoiseDepth", Float) = 0
		_ParallaxNoiseNegate("ParallaxNoiseNegate", Range( 0 , 1)) = 0
		_EmissionVSSwitch("EmissionVSSwitch", Range( 0 , 1)) = 0
		[Toggle]_RampEnabled("RampEnabled", Float) = 0
		[Toggle]_InnerRimEnabled("InnerRimEnabled", Float) = 0
		[Toggle]_InnerRimProfileEnabled("InnerRimProfileEnabled", Float) = 0
		[Toggle]_ParallaxNoiseEnabled("ParallaxNoiseEnabled", Float) = 0
		[Toggle]_VerticalGradientEnabled("VerticalGradientEnabled", Float) = 0
		[Toggle]_AppearGradientEnabled("AppearGradientEnabled", Float) = 0

		[HideInInspector]_Cutoff("Cutoff (Default: 0.5)", Range(0.0, 0.99)) = 0.5
	}

	SubShader
	{
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		Cull Back
		//AlphaToMask Off
		HLSLINCLUDE
		#pragma target 2.0

		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

		
		CBUFFER_START(UnityPerMaterial)
		float4 _AlbedoTransparency_ST;
		float4 _AlbedoColorTint;
		float4 _Normal_ST;
		float4 _MetallicSmoothness_ST;
		float4 _FinalColor;
		float4 _RampColorTint;
		float4 _InnerRimMask_ST;
		float _AppearVertexYOffset;
		float _VerticalGradientFlipSwitch;
		float _VerticalGradientExp;
		float _AppearGradientEnabled;
		float _AppearGradientAbsSwitch;
		float _AppearGradientOffset;
		float _AppearGradientRemapMax;
		float _AppearGradientPower;
		float _AppearGradientExp;
		float _VerticalGradientRemapMax;
		float _RempRemapMax;
		float _RempOffsetExp;
		float _EmissionVSSwitch;
		float _AppearGradientFlipSwitch;
		float _VerticalGradientOffset;
		float _ParallaxNoiseNegate;
		float _VerticalGradientEnabled;
		float _FinalPower;
		float _RampEnabled;
		float _InnerRimEnabled;
		float _InnerRimProfileEnabled;
		float _InnerRimHackNormals;
		float _InnerRimExp;
		float _VerticalGradientWorldPosition;
		float _InnerRimMaskFlip;
		float _InnerRimMaskNegate;
		float _ParallaxNoiseEnabled;
		float _ParallaxNoiseScaleU;
		float _ParallaxNoiseScaleV;
		float _ParallaxNoiseDepth;
		float _Metallic;
		float _InnerRimMaskExp;
		float _Smoothness;
		float _Cutoff;
		CBUFFER_END
		
		TEXTURE2D(_AlbedoTransparency); SAMPLER(sampler_AlbedoTransparency);
		TEXTURE2D(_Normal); SAMPLER(sampler_Normal);
		TEXTURE2D(_InnerRimProfile); SAMPLER(sampler_InnerRimProfile);
		TEXTURE2D(_InnerRimMask); SAMPLER(sampler_InnerRimMask);
		TEXTURE2D(_ParallaxNoise); SAMPLER(sampler_ParallaxNoise);
		TEXTURE2D(_Ramp); SAMPLER(sampler_Ramp);
		TEXTURE2D(_MetallicSmoothness); SAMPLER(sampler_MetallicSmoothness);


		struct VertexInput
		{
			float4 positionOS : POSITION;
			float3 normalOS : NORMAL;
			float4 tangentOS : TANGENT;
			float4 uvLM : TEXCOORD1;
			float4 uv : TEXCOORD0;
			float4 vertexColor : COLOR;
		};

		struct VertexOutput
		{
			float4 positionCS : SV_POSITION;
			float3 positionWS : TEXCOORD0;
			float3 normalWS : TEXCOORD1;
			float3 tangentWS : TEXCOORD2;
			float3 bitangentWS : TEXCOORD3;
			float4 uv : TEXCOORD4;
			float4 vertexColor : COLOR;
			float4 positionOS : TEXCOORD5;
			float2 uvLM : TEXCOORD6;
		#ifdef _MAIN_LIGHT_SHADOWS
			float4 shadowCoord : TEXCOORD7; 
		#endif	
		};

		#include "../FALib/FAShaderUtils.hlsl"
		#include "../FALib/FALightingSimple.hlsl"

		VertexOutput vert ( VertexInput input )
		{
			VertexOutput output = (VertexOutput)0;

			output.uv = input.uv;
			output.uvLM= input.uvLM * unity_LightmapST.xy + unity_LightmapST.zw;

			output.vertexColor = input.vertexColor;
			// 顶点Y轴偏移
			output.positionOS = input.positionOS;
			input.positionOS.xyz += float3(0.0 , _AppearVertexYOffset , 0.0);

			VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
			VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

			output.normalWS = normalInput.normalWS;
			output.tangentWS = normalInput.tangentWS;
			output.bitangentWS = normalInput.bitangentWS;

			output.positionCS = vertexInput.positionCS;
			output.positionWS.xyz = vertexInput.positionWS;
			
		#ifdef _MAIN_LIGHT_SHADOWS
			output.shadowCoord = GetShadowCoord(vertexInput);
		#endif	
			return output;
		}

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="SceneEffect" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			//Offset 0 , 0
			//ColorMask RGBA
			

			HLSLPROGRAM
			//#pragma multi_compile _ _CUSTOM_SCREEN_SPACE_OCCLUSION
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			

			FASurfaceData CustomInitializeFASurfaceData(VertexOutput input)
			{
				FASurfaceData surfaceData = (FASurfaceData) 0;

				float3 WorldNormal = normalize( input.normalWS.xyz );
				float3 WorldTangent = input.tangentWS.xyz;
				float3 WorldBiTangent = input.bitangentWS.xyz;

				float3 positionWS = input.positionWS.xyz;
				float3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);

				float2 uv_AlbedoTransparency = TRANSFORM_TEX(input.uv, _AlbedoTransparency);
				float2 uv_Normal = TRANSFORM_TEX(input.uv, _Normal);
				float3 high_normal = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal, sampler_Normal, uv_Normal ), 1.0f );
				
				float3 normalWS = lerp( ( ( WorldTangent * high_normal.x ) + ( WorldBiTangent * high_normal.y ) + ( WorldNormal * high_normal.z ) ) , WorldNormal , _InnerRimHackNormals);
				normalWS = normalize( normalWS );

				// Inner_Rim
				float NDotV = dot( normalWS , normalize(viewDirectionWS) );
				float rim = pow( clamp( NDotV , 0.0 , 1.0 ) , _InnerRimExp );
				float2 inner = (float2(( 1.0 - rim ) , 0.0));

				// Inner_Rim_Mask
				float2 uv_InnerRimMask = TRANSFORM_TEX(input.uv, _InnerRimMask);
				float inner_rim_mask = clamp( ( pow( SAMPLE_TEXTURE2D( _InnerRimMask, sampler_InnerRimMask, uv_InnerRimMask ).r , _InnerRimMaskExp ) + _InnerRimMaskNegate ) , 0.0 , 1.0 );
				
				// parallax_noise
				float2 parallax_noise_scale_uv = (float2(_ParallaxNoiseScaleU , _ParallaxNoiseScaleV));
				float4 parallax_noise_scale_uv_append = ( input.uv * float4( parallax_noise_scale_uv, 0.0 , 0.0 ) );
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanViewDir =  tanToWorld0 * viewDirectionWS.x + tanToWorld1 * viewDirectionWS.y  + tanToWorld2 * viewDirectionWS.z;
				tanViewDir = normalize(tanViewDir);
				float2 paralaxOffset = ParallaxOffset( SAMPLE_TEXTURE2D( _ParallaxNoise, sampler_ParallaxNoise, parallax_noise_scale_uv_append.xy ).r , _ParallaxNoiseDepth , tanViewDir );
				float paralax_noise = clamp( ( SAMPLE_TEXTURE2D( _ParallaxNoise, sampler_ParallaxNoise, ( parallax_noise_scale_uv_append + float4( paralaxOffset, 0.0 , 0.0 ) ).xy ).r + _ParallaxNoiseNegate ) , 0.0 , 1.0 );
				
				// vertical_gradient
				float vertical_gradient_position = clamp( (0.0 + (( (( _VerticalGradientWorldPosition )?( positionWS.y ):( input.positionOS.xyz.y )) + _VerticalGradientOffset ) - 0.0) * (1.0 - 0.0) / (_VerticalGradientRemapMax - 0.0)) , 0.0 , 1.0 );
				float vertical_gradient_flip = lerp( vertical_gradient_position , ( 1.0 - vertical_gradient_position ) , round( _VerticalGradientFlipSwitch ));

				// appear_gradient
				float appear_gradient_abs = lerp( input.positionOS.xyz.y , abs( input.positionOS.xyz.y ) , _AppearGradientAbsSwitch);
				float appear_gradient_remap = clamp( (0.0 + (( appear_gradient_abs + _AppearGradientOffset ) - 0.0) * (1.0 - 0.0) / (_AppearGradientRemapMax - 0.0)) , 0.0 , 1.0 );
				float appear_gradient_flip = lerp( appear_gradient_remap , ( 1.0 - appear_gradient_remap ) , round( _AppearGradientFlipSwitch ));
				
				float inner_rim_color = clamp( ( (( _InnerRimEnabled )?( ( (( _InnerRimProfileEnabled )?( SAMPLE_TEXTURE2D( _InnerRimProfile, sampler_InnerRimProfile, inner ).r ):( rim )) * (( _InnerRimMaskFlip )?( ( 1.0 - inner_rim_mask ) ):( inner_rim_mask )) * (( _ParallaxNoiseEnabled )?( paralax_noise ):( 1.0 )) ) ):( 0.0 )) + (( _VerticalGradientEnabled )?( ( (( _InnerRimMaskFlip )?( ( 1.0 - inner_rim_mask ) ):( inner_rim_mask )) * pow( vertical_gradient_flip , _VerticalGradientExp ) * (( _ParallaxNoiseEnabled )?( paralax_noise ):( 1.0 )) ) ):( 0.0 )) + (( _AppearGradientEnabled )?( ( pow( appear_gradient_flip , _AppearGradientExp ) * _AppearGradientPower ) ):( 0.0 )) ) , 0.0 , 1.0 );
				float inner_rim = clamp( (0.0 + (inner_rim_color - 0.0) * (1.0 - 0.0) / (_RempRemapMax - 0.0)) , 0.0 , 1.0 );
				float2 ramp_uv = (float2(( 1.0 - pow( ( 1.0 - inner_rim ) , _RempOffsetExp ) ) , 0.0));
				float emission_switch = lerp( 1.0 , input.uv.z , _EmissionVSSwitch);
				

				// emission
				float3 emission = ( _FinalPower * (( _RampEnabled )?( ( SAMPLE_TEXTURE2D( _Ramp, sampler_Ramp, ramp_uv ) * _RampColorTint * inner_rim_color * input.vertexColor ) ):( ( _FinalColor * input.vertexColor * inner_rim_color ) )) * emission_switch ).rgb;
				surfaceData.emission = emission;

				// metallic
				float2 uv_MetallicSmoothness = TRANSFORM_TEX(input.uv, _MetallicSmoothness);
				float4 metallic_smoothness = SAMPLE_TEXTURE2D( _MetallicSmoothness, sampler_MetallicSmoothness, uv_MetallicSmoothness );
				surfaceData.metallic = metallic_smoothness.r * _Metallic;

				// smoothness
				surfaceData.smoothness = metallic_smoothness.a * _Smoothness;

				// albedo
				surfaceData.albedo = ( SAMPLE_TEXTURE2D( _AlbedoTransparency, sampler_AlbedoTransparency, uv_AlbedoTransparency ) * _AlbedoColorTint ).rgb;

				
				
				surfaceData.normalTS = half3(0, 0, 1);
				surfaceData.occlusion = 1.0f;
				surfaceData.alpha = 1.0f;
				return surfaceData;
			}

			half4 frag ( VertexOutput input, half facing : VFACE ) : SV_Target
			{
				FASurfaceData surfaceData = CustomInitializeFASurfaceData(input);	
				FABRDFData brdfData;
				InitializeFABRDFData(surfaceData, brdfData);

				
				float3 positionWS = input.positionWS.xyz;
				float3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);

				float3 WorldNormal = normalize( input.normalWS.xyz );
				float3 WorldTangent = input.tangentWS.xyz;
				float3 WorldBiTangent = input.bitangentWS.xyz;

				float2 uv_Normal = TRANSFORM_TEX(input.uv, _Normal);
				float3 high_normal = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal, sampler_Normal, uv_Normal ), 1.0f );
				float3 normalWS = TransformTangentToWorld(high_normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
				normalWS = normalize(normalWS) * facing;


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

				float2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);

			#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
				AmbientOcclusionFactor aoFactor = CustomGetScreenSpaceAmbientOcclusion(uvScreen);
				mainLight.color *= aoFactor.directAmbientOcclusion;
				surfaceData.occlusion = min(surfaceData.occlusion, aoFactor.indirectAmbientOcclusion);
			#endif

				half atten = clamp(mainLight.shadowAttenuation, 0, 1);
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
				return half4(color, alpha);
			}
			ENDHLSL
		}

		Pass
		{
			Name "ShadowCaster"
			Tags{"LightMode" = "ShadowCaster"}

			ZWrite On
			ZTest LEqual
			ColorMask 0

			HLSLPROGRAM
			//--------------------------------------
			// GPU Instancing
			//#pragma multi_compile_instancing

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON

			#pragma vertex vert
			#pragma fragment ShadowPassFragment

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			
			half4 ShadowPassFragment(VertexInput input) : SV_TARGET
			{
				Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_AlbedoTransparency, sampler_AlbedoTransparency)).a, _AlbedoColorTint, _Cutoff);
				return 0;
			}

			ENDHLSL
		}

		Pass
		{
			Name "DepthOnly"
			Tags{"LightMode" = "DepthOnly"}

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			//--------------------------------------
			// GPU Instancing
			//#pragma multi_compile_instancing

			#pragma vertex vert
			#pragma fragment DepthOnlyFragment

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			
			half4 DepthOnlyFragment(VertexInput input) : SV_TARGET
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(_ALPHATEST_ON)
					Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_AlbedoTransparency, sampler_AlbedoTransparency)).a, _AlbedoColorTint, _Cutoff);
				#else
					Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_AlbedoTransparency, sampler_AlbedoTransparency)).a, _AlbedoColorTint, 0);
				#endif
				return 0;
			}
			ENDHLSL
		}
	}
}