Shader "URP/UT/Skybox/Cubemap"
{
    Properties
    {
        // Fog Mode
        [Enum(HeightFog, 0, CustomHeightFog, 1)] _FogMode("Fog Mode", Float) = 0.0
        [ShowIf(_FogMode, Equal, 1.0)]
        _FogIntensity("Fog Intensity", Range(0.0, 1.0)) = 0.5
        
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        _Rotation ("Rotation", Range(0, 360)) = 0
        [NoScaleOffset] _Tex ("Cubemap   (HDR)", Cube) = "grey" {}
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../FALib/FABaseInputMacro.hlsl"

            samplerCUBE _Tex;
            half4 _Tex_HDR;
            half4 _Tint;
            half _Exposure;
            float _Rotation;
            BASE_INPUT_FOG
            #include "../FALib/FACustomFogLib.hlsl"

            float3 RotateAroundYInDegrees(float3 vertex, float degrees)
            {
                float alpha = degrees * PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }

            struct appdata_t
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 texcoord : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                half4 fogColor : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                float3 rotated = RotateAroundYInDegrees(v.vertex.xyz, _Rotation);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(rotated);
                o.vertex = vertexInput.positionCS;
                o.positionWS = vertexInput.positionWS;
                o.texcoord = v.vertex.xyz;
                CustomMixFogColor(vertexInput.positionWS, o.fogColor.xyz, o.fogColor.w);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 tex = texCUBE(_Tex, i.texcoord);
                half3 c = DecodeHDREnvironment(tex, _Tex_HDR);
                c = c * _Tint.rgb * 4.59479380;
                c *= _Exposure;
                c = lerp(i.fogColor.xyz, c.rgb, i.fogColor.w);
                return half4(c, 1);
            }
            ENDHLSL
        }
    }

    Fallback Off
    CustomEditor "LWGUI.LWGUI"
}