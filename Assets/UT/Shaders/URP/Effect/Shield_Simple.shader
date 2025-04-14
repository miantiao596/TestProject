Shader "URP/MoleGame/Effects/Shield_Simple"
{
    Properties
    {
        _FinalPower("Final Power", Range(0, 100)) = 4
        _OpacityScale("Opacity Scale", Range(0.001, 1)) = 0.05
        [NoScaleOffset]_Ramp("Ramp", 2D) = "white" {}
        _RampColorTint("Ramp Color Tint", Color) = (1, 1, 1, 1)
        _RampAffectedByDynamics("Ramp Affected By Dynamics", Range(0, 1)) = 1
        _RampOffsetMultiply("Ramp Offset Multiply", Float) = 1
        _RampOffsetExp("Ramp Offset Exp", Range(0.2, 8)) = 1
        _InnerRimExp("Inner Rim Exp", Range(0.1, 16)) = 4
        _InnerRimFlipSwitch("Inner Rim Flip Switch", Range(0, 1)) = 1
        _DepthMaskDistance("Depth Mask Distance", Float) = 1
        _DepthMaskRemapMax("Depth Mask Remap Max", Float) = 1
        _DepthMaskExp("Depth Mask Exp", Float) = 2
        _DepthMaskScale("Depth Mask Scale", Float) = 1

        //[Toggle]_DEPTHMASKENABLED("Depth Mask Enabled", Float) = 1
        
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
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
        }

        Pass
        {
            Name "Pass"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite Off
            
            //跳过TAA处理的Mask
            Stencil {
                Ref [_TAAStencil]
                WriteMask [_TAAStencilMask]
                Comp always
                Pass [_TAAStencilPassOperate]
            }
            

            // --------------------------------------------------
            // Pass
            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag

            // Keywords
            //#pragma multi_compile_local _ _DEPTHMASKENABLED_ON

            // Defines
            #define VARYINGS_NEED_CULLFACE

             // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            // vert inputs
            struct Attributes
            {
                float3 positionOS : POSITION;
                half3 normalOS : NORMAL;
                half4 tangentOS : TANGENT;
                half4 color : COLOR;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                half3 normalWS : TEXCOORD1;
                float4 clipPosition : TEXCOORD2;
                half4 color : TEXCOORD3;
                half3 viewDirectionWS : TEXCOORD4;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            CBUFFER_START(UnityPerMaterial)
            half _FinalPower;
            half _OpacityScale;
            half4 _RampColorTint;
            half _RampAffectedByDynamics;
            half _RampOffsetMultiply;
            half _RampOffsetExp;
            half _InnerRimExp;
            half _InnerRimFlipSwitch;
            half _DepthMaskDistance;
            half _DepthMaskRemapMax;
            half _DepthMaskExp;
            half _DepthMaskScale;
            CBUFFER_END

            // Object and Global properties
            TEXTURE2D(_Ramp);
            SAMPLER(sampler_Ramp);

            // Shader Functions
            float Remap(float In, float2 InMinMax, float2 OutMinMax)
            {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            float CustomDepthBlend(float4 spr, float dist, float cameraDepth)
            {
                float4 sp = spr / spr.w;
                sp.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? sp.z : sp.z * 0.5 + 0.5;
                float transparentDepth = LinearEyeDepth(sp.z, _ZBufferParams);
                return abs((cameraDepth - transparentDepth) / (dist));
            }

            float GetDepthMask(float4 screenPosition)
            {
                //#if defined(_DEPTHMASKENABLED_ON)
                float2 screenUV = screenPosition.xy / screenPosition.w;
                float cameraDepth = SampleSceneDepth(screenUV);
                float linearCameraDepth = LinearEyeDepth(cameraDepth, _ZBufferParams);
                float deltaDepth = CustomDepthBlend(screenPosition, _DepthMaskDistance, linearCameraDepth);
                float depthRemap = Remap((1 - deltaDepth), float2(0, _DepthMaskRemapMax), float2(0, 1));
                float depthRemapClamp = clamp(depthRemap, 0, 1);
                return clamp((pow(depthRemapClamp, _DepthMaskExp) * _DepthMaskScale), 0, 1);
                //#else
                //return 0;
                //#endif
            }

            float GetInnerRimRaw(half3 normalWS, half3 viewDirectionWS, half faceSign)
            {
                half3 wNormal = normalize(normalWS);
                wNormal = max(0, faceSign) ? wNormal : -wNormal;
                half3 wViewDir = normalize(viewDirectionWS);
                float NoV = dot(wNormal, wViewDir);
                float NoVClamp = clamp(NoV, 0, 1);
                float innerRimFlipSwtich = round(_InnerRimFlipSwitch);
                NoV = lerp(NoVClamp, (1 - NoVClamp), innerRimFlipSwtich);
                return pow(abs(NoV), _InnerRimExp);
            }

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                half3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                half4 tangentWS = half4(TransformObjectToWorldDir(input.tangentOS.xyz), input.tangentOS.w);
                output.positionWS = positionWS;
                output.normalWS = normalWS;			// normalized in TransformObjectToWorldNormal()
                output.positionCS = TransformWorldToHClip(positionWS);
                output.clipPosition = output.positionCS;
                output.color = input.color;
                output.viewDirectionWS = GetWorldSpaceViewDir(positionWS);

                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif

                return output;
            }

            half4 frag(Varyings input) : SV_TARGET 
            {
                half3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                half3 normalWS = renormFactor * input.normalWS;
                float4 screenPosition = ComputeScreenPos(input.clipPosition);
                half faceSign = true;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                faceSign = IS_FRONT_VFACE(input.cullFace, true, false);
                #endif

                // Depth Mask
                float depthMask = GetDepthMask(screenPosition);
                // Inner Rim
                half innerRimRaw = GetInnerRimRaw(normalWS, input.viewDirectionWS, faceSign);

                half opacity = (innerRimRaw * _OpacityScale * 2 + depthMask * 3) * input.color.a;

                //Ramp UV
                half rampU = lerp(innerRimRaw, opacity, _RampAffectedByDynamics);
                rampU = clamp(rampU * _RampOffsetMultiply, 0, 1);
                rampU = 1 - pow((1 - rampU), _RampOffsetExp);
                half2 rampUV = float2(rampU, 0);

                // Color
                half4 rampColor = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, rampUV);
                half4 finalColor = rampColor * _RampColorTint * rampColor * _FinalPower;
                return half4(finalColor.rgb, opacity);
            }
            ENDHLSL
        } //Pass
    } //SubShader
    CustomEditor "JTRP.ShaderDrawer.LWGUI" 
}//Shader