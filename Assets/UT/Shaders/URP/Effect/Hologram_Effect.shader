Shader "URP/MoleGame/Effects/Hologram"
{
	Properties
    {
        [HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
        [HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
        
        [MainColor][HDR]_MainColor("Main Color", Color) = (0.620945,1.420074,3.953349,0.05098039)
        [MainTexture]_MainTex("Main Texture", 2D) = "white" {}
        _Alpha("Alpha", Range( 0 , 1)) = 1
        _RandomOffset("Random Offset", Float) = 0
        [Toggle]_ZWrite("ZWrite", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 2
        
        //[KeywordEnum(World,Local,Custom)] _PositionSpaceFeature("Position Space Feature", Float) = 0
        [Enum(MoleGame.Editor.TATools.SpaceType)]_PositionSpaceFeature("Position Space Feature", Float) = 0
        //[KeywordEnum(World,Local)] _PositionSpaceFeature("Position Space Feature", Float) = 0
        [Enum(MoleGame.Editor.TATools.PositionAxis)] _PositionFeature("Position Feature", Float) = 1
        //[KeywordEnum(X,Y,Z)] _PositionFeature("Position Feature", Float) = 1

        _PositionDirection("Position Direction", Float) = 1
        
        [Main(_FresnelFeatureGroup)]_FresnelFeature("Fresnel Feature", Float) = 0
        [Sub(_FresnelFeatureGroup)]_FresnelRGBScale("Fresnel Scale", Float) = 1
        [Sub(_FresnelFeatureGroup)]_FresnelRGBPower("Fresnel Power", Float) = 2
        [Sub(_FresnelFeatureGroup)]_FresnelAlphaScale("Fresnel Alpha Scale", Float) = 1
        [Sub(_FresnelFeatureGroup)]_FresnelAlphaPower("Fresnel Alpha Power", Float) = 2
        
        [Main(_Line1Group)]_Line1Feature("Line 1 Feature", Float) = 0
        [Sub(_Line1Group)]_Line1("Line 1", 2D) = "white" {}
        [Sub(_Line1Group)]_Line1Speed("Line 1 Speed", Float) = -3.57
        [Sub(_Line1Group)]_Line1Frequency("Line 1 Frequency", Float) = 100
        [Sub(_Line1Group)]_Line1Hardness("Line 1 Hardness", Float) = 1.45
        [Sub(_Line1Group)]_Line1InvertedThickness("Line 1 Inverted Thickness", Range( 0 , 1)) = 0
        [Sub(_Line1Group)]_Line1Alpha("Line 1 Alpha", Float) = 0.15
        
        [Main(_Line2Group)] _Line2Feature("Line 2 Feature", Float) = 0
        [Sub(_Line2Group)]_Line2("Line 2", 2D) = "white" {}
        [Sub(_Line2Group)]_Line2Speed("Line 2 Speed", Float) = -1
        [Sub(_Line2Group)]_Line2Frequency("Line 2 Frequency", Float) = 1
        [Sub(_Line2Group)]_Line2Hardness("Line 2 Hardness", Float) = 2
        [Sub(_Line2Group)]_Line2InvertedThickness("Line 2 Inverted Thickness", Range( 0 , 1)) = 0.255
        [Sub(_Line2Group)]_Line2Alpha("Line 2 Alpha", Float) = 0.1
        
        [Main(_LineGlitchGroup)] _LineGlitchFeature("Line Glitch Feature", Float) = 0
        [Sub(_LineGlitchGroup)]_LineGlitch("Line Glitch", 2D) = "white" {}
        [Sub(_LineGlitchGroup)]_LineGlitchOffset("Line Glitch Offset", Vector) = (0.03,0,0,0)
        [Sub(_LineGlitchGroup)]_LineGlitchSpeed("Line Glitch Speed", Float) = -0.26
        [Sub(_LineGlitchGroup)]_LineGlitchFrequency("Line Glitch Frequency", Float) = 0.2
        [Sub(_LineGlitchGroup)]_LineGlitchHardness("Line Glitch Hardness", Float) = 5
        [Sub(_LineGlitchGroup)]_LineGlitchInvertedThickness("Line Glitch Inverted Thickness", Range( 0 , 1)) = 0.825
        
        [Main(_RandomGlitchGroup)] _RandomGlitchFeature("Random Glitch Feature", Float) = 0
        [Sub(_RandomGlitchGroup)]_RandomGlitchOffset("Random Glitch Offset", Vector) = (-0.5,0,0,0)
        [Sub(_RandomGlitchGroup)]_RandomGlitchAmount("Random Glitch Amount", Range( 0 , 1)) = 0.089
        [Sub(_RandomGlitchGroup)]_RandomGlitchConstant("Random Glitch Constant", Range( 0 , 1)) = 0
        [Sub(_RandomGlitchGroup)]_RandomGlitchTiling("Random Glitch Tiling", Float) = 2.83
        
        [Main(_ColorGlitchGroup)] _ColorGlitchFeature("Color Glitch Feature", Float) = 0
        [Sub(_ColorGlitchGroup)]_ColorGlitchAffect("Color Glitch Affect", Range( 0 , 1)) = 0.5
        
        [Main(_GrainGroup)] _GrainFeature("Grain Feature", Float) = 0
        [Sub(_GrainGroup)]_GrainScale("Grain Scale", Vector) = (50,50,50,0)
        [Sub(_GrainGroup)]_GrainAffect("Grain Affect", Range( 0 , 1)) = 1
        [Sub(_GrainGroup)]_GrainValues("Grain Values", Vector) = (0,1,0,0)	
        
        [Main(_NormalMapGroup)] _NormalMapFeature("Normal Map Feature", Float) = 0
        [Sub(_NormalMapGroup)]_NormalMap("NormalMap", 2D) = "bump" {}	
        [Sub(_NormalMapGroup)]_NormalScale("NormalScale", Float) = 0
        [Sub(_NormalMapGroup)]_NormalAffect("NormalAffect", Range( 0 , 1)) = 0
        
//		[KeywordEnum(Off,Alpha,Color)] _SoftIntersection1Feature("Soft Intersection 1 Feature", Float) = 0
//		_SoftIntersection1Distance("Soft Intersection 1 Distance", Float) = 0
//		_SoftIntersection1Intensity("Soft Intersection 1 Intensity", Float) = 1
//		_SoftIntersection1Affect("Soft Intersection 1 Affect", Range( 0 , 1)) = 1
//		
//		[KeywordEnum(Off,Alpha,Color)] _SoftIntersection2Feature("Soft Intersection 2 Feature", Float) = 0
//		_SoftIntersection2Distance("Soft Intersection 2 Distance", Float) = 0
//		_SoftIntersection2Intensity("Soft Intersection 2 Intensity", Float) = 1
//		_SoftIntersection2Affect("Soft Intersection 2 Affect", Range( 0 , 1)) = 1
        
        [Main(_DissolveGroup)] _DissolveFeature("Dissolve Feature", Float) = 0
        [Sub(_DissolveGroup)]_DissolveScale("Dissolve Scale", Vector) = (0.1,1.01,5,0)
        [Sub(_DissolveGroup)]_DissolveHide("Dissolve Hide", Range( -1 , 1)) = -1
        
        [Main(_MaskFeatureGroup)] _MaskFeature("Mask Feature", Float) = 0
        [SubToggle(_MaskFeatureGroup)]_MaskLocalFeature("Mask Local Feature", Float) = 0
        [Sub(_MaskFeatureGroup)]_MaskCenter("Mask Center", Vector) = (0,0,0,0)
        [Sub(_MaskFeatureGroup)]_MaskSize("Mask Size", Vector) = (0,0,0,0)
        [Sub(_MaskFeatureGroup)]_MaskFalloff("Mask Falloff", Float) = 0
        [Sub(_MaskFeatureGroup)]_MaskInversion("Mask Inversion", Range( 0 , 1)) = 0
        
        [Main(_AlphaMaskGroup)] _AlphaMaskFeature("Alpha Mask Feature", Float) = 0
        [Sub(_AlphaMaskGroup)]_AlphaMask("Alpha Mask", 2D) = "white" {}
        [Sub(_AlphaMaskGroup)]_AlphaMaskAffect("Alpha Mask Affect", Range( 0 , 1)) = 0.5

        [Main(_VoxelizationGroup)] _VoxelizationFeature("Voxelization Feature", Float) = 0
        [Sub(_VoxelizationGroup)]_Voxelization("Voxelization", Float) = 100
        [Sub(_VoxelizationGroup)]_VoxelizationAffect("Voxelization Affect", Range( 0 , 1)) = 1
        
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
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        
        
        Pass
        {
            //Tags{"LightMode" = "SceneEffect" }
            HLSLINCLUDE
            #pragma target 3.0
            ENDHLSL
            Blend SrcAlpha OneMinusSrcAlpha
            AlphaToMask Off
            Cull [_CullMode]
            ColorMask RGBA
            ZWrite [_ZWrite]
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            
            
            //#include "UnityCG.cginc"
            //#include "UnityShaderVariables.cginc"
            //#include "UnityStandardUtils.cginc"
            //#define ASE_NEEDS_VERT_POSITION
            //#define ASE_NEEDS_VERT_NORMAL
            //#define ASE_NEEDS_FRAG_POSITION
            //#pragma shader_feature _VOXELIZATIONFEATURE_ON
            //#pragma shader_feature _LINEGLITCHFEATURE_ON
            //#pragma shader_feature _POSITIONSPACEFEATURE_WORLD _POSITIONSPACEFEATURE_LOCAL _POSITIONSPACEFEATURE_CUSTOM
            //#pragma shader_feature _POSITIONSPACEFEATURE_WORLD _POSITIONSPACEFEATURE_LOCAL
            //#pragma shader_feature _POSITIONFEATURE_X _POSITIONFEATURE_Y _POSITIONFEATURE_Z
            //#pragma multi_compile_instancing
            //#pragma shader_feature _RANDOMGLITCHFEATURE_ON
            //#pragma shader_feature _COLORGLITCHFEATURE_ON
            //#pragma shader_feature _FRESNELFEATURE_ON
            //#pragma shader_feature _NORMALMAPFEATURE_ON
            //#pragma shader_feature _LINEBOTHFEATURE_ON
            //#pragma shader_feature _LINE2FEATURE_ON
            ///#pragma shader_feature _LINE1FEATURE_ON
            //#pragma shader_feature _SOFTINTERSECTION1FEATURE_OFF _SOFTINTERSECTION1FEATURE_ALPHA _SOFTINTERSECTION1FEATURE_COLOR
            //#pragma shader_feature _GRAINFEATURE_ON
            //#pragma shader_feature _SOFTINTERSECTION2FEATURE_OFF _SOFTINTERSECTION2FEATURE_ALPHA _SOFTINTERSECTION2FEATURE_COLOR
            //#pragma shader_feature _DISSOLVEFEATURE_ON
            //#pragma shader_feature _MASKFEATURE_ON
            //#pragma shader_feature _MASKLOCALFEATURE_ON
            //#pragma shader_feature _ALPHAMASKFEATURE_ON


            TEXTURE2D(_LineGlitch);				SAMPLER(sampler_LineGlitch);
            TEXTURE2D(_MainTex);				SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);				SAMPLER(sampler_NormalMap);
            TEXTURE2D(_Line1);				    SAMPLER(sampler_Line1);
            TEXTURE2D(_Line2);				    SAMPLER(sampler_Line2);
            TEXTURE2D(_CameraDepthTexture);		SAMPLER(sampler_CameraDepthTexture);
            TEXTURE2D(_AlphaMask);		        SAMPLER(sampler_AlphaMask);
            
            CBUFFER_START(UnityPerMaterial)
            float _ZWrite;
            float _CullMode;
            float3 _LineGlitchOffset;
            //uniform sampler2D _LineGlitch;
            float4 _LineGlitch_ST;
            float _PositionDirection;
            float _LineGlitchFrequency;
            float _LineGlitchSpeed;
            float _RandomOffset;
            float _LineGlitchInvertedThickness;
            float _LineGlitchHardness;
            float3 _RandomGlitchOffset;
            float _RandomGlitchTiling;
            float _RandomGlitchConstant;
            float _RandomGlitchAmount;
            float _Voxelization;
            float _VoxelizationAffect;
            float _ColorGlitchAffect;
            //uniform sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;
            //uniform float _FresnelScale;
            float _FresnelRGBScale;
            //uniform float _FresnelPower;
            float _FresnelRGBPower;
            //uniform sampler2D _NormalMap;
            float4 _NormalMap_ST;
            float _NormalScale;
            float _NormalAffect;
            float _FresnelAlphaScale;
            float _FresnelAlphaPower;
            //uniform sampler2D _Line1;
            float4 _Line1_ST;
            float _Line1Frequency;
            float _Line1Speed;
            float _Line1InvertedThickness;
            float _Line1Hardness;
            float _Line1Alpha;
            //uniform sampler2D _Line2;
            float4 _Line2_ST;
            float _Line2Frequency;
            float _Line2Speed;
            float _Line2InvertedThickness;
            float _Line2Hardness;
            float _Line2Alpha;
            //UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
            //uniform sampler2D _CameraDepthTexture;
            float4 _CameraDepthTexture_TexelSize;
            float _SoftIntersection1Distance;
            float _SoftIntersection1Intensity;
            float _SoftIntersection1Affect;
            float2 _GrainValues;
            float3 _GrainScale;
            float _GrainAffect;
            float _SoftIntersection2Distance;
            float _SoftIntersection2Intensity;
            float _SoftIntersection2Affect;
            float3 _DissolveScale;
            float _DissolveHide;
            float3 _MaskCenter;
            float3 _MaskSize;
            float _MaskFalloff;
            float _MaskInversion;
            //uniform sampler2D _AlphaMask;
            float4 _AlphaMask_ST;
            float _AlphaMaskAffect;
            float _Alpha;
            //uniform float4x4 _CustomMatrix;

            // switcher
            half _VoxelizationFeature;
            half _LineGlitchFeature;
            half _RandomGlitchFeature;
            half _ColorGlitchFeature;
            half _FresnelFeature;
            half _NormalMapFeature;
            half _Line2Feature;
            half _Line1Feature;
            half _GrainFeature;
            half _DissolveFeature;
            half _MaskFeature;
            half _AlphaMaskFeature;
            half _PositionFeature;
            half _PositionSpaceFeature;
            CBUFFER_END
            
            
//			UNITY_INSTANCING_BUFFER_START(KnifeHologramShaderUnlit)
//				UNITY_DEFINE_INSTANCED_PROP(float4x4, _CustomMatrix)
//#define _CustomMatrix_arr KnifeHologramShaderUnlit
//				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
//#define _MainTex_ST_arr KnifeHologramShaderUnlit
//				UNITY_DEFINE_INSTANCED_PROP(float4, _NormalMap_ST)
//#define _NormalMap_ST_arr KnifeHologramShaderUnlit
//				UNITY_DEFINE_INSTANCED_PROP(float4, _AlphaMask_ST)
//#define _AlphaMask_ST_arr KnifeHologramShaderUnlit
//			UNITY_INSTANCING_BUFFER_END(KnifeHologramShaderUnlit)
            float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
            float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
            float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
            float snoise( float2 v )
            {
                const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
                float2 i = floor( v + dot( v, C.yy ) );
                float2 x0 = v - i + dot( i, C.xx );
                float2 i1;
                i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
                float4 x12 = x0.xyxy + C.xxzz;
                x12.xy -= i1;
                i = mod2D289( i );
                float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
                float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
                m = m * m;
                m = m * m;
                float3 x = 2.0 * frac( p * C.www ) - 1.0;
                float3 h = abs( x ) - 0.5;
                float3 ox = floor( x + 0.5 );
                float3 a0 = x - ox;
                m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
                float3 g;
                g.x = a0.x * x0.x + h.x * x0.y;
                g.yz = a0.yz * x12.xz + h.yz * x12.yw;
                return 130.0 * dot( m, g );
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
            


            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 ase_texcoord : TEXCOORD0;
                float4 ase_tangent : TANGENT;
                float4 ase_color : COLOR;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
                float4 ase_texcoord1 : TEXCOORD1;
                float4 ase_texcoord2 : TEXCOORD2;
                float4 ase_texcoord3 : TEXCOORD3;
                float4 ase_texcoord4 : TEXCOORD4;
                float4 ase_texcoord5 : TEXCOORD5;
                float4 ase_texcoord6 : TEXCOORD6;
                float4 ase_texcoord7 : TEXCOORD7;
                float4 ase_texcoord8 : TEXCOORD8;
                float4 ase_color : COLOR;
            };
            
            v2f vert ( appdata v )
            {
                v2f o = (v2f)0;
                //UNITY_INITIALIZE_OUTPUT(v2f,o);
                //UNITY_SETUP_INSTANCE_ID(v);
                //UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                //UNITY_TRANSFER_INSTANCE_ID(v, o);
                
                float C_ZERO287 = 0.0;
                float3 temp_cast_0 = (C_ZERO287).xxx;
                float3 viewToObjDir94 = mul( UNITY_MATRIX_T_MV, float4( _LineGlitchOffset, 0 ) ).xyz;
                float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
                float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float staticSwitch350 = ase_worldPos.y;
                float staticSwitch351 = v.vertex.xyz.y;
                if(_PositionFeature == 0) // X
                {
                    staticSwitch350 = ase_worldPos.x;
                    staticSwitch351 = v.vertex.xyz.x;
                }
                else if(_PositionFeature == 1) // Y
                {
                    staticSwitch350 = ase_worldPos.y;
                    staticSwitch351 = v.vertex.xyz.y;
                }
                else if(_PositionFeature == 2) // Z
                {
                    staticSwitch350 = ase_worldPos.z;
                    staticSwitch351 = v.vertex.xyz.z;
                }
                // #if defined(_POSITIONFEATURE_X)
                // float staticSwitch350 = ase_worldPos.x;
                // #elif defined(_POSITIONFEATURE_Y)
                // float staticSwitch350 = ase_worldPos.y;
                // #elif defined(_POSITIONFEATURE_Z)
                // float staticSwitch350 = ase_worldPos.z;
                // #else
                // float staticSwitch350 = ase_worldPos.y;
                // #endif
                // #if defined(_POSITIONFEATURE_X)
                // float staticSwitch351 = v.vertex.xyz.x;
                // #elif defined(_POSITIONFEATURE_Y)
                // float staticSwitch351 = v.vertex.xyz.y;
                // #elif defined(_POSITIONFEATURE_Z)
                // float staticSwitch351 = v.vertex.xyz.z;
                // #else
                // float staticSwitch351 = v.vertex.xyz.y;
                // #endif
                //float3 temp_output_377_0 = mul( _CustomMatrix, float4( v.vertex.xyz , 0.0 ) ).xyz;
                //float3 break379 = temp_output_377_0;
                //#if defined(_POSITIONFEATURE_X)
                //float staticSwitch378 = break379.x;
                //#elif defined(_POSITIONFEATURE_Y)
                //float staticSwitch378 = break379.y;
                //#elif defined(_POSITIONFEATURE_Z)
                //float staticSwitch378 = break379.z;
                //#else
                //float staticSwitch378 = break379.y;
                //#endif

                float staticSwitch352 = staticSwitch350;
                
                if(_PositionSpaceFeature == 0) // world
                {
                    staticSwitch352 = staticSwitch350;
                }
                else if(_PositionSpaceFeature == 1) // local
                {
                    staticSwitch352 = staticSwitch351;
                }
                // #if defined(_POSITIONSPACEFEATURE_WORLD)
                // float staticSwitch352 = staticSwitch350;
                // #elif defined(_POSITIONSPACEFEATURE_LOCAL)
                // float staticSwitch352 = staticSwitch351;
                // //#elif defined(_POSITIONSPACEFEATURE_CUSTOM)
                // //float staticSwitch352 = staticSwitch378;
                // #else
                // float staticSwitch352 = staticSwitch350;
                // #endif
                float vertexToFrag497 = ( staticSwitch352 * _PositionDirection );
                float pos353 = vertexToFrag497;
                float mulTime3_g146 = _Time.y * _LineGlitchSpeed;
                float randomoffset385 = _RandomOffset;
                float2 temp_cast_3 = ((pos353*_LineGlitchFrequency + ( mulTime3_g146 + randomoffset385 ))).xx;
                //float clampResult42_g146 = clamp( ( ( tex2Dlod( _LineGlitch, float4( temp_cast_3, 0, 0.0) ).r - _LineGlitchInvertedThickness ) * _LineGlitchHardness ) , 0.0 , 1.0 );
                //float clampResult42_g146 = clamp( ( ( tex2Dlod( sampler_LineGlitch, float4( temp_cast_3, 0, 0.0) ).r - _LineGlitchInvertedThickness ) * _LineGlitchHardness ) , 0.0 , 1.0 );
                float clampResult42_g146 = clamp(((SAMPLE_TEXTURE2D_X_LOD(_LineGlitch, sampler_LineGlitch, float4( temp_cast_3, 0, 0.0) , 0).r - _LineGlitchInvertedThickness) * _LineGlitchHardness), 0.0, 1.0);

                float3 staticSwitch307 = _LineGlitchFeature ? ( ( viewToObjDir94 / ase_objectScale ) * clampResult42_g146 ) : temp_cast_0;

                // #ifdef _LINEGLITCHFEATURE_ON
                // float3 staticSwitch307 = ( ( viewToObjDir94 / ase_objectScale ) * clampResult42_g146 );
                // #else
                // float3 staticSwitch307 = temp_cast_0;
                // #endif

                
                float3 lineglitch491 = staticSwitch307;
                float3 temp_cast_4 = (C_ZERO287).xxx;
                float3 viewToObjDir122 = mul( UNITY_MATRIX_T_MV, float4( _RandomGlitchOffset, 0 ) ).xyz;
                float mulTime149 = _Time.y * -2.3;
                float mulTime155 = _Time.y * -2.05;
                float2 appendResult153 = (float2((pos353*_RandomGlitchTiling + ( mulTime149 + randomoffset385 )) , ( randomoffset385 + mulTime155 )));
                float simplePerlin2D186 = snoise( appendResult153 );
                simplePerlin2D186 = simplePerlin2D186*0.5 + 0.5;
                float4 matrixToPos373 = float4( float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[0][3],float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[1][3],float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[2][3],float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[3][3]);

                float staticSwitch365 = ( matrixToPos373.x + matrixToPos373.y + matrixToPos373.z );
                if(_PositionSpaceFeature == 0) // world
                {
                    staticSwitch365 = ( matrixToPos373.x + matrixToPos373.y + matrixToPos373.z );
                }
                else if(_PositionSpaceFeature == 1) // local
                {
                    staticSwitch365 = C_ZERO287;
                }
                // #if defined(_POSITIONSPACEFEATURE_WORLD)
                // float staticSwitch365 = ( matrixToPos373.x + matrixToPos373.y + matrixToPos373.z );
                // #elif defined(_POSITIONSPACEFEATURE_LOCAL)
                // float staticSwitch365 = C_ZERO287;
                // //#elif defined(_POSITIONSPACEFEATURE_CUSTOM)
                // //float staticSwitch365 = 0.0;
                // #else
                // float staticSwitch365 = ( matrixToPos373.x + matrixToPos373.y + matrixToPos373.z );
                // #endif
                float mulTime139 = _Time.y * -5.74;
                float mulTime157 = _Time.y * -0.83;
                float2 appendResult158 = (float2((staticSwitch365*223.0 + ( mulTime139 + randomoffset385 )) , ( randomoffset385 + mulTime157 )));
                float simplePerlin2D187 = snoise( appendResult158 );
                simplePerlin2D187 = simplePerlin2D187*0.5 + 0.5;
                float clampResult148 = clamp( (-1.0 + (( simplePerlin2D187 + _RandomGlitchConstant ) - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , 0.0 , 1.0 );
                float temp_output_197_0 = ( (-1.0 + (simplePerlin2D186 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * clampResult148 );
                float2 break190 = appendResult153;
                float2 appendResult195 = (float2(( 20.0 * break190.x ) , break190.y));
                float simplePerlin2D188 = snoise( appendResult195 );
                simplePerlin2D188 = simplePerlin2D188*0.5 + 0.5;
                float clampResult192 = clamp( (-1.0 + (simplePerlin2D188 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , 0.0 , 1.0 );
                float lerpResult199 = lerp( 0.0 , clampResult192 , 2.0);
                float3 staticSwitch311 =  _RandomGlitchFeature ? ( ( viewToObjDir122 / ase_objectScale ) * ( temp_output_197_0 + ( temp_output_197_0 * lerpResult199 ) ) * _RandomGlitchAmount ) : temp_cast_4;

                // #ifdef _RANDOMGLITCHFEATURE_ON
                // float3 staticSwitch311 = ( ( viewToObjDir122 / ase_objectScale ) * ( temp_output_197_0 + ( temp_output_197_0 * lerpResult199 ) ) * _RandomGlitchAmount );
                // #else
                // float3 staticSwitch311 = temp_cast_4;
                // #endif
                
                float3 randomglitch493 = staticSwitch311;
                float3 vertexoffset410 = ( lineglitch491 + randomglitch493 );
                float3 temp_output_512_0 = ( v.vertex.xyz + vertexoffset410 );
                float3 lerpResult517 = lerp( temp_output_512_0 , ( round( ( temp_output_512_0 * _Voxelization ) ) / _Voxelization ) , _VoxelizationAffect);
                float3 staticSwitch518 = _VoxelizationFeature ? lerpResult517 : temp_output_512_0;
                // #ifdef _VOXELIZATIONFEATURE_ON
                // float3 staticSwitch518 = lerpResult517;
                // #else
                // float3 staticSwitch518 = temp_output_512_0;
                // #endif
                float3 ModifiedVertexPosition519 = staticSwitch518;
                
                o.ase_texcoord2.xyz = ase_worldPos;
                float3 ase_worldNormal = TransformObjectToWorldNormal(v.normal);
                o.ase_texcoord3.xyz = ase_worldNormal;
                float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent);
                o.ase_texcoord4.xyz = ase_worldTangent;
                float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
                float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
                o.ase_texcoord5.xyz = ase_worldBitangent;
                o.ase_texcoord1.z = vertexToFrag497;
                float3 vertexPos238 = ( v.vertex.xyz + vertexoffset410 );
                float4 ase_clipPos238 = TransformObjectToHClip(vertexPos238);
                float4 screenPos238 = ComputeScreenPos(ase_clipPos238);
                o.ase_texcoord6 = screenPos238;
                float3 vertexPos417 = ( v.vertex.xyz + vertexoffset410 );
                float4 ase_clipPos417 = TransformObjectToHClip(vertexPos417);
                float4 screenPos417 = ComputeScreenPos(ase_clipPos417);
                o.ase_texcoord7 = screenPos417;
                
                o.ase_texcoord1.xy = v.ase_texcoord.xy;
                o.ase_texcoord8 = v.vertex;
                o.ase_color = v.ase_color;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord1.w = 0;
                o.ase_texcoord2.w = 0;
                o.ase_texcoord3.w = 0;
                o.ase_texcoord4.w = 0;
                o.ase_texcoord5.w = 0;
                
                v.vertex.xyz = ModifiedVertexPosition519;
                o.pos = TransformObjectToHClip(v.vertex);
                return o;
            }
            
            float4 frag (v2f i ) : SV_Target
            {
                float4 outColor;

                float3 objToWorld161 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
                float C_ZERO287 = 0.0;

                float staticSwitch360 = ( objToWorld161.x + objToWorld161.y + objToWorld161.z );
                if(_PositionSpaceFeature == 0)  // world
                {
                    staticSwitch360 = ( objToWorld161.x + objToWorld161.y + objToWorld161.z );
                }
                else if(_PositionSpaceFeature == 1) //local
                {
                    staticSwitch360 = C_ZERO287;
                }
                // #if defined(_POSITIONSPACEFEATURE_WORLD)
                // float staticSwitch360 = ( objToWorld161.x + objToWorld161.y + objToWorld161.z );
                // #elif defined(_POSITIONSPACEFEATURE_LOCAL)
                // float staticSwitch360 = C_ZERO287;
                // //#elif defined(_POSITIONSPACEFEATURE_CUSTOM)
                // //float staticSwitch360 = 0.0;
                // #else
                // float staticSwitch360 = ( objToWorld161.x + objToWorld161.y + objToWorld161.z );
                // #endif
                float randomoffset385 = _RandomOffset;
                float mulTime165 = _Time.y * -15.0;
                float mulTime167 = _Time.y * -0.5;
                float2 appendResult168 = (float2((staticSwitch360*223.0 + ( randomoffset385 + mulTime165 )) , ( randomoffset385 + mulTime167 )));
                float simplePerlin2D176 = snoise( appendResult168 );
                simplePerlin2D176 = simplePerlin2D176*0.5 + 0.5;
                float clampResult175 = clamp( (-0.61 + (simplePerlin2D176 - 0.0) * (2.0 - -0.61) / (1.0 - 0.0)) , 0.0 , 1.0 );
                float lerpResult181 = lerp( 1.0 , clampResult175 , _ColorGlitchAffect);
                float staticSwitch279 = _ColorGlitchFeature ? lerpResult181 : 1.0;

                // #ifdef _COLORGLITCHFEATURE_ON
                // float staticSwitch279 = lerpResult181;
                // #else
                // float staticSwitch279 = 1.0;
                // #endif
                //float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_MainTex_ST_arr, _MainTex_ST);
                //float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
                //float4 maincolor232 = ( tex2D( _MainTex, uv_MainTex ) * _MainColor );
                float4 maincolor232 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(i.ase_texcoord1.xy, _MainTex)) * _MainColor;
                float C_ONE288 = 1.0;
                float3 ase_worldPos = i.ase_texcoord2.xyz;
                //float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
                float3 ase_worldViewDir = _WorldSpaceCameraPos.xyz - ase_worldPos;
                ase_worldViewDir = normalize(ase_worldViewDir);
                float3 ase_worldNormal = normalize(i.ase_texcoord3.xyz);
                float fresnelNdotV2 = dot( ase_worldNormal, ase_worldViewDir );
                //float fresnelNode2 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV2, _FresnelPower ) );
                float fresnelNode2 = (0.0 + _FresnelRGBScale * pow(1.0 - fresnelNdotV2, _FresnelRGBPower));
                //float4 _NormalMap_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_NormalMap_ST_arr, _NormalMap_ST);
                //float2 uv_NormalMap = i.ase_texcoord1.xy * _NormalMap_ST_Instance.xy + _NormalMap_ST_Instance.zw;
                float3 ase_worldTangent = i.ase_texcoord4.xyz;
                float3 ase_worldBitangent = i.ase_texcoord5.xyz;
                float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
                float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
                float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
                float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
                ase_tanViewDir = normalize(ase_tanViewDir);
                //float dotResult101 = dot( UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale ) , ase_tanViewDir );
                //float dotResult101 = dot(UnpackNormalScale(tex2D( _NormalMap, uv_NormalMap ), _NormalScale), ase_tanViewDir);
                float dotResult101 = dot(UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, TRANSFORM_TEX(i.ase_texcoord1.xy, _NormalMap)), _NormalScale), ase_tanViewDir);
                float lerpResult106 = lerp( 1.0 , (0.0 + (dotResult101 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , _NormalAffect);
                float staticSwitch341 = _NormalMapFeature ? ( 1.0 - lerpResult106 ) : C_ZERO287;
                // #ifdef _NORMALMAPFEATURE_ON
                // float staticSwitch341 = ( 1.0 - lerpResult106 );
                // #else
                // float staticSwitch341 = C_ZERO287;
                // #endif
                float NormalAffect116 = staticSwitch341;
                float staticSwitch303 = _FresnelFeature ? ( fresnelNode2 + NormalAffect116 ) : C_ONE288;
                // #ifdef _FRESNELFEATURE_ON
                // float staticSwitch303 = ( fresnelNode2 + NormalAffect116 );
                // #else
                // float staticSwitch303 = C_ONE288;
                // #endif
                float fresnelNdotV53 = dot( ase_worldNormal, ase_worldViewDir );
                float fresnelNode53 = ( 0.0 + _FresnelAlphaScale * pow( 1.0 - fresnelNdotV53, _FresnelAlphaPower ) );
                float staticSwitch305 = _FresnelFeature ? fresnelNode53 : C_ZERO287;
                // #ifdef _FRESNELFEATURE_ON
                // float staticSwitch305 = fresnelNode53;
                // #else
                // float staticSwitch305 = C_ZERO287;
                // #endif
                float clampResult57 = clamp( ( staticSwitch305 + NormalAffect116 ) , 0.0 , 1.0 );
                float4 fresnelcolor436 = ( staticSwitch303 * maincolor232 * clampResult57 );
                float4 temp_cast_0 = (C_ZERO287).xxxx;
                float vertexToFrag497 = i.ase_texcoord1.z;
                float pos353 = vertexToFrag497;
                float mulTime3_g163 = _Time.y * _Line1Speed;
                float2 temp_cast_1 = ((pos353*_Line1Frequency + ( mulTime3_g163 + randomoffset385 ))).xx;
                //float clampResult42_g163 = clamp( ( ( tex2D( _Line1, temp_cast_1 ).r - _Line1InvertedThickness ) * _Line1Hardness ) , 0.0 , 1.0 );
                float clampResult42_g163 = clamp( ( (SAMPLE_TEXTURE2D(_Line1, sampler_Line1, temp_cast_1).r - _Line1InvertedThickness ) * _Line1Hardness ) , 0.0 , 1.0 );
                float temp_output_477_0 = clampResult42_g163;
                float3 temp_output_293_0 = (( maincolor232 * temp_output_477_0 )).rgb;
                float temp_output_61_0 = ( temp_output_477_0 * _Line1Alpha );
                float4 appendResult292 = (float4(temp_output_293_0 , temp_output_61_0));
                float4 staticSwitch284 = _Line1Feature ? appendResult292 : temp_cast_0;
                // #ifdef _LINE1FEATURE_ON
                // float4 staticSwitch284 = appendResult292;
                // #else
                // float4 staticSwitch284 = temp_cast_0;
                // #endif
                float mulTime3_g164 = _Time.y * _Line2Speed;
                float2 temp_cast_2 = ((pos353*_Line2Frequency + ( mulTime3_g164 + randomoffset385 ))).xx;
                //float clampResult42_g164 = clamp( ( ( tex2D( _Line2, temp_cast_2 ).r - _Line2InvertedThickness ) * _Line2Hardness ) , 0.0 , 1.0 );
                float clampResult42_g164 = clamp( ( ( SAMPLE_TEXTURE2D(_Line2, sampler_Line2, temp_cast_2).r - _Line2InvertedThickness ) * _Line2Hardness ) , 0.0 , 1.0 );
                float temp_output_476_0 = clampResult42_g164;
                float3 temp_output_294_0 = (( maincolor232 * temp_output_476_0 )).rgb;
                float temp_output_69_0 = ( temp_output_476_0 * _Line2Alpha );
                float4 appendResult295 = (float4(temp_output_294_0 , temp_output_69_0));

                float4 staticSwitch285 = _Line2Feature ? appendResult295 : staticSwitch284;
                
                // #ifdef _LINE2FEATURE_ON
                // float4 staticSwitch285 = appendResult295;
                // #else
                // float4 staticSwitch285 = staticSwitch284;
                // #endif
                float4 appendResult328 = (float4(0.0 , 0.0 , 0.0 , temp_output_61_0));
                float4 appendResult296 = (float4(( temp_output_293_0 * temp_output_294_0 ) , ( temp_output_61_0 * temp_output_69_0 )));
                //#ifdef _LINEBOTHFEATURE_ON
                    
                //float4 staticSwitch286 = ( appendResult328 + appendResult296 );
                //#else
                float4 staticSwitch286 = staticSwitch285;
                //#endif
                float4 line_color298 = staticSwitch286;
                float4 temp_cast_4 = (C_ZERO287).xxxx;
                float4 temp_cast_5 = (C_ZERO287).xxxx;
                float4 screenPos238 = i.ase_texcoord6;
                float4 ase_screenPosNorm238 = screenPos238 / screenPos238.w;
                ase_screenPosNorm238.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm238.z : ase_screenPosNorm238.z * 0.5 + 0.5;
                //float screenDepth238 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm238.xy ));
                float screenDepth238 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, sampler_CameraDepthTexture, ase_screenPosNorm238.xy ), _ZBufferParams);
                float distanceDepth238 = saturate( abs( ( screenDepth238 - LinearEyeDepth( ase_screenPosNorm238.z,  _ZBufferParams) ) / ( _SoftIntersection1Distance ) ) );
                float lerpResult467 = lerp( 1.0 , pow( distanceDepth238 , _SoftIntersection1Intensity ) , _SoftIntersection1Affect);
                float4 appendResult321 = (float4(0.0 , 0.0 , 0.0 , lerpResult467));
                float temp_output_242_0 = ( 1.0 - distanceDepth238 );
                float4 appendResult314 = (float4((( maincolor232 * temp_output_242_0 * _SoftIntersection1Intensity * _SoftIntersection1Affect )).rgb , ( temp_output_242_0 * _SoftIntersection1Intensity * _SoftIntersection1Affect )));
                //#if defined(_SOFTINTERSECTION1FEATURE_OFF)
                //float4 staticSwitch315 = temp_cast_4;
                //#elif defined(_SOFTINTERSECTION1FEATURE_ALPHA)
                //float4 staticSwitch315 = appendResult321;
                //#elif defined(_SOFTINTERSECTION1FEATURE_COLOR)
                //float4 staticSwitch315 = appendResult314;
                //#else
                float4 staticSwitch315 = temp_cast_4;
                //#endif
                float4 intersection1245 = staticSwitch315;
                float mulTime273 = _Time.y * 100.0;
                float simplePerlin3D264 = snoise( (ase_worldPos*_GrainScale + mulTime273) );
                simplePerlin3D264 = simplePerlin3D264*0.5 + 0.5;
                float lerpResult278 = lerp( _GrainValues.x , _GrainValues.y , simplePerlin3D264);
                float lerpResult269 = lerp( 0.0 , lerpResult278 , _GrainAffect);
                float staticSwitch282 = _GrainFeature ? lerpResult269 : 0.0;
                // #ifdef _GRAINFEATURE_ON
                // float staticSwitch282 = lerpResult269;
                // #else
                // float staticSwitch282 = 0.0;
                // #endif
                float grain268 = staticSwitch282;
                float4 temp_cast_7 = (C_ZERO287).xxxx;
                float4 temp_cast_8 = (C_ZERO287).xxxx;
                float4 screenPos417 = i.ase_texcoord7;
                float4 ase_screenPosNorm417 = screenPos417 / screenPos417.w;
                ase_screenPosNorm417.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm417.z : ase_screenPosNorm417.z * 0.5 + 0.5;
                //float screenDepth417 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm417.xy ));
                float screenDepth417 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, sampler_CameraDepthTexture, ase_screenPosNorm417.xy ), _ZBufferParams);
                float distanceDepth417 = saturate( abs( ( screenDepth417 - LinearEyeDepth( ase_screenPosNorm417.z, _ZBufferParams ) ) / ( _SoftIntersection2Distance ) ) );
                float lerpResult471 = lerp( 1.0 , pow( distanceDepth417 , _SoftIntersection2Intensity ) , _SoftIntersection2Affect);
                float4 appendResult424 = (float4(0.0 , 0.0 , 0.0 , lerpResult471));
                float temp_output_418_0 = ( 1.0 - distanceDepth417 );
                float4 appendResult425 = (float4((( maincolor232 * temp_output_418_0 * _SoftIntersection2Intensity * _SoftIntersection2Affect )).rgb , ( temp_output_418_0 * _SoftIntersection2Intensity * _SoftIntersection2Affect )));
                //#if defined(_SOFTINTERSECTION2FEATURE_OFF)
                //float4 staticSwitch429 = temp_cast_7;
                //#elif defined(_SOFTINTERSECTION2FEATURE_ALPHA)
                //float4 staticSwitch429 = appendResult424;
                //#elif defined(_SOFTINTERSECTION2FEATURE_COLOR)
                //float4 staticSwitch429 = appendResult425;
                //#else
                float4 staticSwitch429 = temp_cast_7;
                //#endif
                float4 intersection2430 = staticSwitch429;
                float fresnelalpha434 = clampResult57;
                float intersectionalpha1261 = (staticSwitch315).w;
                //#if defined(_SOFTINTERSECTION1FEATURE_OFF)
                //float staticSwitch330 = intersectionalpha1261;
                //#elif defined(_SOFTINTERSECTION1FEATURE_ALPHA)
                //float staticSwitch330 = C_ZERO287;
                //#elif defined(_SOFTINTERSECTION1FEATURE_COLOR)
                //float staticSwitch330 = intersectionalpha1261;
                //#else
                float staticSwitch330 = intersectionalpha1261;
                //#endif
                float intersectionalpha2431 = (staticSwitch429).w;
                //#if defined(_SOFTINTERSECTION2FEATURE_OFF)
                //float staticSwitch447 = intersectionalpha2431;
                //#elif defined(_SOFTINTERSECTION2FEATURE_ALPHA)
                //float staticSwitch447 = C_ZERO287;
                //#elif defined(_SOFTINTERSECTION2FEATURE_COLOR)
                //float staticSwitch447 = intersectionalpha2431;
                //#else
                float staticSwitch447 = intersectionalpha2431;
                //#endif
                //#if defined(_SOFTINTERSECTION1FEATURE_OFF)
                //float staticSwitch334 = C_ONE288;
                //#elif defined(_SOFTINTERSECTION1FEATURE_ALPHA)
                //float staticSwitch334 = intersectionalpha1261;
                //#elif defined(_SOFTINTERSECTION1FEATURE_COLOR)
                //float staticSwitch334 = C_ONE288;
                //#else
                float staticSwitch334 = C_ONE288;
                //#endif
                //#if defined(_SOFTINTERSECTION2FEATURE_OFF)
                //float staticSwitch448 = C_ONE288;
                //#elif defined(_SOFTINTERSECTION2FEATURE_ALPHA)
                //float staticSwitch448 = intersectionalpha2431;
                //#elif defined(_SOFTINTERSECTION2FEATURE_COLOR)
                //float staticSwitch448 = C_ONE288;
                //#else
                float staticSwitch448 = C_ONE288;
                //#endif
                float clampResult62 = clamp( ( ( (maincolor232).a + fresnelalpha434 + (line_color298).w + staticSwitch330 + staticSwitch447 ) * staticSwitch334 * staticSwitch448 ) , 0.0 , 1.0 );
                //float3 temp_output_377_0 = mul( _CustomMatrix, float4( i.ase_texcoord8.xyz , 0.0 ) ).xyz;

                float3 staticSwitch375 = ase_worldPos;
                if(_PositionSpaceFeature == 0)  // world
                {
                    staticSwitch375 = ase_worldPos;
                }
                else if(_PositionSpaceFeature == 1) //local
                {
                    staticSwitch375 = i.ase_texcoord8.xyz;
                }
                
                // #if defined(_POSITIONSPACEFEATURE_WORLD)
                // float3 staticSwitch375 = ase_worldPos;
                // #elif defined(_POSITIONSPACEFEATURE_LOCAL)
                // float3 staticSwitch375 = i.ase_texcoord8.xyz;
                // //#elif defined(_POSITIONSPACEFEATURE_CUSTOM)
                // //float3 staticSwitch375 = temp_output_377_0;
                // #else
                // float3 staticSwitch375 = ase_worldPos;
                // #endif
                float3 vPos357 = staticSwitch375;
                float simplePerlin3D212 = snoise( ( vPos357 * _DissolveScale ) );
                simplePerlin3D212 = simplePerlin3D212*0.5 + 0.5;
                float clampResult218 = clamp( ( simplePerlin3D212 - _DissolveHide ) , 0.0 , 1.0 );

                float staticSwitch337  = _DissolveFeature ? clampResult218 : C_ONE288;
                // #ifdef _DISSOLVEFEATURE_ON
                // float staticSwitch337 = clampResult218;
                // #else
                // float staticSwitch337 = C_ONE288;
                // #endif
                float dissolve432 = staticSwitch337;
                float3 objToWorld257 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
                //#ifdef _MASKLOCALFEATURE_ON
                //float3 staticSwitch499 = ( _MaskCenter + objToWorld257 );
                //#else
                float3 staticSwitch499 = _MaskCenter;
                //#endif
                float clampResult256 = clamp( ( distance( max( ( abs( ( ase_worldPos - staticSwitch499 ) ) - ( _MaskSize * float3( 0.5,0.5,0.5 ) ) ) , float3( 0,0,0 ) ) , float3( 0,0,0 ) ) / _MaskFalloff ) , 0.0 , 1.0 );
                float lerpResult501 = lerp( clampResult256 , ( 1.0 - clampResult256 ) , _MaskInversion);
                float staticSwitch339 = _MaskFeature ? lerpResult501 : C_ONE288;
                // #ifdef _MASKFEATURE_ON
                // float staticSwitch339 = lerpResult501;
                // #else
                // float staticSwitch339 = C_ONE288;
                // #endif
                float mask254 = staticSwitch339;
                //float4 _AlphaMask_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_AlphaMask_ST_arr, _AlphaMask_ST);
                //float2 uv_AlphaMask = i.ase_texcoord1.xy * _AlphaMask_ST_Instance.xy + _AlphaMask_ST_Instance.zw;
                //float lerpResult400 = lerp( C_ONE288 , tex2D( _AlphaMask, uv_AlphaMask ).r , _AlphaMaskAffect);
                float lerpResult400 = lerp( C_ONE288 , SAMPLE_TEXTURE2D(_AlphaMask, sampler_AlphaMask, TRANSFORM_TEX( i.ase_texcoord1.xy, _AlphaMask)).r , _AlphaMaskAffect);
                float staticSwitch404 = _AlphaMaskFeature ? lerpResult400 : C_ONE288;
                // #ifdef _ALPHAMASKFEATURE_ON
                // float staticSwitch404 = lerpResult400;
                // #else
                // float staticSwitch404 = C_ONE288;
                // #endif
                float alphamask402 = staticSwitch404;
                float4 appendResult325 = (float4((( staticSwitch279 * ( maincolor232 + fresnelcolor436 + float4( (line_color298).xyz , 0.0 ) + intersection1245 + grain268 + intersection2430 ) )).rgb , ( clampResult62 * dissolve432 * mask254 * alphamask402 * _Alpha )));
                
                
                outColor = ( appendResult325 * i.ase_color );
                return outColor;
            }
            ENDHLSL
        }
        
    }
    CustomEditor "LWGUI.LWGUI"
}