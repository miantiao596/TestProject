#ifndef MOLE_EFFECT_GENERAL_LIB
#define MOLE_EFFECT_GENERAL_LIB

#pragma prefer_hlslcc gles
#pragma exclude_renderers d3d11_9x
#pragma target 2.0

#pragma multi_compile_local _ _IN_UI_ON

#pragma multi_compile_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
#pragma multi_compile_local _ _VERTEX_ON
#pragma multi_compile_local _ _DISTORTION_ON
#pragma multi_compile_local _ _DISSOLUTION_ON
#pragma multi_compile_local _ _MASK_ON
            
//#pragma multi_compile_local _ _POLAR_COORDINATES_ON
#pragma multi_compile_local _ _ENABLE_NORMAL_ON
//#pragma shader_feature _ _ENABLE_GRAYOVERLAY_ON
//#pragma shader_feature _ _ENABLE_FRESNEL_ON
#pragma multi_compile_local _ _ENABLE_DECAL_ON

#pragma shader_feature_local _ENABLE_FLATTEN

#pragma multi_compile_local _ UI_ALPHA_MASK

// #pragma multi_compile _ TRANSPARENT_FOG_ON
// #pragma multi_compile_local _ _APPLY_VOLUMETRIC_FOG_COLOR
#pragma multi_compile_local _ _DEPTH_FADE_ON


#pragma shader_feature_local_fragment _SWITCHPBR

// #pragma multi_compile_fog

#pragma vertex vert
#pragma fragment frag

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "../FALib/FAShaderUtils.hlsl"
#include "Assets/UT/Shaders/URP/Effect/Mole_Effect_General_Lighting.hlsl"
// UI Alpha Mask
#include "Assets/UT/Shaders/Lib/UIShaderLib.cginc"

//#include "Assets/UnityPackages/VolumetricFog2/Shaders/CustomVolumetricFogUtils.hlsl"


TEXTURE2D(_MainTex);				SAMPLER(sampler_MainTex);
TEXTURE2D(_BumpMap);				SAMPLER(sampler_BumpMap);
TEXTURE2D(_CameraDepthTexture);		SAMPLER(sampler_CameraDepthTexture);

// UI Alpha Mask
sampler2D _UIAlphaMaskTex;

#ifdef _MASK_ON
    TEXTURE2D(_MaskTex);				SAMPLER(sampler_MaskTex);
    TEXTURE2D(_MaskTex2);				SAMPLER(sampler_MaskTex2);
    TEXTURE2D(_MaskTex3);				SAMPLER(sampler_MaskTex3);
#endif

#ifdef _DISSOLUTION_ON
    TEXTURE2D(_DissolutionTex);				SAMPLER(sampler_DissolutionTex);
#endif

#ifdef _DISTORTION_ON
    TEXTURE2D(_DistortionTex);				SAMPLER(sampler_DistortionTex);
#endif

#ifdef _VERTEX_ON
    sampler2D _VertexTex;
#endif

CBUFFER_START(UnityPerMaterial)
half _FogMode;
half _FogIntensity;
half4 _Color;
half4 _MainTex_ChannelMask;
float4 _MainTex_ST;
half _MainTex_U;
half _MainTex_V;
half _MainTex_RotateAngle;
half _MainTex_UseRotateSpeed;
half _MainTex_RotateSpeed;
half _Intensity;
half _Contrast;
half _NotForMainColor;
half _Desaturate;
half _MainTex_Polar_Coordinates;
uniform half _Main_Rot_01;
half _INPUT_CUSTOMDATA;
half _INPUT_CUSTOMDATA2;
//half _Enable_Normal;
half _BumpScale;
half _Cutoff;

//#ifdef _DISSOLUTION_ON
half4 _DissolutionTex_ST;
half4 _DissolutionTex_ChannelMask;
half _DissolutionTex_U;
half _DissolutionTex_V;
half _DissolutionTex_RotateAngle;
half _DissolutionTex_UseRotateSpeed;
half _DissolutionTex_RotateSpeed;
half _DissolutionReverse;
half _DissolutionPercent;
half _DissolutionSoftEdge;
half _DissolutionEdgeWidth;
half4 _DissolutionEdgeColor;
//#endif

//#ifdef _DISTORTION_ON
half4 _DistortionTex_ST;
half4 _DistortionTex_ChannelMask;
half _DistortionTex_U;
half _DistortionTex_V;
half _DistortionTex_RotateAngle;
half _DistortionTex_UseRotateSpeed;
half _DistortionTex_RotateSpeed;
half _DistortionIntensity;
//#endif

half _Enable_Fresnel;
half4 _FresnelColor;
//iOS系统上，TML设置属性存在精度问题，这里修改为float类型
float _FresnelPower;
float _FresnelIntensity;
float _FresnelPower2;
float _FresnelIntensity2;
float _FresnelAlpha;
float _FresnelAlphaIntensity;

half _Enable_DoubleFaceColor;
half4 _DoubleFaceColor;
half4 _DoubleFaceColor2;

//iOS系统上，TML设置属性存在精度问题，这里修改为float类型
float _GFresnelAlpha;

half _Enable_GrayOverlay;
half4 _GrayOverlayColor;
half _GrayHighlightIntensity;
half _GrayThreshold;
half _Enable_3Colors;
half4 _ColorDark;
half4 _ColorMiddle;
half4 _ColorLight;

//half _Enable_DepthFade;
half _DepthFadeIntensity;
half _DepthFadeOffset;

half _AlphaOverflow;

//#ifdef _MASK_ON
float4 _MaskTex_ST;
half4 _MaskTex_ChannelMask;
half _MaskTex_U;
half _MaskTex_V;
half _MaskTex_RotateAngle;
half _MaskTex_UseRotateSpeed;
half _MaskTex_RotateSpeed;
half _MaskTex_Polar_Coordinates;
uniform half _Mask_Rot_01;

half4 _MaskTex2_ST;
half4 _MaskTex2_ChannelMask;
half _MaskTex2_U;
half _MaskTex2_V;
half _MaskTex2_RotateAngle;
half _MaskTex2_UseRotateSpeed;
half _MaskTex2_RotateSpeed;

half4 _MaskTex3_ST;
half4 _MaskTex3_ChannelMask;
half _MaskTex3_U;
half _MaskTex3_V;
half _MaskTex3_RotateAngle;
half _MaskTex3_UseRotateSpeed;
half _MaskTex3_RotateSpeed;
//#endif

//#ifdef _VERTEX_ON
half4 _VertexTex_ST;
half4 _VertexTex_ChannelMask;
half _VertexTex_U;
half _VertexTex_V;
half _VertexTex_RotateAngle;
half _VertexTex_UseRotateSpeed;
half _VertexTex_RotateSpeed;
half _VertexIntensity;
//#endif

half _ProjectionAngleDiscardThreshold;

// UI Alpha Mask
float4 _UIMaskUVLimit;
float4 _UIMaskRange;
float _UIMaskTexScaleX;
float _UIMaskTexScaleY;

// texture uv type
half _MainTex_UVType;
half _MaskTex_UVType;
half _MaskTex2_UVType;
half _MaskTex3_UVType;
half _DissolutionTex_UVType;
half _DistortionTex_UVType;
half _VertexTex_UVType;

//预乘alpha参数
#ifndef NO_TPA
half _TPA;
#endif

half _DstBlend;

//iOS系统上，TML设置属性存在精度问题，这里修改为float类型
float _GAlpha;


//float _Fog_Blend_Mode;

float _DepthClip;

half _POLAR_COORDINATES;

half _Smoothness;
half _Metallic;

float _FlattenPlaneOffset;
float _FlattenFactor;
float3 _FlattenWorldOriginPos;
half _CustomBakeGIColor;
half4 _BekeGIColor;
CBUFFER_END

float4 _CameraForward;
float4 _CameraPos;

#include "../FALib/FAEffectLib.hlsl"
#include "../FALib/FACustomFogLib.hlsl"

// 灰色重着色 (_GrayThreshold, _GrayOverlayColor, _GrayHighlightIntensity)
half4 GetGrayOverlayColor(half4 colorSource, half customIntensity = 1)
{
    half gray = (colorSource.r + colorSource.g + colorSource.b)/3.0f;
    half canIntensity = step(_GrayThreshold, gray);
    half4 grayOverlayColor = _GrayOverlayColor;
    PARTICLE_COLOR(grayOverlayColor);
    half4 grayColor = half4(colorSource.rgb + grayOverlayColor.rgb, colorSource.a);
    half4 color = lerp(grayColor, colorSource * customIntensity * _GrayHighlightIntensity, canIntensity);
    // 3 Colors
    half3 colorLerp1 = lerp(_ColorDark.rgb, _ColorMiddle.rgb, saturate(color.rgb * 2.0));
    half3 colorLerp2 = lerp(_ColorMiddle.rgb, _ColorLight.rgb, saturate((color.rgb - 0.5) * 2.0));
    half3 colorLerp3 = lerp(colorLerp1, colorLerp2, color.rgb);
    color = lerp(color, half4(colorLerp3, colorSource.a), _Enable_3Colors);
    return color;
}

// 切边羽化（交界处透明） (_CameraDepthTexture, sampler_CameraDepthTexture, _DepthFadeOffset, _DepthFadeIntensity)
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

float2 PolarCoordinatesUV(uniform float _rot, float2 uv, half enabled)
{
    float angle = (1.0 - length(uv * 2 - 1)) * 3.141592654 * 2.0 * _rot; // 扭曲角度
    float spd = 1.0;
    float cos_ang = cos(spd*angle);
    float sin_ang = sin(spd*angle);
    float2x2 rotateM = float2x2(cos_ang, -sin_ang, sin_ang, cos_ang);  //旋转矩阵
    
    float2 piv = float2(0.5,0.5);
    float2 uv_rotated = mul(uv - piv, rotateM) + piv; // 平移-》旋转-》平移
    float2 uv_tmp = uv_rotated * 2.0 + -1.0;
    float2 uv_new = float2(atan2(uv_tmp.x, uv_tmp.y) * (1/(3.141592654 * 2)) * 6, length(uv_tmp));
    return lerp(uv, uv_new, enabled);
}

struct Attributes {
    float4	positionOS		: POSITION;
    half4	color			: COLOR;
    half3	normalOS		: NORMAL;
    half4	tangentOS		: TANGENT;
    float4	texcoord		: TEXCOORD0;
    float4	texcoord1		: TEXCOORD1;
    float2	texcoord2		: TEXCOORD2;
    float2  staticLightmapUV   : TEXCOORD3;
};

struct Varyings {
    float4	positionCS				: SV_POSITION;
    half4	color					: COLOR;
    float4	texcoord				: TEXCOORD0;	// xy : uv				zw : CustomData1.xy
    float4	texcoord1				: TEXCOORD1;	// xy : CustomData1.zw	zw : CustomData2.xy
    float2	texcoord2				: TEXCOORD2;	// xy : CustomData2.zw (preserve)
    float4	positionWSAndFogFactor	: TEXCOORD3;	// xyz: positionWS, w: vertex fog factor
    half3	normalWS				: TEXCOORD4;
    half3	tangentWS				: TEXCOORD5;
    half3	bitangentWS				: TEXCOORD6;
    float4	positionScreen			: TEXCOORD7;
    float4  fogColor                : TEXCOORD8;
    #if defined(_DISTORTION_ON) || defined(_DISSOLUTION_ON)
        float4	uvDis        		: TEXCOORD9;
    #endif
    #ifdef _MASK_ON
        float4	uvMask				: TEXCOORD10;
        float2	uvMask2				: TEXCOORD11;
    #endif
    #ifdef _ENABLE_DECAL_ON
        float4 viewRayOS				: TEXCOORD12; // xyz: viewRayOS, w: extra copy of positionVS.z
        float4 cameraPosOS				: TEXCOORD13;
    #endif
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 14);
};

struct UVData {
    float2 uvMain;
#if defined(_DISTORTION_ON) || defined(_DISSOLUTION_ON)
    float4 uvDis;
#endif
#ifdef _MASK_ON
    float4 uvMask;
    float2 uvMask2;
#endif
};

UVData GetUVData(float2 uvMain, float2 uv2, float time, half4 customData1, half2 customData2)
{
    UVData output;

#if defined _DISTORTION_ON || defined _DISSOLUTION_ON
    output.uvDis = float4(0, 0, 0, 0);
#endif
#ifdef _DISTORTION_ON
    float2 uvDistortion = lerp(uvMain.xy, uv2.xy, _DistortionTex_UVType);
    output.uvDis.xy = RotateUV(TRANSFORM_TEX(uvDistortion, _DistortionTex), _DistortionTex_RotateAngle, 1);
    if (_DistortionTex_UseRotateSpeed > 0)
    {
        output.uvDis.xy = RotateUVBySpeed(TRANSFORM_TEX(uvDistortion, _DistortionTex), _DistortionTex_RotateSpeed, time);
    }
    output.uvDis.xy += time * float2(_DistortionTex_U, _DistortionTex_V);
#endif
#ifdef _DISSOLUTION_ON
    float2 uvDissolution = lerp(uvMain.xy, uv2.xy, _DissolutionTex_UVType);
    output.uvDis.zw = RotateUV(TRANSFORM_TEX(uvDissolution, _DissolutionTex), _DissolutionTex_RotateAngle, 1);
    if (_DissolutionTex_UseRotateSpeed > 0)
    {
        output.uvDis.zw = RotateUVBySpeed(TRANSFORM_TEX(uvDissolution, _DissolutionTex), _DissolutionTex_RotateSpeed, time);
    }
    output.uvDis.zw += time * float2(_DissolutionTex_U, _DissolutionTex_V);
#endif

#ifdef _MASK_ON
    float2 uvMask = lerp(uvMain.xy, uv2.xy, _MaskTex_UVType);
    if(_POLAR_COORDINATES)
    {
        float2 polarDisabledMaskUV = TRANSFORM_TEX(uvMask, _MaskTex) + customData2.xy;
        float2 polarEnabledMaskUV = lerp(polarDisabledMaskUV, uvMask, _MaskTex_Polar_Coordinates);
        float2 maskUV = lerp(polarDisabledMaskUV, polarEnabledMaskUV, _MaskTex_Polar_Coordinates);
        output.uvMask.xy = RotateUV(maskUV, _MaskTex_RotateAngle, 1);
    }
    else
    {
        output.uvMask.xy = RotateUV(TRANSFORM_TEX(uvMask, _MaskTex) + customData2.xy, _MaskTex_RotateAngle, 1);
    }
    if (_MaskTex_UseRotateSpeed > 0)
    {
        output.uvMask.xy = RotateUVBySpeed(output.uvMask.xy, _MaskTex_RotateSpeed, time);
    }

    float2 uvMask2 = lerp(uvMain.xy, uv2.xy, _MaskTex2_UVType);
    output.uvMask.zw = RotateUV(TRANSFORM_TEX(uvMask2, _MaskTex2), _MaskTex2_RotateAngle, 1);
    if (_MaskTex2_UseRotateSpeed > 0)
    {
        output.uvMask.zw = RotateUVBySpeed(TRANSFORM_TEX(uvMask2, _MaskTex2), _MaskTex2_RotateSpeed, time);
    }
    output.uvMask.zw += time * float2(_MaskTex2_U, _MaskTex2_V);

    float2 uvMask3 = lerp(uvMain.xy, uv2.xy, _MaskTex3_UVType);
    output.uvMask2.xy = RotateUV(TRANSFORM_TEX(uvMask3, _MaskTex3), _MaskTex3_RotateAngle, 1);
    if (_MaskTex3_UseRotateSpeed > 0)
    {
        output.uvMask2.xy = RotateUVBySpeed(TRANSFORM_TEX(uvMask3, _MaskTex3), _MaskTex3_RotateSpeed, time);
    }
    output.uvMask2.xy += time * float2(_MaskTex3_U, _MaskTex3_V);
#endif

    float2 tmpUV = lerp(uvMain.xy, uv2.xy, _MainTex_UVType);
    
    if(_POLAR_COORDINATES)
    {
        float2 polarDisabledMainUV = TRANSFORM_TEX(tmpUV, _MainTex);
        float2 mainUV = lerp(polarDisabledMainUV, tmpUV, _MainTex_Polar_Coordinates);
        output.uvMain = RotateUV(mainUV, _MainTex_RotateAngle, 1);
    }
    else
    {
        output.uvMain = RotateUV(TRANSFORM_TEX(tmpUV, _MainTex), _MainTex_RotateAngle, 1);
    }
    
    if (_MainTex_UseRotateSpeed > 0)
    {
        output.uvMain = RotateUVBySpeed(tmpUV, _MainTex_RotateSpeed, time);
    }
    return output;
}

#ifdef _ENABLE_DECAL_ON
// Decal 移植NiloCat Screen Space Decal
// https://github.com/ColinLeung-NiloCat/UnityURPUnlitScreenSpaceDecalShader/blob/master/URP_NiloCatExtension_ScreenSpaceDecal_Unlit.shader

struct DecalData
{
    float4 viewRayOS;
    float4 cameraPosOS;
};

DecalData GetDecalData(float3 positionVS)
{
    DecalData output;

    // get "camera to vertex" ray in View space
    float3 viewRay = positionVS;

    // [important note]
    //=========================================================
    // "viewRay z division" must do in the fragment shader, not vertex shader! (due to rasteriazation varying interpolation's perspective correction)
    // We skip the "viewRay z division" in vertex shader for now, and store the division value into varying o.viewRayOS.w first,
    // we will do the division later when we enter fragment shader
    // viewRay /= viewRay.z; //skip the "viewRay z division" in vertex shader for now
    output.viewRayOS.w = viewRay.z;//store the division value to varying o.viewRayOS.w
    //=========================================================

    // unity's camera space is right hand coord(negativeZ pointing into screen), we want positive z ray in fragment shader, so negate it
    viewRay *= -1;

    // it is ok to write very expensive code in decal's vertex shader,
    // it is just a unity cube(4*6 vertices) per decal only, won't affect GPU performance at all.
    float4x4 ViewToObjectMatrix = mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V);

    // transform everything to object space(decal space) in vertex shader first, so we can skip all matrix mul() in fragment shader
    output.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
    output.cameraPosOS.xyz = mul(ViewToObjectMatrix, float4(0,0,0,1)).xyz; // hard code 0 or 1 can enable many compiler optimization

    return output;
}

float2 CalculateDecalUV(Varyings input)
{
    // [important note]
    //========================================================================
    // now do "viewRay z division" that we skipped in vertex shader earlier.
    input.viewRayOS.xyz /= input.viewRayOS.w;
    //========================================================================

    float2 screenSpaceUV = input.positionScreen.xy / input.positionScreen.w;
    float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenSpaceUV);

    float3 decalSpaceScenePos;

    // if perspective camera, LinearEyeDepth will handle everything for user
    // remember we can't use LinearEyeDepth for orthographic camera!
    float sceneDepthVS = LinearEyeDepth(sceneRawDepth,_ZBufferParams);

    // scene depth in any space = rayStartPos + rayDir * rayLength
    // here all data in ObjectSpace(OS) or DecalSpace
    // be careful, viewRayOS is not a unit vector, so don't normalize it, it is a direction vector which view space z's length is 1
    decalSpaceScenePos = input.cameraPosOS.xyz + input.viewRayOS.xyz * sceneDepthVS;

    // convert unity cube's [-0.5,0.5] vertex pos range to [0,1] uv. Only works if you use a unity cube in mesh filter!
    float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;

    // discard logic
    //===================================================
    // discard "out of cube volume" pixels
    float shouldClip = 0;

    // also discard "scene normal not facing decal projector direction" pixels
    float3 decalSpaceHardNormal = normalize(cross(ddx(decalSpaceScenePos), ddy(decalSpaceScenePos)));//reconstruct scene hard normal using scene pos ddx&ddy
    // compare scene hard normal with decal projector's dir, decalSpaceHardNormal.z equals dot(decalForwardDir,sceneHardNormalDir)
    shouldClip = decalSpaceHardNormal.z > _ProjectionAngleDiscardThreshold ? 0 : 1;

    // call discard
    // if ZWrite is Off, clip() is fast enough on mobile, because it won't write the DepthBuffer, so no GPU pipeline stall(confirmed by ARM staff).
    clip(0.5 - abs(decalSpaceScenePos) - shouldClip);
    //===================================================

    return decalSpaceUV.xy;
}
#endif

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.color = input.color;
    PARTICLE_COLOR(output.color)
    // 自定义数据
    // output.texcoord xy : uv    z: HDR强度; w: 溶解进度
    // texcoord1  x: 扭曲强度;  y: 顶点动画强度  z: MASK U偏移 w:  MASK V偏移
    // texcoord2  暂未定义
    output.texcoord = input.texcoord;
    output.texcoord1 = input.texcoord1;
    output.texcoord2 = input.texcoord2;
    output.normalWS = vertexNormalInput.normalWS;
    output.tangentWS = vertexNormalInput.tangentWS;
    output.bitangentWS = vertexNormalInput.bitangentWS;

    float3 posOS = input.positionOS.xyz;

    float time = fmod(_Time.x, 10);

    half4 customData1 = lerp(half4(0,0,0,0), half4(input.texcoord.zw, input.texcoord1.xy), _INPUT_CUSTOMDATA);
    half2 customData2 = lerp(half2(0,0), input.texcoord1.zw, _INPUT_CUSTOMDATA2);

    // 顶点动画
    #ifdef _VERTEX_ON
        float2 uvVertexByType = lerp(input.texcoord.xy, input.texcoord1.xy, _VertexTex_UVType);
        float2 uvVertex = RotateUV(TRANSFORM_TEX(uvVertexByType, _VertexTex), _VertexTex_RotateAngle, 1);
        if (_VertexTex_UseRotateSpeed > 0)
        {
            uvVertex = RotateUVBySpeed(TRANSFORM_TEX(uvVertexByType, _VertexTex), _VertexTex_RotateSpeed, time);
        }
        uvVertex += time * float2(_VertexTex_U, _VertexTex_V);
        half4 varVertexTex = tex2Dlod(_VertexTex, float4(uvVertex, 0, 0));

        half customVertexIntensity = lerp(_VertexIntensity, customData1.w, any(customData1.w));

        posOS += input.normalOS * dot(varVertexTex, _VertexTex_ChannelMask) * customVertexIntensity;
    #endif
    VertexPositionInputs vertexInput = GetVertexPositionInputs(posOS);
    output.positionCS = vertexInput.positionCS;
    
    #if defined(_ENABLE_FLATTEN)
    // 1.计算顶点沿着相机朝向需要前进的距离，然后获得该类似正交视角的顶点。
    // 2.计算顶点沿着相机视线方向需要前进的距离，并根据正交顶点和原顶点求出透视视角下顶点的期望位置。
    float3 flattenDirection = normalize(_CameraForward.xyz);
    float3 camViewDirection = normalize(vertexInput.positionWS.xyz - _CameraPos.xyz);
    float3 originPos = float3(0, 0, 0) - flattenDirection * _FlattenPlaneOffset;
    float flattenProjectionDistance = dot(vertexInput.positionWS.xyz - originPos, flattenDirection);
    float3 flattenProjection = flattenProjectionDistance * flattenDirection;
    float safeNormViewProjFlatten = saturate(abs(dot(flattenDirection, camViewDirection)));
    float viewProjectionDistance = flattenProjectionDistance / safeNormViewProjFlatten;
    float3 viewProjection = viewProjectionDistance * camViewDirection;
    float3 flattenedVertex = vertexInput.positionWS.xyz - viewProjection;
    float diffProjFromPos2OriginInObjSpace = dot(flattenDirection, _FlattenWorldOriginPos - vertexInput.positionWS.xyz);
    float invViewProjDis = diffProjFromPos2OriginInObjSpace / safeNormViewProjFlatten;
    flattenedVertex -= camViewDirection * invViewProjDis * _FlattenFactor;
	
    vertexInput.positionWS = flattenedVertex;
    output.positionCS = TransformWorldToHClip(vertexInput.positionWS);
    vertexInput.positionCS = output.positionCS;
    #endif

    #ifdef _ENABLE_DECAL_ON
        DecalData decalData = GetDecalData(vertexInput.positionVS);
        output.viewRayOS = decalData.viewRayOS;
        output.cameraPosOS = decalData.cameraPosOS;
    #else
        UVData uvData = GetUVData(input.texcoord.xy, input.texcoord1.xy, time, customData1, customData2);
        output.texcoord.xy = uvData.uvMain;
        #if defined(_DISTORTION_ON) || defined(_DISSOLUTION_ON)
            output.uvDis = uvData.uvDis;
        #endif
        #ifdef _MASK_ON
            output.uvMask = uvData.uvMask;
            output.uvMask2 = uvData.uvMask2;
        #endif
    #endif
    // no use here
    //float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    output.positionWSAndFogFactor = float4(vertexInput.positionWS, 0/*fogFactor*/);
    output.positionScreen = ComputeScreenPos(vertexInput.positionCS);
    output.positionScreen.z = -vertexInput.positionVS.z;
    #ifndef _PIXELFOG_ON
        CustomMixFogColor( output.positionWSAndFogFactor, output.fogColor.xyz, output.fogColor.w);
    #endif
    return output;

}

	inline GeneralSurfaceData InitializeFASurfaceDataCustom(Varyings input, half4 color, half3 normal, half facing = 1)
	{
		//Varyings input = input.varyingsBase;

		GeneralSurfaceData outSurfaceData = (GeneralSurfaceData)0;

		outSurfaceData.albedo = color.rgb;
		outSurfaceData.alpha = 1;
		outSurfaceData.occlusion = 1;
		outSurfaceData.metallic = _Metallic;
		outSurfaceData.smoothness = _Smoothness;
		outSurfaceData.normalWS = normal;

		return outSurfaceData;
	}

    half4 OutputSceneObjectStandardColor(Varyings input, GeneralSurfaceData surfaceData, half facing = 1)
	{
		float3 normalWS = surfaceData.normalWS;
		normalWS = normalize(normalWS) * facing;

		float3 positionWS = input.positionWSAndFogFactor.xyz;
		float3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);

		GeneralBRDFData brdfData;
		InitializeFABRDFData(surfaceData, brdfData);

		//#ifdef LIGHTMAP_ON
			half3 bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, normalWS);
            bakedGI = lerp(_BekeGIColor.rgb, bakedGI, _CustomBakeGIColor);
		//#else
		//	half3 bakedGI = lerp(SampleSH(normalWS), max(0, _CharacterAmbientColor.rgb), _UseCharacterAmbient);
		//#endif

		#ifdef _MAIN_LIGHT_SHADOWS
			Light mainLight = GetMainLight(input.shadowCoord);
		#else
			Light mainLight = GetMainLight();
		#endif


		float2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);

		//half atten = clamp(mainLight.shadowAttenuation, 0, 1);

		half3 color = FAGlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS, uvScreen, 1);
		
#ifdef LIGHTMAP_ON
		half grey = Luminance(bakedGI);//bakedGI.r * 0.29 + bakedGI.g * 0.59 + bakedGI.b * 0.12;
#else
		half grey = 1;
#endif
		mainLight.color = lerp(mainLight.color * grey, mainLight.color, smoothstep(0.0, 0.2, grey));
		color += FALightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);

			// URP Lighting
			uint pixelLightCount = GetAdditionalLightsCount();
			for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
			{
				Light light = GetAdditionalLight(lightIndex, positionWS);

				light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
				color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
			}

        float4 final_color = half4(color, 1);

		return final_color;
	}

half4 frag(Varyings input, half facing : VFACE) : SV_Target
{
    half faceSign = saturate(-facing);		// 0,1

    float4 color = input.color * _Intensity;

    float time = fmod(_Time.x, 10);
    
    float2 uvMain = input.texcoord.xy;
        
    half4 customData1 = lerp(half4(0,0,0,0), half4(input.texcoord.zw, input.texcoord1.xy), _INPUT_CUSTOMDATA);
    half2 customData2 = lerp(half2(0,0), input.texcoord1.zw, _INPUT_CUSTOMDATA2);

    #ifdef _ENABLE_DECAL_ON
        float2 decalUV = CalculateDecalUV(input);
        UVData uvData = GetUVData(decalUV, float2(0, 0), time, customData1, customData2);
        uvMain = uvData.uvMain;
    #else
        UVData uvData;
        uvData.uvMain = uvMain;
        #if defined(_DISTORTION_ON) || defined(_DISSOLUTION_ON)
            uvData.uvDis = input.uvDis;
        #endif
        #ifdef _MASK_ON
            uvData.uvMask = input.uvMask;
            uvData.uvMask2 = input.uvMask2;
        #endif
    #endif
    if(_POLAR_COORDINATES)
    {
        uvMain = PolarCoordinatesUV(_Main_Rot_01, uvMain, _MainTex_Polar_Coordinates);
        uvMain = lerp(uvMain, TRANSFORM_TEX(uvMain, _MainTex), _MainTex_Polar_Coordinates);
    }
    uvMain.xy += time * float2(_MainTex_U, _MainTex_V);

    // 增强（曝光）
    half customIntensity = lerp(1, customData1.x, any(customData1.x));

    // 扭曲
    #ifdef _DISTORTION_ON
        // 扭曲强度
        half customDistortionIntensity = lerp(_DistortionIntensity, customData1.z, any(customData1.z));
        uvMain = GetDistortionUV(uvMain, input.uvDis.xy, customDistortionIntensity);
    #endif
    // 法线
    half3 normalWS;
#ifdef _ENABLE_NORMAL_ON
    {
        half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uvMain);
        half3 normalTS = UnpackNormalScale(n, _BumpScale) * facing;
        normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
    }
#else
    {
        normalWS = normalize(input.normalWS) * facing;

    }
#endif
    // 主贴图
    half4 varMainTex = PARTILE_TEXTURE2D(_MainTex, sampler_MainTex, uvMain, _MainTex_ChannelMask);
    if (_NotForMainColor > 0)
    {
        varMainTex.rgb = lerp(varMainTex.rgb, Luminance(varMainTex.rgb), _Desaturate);
    }
    color *= varMainTex;

    // 叠加颜色
    half4 doubleFaceColor = lerp(_DoubleFaceColor, _DoubleFaceColor2, faceSign);
    float4 tintColor = lerp(_Color, doubleFaceColor, _Enable_DoubleFaceColor);
    PARTICLE_COLOR(tintColor);
    color *= tintColor;

    // 避免Alpha受_Intensity放大影响
    //color.a = saturate(input.color.a - 0.03) * saturate(varMainTex.a - 0.03) * saturate(tintColor.a - 0.03);
    color.a = saturate(input.color.a * varMainTex.a * tintColor.a - 0.01);

    // Contrast
    color.rgb = lerp(half3(0.5, 0.5, 0.5), color.rgb, _Contrast);

    // 灰色重着色
    if(_Enable_GrayOverlay)
    {
        color = GetGrayOverlayColor(color, customIntensity);
    }
    else
    {
        color = color * customIntensity;
    }

    // 遮罩
    #ifdef _MASK_ON
        if(_POLAR_COORDINATES)
        {
            uvData.uvMask.xy = PolarCoordinatesUV(_Mask_Rot_01, uvData.uvMask.xy, _MaskTex_Polar_Coordinates);
            uvData.uvMask.xy = lerp(uvData.uvMask.xy, TRANSFORM_TEX(uvData.uvMask.xy, _MaskTex) + customData2.xy, _MaskTex_Polar_Coordinates);
        }
        
        uvData.uvMask.xy += time * float2(_MaskTex_U, _MaskTex_V);
        half4 varMaskTex = PARTILE_TEXTURE2D(_MaskTex, sampler_MaskTex,  uvData.uvMask.xy, _MaskTex_ChannelMask);
        half4 varMaskTex2 = PARTILE_TEXTURE2D(_MaskTex2, sampler_MaskTex2, uvData.uvMask.zw, _MaskTex2_ChannelMask);
        half4 varMaskTex3 = PARTILE_TEXTURE2D(_MaskTex3, sampler_MaskTex3, uvData.uvMask2.xy, _MaskTex3_ChannelMask);
        color *= varMaskTex * varMaskTex2 * varMaskTex3;
    #endif

    // 溶解
    #ifdef _DISSOLUTION_ON
        // 溶解强度
        half customDissolutionPercent = lerp(_DissolutionPercent, customData1.y, any(customData1.y));
        color = GetDissolutionColor(color, uvData.uvDis.zw, customDissolutionPercent);
    #endif

    // AlphaClip
    #ifdef _ALPHATEST_ON
        clip(color.a - _Cutoff);
    #endif

    // 菲涅尔
    if(_Enable_Fresnel)
    {
        float3 positionWS = input.positionWSAndFogFactor.xyz;
        half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
        half NdotV = saturate(dot(normalWS, viewDirectionWS));
        half fresnelFactor = 1 - NdotV;

        if (_FresnelAlpha > 0)
        {
            color.a *= (1 - fresnelFactor * _FresnelAlphaIntensity) * _GFresnelAlpha;
        }
        else
        {
            half fresnelPower = lerp(_FresnelPower, _FresnelPower2, faceSign);
            half fresnelIntensity = lerp(_FresnelIntensity, _FresnelIntensity2, faceSign);
            half fresnel = pow(max(0.0001, fresnelFactor), fresnelPower) * fresnelIntensity;  // fresnelFactor做保护，metal会分解pow函数执行log2，fresnelFactor不能为0
            half4 fresnelColor = _FresnelColor;
            PARTICLE_COLOR(fresnelColor);
            color.rgb += (fresnelColor.rgb * fresnel) * _GFresnelAlpha;
        }
    }

    // 切边羽化（交界处透明）
    // 相当于 SoftParticles
#ifdef _DEPTH_FADE_ON    
        color.a *= GetDepthFade(input.positionScreen);
#endif
    // 去色
    if (_NotForMainColor < 1)
    {
        color.rgb = lerp(color.rgb, Luminance(color.rgb), _Desaturate);
    }

#ifdef _SWITCHPBR
    GeneralSurfaceData surfaceData = InitializeFASurfaceDataCustom(input, color, normalWS);
	color.rgb = OutputSceneObjectStandardColor(input, surfaceData, facing).rgb;
#endif



        #ifdef _PIXELFOG_ON
		CustomMixFogColor(input.positionWSAndFogFactor.xyz, input.fogColor.xyz, input.fogColor.w);
		#endif        
    color.rgb = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);
    // Alpha溢出处理
    if (_AlphaOverflow > 0)
    {
        half alphaSign = step(1, color.a);
        color.rgb = lerp(color.rgb, color.rgb * color.a, alphaSign);
    }
    color.a = saturate(color.a);

    // UI Alpha Mask
#ifdef UI_ALPHA_MASK
    color.a *= UI_ALPHA_MASK_FRAG_COLOR(input.positionWSAndFogFactor.xyz);
#endif
#ifdef _ALPHAPREMULTIPLY_ON
    color.rgb *= color.a;
#endif

    color.a *= _TPA;
    
    color *= _GAlpha;
    
#ifdef _DOF_ALPHA_CLIP
        //clip(color.a - 1.0f/255.0f);
        clip(color.a - _DepthClip);
        //clip(color - 1.0f/255.0f);
#endif
    //return half4(0.5, 0.5, 0.5, 0);
// #ifdef TRANSPARENT_FOG_ON
//     #ifdef _APPLY_VOLUMETRIC_FOG_COLOR
//         return ApplyAndBlendFogColor(input.positionWSAndFogFactor.xyz, input.positionScreen, _Fog_Blend_Mode, color);
//     #endif
// #endif
		

		
	
    return color;
}
#endif