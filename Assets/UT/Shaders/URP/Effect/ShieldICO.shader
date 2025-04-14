Shader "URP/MoleGame/Effects/ShieldICO"
{
    Properties
    {
        _FinalColor("Final Color", Color) = (1, 1, 1, 1)
        _FinalPower("Final Power", Range(0, 100)) = 4
        _FinalOpacityPower("Final Opacity Power", Float) = 1
        [NoScaleOffset]_Ramp("Ramp", 2D) = "white" {}
        _RampColorTint("Ramp Color Tint", Color) = (1, 1, 1, 1)
        _RampAffectedByDynamics("Ramp Affected By Dynamics", Range(0, 1)) = 1
        _RampOffsetMultiply("Ramp Offset Multiply", Float) = 1
        _RampOffsetExp("Ramp Offset Exp", Range(0.2, 8)) = 1
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        _MainTexChannels("MainTex Channels", Vector) = (1, 0, 0, 0)
        _MainTexScrollSpeed("MainTex Scroll Speed", Float) = 0
        [NoScaleOffset]_OffsetTexture("Offset Texture", 2D) = "white" {}
        _OffsetTextureScaleU("Offset Texture Scale U", Float) = 1
        _OffsetTextureScaleV("Offset Texture Scale V", Float) = 1
        _OffsetTextureScrollSpeedU("Offset Texture Scroll Speed U", Float) = 0
        _OffsetTextureScrollSpeedV("Offset Texture Scroll Speed V", Float) = 0
        _OffsetStyle("Offset Style", Range(0, 1)) = 0
        _OffsetPower("Offset Power", Float) = 0
        _OffsetGChannelMasking("Offset G Channel Masking", Range(0, 1)) = 0
        _OffsetToOpacityNegate("Offset To Opacity Negate", Range(0, 1)) = 1
        _OffsetToOpacityExp("Offset To Opacity Exp", Range(0.2, 8)) = 1
        _OffsetToOpacityTopFixExp("Offset To Opacity Top Fix Exp", Range(0.2, 8)) = 8
        _OffsetToOpacityTopFixValue("Offset To Opacity Top Fix Value", Range(0, 1)) = 0.25
        [NoScaleOffset]_TrisGlareTexture("Tris Glare Texture", 2D) = "white" {}
        _TrisGlareTextureScaleU("Tris Glare Texture Scale U", Float) = 1
        _TrisGlareTextureScaleV("Tris Glare Texture Scale V", Float) = 1
        _TrisGlareNegate("Tris Glare Negate", Range(0, 1)) = 1
        _VerticalGradientFlipSwitch("Vertical Gradient Flip Switch", Range(0, 1)) = 0
        _VerticalGradientAbsSwitch("Vertical Gradient Abs Switch", Range(0, 1)) = 1
        _VerticalGradientClampSwitch("Vertical Gradient Clamp Switch", Range(0, 1)) = 0
        _VerticalGradientRemapMax("Vertical Gradient Remap Max", Float) = 1
        _VerticalGradientOffset("Vertical Gradient Offset", Float) = 0
        [NoScaleOffset]_VerticalGradientProfile("Vertical Gradient Profile", 2D) = "white" {}
        [ToggleUI]_INNERRIMENABLED("Inner Rim Enabled", Float) = 0
        _InnerRimExp("Inner Rim Exp", Range(0.1, 16)) = 4
        _InnerRimFlipSwitch("Inner Rim Flip Switch", Range(0, 1)) = 1
        _WavesSpeed("Waves Speed", Float) = 4
        _WavesScale("Waves Scale", Float) = 8
        _DepthMaskDistance("Depth Mask Distance", Float) = 1
        _DepthMaskRemapMax("Depth Mask Remap Max", Float) = 1
        _DepthMaskExp("Depth Mask Exp", Float) = 2
        _DepthMaskMultiply("Depth Mask Multiply", Float) = 0.25
        _AppearGradientFlipSwitch("Appear Gradient Flip Switch", Range(0, 1)) = 0
        _AppearGradientAbsSwitch("Appear Gradient Abs Switch", Range(0, 1)) = 1
        _AppearGradientClampSwitch("Appear Gradient Clamp Switch", Range(0, 1)) = 0
        _AppearGradientRemapMax("Appear Gradient Remap Max", Float) = 1
        _AppearGradientOffset("Appear Gradient Offset", Float) = 0
        _AppearGradientDynamicsNegate("Appear Gradient Dynamics Negate", Range(0, 1)) = 0
        _AppearGradientDistortionAmount("Appear Gradient Distortion Amount", Range(0, 1)) = 0
        [NoScaleOffset]_AppearGradientProfile("Appear Gradient Profile", 2D) = "white" {}
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        [Toggle]_RAMPENABLED("Ramp Enabled", Float) = 0
        [Toggle]_TRISGLAREENABLED("Tris Glare Enabled", Float) = 0
        [Toggle]_VERTICALGRADIENTENABLED("Vertical Gradient Enabled", Float) = 0
        [Toggle]_WAVESENABLED("Waves Enabled", Float) = 0
        [Toggle]_DEPTHMASKENABLED("Depth Mask Enabled", Float) = 0
        [Toggle]_Zwrite("ZWrite", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 2
        
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
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "IgnoreProjector" = "True"
            "Queue"="Transparent"
        }

        HLSLINCLUDE
            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1

            #define ATTRIBUTES_NEED_NORMAL

            #define ATTRIBUTES_NEED_TANGENT

            #define ATTRIBUTES_NEED_TEXCOORD0

            #define ATTRIBUTES_NEED_TEXCOORD1

            #define ATTRIBUTES_NEED_TEXCOORD2

            #define ATTRIBUTES_NEED_COLOR

            #define VARYINGS_NEED_POSITION_WS

            #define VARYINGS_NEED_NORMAL_WS

            #define VARYINGS_NEED_TEXCOORD0

            #define VARYINGS_NEED_TEXCOORD1

            #define VARYINGS_NEED_TEXCOORD2

            #define VARYINGS_NEED_COLOR

            #define VARYINGS_NEED_VIEWDIRECTION_WS

            #define VARYINGS_NEED_CULLFACE

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                float4 color : COLOR;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                float4 texCoord0;
                float4 texCoord1;
                float4 texCoord2;
                float4 color;
                float3 viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            struct SurfaceDescriptionInputs
            {
                float3 WorldSpaceNormal;
                float3 WorldSpaceViewDirection;
                float3 ObjectSpacePosition;
                float3 WorldSpacePosition;
                float4 ScreenPosition;
                float4 uv0;
                float4 uv1;
                float4 uv2;
                float4 VertexColor;
                float3 TimeParameters;
                float FaceSign;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 WorldSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
                float4 uv1;
                float4 uv2;
                float3 TimeParameters;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float3 interp0 : TEXCOORD0;
                float3 interp1 : TEXCOORD1;
                float4 interp2 : TEXCOORD2;
                float4 interp3 : TEXCOORD3;
                float4 interp4 : TEXCOORD4;
                float4 interp5 : TEXCOORD5;
                float3 interp6 : TEXCOORD6;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.positionWS;
                output.interp1.xyz =  input.normalWS;
                output.interp2.xyzw =  input.texCoord0;
                output.interp3.xyzw =  input.texCoord1;
                output.interp4.xyzw =  input.texCoord2;
                output.interp5.xyzw =  input.color;
                output.interp6.xyz =  input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.texCoord0 = input.interp2.xyzw;
                output.texCoord1 = input.interp3.xyzw;
                output.texCoord2 = input.interp4.xyzw;
                output.color = input.interp5.xyzw;
                output.viewDirectionWS = input.interp6.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _FinalColor;
            float _FinalPower;
            float _FinalOpacityPower;
            float4 _Ramp_TexelSize;
            float4 _RampColorTint;
            float _RampAffectedByDynamics;
            float _RampOffsetMultiply;
            float _RampOffsetExp;
            float4 _MainTex_TexelSize;
            float4 _MainTexChannels;
            float _MainTexScrollSpeed;
            float4 _OffsetTexture_TexelSize;
            float _OffsetTextureScaleU;
            float _OffsetTextureScaleV;
            float _OffsetTextureScrollSpeedU;
            float _OffsetTextureScrollSpeedV;
            float _OffsetStyle;
            float _OffsetPower;
            float _OffsetGChannelMasking;
            float _OffsetToOpacityNegate;
            float _OffsetToOpacityExp;
            float _OffsetToOpacityTopFixExp;
            float _OffsetToOpacityTopFixValue;
            float4 _TrisGlareTexture_TexelSize;
            float _TrisGlareTextureScaleU;
            float _TrisGlareTextureScaleV;
            float _TrisGlareNegate;
            float _VerticalGradientFlipSwitch;
            float _VerticalGradientAbsSwitch;
            float _VerticalGradientClampSwitch;
            float _VerticalGradientRemapMax;
            float _VerticalGradientOffset;
            float4 _VerticalGradientProfile_TexelSize;
            float _INNERRIMENABLED;
            float _InnerRimExp;
            float _InnerRimFlipSwitch;
            float _WavesSpeed;
            float _WavesScale;
            float _DepthMaskDistance;
            float _DepthMaskRemapMax;
            float _DepthMaskExp;
            float _DepthMaskMultiply;
            float _AppearGradientFlipSwitch;
            float _AppearGradientAbsSwitch;
            float _AppearGradientClampSwitch;
            float _AppearGradientRemapMax;
            float _AppearGradientOffset;
            float _AppearGradientDynamicsNegate;
            float _AppearGradientDistortionAmount;
            float4 _AppearGradientProfile_TexelSize;
            half _Zwrite;
            half _CullMode;
            CBUFFER_END

            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Ramp);
            SAMPLER(sampler_Ramp);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_OffsetTexture);
            SAMPLER(sampler_OffsetTexture);
            TEXTURE2D(_TrisGlareTexture);
            SAMPLER(sampler_TrisGlareTexture);
            TEXTURE2D(_VerticalGradientProfile);
            SAMPLER(sampler_VerticalGradientProfile);
            TEXTURE2D(_AppearGradientProfile);
            SAMPLER(sampler_AppearGradientProfile);

            // Graph Functions
            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }

            void Unity_Sine_float(float In, out float Out)
            {
                Out = sin(In);
            }

            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
            {
                Out = lerp(A, B, T);
            }

            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }

            void Unity_Normalize_float3(float3 In, out float3 Out)
            {
                Out = normalize(In);
            }

            void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }

            void Unity_Absolute_float(float In, out float Out)
            {
                Out = abs(In);
            }

            void Unity_Round_float(float In, out float Out)
            {
                Out = round(In);
            }

            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }

            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
            {
                Out = clamp(In, Min, Max);
            }

            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }

            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }

            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A + B;
            }

            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }

            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }

            void CustomDepthBlend_float(float4 spr, float dist, float depthnode, out float DepthBlendResult)
            {
                float4 sp = spr / spr.w;
                sp.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? sp.z : sp.z * 0.5 + 0.5;

                //float screenDepth6 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( sp.xy ),_ZBufferParams);

                float distanceDepth6 = abs( ( depthnode - LinearEyeDepth( sp.z,_ZBufferParams ) ) / ( dist ) );
                DepthBlendResult = distanceDepth6;
            }

            void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
            {
                Out = Predicate ? True : False;
            }

            void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
            {
                Out = dot(A, B);
            }

            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
            {
                Out = Predicate ? True : False;
            }

            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                float waveStart;
                Unity_Multiply_float(_WavesScale, IN.ObjectSpacePosition.y, waveStart);
                float waveOffset;
                Unity_Multiply_float(IN.TimeParameters.x, _WavesSpeed, waveOffset);
                float wavePosition;
                Unity_Add_float(waveStart, waveOffset, wavePosition);
                float waveSine;
                Unity_Sine_float(wavePosition, waveSine);
                float waveSineRemap;
                Unity_Remap_float(waveSine, float2 (-1, 1), float2 (0, 1), waveSineRemap);
                #if defined(_WAVESENABLED_ON)
                float waveFactor = waveSineRemap;
                #else
                float waveFactor = 1;
                #endif
                UnityTexture2D offsetTexture = UnityBuildTexture2DStructNoScale(_OffsetTexture);
                float2 uvOffset;
                Unity_Lerp_float2(IN.uv1.xy, IN.uv2.xy, (_OffsetStyle.xx), uvOffset);
                float2 offsetTexScale = float2(_OffsetTextureScaleU, _OffsetTextureScaleV);
                float2 offsetTexUVStart;
                Unity_Multiply_float(uvOffset, offsetTexScale, offsetTexUVStart);
                float offsetTexUOffset;
                Unity_Multiply_float(IN.TimeParameters.x, _OffsetTextureScrollSpeedU, offsetTexUOffset);
                float offsetTexU;
                Unity_Add_float(offsetTexUVStart.x, offsetTexUOffset, offsetTexU);
                float offsetTexVOffset;
                Unity_Multiply_float(IN.TimeParameters.x, _OffsetTextureScrollSpeedV, offsetTexVOffset);
                float offsetTexV;
                Unity_Add_float(offsetTexUVStart.y, offsetTexVOffset, offsetTexV);
                float2 offsetTexUV = float2(offsetTexU, offsetTexV);
                #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
                    float4 offsetTexColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
                #else
                    float4 offsetTexColor = SAMPLE_TEXTURE2D_LOD(offsetTexture.tex, offsetTexture.samplerstate, offsetTexUV, 0);
                #endif
                float tempOpacityFactor;
                Unity_Multiply_float(waveFactor, offsetTexColor.r, tempOpacityFactor);
                float3 normalWS;
                Unity_Normalize_float3(IN.WorldSpaceNormal, normalWS);
                float3 tempNormalWS;
                Unity_Multiply_float((tempOpacityFactor.xxx), normalWS, tempNormalWS);
                float3 transformedNormalWS;
                Unity_Multiply_float(tempNormalWS, (_OffsetPower.xxx), transformedNormalWS);
                UnityTexture2D verticalGradientProfileTexture = UnityBuildTexture2DStructNoScale(_VerticalGradientProfile);
                float absPositionOSY;
                Unity_Absolute_float(IN.ObjectSpacePosition.y, absPositionOSY);
                float verticalGradientAbsSwitch;
                Unity_Round_float(_VerticalGradientAbsSwitch, verticalGradientAbsSwitch);
                float tempPositionOSY;
                Unity_Lerp_float(IN.ObjectSpacePosition.y, absPositionOSY, verticalGradientAbsSwitch, tempPositionOSY);
                float clampedPositionOSY;
                Unity_Clamp_float(tempPositionOSY, 0, 100, clampedPositionOSY);
                float verticalGradientClampSwitch = _VerticalGradientClampSwitch;
                float positionOSY;
                Unity_Lerp_float(tempPositionOSY, clampedPositionOSY, verticalGradientClampSwitch, positionOSY);
                float gradientPositionStart;
                Unity_Add_float(positionOSY, _VerticalGradientOffset, gradientPositionStart);
                float remappedGradientPosition;
                Unity_Remap_float(gradientPositionStart, float2(0, _VerticalGradientRemapMax), float2 (0, 1), remappedGradientPosition);
                float clampedGradientPosition;
                Unity_Clamp_float(remappedGradientPosition, 0, 1, clampedGradientPosition);
                float oppositeGradientPosition;
                Unity_OneMinus_float(clampedGradientPosition, oppositeGradientPosition);
                float verticalGradientFlipSwitch;
                Unity_Round_float(_VerticalGradientFlipSwitch, verticalGradientFlipSwitch);
                float gradientPosition;
                Unity_Lerp_float(clampedGradientPosition, oppositeGradientPosition, verticalGradientFlipSwitch, gradientPosition);
                #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
                    float4 verticalGradientProfileTextColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
                #else
                    float4 verticalGradientProfileTextColor = SAMPLE_TEXTURE2D_LOD(verticalGradientProfileTexture.tex, verticalGradientProfileTexture.samplerstate, float2(gradientPosition, 0), 0);
                #endif
                float channelGMask;
                Unity_Lerp_float(1, verticalGradientProfileTextColor.g, _OffsetGChannelMasking, channelGMask);
                float3 maskedNormalWS;
                Unity_Multiply_float(transformedNormalWS, (channelGMask.xxx), maskedNormalWS);
                float3 transformedPosition;
                Unity_Add_float3(maskedNormalWS, IN.ObjectSpacePosition, transformedPosition);
                description.Position = transformedPosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal =           input.normalOS;
                output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =          input.tangentOS.xyz;
                output.ObjectSpacePosition =         input.positionOS;
                output.uv1 =                         input.uv1;
                output.uv2 =                         input.uv2;
                output.TimeParameters =              _TimeParameters.xyz;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);


                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);

                output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
                output.WorldSpacePosition =          input.positionWS;
                output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
                output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                output.uv0 =                         input.texCoord0;
                output.uv1 =                         input.texCoord1;
                output.uv2 =                         input.texCoord2;
                output.VertexColor =                 input.color;
                output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value

                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }
        ENDHLSL


        Pass
        {
            Name "StandardLit"
            Tags
            {
                "LightMode" = "SceneEffect"
            }

            // Render State
            Cull [_CullMode]
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite [_Zwrite]
            
            //跳过TAA处理的Mask
            Stencil {
                Ref [_TAAStencil]
                WriteMask [_TAAStencilMask]
                Comp always
                Pass [_TAAStencilPassOperate]
            }

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
            //#pragma target 4.5
            //#pragma exclude_renderers gles gles3 glcore
            //#pragma multi_compile_instancing
            //#pragma multi_compile_fog
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma shader_feature _ _SAMPLE_GI
            #pragma shader_feature_local _ _RAMPENABLED_ON
            #pragma shader_feature_local _ _TRISGLAREENABLED_ON
            #pragma shader_feature_local _ _VERTICALGRADIENTENABLED_ON
            #pragma shader_feature_local _ _WAVESENABLED_ON
            #pragma shader_feature_local _ _DEPTHMASKENABLED_ON

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D rampTexture = UnityBuildTexture2DStructNoScale(_Ramp);
                UnityTexture2D verticalGradientProfileTexture = UnityBuildTexture2DStructNoScale(_VerticalGradientProfile);
                float absPositionOSY;
                Unity_Absolute_float(IN.ObjectSpacePosition.y, absPositionOSY);
                float verticalGradientAbsSwitch;
                Unity_Round_float(_VerticalGradientAbsSwitch, verticalGradientAbsSwitch);
                float tempPositionOSY;
                Unity_Lerp_float(IN.ObjectSpacePosition.y, absPositionOSY, verticalGradientAbsSwitch, tempPositionOSY);
                float clampedPositionOSY;
                Unity_Clamp_float(tempPositionOSY, 0, 100, clampedPositionOSY);
                float verticalGradientClampSwitch = _VerticalGradientClampSwitch;
                float positionOSY;
                Unity_Lerp_float(tempPositionOSY, clampedPositionOSY, verticalGradientClampSwitch, positionOSY);
                float gradientPositionStart;
                Unity_Add_float(positionOSY, _VerticalGradientOffset, gradientPositionStart);
                float remappedGradientPosition;
                Unity_Remap_float(gradientPositionStart, float2(0, _VerticalGradientRemapMax), float2 (0, 1), remappedGradientPosition);
                float clampedGradientPosition;
                Unity_Clamp_float(remappedGradientPosition, 0, 1, clampedGradientPosition);
                float oppositeGradientPosition;
                Unity_OneMinus_float(clampedGradientPosition, oppositeGradientPosition);
                float verticalGradientFlipSwitch;
                Unity_Round_float(_VerticalGradientFlipSwitch, verticalGradientFlipSwitch);
                float gradientPosition;
                Unity_Lerp_float(clampedGradientPosition, oppositeGradientPosition, verticalGradientFlipSwitch, gradientPosition);
                #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
                float4 verticalGradientProfileTextColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
                #else
                float4 verticalGradientProfileTextColor = SAMPLE_TEXTURE2D_LOD(verticalGradientProfileTexture.tex, verticalGradientProfileTexture.samplerstate, float2(gradientPosition, 0), 0);
                #endif
                float sceneDepthEye;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), sceneDepthEye);
                float customDepthBlend;
                CustomDepthBlend_float(IN.ScreenPosition, _DepthMaskDistance, sceneDepthEye, customDepthBlend);
                float oppositeCustomDepthBlend;
                Unity_OneMinus_float(customDepthBlend, oppositeCustomDepthBlend);
                float remappedDepthBlend;
                Unity_Remap_float(oppositeCustomDepthBlend, float2(0, _DepthMaskRemapMax), float2 (0, 1), remappedDepthBlend);
                float clampedDepthBlend;
                Unity_Clamp_float(remappedDepthBlend, 0, 1, clampedDepthBlend);
                float tempDepthBlend;
                Unity_Power_float(clampedDepthBlend, _DepthMaskExp, tempDepthBlend);
                float maskedDepthBlend;
                Unity_Multiply_float(tempDepthBlend, _DepthMaskMultiply, maskedDepthBlend);
                float clampedMaskedDepthBlend;
                Unity_Clamp_float(maskedDepthBlend, 0, 1, clampedMaskedDepthBlend);
                #if defined(_DEPTHMASKENABLED_ON)
                float maskedDepth = clampedMaskedDepthBlend;
                #else
                float maskedDepth = 0;
                #endif
                float finalMaskedDepth;
                Unity_Add_float(verticalGradientProfileTextColor.r, maskedDepth, finalMaskedDepth);
                float isFrontFace = max(0, IN.FaceSign);
                float3 nomalizedNormalWS;
                Unity_Normalize_float3(IN.WorldSpaceNormal, nomalizedNormalWS);
                float3 normalWS;
                Unity_Branch_float3(isFrontFace, nomalizedNormalWS, -nomalizedNormalWS, normalWS);
                float3 normalizedViewDirectionWS;
                Unity_Normalize_float3(IN.WorldSpaceViewDirection, normalizedViewDirectionWS);
                float tempCos;
                Unity_DotProduct_float3(normalWS, normalizedViewDirectionWS, tempCos);
                float cosine;
                Unity_Clamp_float(tempCos, 0, 1, cosine);
                float innerRimFlipSwitch;
                Unity_Round_float(_InnerRimFlipSwitch, innerRimFlipSwitch);
                float finalCosine;
                Unity_Lerp_float(cosine, 1 - cosine, innerRimFlipSwitch, finalCosine);
                float innerRimFactor;
                Unity_Power_float(finalCosine, _InnerRimExp, innerRimFactor);
                float innerRimFactorXFinalMaskedDepth;
                Unity_Multiply_float(finalMaskedDepth, innerRimFactor, innerRimFactorXFinalMaskedDepth);
                UnityTexture2D mainTexture = UnityBuildTexture2DStructNoScale(_MainTex);
                float mainUVOffsetX;
                Unity_Multiply_float(_MainTexScrollSpeed, IN.TimeParameters.x, mainUVOffsetX);
                float2 uvMain;
                Unity_Add_float2(IN.uv0.xy, float2(mainUVOffsetX, 0), uvMain);
                float4 mainTexColor = SAMPLE_TEXTURE2D(mainTexture.tex, mainTexture.samplerstate, uvMain);
                Unity_Multiply_float(mainTexColor, _MainTexChannels, mainTexColor);

                float waveStart;
                Unity_Multiply_float(_WavesScale, IN.ObjectSpacePosition.y, waveStart);
                float waveOffset;
                Unity_Multiply_float(IN.TimeParameters.x, _WavesSpeed, waveOffset);
                float wavePosition;
                Unity_Add_float(waveStart, waveOffset, wavePosition);
                float waveSine;
                Unity_Sine_float(wavePosition, waveSine);
                float waveSineRemap;
                Unity_Remap_float(waveSine, float2 (-1, 1), float2 (0, 1), waveSineRemap);
                #if defined(_WAVESENABLED_ON)
                float waveFactor = waveSineRemap;
                #else
                float waveFactor = 1;
                #endif
                UnityTexture2D offsetTexture = UnityBuildTexture2DStructNoScale(_OffsetTexture);
                float2 uvOffset;
                Unity_Lerp_float2(IN.uv1.xy, IN.uv2.xy, (_OffsetStyle.xx), uvOffset);
                float2 offsetTexScale = float2(_OffsetTextureScaleU, _OffsetTextureScaleV);
                float2 offsetTexUVStart;
                Unity_Multiply_float(uvOffset, offsetTexScale, offsetTexUVStart);
                float offsetTexUOffset;
                Unity_Multiply_float(IN.TimeParameters.x, _OffsetTextureScrollSpeedU, offsetTexUOffset);
                float offsetTexU;
                Unity_Add_float(offsetTexUVStart.x, offsetTexUOffset, offsetTexU);
                float offsetTexVOffset;
                Unity_Multiply_float(IN.TimeParameters.x, _OffsetTextureScrollSpeedV, offsetTexVOffset);
                float offsetTexV;
                Unity_Add_float(offsetTexUVStart.y, offsetTexVOffset, offsetTexV);
                float2 offsetTexUV = float2(offsetTexU, offsetTexV);
                #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
                float4 offsetTexColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
                #else
                float4 offsetTexColor = SAMPLE_TEXTURE2D_LOD(offsetTexture.tex, offsetTexture.samplerstate, offsetTexUV, 0);
                #endif
                float tempOpacityFactor;
                Unity_Multiply_float(waveFactor, offsetTexColor.r, tempOpacityFactor);
                Unity_Power_float(tempOpacityFactor, _OffsetToOpacityExp, tempOpacityFactor);
                float negateOpacityFactor;
                Unity_Add_float(tempOpacityFactor, _OffsetToOpacityNegate, negateOpacityFactor);
                float clampedAbsPositionOSY;
                Unity_Clamp_float(absPositionOSY, 0, 1, clampedAbsPositionOSY);
                float opacityFactorTopFix;
                Unity_Power_float(clampedAbsPositionOSY, _OffsetToOpacityTopFixExp, opacityFactorTopFix);
                float oppositeOpacityFactorTopFix;
                Unity_OneMinus_float(opacityFactorTopFix, oppositeOpacityFactorTopFix);
                Unity_Lerp_float(_OffsetToOpacityTopFixValue, negateOpacityFactor, oppositeOpacityFactorTopFix, tempOpacityFactor);
                float clampedOpacityFactor;
                Unity_Clamp_float(tempOpacityFactor, 0, 1, clampedOpacityFactor);
                Unity_Multiply_float(mainTexColor, float4(clampedOpacityFactor, clampedOpacityFactor, 1, 1), mainTexColor);
                float mainTexColorSum = dot(mainTexColor, float4(1,1,1,1));
                Unity_Clamp_float(mainTexColorSum, 0, 1, mainTexColorSum);
                #if !defined(_VERTICALGRADIENTENABLED_ON)
                finalMaskedDepth = 1;
                #endif
                float mainTexColorSumXFinalMaskedDepth;
                Unity_Multiply_float(mainTexColorSum, finalMaskedDepth, mainTexColorSumXFinalMaskedDepth);
                float rimFactor;
                Unity_Branch_float(_INNERRIMENABLED, innerRimFactor, 1, rimFactor);
                float rimFactorAddMaskedDepth;
                Unity_Add_float(rimFactor, maskedDepth, rimFactorAddMaskedDepth);
                Unity_Clamp_float(rimFactorAddMaskedDepth, 0, 1, rimFactorAddMaskedDepth);
                float opacityFactor;
                Unity_Multiply_float(mainTexColorSumXFinalMaskedDepth, rimFactorAddMaskedDepth, opacityFactor);
                Unity_Multiply_float(opacityFactor, _FinalOpacityPower, opacityFactor);

                UnityTexture2D trisGlareTexture = UnityBuildTexture2DStructNoScale(_TrisGlareTexture);
                float2 trisGlareTextureUVScale = float2(_TrisGlareTextureScaleU, _TrisGlareTextureScaleV);
                float2 scaledTrisGlareTextureUV;
                Unity_Multiply_float(IN.uv2.xy, trisGlareTextureUVScale, scaledTrisGlareTextureUV);
                float trisGlareTexU = scaledTrisGlareTextureUV.x + offsetTexUOffset;
                float trisGlareTexV = scaledTrisGlareTextureUV.y + offsetTexVOffset;
                float2 trisGlareTexUV = float2(trisGlareTexU, trisGlareTexV);
                float4 trisGlareTexColor = SAMPLE_TEXTURE2D(trisGlareTexture.tex, trisGlareTexture.samplerstate, trisGlareTexUV);
                float negateTrisGlareTexColor;
                Unity_Add_float(trisGlareTexColor.r, _TrisGlareNegate, negateTrisGlareTexColor);
                float trisGlareFactor;
                Unity_Clamp_float(negateTrisGlareTexColor, 0, 1, trisGlareFactor);
                #if !defined(_TRISGLAREENABLED_ON)
                trisGlareFactor  = 1;
                #endif
                float mainTexColorG;
                Unity_Add_float(trisGlareFactor, mainTexColor.g, mainTexColorG);
                Unity_Clamp_float(mainTexColorG, 0, 1, mainTexColorG);
                Unity_Multiply_float(opacityFactor, mainTexColorG, opacityFactor);
                UnityTexture2D appearGradientProfileTex = UnityBuildTexture2DStructNoScale(_AppearGradientProfile);
                float appearGradientAbsSwitch;
                Unity_Round_float(_AppearGradientAbsSwitch, appearGradientAbsSwitch);
                float tempAppearGradientPositionY;
                Unity_Lerp_float(IN.ObjectSpacePosition.y, absPositionOSY, appearGradientAbsSwitch, tempAppearGradientPositionY);
                float clampedAppearGradientPositionY;
                Unity_Clamp_float(tempAppearGradientPositionY, 0, 100, clampedAppearGradientPositionY);
                Unity_Lerp_float(tempAppearGradientPositionY, clampedAppearGradientPositionY, _AppearGradientClampSwitch, clampedAppearGradientPositionY);
                float appearGradientPositionY;
                Unity_Add_float(clampedAppearGradientPositionY, _AppearGradientOffset, appearGradientPositionY);
                float distortedOpacityFactor;
                Unity_Multiply_float(clampedOpacityFactor, _AppearGradientDistortionAmount, distortedOpacityFactor);
                float distortedAppearGradientPositionY;
                Unity_Add_float(appearGradientPositionY, distortedOpacityFactor, distortedAppearGradientPositionY);
                float remappedAppearGradientPositionY;
                Unity_Remap_float(distortedAppearGradientPositionY, float2(0, _AppearGradientRemapMax), float2 (0, 1), remappedAppearGradientPositionY);
                float clampedAppearGradientPositionY1;
                Unity_Clamp_float(remappedAppearGradientPositionY, 0, 1, clampedAppearGradientPositionY1);
                float appearGradientFlipSwitch;
                Unity_Round_float(_AppearGradientFlipSwitch, appearGradientFlipSwitch);
                float finalAppearGradientPositionY;
                Unity_Lerp_float(clampedAppearGradientPositionY1, 1 - clampedAppearGradientPositionY1, appearGradientFlipSwitch, finalAppearGradientPositionY);
                float2 appearGradientPosition = float2(finalAppearGradientPositionY, 0);
                float4 appearGradientTexColor = SAMPLE_TEXTURE2D(appearGradientProfileTex.tex, appearGradientProfileTex.samplerstate, appearGradientPosition);
                Unity_Multiply_float(opacityFactor, appearGradientTexColor.g, opacityFactor);
                float appearGradientTexColorRxG;
                Unity_Multiply_float(appearGradientTexColor.r, appearGradientTexColor.g, appearGradientTexColorRxG);
                Unity_Add_float(mainTexColorSum, _AppearGradientDynamicsNegate, mainTexColorSum);
                Unity_Clamp_float(mainTexColorSum, 0, 1, mainTexColorSum);
                float appearGradientTexFactor;
                Unity_Multiply_float(appearGradientTexColorRxG, mainTexColorSum, appearGradientTexFactor);
                Unity_Multiply_float(appearGradientTexFactor, innerRimFactor, appearGradientTexFactor);
                Unity_Add_float(opacityFactor, appearGradientTexFactor, opacityFactor);
                Unity_Clamp_float(opacityFactor, 0, 1, opacityFactor);
                Unity_Multiply_float(opacityFactor, IN.VertexColor.a, opacityFactor);
                float rampOffset;
                Unity_Lerp_float(innerRimFactorXFinalMaskedDepth, opacityFactor, _RampAffectedByDynamics, rampOffset);
                Unity_Multiply_float(rampOffset, _RampOffsetMultiply, rampOffset);
                Unity_Clamp_float(rampOffset, 0, 1, rampOffset);
                float rampTexU = 1 - pow(1 - rampOffset, _RampOffsetExp);
                float2 rampTexUV = float2(rampTexU, 0);
                float4 rampTexColor = SAMPLE_TEXTURE2D(rampTexture.tex, rampTexture.samplerstate, rampTexUV);
                float4 rampColor;
                Unity_Multiply_float(rampTexColor, _RampColorTint, rampColor);
                #if !defined(_RAMPENABLED_ON)
                rampColor = _FinalColor;
                #endif
                float4 baseColor;
                Unity_Multiply_float(rampColor, (_FinalPower.xxxx), baseColor);
                float opacity;
                Unity_Multiply_float(opacityFactor, _FinalColor.a, opacity);
                surface.BaseColor = (baseColor.xyz);
                surface.Alpha = opacity;
                return surface;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
        }
        
        Pass
        {
            Name "StandardLit"
            Tags
            {
                "LightMode" = "Effect"
            }

            // Render State
            Cull [_CullMode]
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite [_Zwrite]

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
            //#pragma target 4.5
            //#pragma exclude_renderers gles gles3 glcore
            //#pragma multi_compile_instancing
            //#pragma multi_compile_fog
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma shader_feature _ _SAMPLE_GI
            #pragma shader_feature_local _ _RAMPENABLED_ON
            #pragma shader_feature_local _ _TRISGLAREENABLED_ON
            #pragma shader_feature_local _ _VERTICALGRADIENTENABLED_ON
            #pragma shader_feature_local _ _WAVESENABLED_ON
            #pragma shader_feature_local _ _DEPTHMASKENABLED_ON

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D rampTexture = UnityBuildTexture2DStructNoScale(_Ramp);
                UnityTexture2D verticalGradientProfileTexture = UnityBuildTexture2DStructNoScale(_VerticalGradientProfile);
                float absPositionOSY;
                Unity_Absolute_float(IN.ObjectSpacePosition.y, absPositionOSY);
                float verticalGradientAbsSwitch;
                Unity_Round_float(_VerticalGradientAbsSwitch, verticalGradientAbsSwitch);
                float tempPositionOSY;
                Unity_Lerp_float(IN.ObjectSpacePosition.y, absPositionOSY, verticalGradientAbsSwitch, tempPositionOSY);
                float clampedPositionOSY;
                Unity_Clamp_float(tempPositionOSY, 0, 100, clampedPositionOSY);
                float verticalGradientClampSwitch = _VerticalGradientClampSwitch;
                float positionOSY;
                Unity_Lerp_float(tempPositionOSY, clampedPositionOSY, verticalGradientClampSwitch, positionOSY);
                float gradientPositionStart;
                Unity_Add_float(positionOSY, _VerticalGradientOffset, gradientPositionStart);
                float remappedGradientPosition;
                Unity_Remap_float(gradientPositionStart, float2(0, _VerticalGradientRemapMax), float2 (0, 1), remappedGradientPosition);
                float clampedGradientPosition;
                Unity_Clamp_float(remappedGradientPosition, 0, 1, clampedGradientPosition);
                float oppositeGradientPosition;
                Unity_OneMinus_float(clampedGradientPosition, oppositeGradientPosition);
                float verticalGradientFlipSwitch;
                Unity_Round_float(_VerticalGradientFlipSwitch, verticalGradientFlipSwitch);
                float gradientPosition;
                Unity_Lerp_float(clampedGradientPosition, oppositeGradientPosition, verticalGradientFlipSwitch, gradientPosition);
                #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
                float4 verticalGradientProfileTextColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
                #else
                float4 verticalGradientProfileTextColor = SAMPLE_TEXTURE2D_LOD(verticalGradientProfileTexture.tex, verticalGradientProfileTexture.samplerstate, float2(gradientPosition, 0), 0);
                #endif
                float sceneDepthEye;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), sceneDepthEye);
                float customDepthBlend;
                CustomDepthBlend_float(IN.ScreenPosition, _DepthMaskDistance, sceneDepthEye, customDepthBlend);
                float oppositeCustomDepthBlend;
                Unity_OneMinus_float(customDepthBlend, oppositeCustomDepthBlend);
                float remappedDepthBlend;
                Unity_Remap_float(oppositeCustomDepthBlend, float2(0, _DepthMaskRemapMax), float2 (0, 1), remappedDepthBlend);
                float clampedDepthBlend;
                Unity_Clamp_float(remappedDepthBlend, 0, 1, clampedDepthBlend);
                float tempDepthBlend;
                Unity_Power_float(clampedDepthBlend, _DepthMaskExp, tempDepthBlend);
                float maskedDepthBlend;
                Unity_Multiply_float(tempDepthBlend, _DepthMaskMultiply, maskedDepthBlend);
                float clampedMaskedDepthBlend;
                Unity_Clamp_float(maskedDepthBlend, 0, 1, clampedMaskedDepthBlend);
                #if defined(_DEPTHMASKENABLED_ON)
                float maskedDepth = clampedMaskedDepthBlend;
                #else
                float maskedDepth = 0;
                #endif
                float finalMaskedDepth;
                Unity_Add_float(verticalGradientProfileTextColor.r, maskedDepth, finalMaskedDepth);
                float isFrontFace = max(0, IN.FaceSign);
                float3 nomalizedNormalWS;
                Unity_Normalize_float3(IN.WorldSpaceNormal, nomalizedNormalWS);
                float3 normalWS;
                Unity_Branch_float3(isFrontFace, nomalizedNormalWS, -nomalizedNormalWS, normalWS);
                float3 normalizedViewDirectionWS;
                Unity_Normalize_float3(IN.WorldSpaceViewDirection, normalizedViewDirectionWS);
                float tempCos;
                Unity_DotProduct_float3(normalWS, normalizedViewDirectionWS, tempCos);
                float cosine;
                Unity_Clamp_float(tempCos, 0, 1, cosine);
                float innerRimFlipSwitch;
                Unity_Round_float(_InnerRimFlipSwitch, innerRimFlipSwitch);
                float finalCosine;
                Unity_Lerp_float(cosine, 1 - cosine, innerRimFlipSwitch, finalCosine);
                float innerRimFactor;
                Unity_Power_float(finalCosine, _InnerRimExp, innerRimFactor);
                float innerRimFactorXFinalMaskedDepth;
                Unity_Multiply_float(finalMaskedDepth, innerRimFactor, innerRimFactorXFinalMaskedDepth);
                UnityTexture2D mainTexture = UnityBuildTexture2DStructNoScale(_MainTex);
                float mainUVOffsetX;
                Unity_Multiply_float(_MainTexScrollSpeed, IN.TimeParameters.x, mainUVOffsetX);
                float2 uvMain;
                Unity_Add_float2(IN.uv0.xy, float2(mainUVOffsetX, 0), uvMain);
                float4 mainTexColor = SAMPLE_TEXTURE2D(mainTexture.tex, mainTexture.samplerstate, uvMain);
                Unity_Multiply_float(mainTexColor, _MainTexChannels, mainTexColor);

                float waveStart;
                Unity_Multiply_float(_WavesScale, IN.ObjectSpacePosition.y, waveStart);
                float waveOffset;
                Unity_Multiply_float(IN.TimeParameters.x, _WavesSpeed, waveOffset);
                float wavePosition;
                Unity_Add_float(waveStart, waveOffset, wavePosition);
                float waveSine;
                Unity_Sine_float(wavePosition, waveSine);
                float waveSineRemap;
                Unity_Remap_float(waveSine, float2 (-1, 1), float2 (0, 1), waveSineRemap);
                #if defined(_WAVESENABLED_ON)
                float waveFactor = waveSineRemap;
                #else
                float waveFactor = 1;
                #endif
                UnityTexture2D offsetTexture = UnityBuildTexture2DStructNoScale(_OffsetTexture);
                float2 uvOffset;
                Unity_Lerp_float2(IN.uv1.xy, IN.uv2.xy, (_OffsetStyle.xx), uvOffset);
                float2 offsetTexScale = float2(_OffsetTextureScaleU, _OffsetTextureScaleV);
                float2 offsetTexUVStart;
                Unity_Multiply_float(uvOffset, offsetTexScale, offsetTexUVStart);
                float offsetTexUOffset;
                Unity_Multiply_float(IN.TimeParameters.x, _OffsetTextureScrollSpeedU, offsetTexUOffset);
                float offsetTexU;
                Unity_Add_float(offsetTexUVStart.x, offsetTexUOffset, offsetTexU);
                float offsetTexVOffset;
                Unity_Multiply_float(IN.TimeParameters.x, _OffsetTextureScrollSpeedV, offsetTexVOffset);
                float offsetTexV;
                Unity_Add_float(offsetTexUVStart.y, offsetTexVOffset, offsetTexV);
                float2 offsetTexUV = float2(offsetTexU, offsetTexV);
                #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
                float4 offsetTexColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
                #else
                float4 offsetTexColor = SAMPLE_TEXTURE2D_LOD(offsetTexture.tex, offsetTexture.samplerstate, offsetTexUV, 0);
                #endif
                float tempOpacityFactor;
                Unity_Multiply_float(waveFactor, offsetTexColor.r, tempOpacityFactor);
                Unity_Power_float(tempOpacityFactor, _OffsetToOpacityExp, tempOpacityFactor);
                float negateOpacityFactor;
                Unity_Add_float(tempOpacityFactor, _OffsetToOpacityNegate, negateOpacityFactor);
                float clampedAbsPositionOSY;
                Unity_Clamp_float(absPositionOSY, 0, 1, clampedAbsPositionOSY);
                float opacityFactorTopFix;
                Unity_Power_float(clampedAbsPositionOSY, _OffsetToOpacityTopFixExp, opacityFactorTopFix);
                float oppositeOpacityFactorTopFix;
                Unity_OneMinus_float(opacityFactorTopFix, oppositeOpacityFactorTopFix);
                Unity_Lerp_float(_OffsetToOpacityTopFixValue, negateOpacityFactor, oppositeOpacityFactorTopFix, tempOpacityFactor);
                float clampedOpacityFactor;
                Unity_Clamp_float(tempOpacityFactor, 0, 1, clampedOpacityFactor);
                Unity_Multiply_float(mainTexColor, float4(clampedOpacityFactor, clampedOpacityFactor, 1, 1), mainTexColor);
                float mainTexColorSum = dot(mainTexColor, float4(1,1,1,1));
                Unity_Clamp_float(mainTexColorSum, 0, 1, mainTexColorSum);
                #if !defined(_VERTICALGRADIENTENABLED_ON)
                finalMaskedDepth = 1;
                #endif
                float mainTexColorSumXFinalMaskedDepth;
                Unity_Multiply_float(mainTexColorSum, finalMaskedDepth, mainTexColorSumXFinalMaskedDepth);
                float rimFactor;
                Unity_Branch_float(_INNERRIMENABLED, innerRimFactor, 1, rimFactor);
                float rimFactorAddMaskedDepth;
                Unity_Add_float(rimFactor, maskedDepth, rimFactorAddMaskedDepth);
                Unity_Clamp_float(rimFactorAddMaskedDepth, 0, 1, rimFactorAddMaskedDepth);
                float opacityFactor;
                Unity_Multiply_float(mainTexColorSumXFinalMaskedDepth, rimFactorAddMaskedDepth, opacityFactor);
                Unity_Multiply_float(opacityFactor, _FinalOpacityPower, opacityFactor);

                UnityTexture2D trisGlareTexture = UnityBuildTexture2DStructNoScale(_TrisGlareTexture);
                float2 trisGlareTextureUVScale = float2(_TrisGlareTextureScaleU, _TrisGlareTextureScaleV);
                float2 scaledTrisGlareTextureUV;
                Unity_Multiply_float(IN.uv2.xy, trisGlareTextureUVScale, scaledTrisGlareTextureUV);
                float trisGlareTexU = scaledTrisGlareTextureUV.x + offsetTexUOffset;
                float trisGlareTexV = scaledTrisGlareTextureUV.y + offsetTexVOffset;
                float2 trisGlareTexUV = float2(trisGlareTexU, trisGlareTexV);
                float4 trisGlareTexColor = SAMPLE_TEXTURE2D(trisGlareTexture.tex, trisGlareTexture.samplerstate, trisGlareTexUV);
                float negateTrisGlareTexColor;
                Unity_Add_float(trisGlareTexColor.r, _TrisGlareNegate, negateTrisGlareTexColor);
                float trisGlareFactor;
                Unity_Clamp_float(negateTrisGlareTexColor, 0, 1, trisGlareFactor);
                #if !defined(_TRISGLAREENABLED_ON)
                trisGlareFactor  = 1;
                #endif
                float mainTexColorG;
                Unity_Add_float(trisGlareFactor, mainTexColor.g, mainTexColorG);
                Unity_Clamp_float(mainTexColorG, 0, 1, mainTexColorG);
                Unity_Multiply_float(opacityFactor, mainTexColorG, opacityFactor);
                UnityTexture2D appearGradientProfileTex = UnityBuildTexture2DStructNoScale(_AppearGradientProfile);
                float appearGradientAbsSwitch;
                Unity_Round_float(_AppearGradientAbsSwitch, appearGradientAbsSwitch);
                float tempAppearGradientPositionY;
                Unity_Lerp_float(IN.ObjectSpacePosition.y, absPositionOSY, appearGradientAbsSwitch, tempAppearGradientPositionY);
                float clampedAppearGradientPositionY;
                Unity_Clamp_float(tempAppearGradientPositionY, 0, 100, clampedAppearGradientPositionY);
                Unity_Lerp_float(tempAppearGradientPositionY, clampedAppearGradientPositionY, _AppearGradientClampSwitch, clampedAppearGradientPositionY);
                float appearGradientPositionY;
                Unity_Add_float(clampedAppearGradientPositionY, _AppearGradientOffset, appearGradientPositionY);
                float distortedOpacityFactor;
                Unity_Multiply_float(clampedOpacityFactor, _AppearGradientDistortionAmount, distortedOpacityFactor);
                float distortedAppearGradientPositionY;
                Unity_Add_float(appearGradientPositionY, distortedOpacityFactor, distortedAppearGradientPositionY);
                float remappedAppearGradientPositionY;
                Unity_Remap_float(distortedAppearGradientPositionY, float2(0, _AppearGradientRemapMax), float2 (0, 1), remappedAppearGradientPositionY);
                float clampedAppearGradientPositionY1;
                Unity_Clamp_float(remappedAppearGradientPositionY, 0, 1, clampedAppearGradientPositionY1);
                float appearGradientFlipSwitch;
                Unity_Round_float(_AppearGradientFlipSwitch, appearGradientFlipSwitch);
                float finalAppearGradientPositionY;
                Unity_Lerp_float(clampedAppearGradientPositionY1, 1 - clampedAppearGradientPositionY1, appearGradientFlipSwitch, finalAppearGradientPositionY);
                float2 appearGradientPosition = float2(finalAppearGradientPositionY, 0);
                float4 appearGradientTexColor = SAMPLE_TEXTURE2D(appearGradientProfileTex.tex, appearGradientProfileTex.samplerstate, appearGradientPosition);
                Unity_Multiply_float(opacityFactor, appearGradientTexColor.g, opacityFactor);
                float appearGradientTexColorRxG;
                Unity_Multiply_float(appearGradientTexColor.r, appearGradientTexColor.g, appearGradientTexColorRxG);
                Unity_Add_float(mainTexColorSum, _AppearGradientDynamicsNegate, mainTexColorSum);
                Unity_Clamp_float(mainTexColorSum, 0, 1, mainTexColorSum);
                float appearGradientTexFactor;
                Unity_Multiply_float(appearGradientTexColorRxG, mainTexColorSum, appearGradientTexFactor);
                Unity_Multiply_float(appearGradientTexFactor, innerRimFactor, appearGradientTexFactor);
                Unity_Add_float(opacityFactor, appearGradientTexFactor, opacityFactor);
                Unity_Clamp_float(opacityFactor, 0, 1, opacityFactor);
                Unity_Multiply_float(opacityFactor, IN.VertexColor.a, opacityFactor);
                float rampOffset;
                Unity_Lerp_float(innerRimFactorXFinalMaskedDepth, opacityFactor, _RampAffectedByDynamics, rampOffset);
                Unity_Multiply_float(rampOffset, _RampOffsetMultiply, rampOffset);
                Unity_Clamp_float(rampOffset, 0, 1, rampOffset);
                float rampTexU = 1 - pow(1 - rampOffset, _RampOffsetExp);
                float2 rampTexUV = float2(rampTexU, 0);
                float4 rampTexColor = SAMPLE_TEXTURE2D(rampTexture.tex, rampTexture.samplerstate, rampTexUV);
                float4 rampColor;
                Unity_Multiply_float(rampTexColor, _RampColorTint, rampColor);
                #if !defined(_RAMPENABLED_ON)
                rampColor = _FinalColor;
                #endif
                float4 baseColor;
                Unity_Multiply_float(rampColor, (_FinalPower.xxxx), baseColor);
                float opacity;
                Unity_Multiply_float(opacityFactor, _FinalColor.a, opacity);
                surface.BaseColor = (baseColor.xyz);
                surface.Alpha = opacity;
                return surface;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite On
            ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
            //#pragma target 4.5
            //#pragma exclude_renderers gles gles3 glcore
            // #pragma multi_compile_instancing
            // #pragma multi_compile _ DOTS_INSTANCING_ON
            // #pragma vertex vert
            // #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // #pragma shader_feature_local _ _RAMPENABLED_ON
            // #pragma shader_feature_local _ _TRISGLAREENABLED_ON
            // #pragma shader_feature_local _ _VERTICALGRADIENTENABLED_ON
            // #pragma shader_feature_local _ _WAVESENABLED_ON
            // #pragma shader_feature_local _ _DEPTHMASKENABLED_ON

            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                // UnityTexture2D mainTexture = UnityBuildTexture2DStructNoScale(_MainTex);
                // float mainUVOffsetX;
                // Unity_Multiply_float(_MainTexScrollSpeed, IN.TimeParameters.x, mainUVOffsetX);
                // float2 uvMain;
                // Unity_Add_float2(IN.uv0.xy, float2(mainUVOffsetX, 0), uvMain);
                // float4 mainTexColor = SAMPLE_TEXTURE2D(mainTexture.tex, mainTexture.samplerstate, uvMain);
                // Unity_Multiply_float(mainTexColor, _MainTexChannels, mainTexColor);
                //
                // float waveStart;
                // Unity_Multiply_float(_WavesScale, IN.ObjectSpacePosition.y, waveStart);
                // float waveOffset;
                // Unity_Multiply_float(IN.TimeParameters.x, _WavesSpeed, waveOffset);
                // float wavePosition;
                // Unity_Add_float(waveStart, waveOffset, wavePosition);
                // float waveSine;
                // Unity_Sine_float(wavePosition, waveSine);
                // float waveSineRemap;
                // Unity_Remap_float(waveSine, float2 (-1, 1), float2 (0, 1), waveSineRemap);
                // #if defined(_WAVESENABLED_ON)
                // float waveFactor = waveSineRemap;
                // #else
                // float waveFactor = 1;
                // #endif
                // UnityTexture2D offsetTexture = UnityBuildTexture2DStructNoScale(_OffsetTexture);
                // float2 uvOffset;
                // Unity_Lerp_float2(IN.uv1.xy, IN.uv2.xy, (_OffsetStyle.xx), uvOffset);
                // float2 offsetTexScale = float2(_OffsetTextureScaleU, _OffsetTextureScaleV);
                // float2 offsetTexUVStart;
                // Unity_Multiply_float(uvOffset, offsetTexScale, offsetTexUVStart);
                // float offsetTexUOffset;
                // Unity_Multiply_float(IN.TimeParameters.x, _OffsetTextureScrollSpeedU, offsetTexUOffset);
                // float offsetTexU;
                // Unity_Add_float(offsetTexUVStart.x, offsetTexUOffset, offsetTexU);
                // float offsetTexVOffset;
                // Unity_Multiply_float(IN.TimeParameters.x, _OffsetTextureScrollSpeedV, offsetTexVOffset);
                // float offsetTexV;
                // Unity_Add_float(offsetTexUVStart.y, offsetTexVOffset, offsetTexV);
                // float2 offsetTexUV = float2(offsetTexU, offsetTexV);
                // #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
                // float4 offsetTexColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
                // #else
                // float4 offsetTexColor = SAMPLE_TEXTURE2D_LOD(offsetTexture.tex, offsetTexture.samplerstate, offsetTexUV, 0);
                // #endif
                // float tempOpacityFactor;
                // Unity_Multiply_float(waveFactor, offsetTexColor.r, tempOpacityFactor);
                // Unity_Power_float(tempOpacityFactor, _OffsetToOpacityExp, tempOpacityFactor);
                // float negateOpacityFactor;
                // Unity_Add_float(tempOpacityFactor, _OffsetToOpacityNegate, negateOpacityFactor);
                // float absPositionOSY;
                // Unity_Absolute_float(IN.ObjectSpacePosition.y, absPositionOSY);
                // float clampedAbsPositionOSY;
                // Unity_Clamp_float(absPositionOSY, 0, 1, clampedAbsPositionOSY);
                // float opacityFactorTopFix;
                // Unity_Power_float(clampedAbsPositionOSY, _OffsetToOpacityTopFixExp, opacityFactorTopFix);
                // float oppositeOpacityFactorTopFix;
                // Unity_OneMinus_float(opacityFactorTopFix, oppositeOpacityFactorTopFix);
                // Unity_Lerp_float(_OffsetToOpacityTopFixValue, negateOpacityFactor, oppositeOpacityFactorTopFix, tempOpacityFactor);
                // float clampedOpacityFactor;
                // Unity_Clamp_float(tempOpacityFactor, 0, 1, clampedOpacityFactor);
                // Unity_Multiply_float(mainTexColor, float4(clampedOpacityFactor, clampedOpacityFactor, 1, 1), mainTexColor);
                // float mainTexColorSum = dot(mainTexColor, float4(1,1,1,1));
                // Unity_Clamp_float(mainTexColorSum, 0, 1, mainTexColorSum);
                // UnityTexture2D verticalGradientProfileTexture = UnityBuildTexture2DStructNoScale(_VerticalGradientProfile);
                // float verticalGradientAbsSwitch;
                // Unity_Round_float(_VerticalGradientAbsSwitch, verticalGradientAbsSwitch);
                // float tempPositionOSY;
                // Unity_Lerp_float(IN.ObjectSpacePosition.y, absPositionOSY, verticalGradientAbsSwitch, tempPositionOSY);
                // float clampedPositionOSY;
                // Unity_Clamp_float(tempPositionOSY, 0, 100, clampedPositionOSY);
                // float verticalGradientClampSwitch = _VerticalGradientClampSwitch;
                // float positionOSY;
                // Unity_Lerp_float(tempPositionOSY, clampedPositionOSY, verticalGradientClampSwitch, positionOSY);
                // float gradientPositionStart;
                // Unity_Add_float(positionOSY, _VerticalGradientOffset, gradientPositionStart);
                // float remappedGradientPosition;
                // Unity_Remap_float(gradientPositionStart, float2(0, _VerticalGradientRemapMax), float2 (0, 1), remappedGradientPosition);
                // float clampedGradientPosition;
                // Unity_Clamp_float(remappedGradientPosition, 0, 1, clampedGradientPosition);
                // float oppositeGradientPosition;
                // Unity_OneMinus_float(clampedGradientPosition, oppositeGradientPosition);
                // float verticalGradientFlipSwitch;
                // Unity_Round_float(_VerticalGradientFlipSwitch, verticalGradientFlipSwitch);
                // float gradientPosition;
                // Unity_Lerp_float(clampedGradientPosition, oppositeGradientPosition, verticalGradientFlipSwitch, gradientPosition);
                // #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
                // float4 verticalGradientProfileTextColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
                // #else
                // float4 verticalGradientProfileTextColor = SAMPLE_TEXTURE2D_LOD(verticalGradientProfileTexture.tex, verticalGradientProfileTexture.samplerstate, float2(gradientPosition, 0), 0);
                // #endif
                // float sceneDepthEye;
                // Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), sceneDepthEye);
                // float customDepthBlend;
                // CustomDepthBlend_float(IN.ScreenPosition, _DepthMaskDistance, sceneDepthEye, customDepthBlend);
                // float oppositeCustomDepthBlend;
                // Unity_OneMinus_float(customDepthBlend, oppositeCustomDepthBlend);
                // float remappedDepthBlend;
                // Unity_Remap_float(oppositeCustomDepthBlend, float2(0, _DepthMaskRemapMax), float2 (0, 1), remappedDepthBlend);
                // float clampedDepthBlend;
                // Unity_Clamp_float(remappedDepthBlend, 0, 1, clampedDepthBlend);
                // float tempDepthBlend;
                // Unity_Power_float(clampedDepthBlend, _DepthMaskExp, tempDepthBlend);
                // float maskedDepthBlend;
                // Unity_Multiply_float(tempDepthBlend, _DepthMaskMultiply, maskedDepthBlend);
                // float clampedMaskedDepthBlend;
                // Unity_Clamp_float(maskedDepthBlend, 0, 1, clampedMaskedDepthBlend);
                // #if defined(_DEPTHMASKENABLED_ON)
                // float maskedDepth = clampedMaskedDepthBlend;
                // #else
                // float maskedDepth = 0;
                // #endif
                // float finalMaskedDepth;
                // Unity_Add_float(verticalGradientProfileTextColor.r, maskedDepth, finalMaskedDepth);
                // #if !defined(_VERTICALGRADIENTENABLED_ON)
                // finalMaskedDepth = 1;
                // #endif
                // float mainTexColorSumXFinalMaskedDepth;
                // Unity_Multiply_float(mainTexColorSum, finalMaskedDepth, mainTexColorSumXFinalMaskedDepth);
                // float isFrontFace = max(0, IN.FaceSign);
                // float3 nomalizedNormalWS;
                // Unity_Normalize_float3(IN.WorldSpaceNormal, nomalizedNormalWS);
                // float3 normalWS;
                // Unity_Branch_float3(isFrontFace, nomalizedNormalWS, -nomalizedNormalWS, normalWS);
                // float3 normalizedViewDirectionWS;
                // Unity_Normalize_float3(IN.WorldSpaceViewDirection, normalizedViewDirectionWS);
                // float tempCos;
                // Unity_DotProduct_float3(normalWS, normalizedViewDirectionWS, tempCos);
                // float cosine;
                // Unity_Clamp_float(tempCos, 0, 1, cosine);
                // float innerRimFlipSwitch;
                // Unity_Round_float(_InnerRimFlipSwitch, innerRimFlipSwitch);
                // float finalCosine;
                // Unity_Lerp_float(cosine, 1 - cosine, innerRimFlipSwitch, finalCosine);
                // float innerRimFactor;
                // Unity_Power_float(finalCosine, _InnerRimExp, innerRimFactor);
                // float rimFactor;
                // Unity_Branch_float(_INNERRIMENABLED, innerRimFactor, 1, rimFactor);
                // float rimFactorAddMaskedDepth;
                // Unity_Add_float(rimFactor, maskedDepth, rimFactorAddMaskedDepth);
                // Unity_Clamp_float(rimFactorAddMaskedDepth, 0, 1, rimFactorAddMaskedDepth);
                // float opacityFactor;
                // Unity_Multiply_float(mainTexColorSumXFinalMaskedDepth, rimFactorAddMaskedDepth, opacityFactor);
                // Unity_Multiply_float(opacityFactor, _FinalOpacityPower, opacityFactor);
                // UnityTexture2D trisGlareTexture = UnityBuildTexture2DStructNoScale(_TrisGlareTexture);
                // float2 trisGlareTextureUVScale = float2(_TrisGlareTextureScaleU, _TrisGlareTextureScaleV);
                // float2 scaledTrisGlareTextureUV;
                // Unity_Multiply_float(IN.uv2.xy, trisGlareTextureUVScale, scaledTrisGlareTextureUV);
                // float trisGlareTexU = scaledTrisGlareTextureUV.x + offsetTexUOffset;
                // float trisGlareTexV = scaledTrisGlareTextureUV.y + offsetTexVOffset;
                // float2 trisGlareTexUV = float2(trisGlareTexU, trisGlareTexV);
                // float4 trisGlareTexColor = SAMPLE_TEXTURE2D(trisGlareTexture.tex, trisGlareTexture.samplerstate, trisGlareTexUV);
                // float negateTrisGlareTexColor;
                // Unity_Add_float(trisGlareTexColor.r, _TrisGlareNegate, negateTrisGlareTexColor);
                // float trisGlareFactor;
                // Unity_Clamp_float(negateTrisGlareTexColor, 0, 1, trisGlareFactor);
                // #if !defined(_TRISGLAREENABLED_ON)
                // trisGlareFactor = 1;
                // #endif
                // float mainTexColorG;
                // Unity_Add_float(trisGlareFactor, mainTexColor.g, mainTexColorG);
                // Unity_Clamp_float(mainTexColorG, 0, 1, mainTexColorG);
                // Unity_Multiply_float(opacityFactor, mainTexColorG, opacityFactor);
                // UnityTexture2D appearGradientProfileTex = UnityBuildTexture2DStructNoScale(_AppearGradientProfile);
                // float appearGradientAbsSwitch;
                // Unity_Round_float(_AppearGradientAbsSwitch, appearGradientAbsSwitch);
                // float tempAppearGradientPositionY;
                // Unity_Lerp_float(IN.ObjectSpacePosition.y, absPositionOSY, appearGradientAbsSwitch, tempAppearGradientPositionY);
                // float clampedAppearGradientPositionY;
                // Unity_Clamp_float(tempAppearGradientPositionY, 0, 100, clampedAppearGradientPositionY);
                // Unity_Lerp_float(tempAppearGradientPositionY, clampedAppearGradientPositionY, _AppearGradientClampSwitch, clampedAppearGradientPositionY);
                // float appearGradientPositionY;
                // Unity_Add_float(clampedAppearGradientPositionY, _AppearGradientOffset, appearGradientPositionY);
                // float distortedOpacityFactor;
                // Unity_Multiply_float(clampedOpacityFactor, _AppearGradientDistortionAmount, distortedOpacityFactor);
                // float distortedAppearGradientPositionY;
                // Unity_Add_float(appearGradientPositionY, distortedOpacityFactor, distortedAppearGradientPositionY);
                // float remappedAppearGradientPositionY;
                // Unity_Remap_float(distortedAppearGradientPositionY, float2(0, _AppearGradientRemapMax), float2 (0, 1), remappedAppearGradientPositionY);
                // float clampedAppearGradientPositionY1;
                // Unity_Clamp_float(remappedAppearGradientPositionY, 0, 1, clampedAppearGradientPositionY1);
                // float appearGradientFlipSwitch;
                // Unity_Round_float(_AppearGradientFlipSwitch, appearGradientFlipSwitch);
                // float finalAppearGradientPositionY;
                // Unity_Lerp_float(clampedAppearGradientPositionY1, 1 - clampedAppearGradientPositionY1, appearGradientFlipSwitch, finalAppearGradientPositionY);
                // float2 appearGradientPosition = float2(finalAppearGradientPositionY, 0);
                // float4 appearGradientTexColor = SAMPLE_TEXTURE2D(appearGradientProfileTex.tex, appearGradientProfileTex.samplerstate, appearGradientPosition);
                // Unity_Multiply_float(opacityFactor, appearGradientTexColor.g, opacityFactor);
                // float appearGradientTexColorRxG;
                // Unity_Multiply_float(appearGradientTexColor.r, appearGradientTexColor.g, appearGradientTexColorRxG);
                // Unity_Add_float(mainTexColorSum, _AppearGradientDynamicsNegate, mainTexColorSum);
                // Unity_Clamp_float(mainTexColorSum, 0, 1, mainTexColorSum);
                // float appearGradientTexFactor;
                // Unity_Multiply_float(appearGradientTexColorRxG, mainTexColorSum, appearGradientTexFactor);
                // Unity_Multiply_float(appearGradientTexFactor, innerRimFactor, appearGradientTexFactor);
                // Unity_Add_float(opacityFactor, appearGradientTexFactor, opacityFactor);
                // Unity_Clamp_float(opacityFactor, 0, 1, opacityFactor);
                // Unity_Multiply_float(opacityFactor, IN.VertexColor.a, opacityFactor);
                // float opacity;
                // Unity_Multiply_float(opacityFactor, _FinalColor.a, opacity);
                // surface.Alpha = opacity;
                return surface;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "JTRP.ShaderDrawer.LWGUI" 
    FallBack "Hidden/Shader Graph/FallbackError"
}