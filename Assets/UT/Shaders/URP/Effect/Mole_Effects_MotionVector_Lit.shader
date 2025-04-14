Shader "URP/MoleGame/Effects/MotionVector_Lit"
{
    Properties
    {
         [Preset(GroupPreset,Standard_RenderingPreset)] _RenderMode ("Rendering Mode", Float) = 4.0
        [HideInInspector]_TransparentMode("__mode", Float) = 3.0
        [HideInInspector]_SrcBlend("__src", Float) = 1.0
        [HideInInspector]_DstBlend("__dst", Float) = 10.0
        //TransparentPremultipliedAlpha 半透明预乘Alpha参数，太长了改个缩写
        [HideInInspector]_TPA("__TPA", Float) = 1.0

        _MainTex ("Texture", 2D) = "white" {}
        [MainColor][Gamma][HDR]_Color("Main Color", Color) = (1,1,1,1)
        [Channel(RGBAChannelMaskToVec4)]_MainTex_ChannelMask("Main Texture Channel Mask (Default: RGBA)", Vector) = (1,0,0,0)
        _Intensity("Intensity (Default: 1)", Float) = 1

        [HideInInspector]_Emissive_Intensity("Emissive Intensity", Range(0.0,100.0)) = 0.0
        [HideInInspector][HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)

        _MaskTex("Mask Texture", 2D) = "white" {}
        _FlowMap("Flow Map(RG)", 2D) = "bump" {}
        _FlowPercent("Flow Percent", Range(0, 1)) = 0

        [Main(_LightGroup)]_ENABLE_NORMAL("Enable Normal", Float) = 0
        [Sub(_LightGroup)]_BumpMap("Normal Texture", 2D) = "bump" {}
        [Sub(_LightGroup)]_BumpScale("Normal Scale", Float) = 1.0
        [Sub(_LightGroup)]_LightWrapping ("Light Wrapping", Float ) = 1.5

        [Main(_FrameAnimGroup)]_SUBUV_ANIM("SubUV Animation", Float) = 0
        [Sub(_FrameAnimGroup)]_SubUV("Sub UV Matrix", Vector) = (8,8,0,0)
        [Sub(_FrameAnimGroup)]_PlayTime("Play Time in Sec", Float) = 30
        [Sub(_FrameAnimGroup)]_MotionDistortionStrength("Motion Distortion Strength", Range(0, 100)) = 7.5

        // Dissolution溶解贴图
        [Main(_DissolutionGroup)]_DISSOLUTION("Dissolution", Float) = 0
        [Sub(_DissolutionGroup)]_DissolutionTex("Dissolution Texture", 2D) = "white" {}
        [SubToggle(_DissolutionGroup)]_DissolutionReverse("Dissolution Reverse", Float) = 0
        [Sub(_DissolutionGroup)]_DissolutionPercent("Dissolution Percent", Range(0, 1)) = 0.5
        [Channel(_DissolutionGroup)]_DissolutionTex_ChannelMask("Dissolution Texture Channel Mask (Default: R)", Vector) = (1,0,0,0)
        [Sub(_DissolutionGroup)]_DissolutionSoftEdge("Dissolution Soft Edge", Range(0, 1)) = 0
        [Sub(_DissolutionGroup)][Gamma][HDR]_DissolutionEdgeColor("Dissolution Edge Color", Color) = (1,1,1,1)
        [Sub(_DissolutionGroup)]_DissolutionEdgeWidth("Dissolution Edge Width", Range(0, 1)) = 0

        // DepthFade 切边羽化（交界处透明）
        [Main(_DepthFadeGroup)]_DEPTH_FADE("Depth Fade", Float) = 0
        [Sub(_DepthFadeGroup)]_DepthFadeOffset("Depth Fade Offset", Float) = 0
        [Sub(_DepthFadeGroup)]_DepthFadeIntensity("Depth Fade Intensity", Float) = 0

        // AlphaClip
        [Main(_AlphaClipGroup, _ALPHATEST_ON)]_AlphaClip_On("Alpha Clip		(Default: Off)", Float) = 0
        [Sub(_AlphaClipGroup)]_Cutoff("Cutoff (Default: 0.5)", Range(0, 0.99)) = 0.5

        [Header(x Intensity   y Dissolution Percent   z Flow Percent   w Time)]
        [Toggle]_USE_VERTEX_STREAM("Use Vertex Stream", Float) = 0

        [Header(ZTest)]
        [Enum(MoleGame.Editor.TATools.ZTest)]_ZTest("ZTest (Default: LessEqual)", Float) = 4
        [Header(ZWrite)]
        [Toggle]_ZWrite("ZWrite (Default: Off)", Float) = 0
        
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
        Tags {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
            "PreviewType" = "Plane"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#ifdef _FORWARD_PLUS_Z_BINING
        #include "Packages/com.mole.forwardplus/ShaderLibrary/ForwardPlusWithZBin/ForwardPlusWithZBinInput.hlsl"
        #include "Packages/com.mole.forwardplus/ShaderLibrary/ForwardPlusWithZBin/ForwardPlusWithZbinClustering.hlsl"
#endif

        TEXTURE2D(_MainTex);           SAMPLER(sampler_MainTex);
        TEXTURE2D(_MaskTex);           SAMPLER(sampler_MaskTex);
        TEXTURE2D(_FlowMap);           SAMPLER(sampler_FlowMap);
        TEXTURE2D(_DissolutionTex);    SAMPLER(sampler_DissolutionTex);

        CBUFFER_START(UnityPerMaterial)
        half4 _MainTex_ST;
        half4 _BumpMap_ST;
        half4 _MaskTex_ST;
        half4 _FlowMap_ST;
        half4 _DissolutionTex_ST;
        half4 _MainTex_ChannelMask;
        half4 _Color;
        half  _Intensity;
        half  _BumpScale;
        half  _LightWrapping;
        half  _Emissive_Intensity;
        half4 _EmissionColor;
        half  _Cutoff;
        half  _FlowPercent;
        float2 _SubUV;
        half  _PlayTime;
        half  _MotionDistortionStrength;

        half4 _DissolutionTex_ChannelMask;
        half  _DissolutionReverse;
        half  _DissolutionPercent;
        half  _DissolutionSoftEdge;
        half4 _DissolutionEdgeColor;
        half  _DissolutionEdgeWidth;

        half _DepthFadeIntensity;
        half _DepthFadeOffset;

        half _USE_VERTEX_STREAM;
        //预乘alpha参数
        #ifndef NO_TPA
            half _TPA;
        #endif
        CBUFFER_END

        #include "../FALib/FAEffectLib.hlsl"

        #pragma vertex vert
        #pragma fragment frag
        // make fog work
        //#pragma multi_compile_fog

        #pragma multi_compile_local _ _ALPHATEST_ON _ALPHAPREMULTIPLY_ON
        #pragma multi_compile_local _ _ENABLE_NORMAL_ON
        #pragma multi_compile_local _ _SUBUV_ANIM_ON
        #pragma multi_compile_local _ _DISSOLUTION_ON
        #pragma multi_compile_local _ _DEPTH_FADE_ON
        #pragma shader_feature _ _FORWARD_PLUS_Z_BINING

        struct Attributes
        {
            float4 positionOS : POSITION;
            half3 normalOS : NORMAL;
            half4 tangentOS : TANGENT;
            half4 color : COLOR;
            float4 uvAndvs1xy : TEXCOORD0; // UV and Vertex Stream xy
            float2 vs1zw : TEXCOORD1; // Vertex Stream zw
        };

        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 uvMain : TEXCOORD0;
            float4 uvMask : TEXCOORD1;
            half4 color : TEXCOORD2;
            half3 normalWS : TEXCOORD3;
            half3 tangentWS : TEXCOORD4;
            half3 bitangentWS : TEXCOORD5;
            half4 positionScreen : TEXCOORD6;
            half3 positionWS : TEXCOORD7;
            float4 vertexStream : TEXCOORD8;
#ifdef _ENABLE_NORMAL_ON
            DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 9);
#endif
        };

        struct FASurfaceData
        {
            half3 albedo;
            half3 normalTS;
            half  alpha;
        };

#ifdef _SUBUV_ANIM_ON
        inline float2 getSubUV(float frame, float totalFrameNum, float2 subUVdim, float2 uv)
        {
            float frameNum = floor(fmod(frame, totalFrameNum));
            // UV 坐标原点是左下角，纵向索引转坐标需要注意
            float indexU = fmod(frameNum, subUVdim.x);
            float indexV = subUVdim.y - floor(frameNum / subUVdim.x) - 1;
            return (float2(indexU, indexV) + uv)/ subUVdim;
        }

        inline float2 getMotionVector(half4 flowMapTex, float timeFrac, half distortion)
        {
            return (flowMapTex.rg * 2 - 1) * timeFrac * distortion;
        }
#endif

#ifdef _DEPTH_FADE_ON
        // 切边羽化（交界处透明）
        float GetDepthFade(float4 positionScreen)
        {
            if (_DepthFadeIntensity <= 0)
                return 1;
            float2 uvScreen = positionScreen.xy / positionScreen.w;
            float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uvScreen);
            float sceneZ =  LinearEyeDepth(depth, _ZBufferParams);
            float thisZ = positionScreen.z;
            float fade = saturate((sceneZ - thisZ - _DepthFadeOffset) / _DepthFadeIntensity);
            return fade;
        }
#endif

        inline FASurfaceData InitializeFASurfaceDataCustom(Varyings input)
        {
            float2 uvMain = input.uvMain.xy;
            float2 uvFlowMap = input.uvMain.zw;
            float2 uvMask = input.uvMask.xy;
            float2 uvDis = input.uvMask.zw;

            FASurfaceData outSurfaceData = (FASurfaceData)0;

            half intensity = lerp(_Intensity, input.vertexStream.x, _USE_VERTEX_STREAM);
            half4 albedo = input.color * _Color * intensity;
#ifdef _SUBUV_ANIM_ON
            half fps = _SubUV.x * _SubUV.y / _PlayTime;
            float frame = lerp(_Time.y, input.vertexStream.w, _USE_VERTEX_STREAM) * fps;
            float timeFrac = frac(frame);
            float totalFrameNum = _SubUV.x * _SubUV.y;
            float2 subUVMain1 = getSubUV(frame, totalFrameNum, _SubUV, uvMain);
            float nextFrame = frame + 1;
            // 使用custom data值来作为Time输入时，防止播放到最后回到第0帧
            nextFrame = lerp(nextFrame, min(nextFrame, totalFrameNum - 1), _USE_VERTEX_STREAM);
            float2 subUVMain2 = getSubUV(nextFrame, totalFrameNum, _SubUV, uvMain);

            half distortionStrength = _MotionDistortionStrength/2000;
            half4 flowMapTex1 = SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, subUVMain1);
            half4 flowMapTex2 = SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, subUVMain2);
            float2 uvMain1 = subUVMain1 - getMotionVector(flowMapTex1, timeFrac, distortionStrength);
            float2 uvMain2 = subUVMain2 + getMotionVector(flowMapTex2, 1-timeFrac, distortionStrength);
            half4 mainTexColor1 = PARTILE_TEXTURE2D(_MainTex, sampler_MainTex, uvMain1, _MainTex_ChannelMask);
            half4 mainTexColor2 = PARTILE_TEXTURE2D(_MainTex, sampler_MainTex, uvMain2, _MainTex_ChannelMask);
            albedo *= lerp(mainTexColor1, mainTexColor2, timeFrac);
            uvMain = subUVMain1;
#else
            half4 flowMapTex = SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, uvFlowMap);
            half flowPercent = lerp(_FlowPercent, input.vertexStream.z, _USE_VERTEX_STREAM);
            uvMain = lerp(uvMain, flowMapTex.rg, flowPercent);
            uvDis = lerp(uvDis, flowMapTex.rg, flowPercent);
            albedo *= PARTILE_TEXTURE2D(_MainTex, sampler_MainTex, uvMain, _MainTex_ChannelMask);
#endif //_SUBUV_ANIM_ON

            albedo *= SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uvMask);

#ifdef _DISSOLUTION_ON
            half disPercent = lerp(_DissolutionPercent, input.vertexStream.y, _USE_VERTEX_STREAM);
            albedo = GetDissolutionColor(albedo, uvDis, disPercent);
#endif

#ifdef _DEPTH_FADE_ON
            albedo.a *= GetDepthFade(input.positionScreen);
#endif

#ifdef _ALPHATEST_ON
        clip(albedo.a - _Cutoff);
#endif

#ifdef _ALPHAPREMULTIPLY_ON
            albedo.rgb *= albedo.a;
#endif
#ifndef NO_TPA
            albedo.a *= _TPA;
#endif

            outSurfaceData.albedo = albedo.rgb;
            outSurfaceData.alpha = albedo.a;
            half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uvMain);
            outSurfaceData.normalTS = UnpackNormalScale(n, _BumpScale);
            return outSurfaceData;
        }

#ifdef _ENABLE_NORMAL_ON
        half3 GetDiffuse(Light light, half3 normalDirection)
        {
            half3 lightDirection = normalize(light.direction);
            half NdotL = dot(normalDirection, lightDirection);
            half3 w = half3(_LightWrapping, _LightWrapping, _LightWrapping) * 0.5;        // Light wrapping
            half3 NdotLWrap = NdotL * (1.0 - w);
            half3 forwardLight = max(half3(0, 0, 0), NdotLWrap + w);
            half3 diffuse = forwardLight * light.color * light.distanceAttenuation * light.shadowAttenuation;
            return diffuse;
        }

        half4 outputStandardColor(FASurfaceData surfaceData, Varyings input)
        {
            half3 positionWS = input.positionWS.xyz;
            half3 normalWS = TransformTangentToWorld(surfaceData.normalTS,
                                half3x3(input.tangentWS, input.bitangentWS, input.normalWS));

            normalWS = NormalizeNormalPerPixel(normalWS);
            half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
            half3 bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, normalWS);

            Light mainLight = GetMainLight();

            half3 diffuse = bakedGI + GetDiffuse(mainLight, normalWS);

#ifdef _FORWARD_PLUS_Z_BINING
            half2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);
            bool isMatch;
            for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_LIGHTS); lightIndex++)
            {
                Light light = ForwardPlusGetAdditionalLight(lightIndex, positionWS, isMatch);
                if (isMatch)
                {
                    diffuse += GetDiffuse(light, normalWS);
                }
            }
            ClusteredLightLoop cll = ClusteredLightLoopInit(uvScreen, positionWS);
            while (ClusteredLightLoopNextWord(cll)) {
                while (ClusteredLightLoopNextLight(cll)) {
                    uint lightIndex = ClusteredLightLoopGetLightIndex(cll);
                    Light light = ForwardPlusGetAdditionalLight(lightIndex, positionWS, isMatch);
                    if (isMatch)
                    {
                        diffuse += GetDiffuse(light, normalWS);
                    }
                }
            }
#else
            // URP Lighting
            uint pixelLightCount = GetAdditionalLightsCount();
            for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
            {
                Light light = GetAdditionalLight(lightIndex, positionWS);
                diffuse += GetDiffuse(light, normalWS);
            }
#endif

            half3 colorLit = surfaceData.albedo * diffuse;// + bakedGI;

            return half4(colorLit, surfaceData.alpha);
        }
#endif

        Varyings vert (Attributes input)
        {
            Varyings output = (Varyings)0;
            VertexPositionInputs vertexInputs = GetVertexPositionInputs(input.positionOS.xyz);
            VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
            output.positionCS = vertexInputs.positionCS;
            output.color = input.color;
            output.positionWS = vertexInputs.positionWS;

            float2 uvMain = input.uvAndvs1xy.xy;
            output.uvMain.xy = TRANSFORM_TEX(uvMain, _MainTex);
            output.uvMain.zw = TRANSFORM_TEX(uvMain, _FlowMap);
            output.uvMask.xy = TRANSFORM_TEX(uvMain, _MaskTex);
            output.uvMask.zw = TRANSFORM_TEX(uvMain, _DissolutionTex);
            output.positionScreen = ComputeScreenPos(vertexInputs.positionCS);
            output.positionScreen.z = - vertexInputs.positionVS.z;
            output.normalWS = normalInputs.normalWS;
            output.tangentWS = normalInputs.tangentWS;
            output.bitangentWS = normalInputs.bitangentWS;
            output.vertexStream = float4(input.uvAndvs1xy.zw, input.vs1zw.xy);
#ifdef _ENABLE_NORMAL_ON
            OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
            OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
#endif
            return output;
        }

        half4 frag (Varyings input) : SV_Target
        {
            FASurfaceData surfaceData;
            surfaceData = InitializeFASurfaceDataCustom(input);
#ifdef _ENABLE_NORMAL_ON
            return outputStandardColor(surfaceData, input);
#else
            return half4(surfaceData.albedo, surfaceData.alpha);
#endif
        }
        ENDHLSL

        Pass
        {
            Name "Mole Flow Map"
            Tags { "LightMode" = "SceneEffect" }
            Blend [_SrcBlend] [_DstBlend]
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            
            //跳过TAA处理的Mask
            Stencil {
                Ref [_TAAStencil]
                WriteMask [_TAAStencilMask]
                Comp always
                Pass [_TAAStencilPassOperate]
            }

            HLSLPROGRAM
            ENDHLSL
        }

    }

   CustomEditor "LWGUI.LWGUI"
}