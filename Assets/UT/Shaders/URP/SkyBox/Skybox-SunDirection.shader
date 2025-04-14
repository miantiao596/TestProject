Shader "URP/UT/Skybox/SunDirection"
{
    Properties
    {
        // Fog Mode
        [Enum(HeightFog, 0, CustomHeightFog, 1)] _FogMode("Fog Mode", Float) = 0.0
        [ShowIf(_FogMode, Equal, 1.0)]
        _FogIntensity("Fog Intensity", Range(0.0, 1.0)) = 0.5

        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        _RotationY ("RotationY", Range(-360, 360)) = 0
        _RotationX ("RotationX", Range(-360, 360)) = 0
        _RotationZ ("RotationZ", Range(-360, 360)) = 0

        [NoScaleOffset] _Tex ("Cubemap   (HDR)", Cube) = "grey" {}
        [NoScaleOffset] _TexMask ("CubemapMask   (HDR)", Cube) = "grey" {}


        [Header(Sun)]
        [KeywordEnum(None, Simple, High Quality)] _SunDisk ("Sun", Int) = 2
        _SunRotation("SunRotation(X)(Y)",vector) = (0,0,0,0)
        [PowerSlider(3)]_SunSize ("Sun Size", Range(0,1)) = 0.04
        _SunSizeConvergence("Sun Size Convergence", Range(1,10)) = 5
        _SunColor ("Sun Color", Color) = (.5, .5, .5, 1)
        _Brightness("Sun Brightness",Range(0,10)) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox"
        }
        Cull Off ZWrite Off

        Pass
        {

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            //#include "UnityCG.cginc"
            //#include "Lighting.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../FAlib/FABaseInputMacro.hlsl"

            #pragma multi_compile_local _SUNDISK_NONE _SUNDISK_SIMPLE _SUNDISK_HIGH_QUALITY

            CBUFFER_START(UnityPerMaterial)
            half4 _Tex_HDR,_TexMask_HDR;
            half4 _Tint;
            half _Exposure;
            float _RotationY,_RotationX,_RotationZ;
            float4 _SunRotation;
            float _Brightness;
            uniform half _SunSize;
            uniform half _SunSizeConvergence;
            uniform half3 _SunColor;
            half _FogMode;
            half _FogIntensity;
            CBUFFER_END
            
            samplerCUBE _Tex,_TexMask;

            //BASE_INPUT_FOG
            #include "../FALib/FACustomFogLib.hlsl"

            #define MIE_G (-0.990)
            #define MIE_G2 0.9801

            // no sun disk - the fastest option
            #define SKYBOX_SUNDISK_NONE 0
            // simplistic sun disk - without mie phase function
            #define SKYBOX_SUNDISK_SIMPLE 1
            // full calculation - uses mie phase function
            #define SKYBOX_SUNDISK_HQ 2

            #ifndef SKYBOX_SUNDISK
                #if defined(_SUNDISK_NONE)
                    #define SKYBOX_SUNDISK SKYBOX_SUNDISK_NONE
                #elif defined(_SUNDISK_SIMPLE)
                    #define SKYBOX_SUNDISK SKYBOX_SUNDISK_SIMPLE
                #else
                    #define SKYBOX_SUNDISK SKYBOX_SUNDISK_HQ
                #endif
            #endif

            float3 RotateAroundYInDegrees (float3 vertex, float degrees)
            {
                float alpha = degrees * PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }

            float3 RotateAroundXInDegrees (float3 vertex, float degrees)
            {
                float alpha = degrees * PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(vertex.x,mul(m, vertex.zy)).xzy;
            }

            float3 RotateAroundZInDegrees (float3 vertex, float degrees)
            {
                float alpha = degrees * PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xy).x, vertex.z,mul(m, vertex.xy).y).xzy;
            }



            struct appdata_t 
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 texcoord : TEXCOORD0;

                float3 direction : TEXCOORD1;

                #if SKYBOX_SUNDISK == SKYBOX_SUNDISK_HQ
                    // for HQ sun disk, we need vertex itself to calculate ray-dir per-pixel
                    float3  vertex          : TEXCOORD2;
                #elif SKYBOX_SUNDISK == SKYBOX_SUNDISK_SIMPLE
                    half3   rayDir          : TEXCOORD3;
                    
                #endif
                float3   positionWS  : TEXCOORD4;
                half4 fogColor : TEXCOORD5;
                UNITY_VERTEX_OUTPUT_STEREO

            };

            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                
                
                float3 rotated = RotateAroundYInDegrees(v.vertex.xyz, _RotationY);
                // float3 rotated = RotateAroundXInDegrees(v.vertex.xyz, _RotationY);
                // float3 rotated = RotateAroundZInDegrees(v.vertex.xyz, _RotationX);

                rotated = RotateAroundXInDegrees(rotated,_RotationX);
                rotated = RotateAroundZInDegrees(rotated,_RotationZ);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(rotated);
                o.pos = vertexInput.positionCS;
                o.positionWS = vertexInput.positionWS;
                o.texcoord = v.vertex.xyz;

                // Get the ray from the camera to the vertex and its length (which is the far point of the ray passing through the atmosphere)
                float3 eyeRay = normalize(mul((float3x3)unity_ObjectToWorld, rotated.xyz));

                #if SKYBOX_SUNDISK == SKYBOX_SUNDISK_HQ
                    o.vertex          = -eyeRay;
                #elif SKYBOX_SUNDISK == SKYBOX_SUNDISK_SIMPLE
                    o.rayDir          = half3(-eyeRay);
                #endif

                o.direction = half3(0,0,1);

                float4 angle = _SunRotation * PI/180.0;
                float4x4 M_rotationX = float4x4(
                1,0,0,0,
                0,cos(angle.y),-sin(angle.y),0,
                0,sin(angle.y),cos(angle.y),0,
                0,0,0,1
                );

                // 旋转变换y轴
                float4x4 M_rotationY = float4x4(
                cos(angle.x),0,sin(angle.x),0,
                0,1,0,0,
                -sin(angle.x),0,cos(angle.x),0,
                0,0,0,1
                );

                // 旋转变换z轴
                float4x4 M_rotationZ = float4x4(
                cos(angle.z),-sin(angle.z),0,0,
                sin(angle.z),cos(angle.z),0,0,
                0,0,1,0,
                0,0,0,1
                );

                o.direction = mul(M_rotationX,mul(M_rotationY,mul(M_rotationZ,o.direction)));
                CustomMixFogColor(vertexInput.positionWS, o.fogColor.xyz, o.fogColor.w);
                return o;
            }

            // Calculates the Mie phase function
            half4 getMiePhase(half eyeCos, half eyeCos2)
            {
                half temp = 1.0 + MIE_G2 - 2.0 * MIE_G * eyeCos;
                temp = pow(temp, pow(_SunSize,0.65) * 10);
                temp = max(temp,1.0e-4); // prevent division by zero, esp. in half precision
                temp = 1.5 * ((1.0 - MIE_G2) / (2.0 + MIE_G2)) * (1.0 + eyeCos2) / temp;
                half3 c = temp * _SunColor.rgb;
                return half4(c,1);
            }

            // Calculates the sun shape
            half4 calcSunAttenuation(half3 lightPos, float3 ray)
            {
                #if SKYBOX_SUNDISK == SKYBOX_SUNDISK_SIMPLE
                    half3 delta = lightPos - ray;
                    half dist = length(delta);
                    half spot = 1.0 - smoothstep(0.0, _SunSize, dist);
                    half3 c = spot * spot * _SunColor.rgb;
                    return half4(c,1);
                #else // SKYBOX_SUNDISK_HQ
                    half focusedEyeCos = pow(saturate(dot(lightPos, ray)), _SunSizeConvergence);
                    return getMiePhase(-focusedEyeCos, focusedEyeCos * focusedEyeCos);
                #endif
            }
            
            half4 frag (v2f i) : SV_Target
            {
                half4 tex = texCUBE (_Tex, i.texcoord);
                half3 c = DecodeHDREnvironment(tex, _Tex_HDR);
                half4 texMask = texCUBE (_TexMask, i.texcoord);
                half3 texMaskDecode = DecodeHDREnvironment(texMask, _TexMask_HDR);
                
                c = c * _Tint.rgb * 4.59479380 * texMaskDecode;
                c *= _Exposure;

                #if SKYBOX_SUNDISK == SKYBOX_SUNDISK_HQ
                    half3 ray = normalize(i.vertex.xyz);
                #elif SKYBOX_SUNDISK == SKYBOX_SUNDISK_SIMPLE
                    half3 ray = i.rayDir.xyz;
                #endif
                
                #if SKYBOX_SUNDISK != SKYBOX_SUNDISK_NONE
                    
                    c.rgb += calcSunAttenuation(i.direction, -ray).xyz * _Brightness;
                #endif
                
                c = lerp(i.fogColor.xyz, c.rgb, i.fogColor.w);

                return half4(c, 1);
            }
            ENDHLSL
        }
    }

    Fallback Off
    CustomEditor "LWGUI.LWGUI"
}
