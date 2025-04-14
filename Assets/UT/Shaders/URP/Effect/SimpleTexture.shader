Shader "URP/MoleGame/Effects/SimpleTexture"
{
    Properties
    {
        _SrcBlend("src", Float) = 1.0
		_DstBlend("dst", Float) = 0.0

        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _RotateAngle("Rotate Angle", float) = 0

        // 全息效果
        [Toggle(_ST_HOLOGRAM2_ON)]_Hologram2_Enable("Hologram2 On", float) = 0
        [HDR]_ST_Hologram2_Color("Main Color", Color) = (0.620945,1.420074,3.953349,0.05098039)
        _ST_Hologram2_Alpha("Alpha", Range( 0 , 1)) = 1
        _ST_Hologram2_RandomOffset("Random Offset", Float) = 100        
        [Enum(UnityEngine.Rendering.SpaceType)] _ST_Hologram2_PositionSpaceFeature("Position Space Feature", Float) = 0
        [Enum(UnityEngine.Rendering.PositionAxis)] _ST_Hologram2_PositionFeature("Position Feature", Float) = 1
        _ST_Hologram2_PositionDirection("Position Direction", Float) = 1       
        _ST_Hologram2_FresnelRGBScale("Fresnel Scale", Float) = 6.12
        _ST_Hologram2_FresnelRGBPower("Fresnel Power", Float) = 2
        _ST_Hologram2_FresnelAlphaScale("Fresnel Alpha Scale", Float) = 3
        _ST_Hologram2_FresnelAlphaPower("Fresnel Alpha Power", Float) = 4
        _ST_Hologram2_Line1("Line 1", 2D) = "white" {}
        _ST_Hologram2_Line1Speed("Line 1 Speed", Float) = -2
        _ST_Hologram2_Line1Frequency("Line 1 Frequency", Float) = 40
        _ST_Hologram2_Line1Hardness("Line 1 Hardness", Float) = 4.6
        _ST_Hologram2_Line1InvertedThickness("Line 1 Inverted Thickness", Range( 0 , 1)) = 0.078
        _ST_Hologram2_Line1Alpha("Line 1 Alpha", Float) = 0.7
        _ST_Hologram2_LineGlitch("Line Glitch", 2D) = "white" {}
        _ST_Hologram2_LineGlitchOffset("Line Glitch Offset", Vector) = (0.03,0,0,0)
        _ST_Hologram2_LineGlitchSpeed("Line Glitch Speed", Float) = -0.26
        _ST_Hologram2_LineGlitchFrequency("Line Glitch Frequency", Float) = 0.8
        _ST_Hologram2_LineGlitchHardness("Line Glitch Hardness", Float) = 5
        _ST_Hologram2_LineGlitchInvertedThickness("Line Glitch Inverted Thickness", Range( 0 , 1)) = 0.825
        _ST_Hologram2_RandomGlitchOffset("Random Glitch Offset", Vector) = (-0.3,0,0,0)
        _ST_Hologram2_RandomGlitchAmount("Random Glitch Amount", Range( 0 , 1)) = 0.063
        _ST_Hologram2_RandomGlitchConstant("Random Glitch Constant", Range( 0 , 1)) = 0
        _ST_Hologram2_RandomGlitchTiling("Random Glitch Tiling", Float) = 2.13
        _ST_Hologram2_ColorGlitchAffect("Color Glitch Affect", Range( 0 , 1)) = 0.242
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline"}
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        Pass
        {
            Tags {"LightMode" = "SceneEffect" }
            Blend [_SrcBlend] [_DstBlend]
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "../FALib/FAShaderUtils.hlsl"
            
            #pragma vertex VertexFunction
            #pragma fragment FragmentFunction
            #pragma multi_compile_local _ _ST_HOLOGRAM2_ON
           
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                half3 normalOS     : NORMAL;
                half4 tangentOS    : TANGENT;
            };

            struct Varyings
            {
                float2 uv               : TEXCOORD0;
                float4 positionCS       : SV_POSITION;
                float3 positionWS       : TEXCOORD1; 
                half3  normalWS         : TEXCOORD2;
                half3 tangentWS		    : TEXCOORD3;
                half3 bitangentWS		: TEXCOORD4;
            #ifdef _ST_HOLOGRAM2_ON
                float4 positionOSAndDirect   :   TEXCOORD5; 
            #endif
            };
            
            TEXTURE2D(_MainTex);				    SAMPLER(sampler_MainTex);
            TEXTURE2D(_ST_Hologram2_Line1);		    SAMPLER(sampler_ST_Hologram2_Line1);
            TEXTURE2D(_ST_Hologram2_LineGlitch);		SAMPLER(sampler_ST_Hologram2_LineGlitch);
            TEXTURE2D(_ST_Hologram2_NormalMap);		SAMPLER(sampler_ST_Hologram2_NormalMap);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _Color;
            float _RotateAngle;
            half4 _ST_Hologram2_Color; 
            half _ST_Hologram2_Alpha;
            half _ST_Hologram2_RandomOffset;     
            half _ST_Hologram2_PositionSpaceFeature;
            half _ST_Hologram2_PositionFeature;
            half _ST_Hologram2_PositionDirection;
            half _ST_Hologram2_FresnelRGBScale;
            half _ST_Hologram2_FresnelRGBPower;
            half _ST_Hologram2_FresnelAlphaScale;
            half _ST_Hologram2_FresnelAlphaPower;
            half4 _ST_Hologram2_Line1_ST;
            half _ST_Hologram2_Line1Speed;
            half _ST_Hologram2_Line1Frequency;
            half _ST_Hologram2_Line1Hardness;
            half _ST_Hologram2_Line1InvertedThickness;
            half _ST_Hologram2_Line1Alpha;
            half4 _ST_Hologram2_LineGlitch_ST;
            half3 _ST_Hologram2_LineGlitchOffset;
            half _ST_Hologram2_LineGlitchSpeed;
            half _ST_Hologram2_LineGlitchFrequency;
            half _ST_Hologram2_LineGlitchHardness;
            half _ST_Hologram2_LineGlitchInvertedThickness;
            half3 _ST_Hologram2_RandomGlitchOffset;
            half _ST_Hologram2_RandomGlitchAmount;
            half _ST_Hologram2_RandomGlitchConstant;
            half _ST_Hologram2_RandomGlitchTiling;
            half _ST_Hologram2_ColorGlitchAffect;
            half3 _ST_Hologram2_GrainScale;
            half _ST_Hologram2_GrainAffect;
            half4 _ST_Hologram2_GrainValues;
            half4 _ST_Hologram2_NormalMap_ST;
            half _ST_Hologram2_NormalScale;
            half _ST_Hologram2_NormalAffect;
            half3 _ST_Hologram2_DissolveScale;
            half _ST_Hologram2_DissolveHide;
            CBUFFER_END
            
            //#include "../Lib/FACharacterEffect.hlsl"
            #ifdef _ST_HOLOGRAM2_ON
                #include "../FALib/FAShaderUtils.hlsl"
                float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
                float2 mod2D289( float2 x ) {  return    x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
                float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
                #define MOD2 float2(.1031,.11369)
                float hash21(float2 p)
                {
                    float2 p2 = frac(p * MOD2);
                    p2 += dot(p2, p2.yx + 19.19);
                    return -1.0 + 2.0 * frac((p2.x + p2.y) * p2.y);
                    //return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
                }
                float snoise( float2 p )
                {
                    float2 pi = floor(p);
                    float2 pf = p - pi;
            
                    float2 w = pf * pf * (3.0 - 2.0 * pf);
            
                    return 
                        lerp(
                            lerp(hash21(pi + float2(0, 0)), hash21(pi + float2(1, 0)), w.x),
                            lerp(hash21(pi + float2(0, 1)), hash21(pi + float2(1, 1)), w.x), 
                            w.y);
                }

                // vertex
                float4 Hologram2Vertex(float3 positionOS, float3 positionWS)
                {
                    float3 lineGlitchM2V = mul(UNITY_MATRIX_T_MV, half4(_ST_Hologram2_LineGlitchOffset, 0)).xyz;  // 从模型空间变换到观察空间
                    float3 objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
                    float time = _Time.y;//fmod(_Time.x, 10);
                    
                    half axisWS = positionWS.x;
                    half axisOS = positionOS.x;
                    if(_ST_Hologram2_PositionFeature == 1)
                    {
                        axisWS = positionWS.y;
                        axisOS = positionOS.y;
                    }
                    else if(_ST_Hologram2_PositionFeature == 2)
                    {
                        axisWS = positionWS.z;
                        axisOS = positionOS.z;
                    }
                    
                    half axis = axisWS;
                    if(_ST_Hologram2_PositionSpaceFeature == 1)
                    {
                        axis = axisOS;
                    }
                    
                    half direct = axis * _ST_Hologram2_PositionDirection;
                    
                    // line glitch
                    float lineGlitchDist = time * _ST_Hologram2_LineGlitchSpeed;
                    float2  lineGlitchUV = (direct * _ST_Hologram2_LineGlitchFrequency + (lineGlitchDist + _ST_Hologram2_RandomOffset)).xx;
                    float lineGlitchClamp = clamp(((SAMPLE_TEXTURE2D_X_LOD(_ST_Hologram2_LineGlitch, sampler_ST_Hologram2_LineGlitch, float4(lineGlitchUV, 0, 0), 0).r - _ST_Hologram2_LineGlitchInvertedThickness) * _ST_Hologram2_LineGlitchHardness), 0.0, 1.0);
                    float3 lineGlithOffset = (lineGlitchM2V / objectScale) * lineGlitchClamp;
                    
                    // Random Glitch
                    float3 randomGlitchM2V = mul(UNITY_MATRIX_T_MV, half4(_ST_Hologram2_RandomGlitchOffset, 0)).xyz;
                    float2 randomGlithUV = float2((direct * _ST_Hologram2_RandomGlitchTiling + (time * -2.3 + _ST_Hologram2_RandomOffset)), (_ST_Hologram2_RandomOffset + time * -2.05));
                    float simplePerlin = snoise(randomGlithUV);
                    simplePerlin = simplePerlin * 0.5 + 0.5;
                    
                    float4 matrixToPos = float4( float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[0][3],float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[1][3],float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[2][3],float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[3][3]);  
                    float offset = matrixToPos.x + matrixToPos.y + matrixToPos.z;
                    if(_ST_Hologram2_PositionSpaceFeature == 1)
                    {
                        offset = 0;
                    }
                    float2 randomGlithUVOffset = float2((offset * 223 + (time * -5.74 + _ST_Hologram2_RandomOffset)), (_ST_Hologram2_RandomOffset + time * -0.83));
                    float simplePerlinRandomGlith = snoise(randomGlithUVOffset);
                    simplePerlinRandomGlith = simplePerlinRandomGlith * 0.5 + 0.5;
                    float randomGlithOffsetClamp = clamp((-1 + (simplePerlinRandomGlith + _ST_Hologram2_RandomGlitchConstant) * 2), 0, 1);
                    float randomGlithFinal = (-1 + simplePerlin * 2) * randomGlithOffsetClamp;
                    
                    float2 tempUV = ((20 * randomGlithUV.x) , randomGlithUV.y);
                    float simplePerlinTemp = snoise(tempUV);
                    simplePerlinTemp = simplePerlinTemp * 0.5 + 0.5;
                    float tempClamp = clamp((-1 + simplePerlinTemp * 2), 0 ,1);
                    float tempLerp = lerp(0, tempClamp, 2);
                    float3 randomGlithOffset = (lineGlitchM2V / objectScale) * (randomGlithFinal + randomGlithFinal * tempLerp) * _ST_Hologram2_RandomGlitchAmount;
                    
                    
                    float3 vertexOffset = lineGlithOffset + randomGlithOffset;
                    return float4(positionOS + vertexOffset, direct);
                }
                
                // fragment
                float4 Hologram2Fragment(float4 sourceColor, half2 uv, float3 positionOS, float3 positionWS, float3 normalWS, float3 tangentWS, float3 bitangentWS, float direct)
                {
                    float time = _Time.y;//fmod(_Time.x, 10);
                    float3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - positionWS);
                    float3 normalWorld = normalize(normalWS);

                    
                    half3 m2W = mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz;
                    
                    half temp = m2W.x + m2W.y + m2W.z;
                    if(_ST_Hologram2_PositionSpaceFeature == 1)
                    {
                        temp = 0;
                    }

                    // color glith
                    float2 randomOffsetUV = float2(temp * 223 + (_ST_Hologram2_RandomOffset + time * -15), (_ST_Hologram2_RandomOffset + time * -0.5));
                    float simplePerlinTemp = snoise(randomOffsetUV);
                    simplePerlinTemp = simplePerlinTemp * 0.5 + 0.5;
                    float tempClamp = clamp((-0.61 + simplePerlinTemp * 2), 0, 1);
                    float tempLerp = lerp(1, tempClamp, _ST_Hologram2_ColorGlitchAffect);
                    float colorGlithParam = tempLerp;
                    
                    half4 mainColor = _ST_Hologram2_Color * sourceColor;// * SAMPLE_TEXTURE2D(_Hologram2_MainTex, sampler_Hologram2_MainTex, TRANSFORM_TEX(uv, _Hologram2_MainTex));
                    float normal = 0;

                    // fresnel
                    float fresnelColorParam = _ST_Hologram2_FresnelRGBScale * pow(1 - dot(normalWorld, worldViewDir), _ST_Hologram2_FresnelRGBPower);
                    float fresnelColorNormal = saturate(fresnelColorParam + normal);
                    float fresnelAlpha = _ST_Hologram2_FresnelAlphaScale * pow(1 - dot(normalWorld, worldViewDir), _ST_Hologram2_FresnelAlphaPower);
                    float fresnelAlphaNormal = clamp((fresnelAlpha + normal), 0, 1);
                    float4 fresnelColor = fresnelColorNormal * mainColor * fresnelAlphaNormal;
                    
                    // line 1
                    float2 line1UV = (direct * _ST_Hologram2_Line1Frequency + (time * _ST_Hologram2_Line1Speed + _ST_Hologram2_RandomOffset)).xx;
                    float line1Param = clamp(((SAMPLE_TEXTURE2D(_ST_Hologram2_Line1, sampler_ST_Hologram2_Line1, line1UV).r - _ST_Hologram2_Line1InvertedThickness) * _ST_Hologram2_Line1Hardness), 0, 1);
                    float3 line1Color = (mainColor * line1Param).rgb;
                    float line1Alpha = line1Param * _ST_Hologram2_Line1Alpha;
                    float4 line1 = float4(line1Color, line1Alpha);

                    float tempAlpha = clamp((mainColor.a + fresnelAlphaNormal + line1.w), 0, 1);

                    float3 color = float4(colorGlithParam * (mainColor + fresnelColor + float4(line1.xyz, 0))).rgb;
                    float alpha = tempAlpha * _ST_Hologram2_Alpha;
                    return saturate(float4(color, alpha));
                }   
            
            #endif
            Varyings VertexFunction (Attributes input)
            {
                Varyings output = (Varyings) 0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionWS = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = vertexNormalInput.normalWS;
                output.tangentWS = vertexNormalInput.tangentWS;
                output.bitangentWS = vertexNormalInput.bitangentWS;
                output.uv = RotateUV(TRANSFORM_TEX(input.uv, _MainTex), _RotateAngle, 1);
            #ifdef _ST_HOLOGRAM2_ON
                float4 posOSAndDirect = Hologram2Vertex(input.positionOS.xyz, vertexInput.positionWS.xyz);
                float3 posOS = posOSAndDirect.xyz;
                output.positionCS = TransformObjectToHClip(posOS);
                output.positionOSAndDirect.xyz = input.positionOS.xyz;
                output.positionOSAndDirect.w = posOSAndDirect.w;
            #endif
                return output;
            }

            half4 FragmentFunction (Varyings input) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _Color;
            #ifdef _ST_HOLOGRAM2_ON
                color = Hologram2Fragment(color, input.uv, input.positionOSAndDirect.xyz, input.positionWS, input.normalWS, input.tangentWS, input.bitangentWS, input.positionOSAndDirect.w);
            #endif
                return color;
            }
            ENDHLSL
        }
    }
}
