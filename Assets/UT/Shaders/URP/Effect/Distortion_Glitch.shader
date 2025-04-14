Shader "URP/MoleGame/Effects/Distortion_Glitch"
{
    Properties
    {
        _Intensity("全局效果强度（粒子透明度可控制）", Range( 0 , 1)) = 1
        [Toggle] _Noise_Direction("噪波反转开关", Float) = 0
        _TexNoise("TexNoise", 2D) = "white" {}
        [Channel(RGBASingleChannelMaskToVec4)]_TexNoiseChannelMask("TexNoise_R/A通道开关", Vector) = (1,0,0,0)
        _TexNoise_UV_Speed("TexNoise_UV_Speed", Vector) = (0.1,0,0,0)
        _TexMask("TexMask", 2D) = "white" {}
        [Channel(RGBASingleChannelMaskToVec4)]_TexMaskChannelMask("TexMask R/A通道开关", Vector) = (1,0,0,0)
        _TexMask_UV_Speed("TexMask UV Speed", Vector) = (0.1,0,0,0)
        _TexMask2("TexMask2", 2D) = "white" {}
        [Channel(RGBASingleChannelMaskToVec4)]_TexMask2ChannelMask("TexMask2 R/A通道开关", Vector) = (1,0,0,0)
        _TexMask_UV_Speed1("TexMask2 UV Speed", Vector) = (0.1,0,0,0)
        _AllDistortionIntensity("扭曲总强度", Range( 0 , 0.1)) = 0.1
        _TexNoise_Intensity("噪声纹理扭曲强度", Range( 0.01 , 1)) = 1
        _RGB_Intensity("RGB分离强度", Range( 0 , 1)) = 0
        _R_Offset("R_Offset（推荐0.6）", Range( -3 , 3)) = 0.6
        _G_Offset("G_Offset（推荐-0.2）", Range( -3 , 3)) = -0.2
        _B_Offset("B_Offset（推荐0.6）", Range( -3 , 3)) = 0.6

        [Main(_MasaicGroup)] _Mosaic("马赛克", Float) = 0
        [SubToggle(_MasaicGroup)] _Mosaic_Tex_Add("马赛克/噪声纹理扭曲 叠加开关", Float) = 0
        [SubToggle(_MasaicGroup)] _Mosaic_Posterize("马赛克分离 开关", Float) = 0
        [Sub(_MasaicGroup)]_Mosaic_Posterize_Control("马赛克分离 Control", Range( 0.01 , 1)) = 1
        [Sub(_MasaicGroup)]_Mosaic_Intensity("马赛克 强度", Range( 0 , 20)) = 1
        [Sub(_MasaicGroup)]_Mosaic_TilingOffset("马赛克 Tiling_Offset", Vector) = (1,5,0.15,0.15)
        [Sub(_MasaicGroup)]_Mosaic_UV_Speed("马赛克_UV_Speed", Vector) = (0.1,0,0,0)
        [Sub(_MasaicGroup)]_Noise_Scale("马赛克Noise_Scale(推荐30)", Float) = 30
        [Sub(_MasaicGroup)]_Mosaic_Pixel("马赛克_Pixel（推荐6）", Float) = 6
        [Sub(_MasaicGroup)]_Mosaic_Power("马赛克_Power", Range( 1 , 20)) = 1
        
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
        LOD 0

        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

        Cull Off

        HLSLINCLUDE
        #pragma target 2.0

        #pragma prefer_hlslcc gles
        #pragma exclude_renderers d3d11_9x

        ENDHLSL

        Pass
        {

            Name "Forward"
            Tags { "LightMode"="Distortion" }

            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            
            //跳过TAA处理的Mask
            Stencil {
                Ref [_TAAStencil]
                WriteMask [_TAAStencilMask]
                Comp always
                Pass [_TAAStencilPassOperate]
            }
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

            #pragma multi_compile_local _ _MOSAIC_ON

            struct VertexInput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
                float4 screenPos : TEXCOORD3;
                float4 uv : TEXCOORD4;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
            half _Noise_Direction;
            float4 _TexMask2_ST;
            float4 _TexNoise_ST;
            float4 _TexMask_ST;
            half4 _TexNoiseChannelMask;
            float4 _Mosaic_TilingOffset;
            half4 _TexMaskChannelMask;
            half4 _TexMask2ChannelMask;
            float2 _TexMask_UV_Speed;
            float2 _TexMask_UV_Speed1;
            float2 _TexNoise_UV_Speed;
            half _Mosaic_Tex_Add;
            half _Mosaic_Posterize;
            float2 _Mosaic_UV_Speed;
            float _Mosaic_Posterize_Control;
            float _Mosaic_Power;
            float _Intensity;
            float _AllDistortionIntensity;
            float _RGB_Intensity;
            float _R_Offset;
            float _G_Offset;
            float _B_Offset;
            float _Mosaic_Pixel;
            float _TexNoise_Intensity;
            float _Noise_Scale;
            float _Mosaic_Intensity;
            CBUFFER_END
            sampler2D _TexNoise;
            sampler2D _TexMask;
            sampler2D _TexMask2;
            sampler2D _DistortionLastCameraColorTexture;

            inline float4 ComputeGrabScreenPos( float4 pos )
            {
                #if UNITY_UV_STARTS_AT_TOP
                float scale = -1.0;
                #else
                float scale = 1.0;
                #endif
                float4 o = pos;
                o.y = pos.w * 0.5f;
                o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
                return o;
            }

            float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
            float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
            float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
            float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
            float snoise( float3 v )
            {
                const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
                float3 i = floor( v + dot( v, C.yyy ) );
                float3 x0 = v - i + dot( i, C.xxx );
                float3 g = step( x0.yzx, x0.xyz );
                float3 l = 1.0 - g;
                float3 i1 = min( g.xyz, l.zxy );
                float3 i2 = max( g.xyz, l.zxy );
                float3 x1 = x0 - i1 + C.xxx;
                float3 x2 = x0 - i2 + C.yyy;
                float3 x3 = x0 - 0.5;
                i = mod3D289( i);
                float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
                float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
                float4 x_ = floor( j / 7.0 );
                float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
                float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
                float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
                float4 h = 1.0 - abs( x ) - abs( y );
                float4 b0 = float4( x.xy, y.xy );
                float4 b1 = float4( x.zw, y.zw );
                float4 s0 = floor( b0 ) * 2.0 + 1.0;
                float4 s1 = floor( b1 ) * 2.0 + 1.0;
                float4 sh = -step( h, 0.0 );
                float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
                float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
                float3 g0 = float3( a0.xy, h.x );
                float3 g1 = float3( a0.zw, h.y );
                float3 g2 = float3( a1.xy, h.z );
                float3 g3 = float3( a1.zw, h.w );
                float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
                g0 *= norm.x;
                g1 *= norm.y;
                g2 *= norm.z;
                g3 *= norm.w;
                float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
                m = m* m;
                m = m* m;
                float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
                return 42.0 * dot( m, px);
            }

            VertexOutput VertexFunction ( VertexInput v  )
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
                float4 screenPos = ComputeScreenPos(ase_clipPos);
                o.screenPos = screenPos;

                o.uv.xy = v.texcoord.xy;
                o.color = v.color;

                //setting value to unused interpolator channels and avoid initialization warnings
                o.uv.zw = 0;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float4 positionCS = TransformWorldToHClip(positionWS);

                o.clipPos = positionCS;
                return o;
            }

            VertexOutput vert ( VertexInput v )
            {
                return VertexFunction( v );
            }

            half4 frag ( VertexOutput IN  ) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

                float globalIntensity = _Intensity * IN.color.a;

                float4 grabScreenPos = IN.screenPos;//ComputeGrabScreenPos(IN.screenPos);
                float4 grabScreenPosNorm = grabScreenPos / grabScreenPos.w;

                float2 uvTexNoise = IN.uv.xy * _TexNoise_ST.xy + _TexNoise_ST.zw;
                float2 offsetUVTexNoise = 1.0 * _Time.y * _TexNoise_UV_Speed + uvTexNoise;
                float4 noiseTexColor = tex2D(_TexNoise, offsetUVTexNoise);
                float directNoiseTexFactor = dot(noiseTexColor, _TexNoiseChannelMask);
                float noiseTexFactor = directNoiseTexFactor * _TexNoise_Intensity;

            #ifdef _MOSAIC_ON
                float2 mosaicTilingScale = float2(_Mosaic_TilingOffset.x , _Mosaic_TilingOffset.y);
                float2 mosaicTilingOffset = float2(_Mosaic_TilingOffset.z , _Mosaic_TilingOffset.w);
                float2 mosaicUV = IN.uv.xy * mosaicTilingScale + mosaicTilingOffset;

                float perlinNoiseFactor = snoise(float3(round( mosaicUV * _Mosaic_Pixel)/_Mosaic_Pixel + ( _Mosaic_UV_Speed * _TimeParameters.x ), 0.0 ) * _Noise_Scale);
                perlinNoiseFactor = perlinNoiseFactor * 0.5 + 0.5;

                float mosaicPosterizeDiv = 256.0 / float((int)(0.0 + (_Mosaic_Posterize_Control - 0.0) * (100.0 - 0.0) / (1.0 - 0.0)));
                float mosaicPosterizeFactor = floor(perlinNoiseFactor * mosaicPosterizeDiv) / mosaicPosterizeDiv;

                float tempMosaicFactor = lerp(perlinNoiseFactor, mosaicPosterizeFactor, _Mosaic_Posterize);

                float mosaicFactor = (pow(tempMosaicFactor , _Mosaic_Power) / 2.0) * _Mosaic_Intensity;
                float effectFactor = lerp(mosaicFactor, mosaicFactor + noiseTexFactor, _Mosaic_Tex_Add);
            #else
                float effectFactor = noiseTexFactor;
            #endif

                float noiseDirection = lerp(1, -1, _Noise_Direction);
                float2 distortedScreenPos = grabScreenPosNorm.xy + (effectFactor * 0.6 - 0.1) * globalIntensity * _AllDistortionIntensity * noiseDirection;
                float colorSplitIntensity = globalIntensity * _RGB_Intensity;
                float2 rOffset = float2(colorSplitIntensity * _R_Offset , 0.0);
                half screenColorR = tex2D(_DistortionLastCameraColorTexture, distortedScreenPos + rOffset * float2(0.01, 0)).r;
                float2 gOffset = float2(_G_Offset * colorSplitIntensity * 0.01, 0.0);
                half screenColorG = tex2D(_DistortionLastCameraColorTexture, distortedScreenPos + gOffset).g;
                float2 bOffset = float2(colorSplitIntensity * _B_Offset, 0.0);
                half screenColorB = tex2D(_DistortionLastCameraColorTexture, distortedScreenPos + bOffset * float2(0.01, 0)).b;
                half3 color = half3(screenColorR, screenColorG, screenColorB);

                float2 uvTexMask = IN.uv.xy * _TexMask_ST.xy + _TexMask_ST.zw;
                float2 offsetUVMask = _Time.y * _TexMask_UV_Speed + uvTexMask;
                half4 colorMask = tex2D(_TexMask, offsetUVMask);
                half maskFactor = dot(colorMask, _TexMaskChannelMask);
                float2 uvTexMask2 = IN.uv.xy * _TexMask2_ST.xy + _TexMask2_ST.zw;
                float2 offsetUVMask2 = _Time.y * _TexMask_UV_Speed1 + uvTexMask2;
                float4 colorMask2 = tex2D(_TexMask2, offsetUVMask2);
                half mask2Factor = dot(colorMask2, _TexMask2ChannelMask);

                float alpha = maskFactor * mask2Factor * directNoiseTexFactor;

                return half4(color, alpha);
            }

            ENDHLSL
        }

    }
    CustomEditor "LWGUI.LWGUI"
}
