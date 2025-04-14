Shader "URP/MoleGame/Effects/FlowMap"
{
    Properties
    {


        [Preset(GroupPreset,Standard_RenderingPreset)] _RenderMode ("Rendering Mode", Float) = 4
        [HideInInspector]_TransparentMode("__mode", Float) = 3.0
        [HideInInspector]_SrcBlend("__src", Float) = 1.0
        [HideInInspector]_DstBlend("__dst", Float) = 10.0
        //TransparentPremultipliedAlpha 半透明预乘Alpha参数，太长了改个缩写
        [HideInInspector]_TPA("__TPA", Float) = 1.0

        [Header(Cull Mode)]
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull (Default: Back)", Float) = 0

        _MainTex ("Texture", 2D) = "white" {}
        [Channel(RGBAChannelMaskToVec4)]_MainTex_ChannelMask("Main Texture Channel Mask (Default: RGBA)", Vector) = (1,1,1,1)
        [MainColor][Gamma][HDR]_Color("Main Color", Color) = (1,1,1,1)
        _Intensity("Intensity (Default: 1)", Float) = 1

        [HideInInspector]_Emissive_Intensity("Emissive Intensity", Range(0.0,100.0)) = 0.0
        [HideInInspector][HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)

        _MaskTex("Mask Texture", 2D) = "white" {}
        _FlowMap("Flow Map(RG) 贴图不要勾sRGB, Wrap Mode选Clamp", 2D) = "bump" {}
        _FlowPercent("Flow Percent", Range(0, 1)) = 0

        [Main(_DissolutionGroup, _DISSOLUTION_ON)]_Dissolution_On("Dissolution		(Default: Off)", Float) = 0
        [SubToggle(_DissolutionGroup)]_DissolutionTex_UVType("Dissolution Texture UV Type(Off:uv1,On:uv2)", float) = 0
        [Sub(_DissolutionGroup)]_DissolutionTex("Dissolution Texture", 2D) = "white" {}
        [Channel(_DissolutionGroup)]_DissolutionTex_ChannelMask("Dissolution Texture Channel Mask (Default: R)", Vector) = (1,0,0,0)
        [Sub(_DissolutionGroup)]_DissolutionTex_U("Dissolution Texture Speed U", Float) = 0
        [Sub(_DissolutionGroup)]_DissolutionTex_V("Dissolution Texture Speed V", Float) = 0
        [SubToggle(_DissolutionGroup)]_DissolutionReverse("Dissolution Reverse", Float) = 0
        [Sub(_DissolutionGroup)]_DissolutionPercent("Dissolution Percent", Range(0, 1.5)) = 0
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

        [Header(x Intensity   y Dissolution Percent   z Flow Percent)]
        [Toggle]_USE_VERTEX_STREAM("Use Vertex Stream", Float) = 0

        [Header(ZTest)]
        [Enum(MoleGame.Editor.TATools.ZTest)]_ZTest("ZTest (Default: LessEqual)", Float) = 4
        [Header(ZWrite)]
        [Toggle]_ZWrite("ZWrite (Default: Off)", Float) = 0

        [HideInInspector]_Stencil("Stencil Ref (Default: 0)", Float) = 0
        [HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("Stencil Comparison (Default: Disabled)", Float) = 0
        
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
        #pragma vertex vert
        #pragma fragment frag
        // make fog work
        //#pragma multi_compile_fog

        #pragma multi_compile_local _ _ALPHATEST_ON _ALPHAPREMULTIPLY_ON
        #pragma multi_compile_local _ _ENABLE_LIGHTS_ON
        #pragma multi_compile_local _ _DISSOLUTION_ON
        #pragma multi_compile_local _ _DEPTH_FADE_ON
        #pragma multi_compile_local _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature _ _FORWARD_PLUS_Z_BINING

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        TEXTURE2D(_MainTex);           SAMPLER(sampler_MainTex);
        TEXTURE2D(_MaskTex);           SAMPLER(sampler_MaskTex);
        TEXTURE2D(_FlowMap);           SAMPLER(sampler_FlowMap);
        TEXTURE2D(_DissolutionTex);    SAMPLER(sampler_DissolutionTex);
        TEXTURE2D(_CameraDepthTexture);    SAMPLER(sampler_CameraDepthTexture);

        CBUFFER_START(UnityPerMaterial)
        half4 _MainTex_ST;
        half4 _MaskTex_ST;
        half4 _FlowMap_ST;
        half4 _DissolutionTex_ST;
        half4 _MainTex_ChannelMask;
        half4 _Color;
        half  _Intensity;
        half  _Emissive_Intensity;
        half4 _EmissionColor;
        half  _Cutoff;
        half  _FlowPercent;

        half4 _DissolutionTex_ChannelMask;
        half _DissolutionTex_U;
        half _DissolutionTex_V;
        half _DissolutionReverse;
        half _DissolutionPercent;
        half _DissolutionSoftEdge;
        half _DissolutionEdgeWidth;
        half4 _DissolutionEdgeColor;

        half _DepthFadeIntensity;
        half _DepthFadeOffset;

        half _USE_VERTEX_STREAM;
        //预乘alpha参数
        #ifndef NO_TPA
            half _TPA;
        #endif
        CBUFFER_END

        #include "../FALib/FAEffectLib.hlsl"

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
            half4 positionWS : TEXCOORD7;
            float4 vertexStream : TEXCOORD8;
        };

        struct FASurfaceData
        {
            half3 albedo;
            half3 normalTS;
            half  alpha;
        };

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

            FASurfaceData outSurfaceData = (FASurfaceData)0;

            half intensity = lerp(_Intensity, input.vertexStream.x, _USE_VERTEX_STREAM);
            half4 albedo = input.color * _Color * intensity;

            float2 flowMapTex = SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, uvFlowMap).rg;
            half flowPercent = lerp(_FlowPercent, input.vertexStream.z, _USE_VERTEX_STREAM);
            // uvMain = lerp(uvMain, flowMapTex.rg, flowPercent);
            // 颜色值<128为负方向
            float2 flowDir = flowMapTex.rg * 2.0 - 1.0;
            uvMain = uvMain + flowPercent * flowDir;
            albedo *= PARTILE_TEXTURE2D(_MainTex, sampler_MainTex, uvMain, _MainTex_ChannelMask);
            albedo *= SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uvMask);

#ifdef _DISSOLUTION_ON
            float2 uvDis = input.uvMask.zw;
            uvDis = lerp(uvDis, flowMapTex.rg, flowPercent);
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
            return outSurfaceData;
        }

        Varyings vert (Attributes input)
        {
            Varyings output = (Varyings)0;
            VertexPositionInputs vertexInputs = GetVertexPositionInputs(input.positionOS.xyz);
            VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
            output.positionCS = vertexInputs.positionCS;
            output.color = input.color;

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
            return output;
        }

        half4 frag (Varyings input) : SV_Target
        {
            FASurfaceData surfaceData;
            surfaceData = InitializeFASurfaceDataCustom(input);

            return half4(surfaceData.albedo, surfaceData.alpha);
        }
        ENDHLSL

        Pass
        {
            Name "Mole Flow Map"
            Tags { "LightMode" = "SceneEffect" }
            Blend [_SrcBlend] [_DstBlend]
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            Cull [_Cull]

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

//        Pass
//        {
//            Name "DepthOnly"
//            Tags{"LightMode" = "DepthOnly"}
//            ZWrite On
//            ColorMask 0
//
//            HLSLPROGRAM
//            ENDHLSL
//
//        }

    }

   CustomEditor "LWGUI.LWGUI"
}