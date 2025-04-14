#ifndef SCENE_SEAGRASS_DEPTH_NORMAL_PASS_INCLUDED
    #define SCENE_SEAGRASS_DEPTH_NORMAL_PASS_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "../Lib/Ut-SpaceTransforms.hlsl"

    struct Attributes
    {
        float4 positionOS    : POSITION;
        half4 tangentOS     : TANGENT;
        float2 texcoord     : TEXCOORD0;
        half3 normalOS      : NORMAL;
    };

    struct Varyings
    {
        float4 positionCS    : SV_POSITION;
        float2 uv           : TEXCOORD1;
        half3 normalWS      : TEXCOORD2;
    };

    half4 SmoothCurve(half x)
    {
        return x * x * (3.0 - 2.0 * x);
    }
    half4 TriangleWave(float4 x)
    {
        return abs(frac(x + 0.5) * 2.0 - 1.0);
    }
    half4 SmoothTriangleWave(half4 x)
    {
        return SmoothCurve(TriangleWave(x));
    }

    Varyings DepthNormalsVertex(Attributes input, uint instanceID : SV_InstanceID)
    {
        Varyings output = (Varyings)0;

        output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
        

        float3 posWS = TransformObjectToWorld(input.positionOS.xyz, instanceID);
        half3 normalWS = TransformObjectToWorldNormal(input.normalOS, instanceID);
        float3 oriPosWS = posWS;

        float3 rootPosWS = GetObjectToWorldMatrix(instanceID)._14_24_34;

        half swayMask = input.texcoord.y;
        swayMask = saturate(swayMask);
        swayMask = pow(swayMask, 2);

        //暂时这么处理，后面风场需要全局控制
        _WindDirection *= 0.017453;
        half3 windDir = normalize(half3(cos(_WindDirection), 0, sin(_WindDirection)));

        float2 windUV = frac(posWS.xz / (_WindWaveSize * TERRAINSIZE));
        //风吹麦浪贴图根据风向旋转uv
        windUV -= float2(0.5, 0.5);
        windUV = float2(windUV.x * windDir.x + windUV.y * windDir.z, windUV.y * windDir.x - windUV.x * windDir.z);
        windUV += float2(0.5, 0.5);
        windUV.x -= frac((_Time.x * _WindWaveSpeed * abs(windDir.x) + 0.5)) * 2.0 - 1.0;
        windUV.y -= frac((_Time.x * _WindWaveSpeed * abs(windDir.z) + 0.5)) * 2.0 - 1.0;
        half windStrength = SAMPLE_TEXTURE2D_LOD(_WindControlMap, sampler_WindControlMap, windUV, 0);
        windStrength *= _WindStrength;
        // offset in world space
        //摆动
        half3 swayAxis = normalize(TransformObjectToWorld(half3(0,1,0), instanceID) - rootPosWS);
        float3 selfRoot = half3(posWS.x, rootPosWS.y, posWS.z);
        half3 growDir = posWS - selfRoot;
        half3 binAxis = cross(windDir, swayAxis);
        half3 offsetDir = cross(normalize(growDir), binAxis);
        offsetDir = normalize(offsetDir);
        half growLength = length(growDir);
        //growLength = lerp(growLength, 1.2 * growLength, saturate(windStrength/10));适当拉伸
        float3 dstVec = normalize((growDir + offsetDir * windStrength * swayMask));
        posWS = selfRoot + dstVec * growLength;
        //颤动
        half detailAmp = 0.1f;
        half objPhase = dot(rootPosWS, 1);
        half vtxPhase = dot(oriPosWS, _FoliageFlutter + objPhase);
        half2 wavesIn = _Time.yy + half2(vtxPhase, objPhase);
        half4 waves = frac(wavesIn.xxyy * half4(1.975, 0.793, 0.375, 0.193)) * 2.0 - 1.0;
        waves = SmoothTriangleWave(waves);
        half2 waveSum = waves.xz + waves.yw;
        float3 bend = _FoliageFlutter * detailAmp * normalWS * windStrength;
        posWS += (waveSum.xyx * bend * swayMask);
        
        output.positionCS = TransformWorldToHClip(posWS);
        output.normalWS = NormalizeNormalPerVertex(normalWS);

        return output;
    }

    half4 DepthNormalsFragment(Varyings input) : SV_TARGET
    {
        #if defined(_ALPHATEST_ON)
            Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, sampler_MainTex)).a, _Color, _Cutoff);
        #else
            Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, sampler_MainTex)).a, _Color, 0);
        #endif
        return half4(PackNormalOctRectEncode(TransformWorldToViewDir(input.normalWS, true)), 0.0, 0.0);
    }
#endif
