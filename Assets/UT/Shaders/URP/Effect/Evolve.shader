Shader "URP/MoleGame/Effects/Evolve"
{
    Properties
    {
        [MainTexture]_MainTex ("Main Texture", 2D) = "white" {}
        [MainColor]_Color ("Main Color", Color) = (1,1,1,1)
        _EvolvePercent("Evolve Percent", Range(0,1)) = 0
        _EvolveParams("传送线粗细;顶点Y轴偏移;传送线断层大小;模型原点Y偏移", Vector) = (0.3,3,0.3,0)
        [HDR]_TransitionColor("Transition Color", Color) = (1,1,0,1)
        _TransitionLength("Transition Length", Float) = 0.4
        _ModelHeight("Model Height", Float) = 2
        
        //TAA用的stencil
		[HideInInspector]_SkipTAA("Skip TAA", int) = 0
		//生效的时候这2个都是16
		[HideInInspector]_TAAStencil("TAA Stencil Ref (Default: 0)", Float) = 16
		[HideInInspector]_TAAStencilMask("TAA Stencil Write Mask (Default: 0)", Float) = 16
		//0是keep 2是Replace
		[HideInInspector]_TAAStencilPassOperate("Stencil Operate (Default: 0)", Float) = 2
    }

    HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "../FALib/FAShaderUtils.hlsl"

        TEXTURE2D(_MainTex);        SAMPLER(sampler_MainTex);
        CBUFFER_START(UnityPerMaterial)
        uniform float4 _MainTex_ST;
        uniform half4 _Color;
        uniform half _EvolvePercent;
        uniform half4 _EvolveParams;
        uniform half4 _TransitionColor;
        uniform half _TransitionLength;
        uniform half _ModelHeight;
        CBUFFER_END

        struct Attributes {
            float4 positionOS   : POSITION;
            float2 uv           : TEXCOORD0;
        };
        struct Varyings {
            float4 positionCS               : SV_POSITION;
            float2 uv                       : TEXCOORD0;
            float3 positionWS               : TEXCOORD1;
            float4 result                   : TEXCOORD2;
        };

        half Filter(half x, float3 worldPos)
        {
            half threshold = _TransitionLength + sin(worldPos.x * 3) * _TransitionLength * 0.1;
            if (x < threshold && x > 0)
            {
                return pow(x / threshold, 0.3);
                //return a/transitionLength;
            }
            else
            {
                return 1;
            }
        }

        float4 VertOffset(float4 posWorld, out float4 result, inout half4 clipPos)
        {
            float4 pos = posWorld;
            half scaleY = 1 / length(unity_WorldToObject[1].xyz);
            // 找到模型的脚底坐标。因为skinMeshRender会根据骨骼绑定会修改模型原点的坐标问题，
            // 这里专门模型的原点+一个世界空间的偏移数值来确定模型的脚底坐标
            float4 modelFootPos = float4(0, 0, 0, 1);
            float modelWorldPosY = mul(unity_ObjectToWorld, modelFootPos).y + _EvolveParams.w * scaleY;
            // 滑动条控制当前滑到了模型身体的哪个部位
            half vertHeightPercent = saturate((posWorld.y - modelWorldPosY) / (_ModelHeight * scaleY));
            float deltaThres = (_EvolvePercent - vertHeightPercent);

            result.x = deltaThres;
            result.y = modelWorldPosY;
            result.zw = 0;

            // 滑动条滑过去的部分，将顶点朝指定的方向移动指定的距离
            if (deltaThres < 0)
            {
                float4x4 translateMat = float4x4(float4(1, 0, 0, 0), float4(0, 1, 0, _EvolveParams.y), float4(0, 0, 1, 0), float4(0, 0, 0, 1));
                float4 translatedWorldPos = mul(translateMat, posWorld);
                clipPos = mul(UNITY_MATRIX_VP, translatedWorldPos);
                pos = translatedWorldPos;
            }
            return pos;
        }

        half4 PixelEvolve(half4 sourceColor, float3 worldPos, float2 params)
        {
            half3 output = sourceColor.rgb;
            half scaleY = 1 / length(unity_WorldToObject[1].xyz);
            float3 posWorld = worldPos;
            half3 result;
            float deltaThres = params.x;
            float modelWorldPosY = params.y;
            float worldModelHeight = _ModelHeight * scaleY;
            if (deltaThres > 0)
            {
                // 沿着滑动条滑动的方向，有一个颜色的渐变
                half t = Filter(deltaThres, posWorld.xyz);
                result.xyz = lerp(_TransitionColor * 2, output.xyz, t);
                half3 colorAdditive = step(_EvolvePercent * worldModelHeight + modelWorldPosY + 0.7 + 0.2 * sin(posWorld.x * 15), posWorld.y);
                result.xyz += colorAdditive;
            }
            // 用噪波来形成传送线
            float middleY = _EvolvePercent * worldModelHeight + modelWorldPosY;
            float worldPercent = (posWorld.y - modelWorldPosY) / worldModelHeight;
            // 用一个sin波，让颜色渐变的边缘避免看着太平整
            middleY += sin(posWorld.x * 100) * 0.2;
            half tConcact = 0;
            half tx = 0;
            half ty = 0;

            // 使用柏林噪声来挖空拉伸的三角形，有一种传送线线条的感觉
            if (worldPercent > _EvolvePercent)
            {
                half lineWidth = _EvolveParams.x;
                half ybreakLength = _EvolveParams.z;

                float theta = posWorld.x + posWorld.y + posWorld.z;
                // 传送线与滑动条连接处的断层部分
                tConcact = worldPercent - _EvolvePercent - sin(theta * 20) * 0.1 - cos(theta * 2 + 1) * 0.03;
                //clip();
                // 水平方向的传送线生成
                half sinVal = sin(posWorld.x);
                tx = fmod((sinVal * sinVal * 25), 2) * lineWidth - 0.5;
                //clip(tx);
                theta = posWorld.x * posWorld.x * 0.03 + posWorld.y;
                // 传送线在Y轴方向的断层
                sinVal = sin(theta * 0.1);
                ty = perlin_noise(float2(posWorld.x + posWorld.z, posWorld.y) * 4) + 0.5 - ybreakLength;
            }
            clip(float4(deltaThres, tx, ty, tConcact));
            //half scalew = length(unity_ObjectToWorld[1].xyz);
            //result.xyz = scalew;
            half sinVal = sin(posWorld.x);
            sinVal = (sinVal * sinVal * 25);
            sinVal = fmod(sinVal, 2) * _EvolveParams.x - 0.5;
            return half4(result.xyz, 1);
        }
        Varyings EvolveVertex(Attributes input)
        {
            Varyings output = (Varyings)0;
            VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
            float4 params;
            float4 clipPos = vertexInput.positionCS;
            float4 posWorld = float4(vertexInput.positionWS, 1);
            posWorld = VertOffset(posWorld, params, clipPos);
            output.result = params;
            output.positionCS = clipPos;
            output.positionWS = posWorld.xyz;
            output.uv = TRANSFORM_TEX(input.uv, _MainTex);
            return output;
        }

        half4 EvolveFragment(Varyings input, half facing : VFACE) : SV_Target
        {
            half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _Color;
            return PixelEvolve(color, input.positionWS, input.result.xy);
        }
    ENDHLSL

    SubShader
    {
        Tags { 
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent" 
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 200

        Pass {
            Name "StandardLit"
            Tags {
                "LightMode" = "SceneEffect"
            }
            
            //跳过TAA处理的Mask
            Stencil {
                Ref [_TAAStencil]
                WriteMask [_TAAStencilMask]
                Comp always
                Pass [_TAAStencilPassOperate]
            }

            HLSLPROGRAM
            #pragma vertex EvolveVertex
            #pragma fragment EvolveFragment
            ENDHLSL
        }

        Pass {
            Name "StandardLit"
            Tags {
                "LightMode" = "Effect"
            }

            HLSLPROGRAM
            #pragma vertex EvolveVertex
            #pragma fragment EvolveFragment
            ENDHLSL
        }
    }
    CustomEditor "JTRP.ShaderDrawer.LWGUI" 
}
