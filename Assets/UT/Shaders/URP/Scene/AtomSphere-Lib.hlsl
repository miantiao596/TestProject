#ifndef ATOMSPHERELIB_INCLUDE
#define ATOMSPHERELIB_INCLUDE
	
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

	#include "../FALib/FABaseInputMacro.hlsl"
	#include "../FALib/FAEffectLib.hlsl"
			
	BASE_INPUT_BASE_TEX
	TEXTURE2D(_MaskTex);			SAMPLER(sampler_MaskTex);
	TEXTURE2D(_MaskTex2);			SAMPLER(sampler_MaskTex2);

	CBUFFER_START(UnityPerMaterial)
    BASE_INPUT_BASE
	half _Intensity;
            
    half4 _MainTex_ChannelMask;
	half _MainTex_U;
	half _MainTex_V;
	half _MainTex_Rotate_Speed;
	half _MainTex_UVType;
	half _MainTex_Dir;
	float4 _MainTex_Range;

	float4 _MaskTex_ST;
	half4 _MaskTex_ChannelMask;
	half _MaskTex_U;
	half _MaskTex_V;
	half _MaskTex_Rotate_Speed;
	half _MaskTex_Dir;
	float4 _MaskTex_Range;

	float4 _MaskTex2_ST;
	half4 _MaskTex2_ChannelMask;
	half _MaskTex2_U;
	half _MaskTex2_V;
	half _MaskTex2_Rotate_Speed;

	float _MaskTex_UVType;
	float _MaskTex2_UVType;
	CBUFFER_END

	struct Attributes
	{
		float4 positionOS	: POSITION;
		float2 uv			: TEXCOORD0;
		float2 uv2			: TEXCOORD1;
	};

	struct Varyings
	{
		float4 positionCS	: SV_POSITION;
		float2 uv			: TEXCOORD0;
		float2 uvMask		: TEXCOORD1;
		float2 uvMask2		: TEXCOORD2;
	};
            
            
    inline half2 RotateUV(half2 sourceUV, float speed)
    {             
        float2 uv = sourceUV.xy - float2(0.5, 0.5);
        float2 rotate = float2(cos(speed * _Time.x), sin(speed * _Time.x));
        uv = float2(uv.x * rotate.x - uv.y * rotate.y, uv.x * rotate.y + uv.y * rotate.x);
        uv += float2(0.5, 0.5);
        return uv;
    }
	
	
	Varyings vert (Attributes input)
	{
		Varyings output;

		VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
		output.positionCS = vertexInput.positionCS;
		//output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                
        float2 posOS = float2(input.positionOS.x, input.positionOS.y + input.positionOS.z);
		float2 posWS = float2(vertexInput.positionWS.x, vertexInput.positionWS.z); 
				
		float2 mainTexUV = input.uv;
		if(_MainTex_UVType == 1) // uv2
		{
			mainTexUV = input.uv2;
		}
		else if(_MainTex_UVType == 2) // 模型坐标
		{
			mainTexUV = posOS;
		}
		else if(_MainTex_UVType == 3) // 世界坐标
		{
			if(_MainTex_Dir == 1) // XY
			{
				posWS = float2(vertexInput.positionWS.x, vertexInput.positionWS.y); 
			}
			else if(_MainTex_Dir == 2) //YZ
			{
				posWS = float2(vertexInput.positionWS.y, vertexInput.positionWS.z); 
			}
			// for width
			mainTexUV.x = (posWS.x - _MainTex_Range.x) / (_MainTex_Range.y - _MainTex_Range.x);
			// for height
			mainTexUV.y = (posWS.y - _MainTex_Range.z) / (_MainTex_Range.w - _MainTex_Range.z);
		}
		output.uv = RotateUV(TRANSFORM_TEX(mainTexUV, _MainTex), _MainTex_Rotate_Speed);
				
		float2 maskTexUV = input.uv;
		if (_MaskTex_UVType == 1)  // uv2
		{
			maskTexUV = input.uv2;
		}
		else if (_MaskTex_UVType == 2)  // 模型坐标
		{       
            maskTexUV = posOS;
		}
		else if (_MaskTex_UVType == 3) // 世界坐标
		{
			if(_MaskTex_Dir == 1) // XY
			{
				posWS = float2(vertexInput.positionWS.x, vertexInput.positionWS.y); 
			}
			else if(_MaskTex_Dir == 2) //YZ
			{
				posWS = float2(vertexInput.positionWS.y, vertexInput.positionWS.z); 
			}
			// for width
			maskTexUV.x = (posWS.x - _MaskTex_Range.x) / (_MaskTex_Range.y - _MaskTex_Range.x);
			// for height
			maskTexUV.y = (posWS.y - _MaskTex_Range.z) / (_MaskTex_Range.w - _MaskTex_Range.z);
		}
		output.uvMask = RotateUV(TRANSFORM_TEX(maskTexUV, _MaskTex), _MaskTex_Rotate_Speed);    
                
        // mask2暂时先不添加世界坐标的扩散功能
        if (_MaskTex2_UVType == 1)
        {
            output.uvMask2 = TRANSFORM_TEX(input.uv2, _MaskTex2);
        }
        else if (_MaskTex2_UVType == 2)
        {
            output.uvMask2 = TRANSFORM_TEX(posOS, _MaskTex2);
        }
        else if (_MaskTex2_UVType == 3)
        {
            output.uvMask2 = TRANSFORM_TEX(posWS, _MaskTex2);
        }
        else
        {
            output.uvMask2 = TRANSFORM_TEX(input.uv, _MaskTex2);
        }
        output.uvMask2 = RotateUV(output.uvMask2, _MaskTex2_Rotate_Speed);
                
		return output;
	}

	half4 frag (Varyings input) : COLOR
	{
		float time = fmod(_Time.x, 10);
		//half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv + time * float2(_MainTex_U, _MainTex_V));
		//half4 mask1 = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, input.uvMask + time * float2(_MaskTex_U, _MaskTex_V));
		//half4 mask2 = SAMPLE_TEXTURE2D(_MaskTex2, sampler_MaskTex2, input.uvMask2 + time * float2(_MaskTex2_U, _MaskTex2_V));
                
        half4 albedo = PARTILE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv + time * float2(_MainTex_U, _MainTex_V), _MainTex_ChannelMask);
		half4 mask1 = PARTILE_TEXTURE2D(_MaskTex, sampler_MaskTex, input.uvMask + time * float2(_MaskTex_U, _MaskTex_V), _MaskTex_ChannelMask);
		half4 mask2 = PARTILE_TEXTURE2D(_MaskTex2, sampler_MaskTex2, input.uvMask2 + time * float2(_MaskTex2_U, _MaskTex2_V), _MaskTex2_ChannelMask);
		//避免alpha超过1,原本的2.5会乘以alpha，并且混合模式为srcAlpha,one,修改后颜色乘两个2.5  
        half4 color = half4(_Color.rgb * _Intensity * albedo.rgb * albedo.a * 2.5 * 2.5, 1) * mask1 * mask2;
		return color;
	}

#endif