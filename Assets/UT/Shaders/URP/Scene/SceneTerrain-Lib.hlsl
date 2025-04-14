#ifndef SCENETERRAIN_INCLUDED
	#define SCENETERRAIN_INCLUDED

	#include "../FALib/FALighting.hlsl"
	#include "../FALib/FAEffectLib.hlsl"
	#include "../FALib/FAHeightFogDebug.hlsl"
	#include "../FALib/FACustomFogLib.hlsl"

	half4 _CharacterAmbientColor;

    struct AttributesSceneObject
    {
    	float4 positionOS   : POSITION;
    	half3 normalOS     : NORMAL;
    	half4 tangentOS    : TANGENT;
    	float4 uv           : TEXCOORD0;
    	float4 uvLM         : TEXCOORD1;
        float2 uv3    : TEXCOORD2;
    	float2 uv4    : TEXCOORD3;
    };
	struct VaryingsSceneObject
	{
		float4 positionCS               : SV_POSITION;
		float4 uvAndUvLM                       : TEXCOORD0;
		float4 positionWSAndFogFactor   : TEXCOORD1; // xyz: positionWS, w: vertex fog factor
		half3  normalWS                 : TEXCOORD2;
		half3 tangentWS				: TEXCOORD3;
		half3 bitangentWS			: TEXCOORD4;
		half4 fogColor               : TEXCOORD5;
		float4	uvCombinedAO				: TEXCOORD6;
		float4	uvBump						: TEXCOORD7;
		float4	uvEmissionAndUV2			: TEXCOORD8;
		float4 uv3AndUV4                    : TEXCOORD9;
		#if _MAIN_LIGHT_SHADOWS || _MAIN_LIGHT_SHADOWS_CASCADE
		float4 shadowCoord			: TEXCOORD10; // compute shadow coord per-vertex for the main light
		#endif
		#ifdef _DIRT_ON
			float4	uvDirtAndExtra			: TEXCOORD11;
		#endif
		#ifdef _TOPDETAIL_ON
			float4	uvTop					: TEXCOORD12;
		#endif
		#ifdef _HEIGHTGRADIENT_ON
		    float2 uvHeightGradient         : TEXCOORD13;
		#endif
	};


	VaryingsSceneObject SceneObjectVertex(AttributesSceneObject input)
	{
		VaryingsSceneObject output = (VaryingsSceneObject)0;

		VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

		// 和VertexPositionInputs差不多，包含了world space中的normal, tangent and bitangent
		// 如果没使用到会被剔除
		VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

		// TRANSFORM_TEX is the same as the old shader library.
		output.uvAndUvLM.xy = input.uv;
		output.uvAndUvLM.zw = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;

		// 目前就使用vertex input中的clip space position
		output.positionCS = vertexInput.positionCS;

		// Computes fog factor per-vertex.
		//float fogFactor = ComputeFogFactorLinear(vertexInput.positionCS.z);
		output.positionWSAndFogFactor = float4(vertexInput.positionWS, 1);

		output.normalWS = vertexNormalInput.normalWS;

		// 上面所说的新的Input结构灵活性在这里可以体现出来
		// 当一个没有定义normal map的变种存在时，tangentWS和bitangentWS不会被引用
		// 而GetVertexNormalInputs只是把normal从object转换到world space中
		// #ifdef _NORMALMAP
		output.tangentWS = vertexNormalInput.tangentWS;
		output.bitangentWS = vertexNormalInput.bitangentWS;
		// #endif

		#if _MAIN_LIGHT_SHADOWS || _MAIN_LIGHT_SHADOWS_CASCADE
		// main light的shadow coord在vertex里计算
		// 如果应用了cascades, URP会在screen space里重构
		// 其他情况下URP会在light space(没有 depth pre-pass and shadow collect pass)里重构shadow
		output.shadowCoord = GetShadowCoord(vertexInput);
		#endif
		
		//output.varyingsBase = LitPassVertex(input);
        output.uv3AndUV4.xy = input.uv3;
		output.uv3AndUV4.zw = input.uv4;
        float2 uvCombinedSmoothnessUV = input.uv.xy;  // UV1
        if(_Smoothness_UVType == 1) //UV2
        {
            uvCombinedSmoothnessUV = input.uvLM.xy;
        }
        else if(_Smoothness_UVType == 4) //UV3
        {
            uvCombinedSmoothnessUV = output.uv3AndUV4.xy;
        }
        else if(_Smoothness_UVType == 5)
        {
            uvCombinedSmoothnessUV = output.uv3AndUV4.zw;
        }

		output.uvCombinedAO.xy = TRANSFORM_TEX(input.uv, _CombinedAO);
		output.uvCombinedAO.zw = uvCombinedSmoothnessUV * _SmoothnessTillingAndOffset.xy + _SmoothnessTillingAndOffset.zw;
		
		output.uvBump.xy = TRANSFORM_TEX(input.uv, _BumpMap);
#ifdef _ENABLE_NORMALADD_ON
		output.uvBump.zw = TRANSFORM_TEX(input.uv, _BumpMap2);
#endif

#ifdef _ENABLE_EMISSIONTEX_ON
		output.uvEmissionAndUV2.xy = TRANSFORM_TEX(input.uv, _EmissionTexture);
#else
		output.uvEmissionAndUV2.xy = float2(1, 1);
#endif

#if defined(_DIRT_ON) && !defined(_LOW_DETAIL)
		{
			output.uvDirtAndExtra.xy = TRANSFORM_TEX(input.uv, _DirtTex);
			// output.uvDirt.zw = TRANSFORM_TEX(input.uv, _DirtMaskTex);
			// output.uvDirtExtra.xy = TRANSFORM_TEX(input.uv, _DirtCombinedAO);
			// output.uvDirtExtra.zw = TRANSFORM_TEX(input.uv, _DirtBumpMap);
			output.uvDirtAndExtra.zw = TRANSFORM_TEX(input.uv, _DirtBumpMap);
		}
#endif
#if defined(_TOPDETAIL_ON) && !defined(_LOW_DETAIL)
		{
			output.uvTop.xy = TRANSFORM_TEX(input.uv, _TopTex);
			output.uvTop.zw = TRANSFORM_TEX(input.uvLM, _TopTex);
			// if (_TopMaskTex_UseUV2 == 0)
			// output.uvTop.zw = TRANSFORM_TEX(input.uv, _TopMaskTex);
			// else
			// output.uvTop.zw = TRANSFORM_TEX(input.uvLM, _TopMaskTex);
		}
#endif
		output.uvEmissionAndUV2.zw = input.uvLM.xy;
		
#ifdef _HEIGHTGRADIENT_ON
        float2 heightUV = input.uv;
        if(_HeightGradientUVType == 1)  //uv2
        {
            heightUV = input.uvLM;
        }    
        else if(_HeightGradientUVType == 3) // 世界坐标
        {
            float2 posWS = float2(output.positionWSAndFogFactor.x, output.positionWSAndFogFactor.z);   // XA
            if(_WorldPos_Dir == 1)
            {
                posWS = float2(output.positionWSAndFogFactor.x, output.positionWSAndFogFactor.y); 
            }else if(_WorldPos_Dir == 2)
            {
                posWS = float2(output.positionWSAndFogFactor.y, output.positionWSAndFogFactor.z); 
            }
            
            heightUV.x = (posWS.x - _CoordinateRange.x) / (_CoordinateRange.y - _CoordinateRange.x);
            heightUV.y = (posWS.y - _CoordinateRange.z) / (_CoordinateRange.w - _CoordinateRange.z);
        }
        output.uvHeightGradient = TRANSFORM_TEX(heightUV, _HeightGradientMaskTex);
#endif
#ifndef _PIXELFOG_ON
		CustomMixFogColor(vertexInput.positionWS, output.fogColor.xyz, output.fogColor.w);
#endif
        //output.uv3AndUV4.xy = input.uv3;
        //output.positionScreen = ComputeScreenPos(output.varyingsBase.positionCS);
		return output;
	}

	half GetWeightValue(TEXTURE2D_ARRAY_PARAM(textureName, samplerName), float2 uv, int id)
	{
		int texIndex = id/4;
		int channel = id - texIndex * 4;
		half4 weight = SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, uv, texIndex);
		return weight[channel];
	}

	struct SceneTerrainMapData
	{
		half4 albedo;
		half3 normalTS;
		half  metallic;
		half  smoothness;
	};

	SceneTerrainMapData CalculateTerrainMapData_Mipmap(float2 uv, int i, float md)
	{
		SceneTerrainMapData outData = (SceneTerrainMapData)0;
		//计算mipmap
		half tile = max(_LayerTilingAndOffset[i].x, _LayerTilingAndOffset[i].y);
		md *= tile * tile;
		float mipmap = max(0.5 * log2(md) - 1, 0);
		
		float2 tex_uv = uv * _LayerTilingAndOffset[i].xy + _LayerTilingAndOffset[i].zw;
		half4 col = SAMPLE_TEXTURE2D_ARRAY_LOD(_BaseMapArray, sampler_BaseMapArray, tex_uv, i, mipmap);
		outData.albedo = col;
		half4 normal = SAMPLE_TEXTURE2D_ARRAY_LOD(_BumpMapArray, sampler_BumpMapArray, tex_uv, i, mipmap);
		half3 normalTS = UnpackNormalScale(normal, _LayerBumpScale[i]);
		outData.normalTS = normalTS;
		half metallic = 0;//_LayerMetallic[i];
		half smoothness = _LayerSmoothness[i] * col.a;
		outData.metallic = metallic;
		outData.smoothness = smoothness;
		return outData;
	}

	SceneTerrainMapData CalculateTerrainMapData_Mipmap_Simple(float2 uv, int i, float md)
	{
		SceneTerrainMapData outData = (SceneTerrainMapData)0;
		//计算mipmap
		half tile = max(_LayerTilingAndOffset[i].x, _LayerTilingAndOffset[i].y);
		md *= tile * tile;
		float mipmap = max(0.5 * log2(md) - 1, 0);
		
		float2 tex_uv = uv * _LayerTilingAndOffset[i].xy + _LayerTilingAndOffset[i].zw;
		half4 col = SAMPLE_TEXTURE2D_ARRAY_LOD(_BaseMapArray, sampler_BaseMapArray, tex_uv, i, mipmap);
		half metallic = 0;//_LayerMetallic[i];
		half smoothness = _LayerSmoothness[i];
		outData.metallic = metallic;
		outData.smoothness = smoothness * col.a;
		outData.albedo = col;
		return outData;
	}

	SceneTerrainMapData BlendTerrainMap(SceneTerrainMapData map1, SceneTerrainMapData map2, SceneTerrainMapData map3, SceneTerrainMapData map4, float4 weight)
	{
		SceneTerrainMapData outData = (SceneTerrainMapData)0;
		half totalWeight = dot(weight, half4(1, 1, 1, 1));
		weight /= (totalWeight + 1e-3f);
		//blend four
		outData.albedo = map1.albedo * weight.r + map2.albedo * weight.g + map3.albedo * weight.b + map4.albedo * weight.a;
		outData.metallic = map1.metallic * weight.r + map2.metallic * weight.g + map3.metallic * weight.b + map4.metallic * weight.a;
		outData.smoothness = map1.smoothness * weight.r + map2.smoothness * weight.g + map3.smoothness * weight.b + map4.smoothness * weight.a;
		half lostWeight = weight.b + weight.a;
		weight += lostWeight / 2;
		outData.normalTS = map1.normalTS * weight.r + map2.normalTS * weight.g;
		return outData;
	}

	float sum4(float4 v)
	{
		return v.x + v.y + v.z + v.w;
	}

	float2 GetHalfPixelUV(float2 uv, float texSize)
	{

		uv -= 1.0 / texSize;
		float texHalfSize = texSize * 0.5f;

		float2 halfUV = floor(uv * texHalfSize) / texHalfSize;

		float2 halfUVLerp = frac(uv * texHalfSize) / texHalfSize;

		return halfUV + halfUVLerp * 0.5 + 0.5 / texSize;
	}

	// 对应官方的InitializeSurfaceData
	inline FASurfaceData InitializeFASurfaceDataCustom(VaryingsSceneObject input, half facing = 1)
	{
		//Varyings input = input.varyingsBase;

		FASurfaceData outSurfaceData = (FASurfaceData)0;
		float2 uv1 = input.uvAndUvLM.xy;

		SceneTerrainMapData outData_1 = (SceneTerrainMapData)0;
		SceneTerrainMapData outData_2 = (SceneTerrainMapData)0;
		SceneTerrainMapData outData_3 = (SceneTerrainMapData)0;
		SceneTerrainMapData outData_4 = (SceneTerrainMapData)0;
		SceneTerrainMapData outData_final = (SceneTerrainMapData)0;


		const float offsetBilinearFix =   1.0f / 512;
		half2 offsetFix = -half2(0.5, 0.5) / _IDSplatTexSize;
		
		half2 uv_00 = uv1 + offsetFix;
		half2 uv_10 = uv_00 + float2(1.0, 0.0) / _IDSplatTexSize;
		half2 uv_01 = uv_00 + float2(0.0, 1.0) / _IDSplatTexSize;
		half2 uv_11 = uv_00 + float2(1.0, 1.0) / _IDSplatTexSize;
		int4 id_00 = SAMPLE_TEXTURE2D(_IDSplat, sampler_IDSplat, uv_00) * 16 + 0.5;
		/*//shader内进行线性插值
		int4 id_10 = SAMPLE_TEXTURE2D(_IDSplat, sampler_IDSplat, uv_10) * 16 + 0.5;
		int4 id_01 = SAMPLE_TEXTURE2D(_IDSplat, sampler_IDSplat, uv_01) * 16 + 0.5;
		int4 id_11 = SAMPLE_TEXTURE2D(_IDSplat, sampler_IDSplat, uv_11) * 16 + 0.5;

		half2 uv_frac = frac(uv1 * _IDSplatTexSize - 0.5 + offsetBilinearFix);
		
		half4 weight00 = SAMPLE_TEXTURE2D(_WeightSplat, sampler_WeightSplat, uv_00);
		half4 weight10 = SAMPLE_TEXTURE2D(_WeightSplat, sampler_WeightSplat, uv_10);
		half4 weight01 = SAMPLE_TEXTURE2D(_WeightSplat, sampler_WeightSplat, uv_01);
		half4 weight11 = SAMPLE_TEXTURE2D(_WeightSplat, sampler_WeightSplat, uv_11);

		half4 matchWeight10, matchWeight01, matchWeight11;
		matchWeight10.x = sum4((id_00.rrrr == id_10.rgba ? 1 : 0) * weight10);
		matchWeight01.x = sum4((id_00.rrrr == id_01.rgba ? 1 : 0) * weight01);
		matchWeight11.x = sum4((id_00.rrrr == id_11.rgba ? 1 : 0) * weight11);
		
		matchWeight10.y = sum4((id_00.gggg == id_10.rgba ? 1 : 0) * weight10);
		matchWeight01.y = sum4((id_00.gggg == id_01.rgba ? 1 : 0) * weight01);
		matchWeight11.y = sum4((id_00.gggg == id_11.rgba ? 1 : 0) * weight11);
		
		matchWeight10.z = sum4((id_00.bbbb == id_10.rgba ? 1 : 0) * weight10);
		matchWeight01.z = sum4((id_00.bbbb == id_01.rgba ? 1 : 0) * weight01);
		matchWeight11.z = sum4((id_00.bbbb == id_11.rgba ? 1 : 0) * weight11);

		matchWeight10.w = sum4((id_00.aaaa == id_10.rgba ? 1 : 0) * weight10);
		matchWeight01.w = sum4((id_00.aaaa == id_01.rgba ? 1 : 0) * weight01);
		matchWeight11.w = sum4((id_00.aaaa == id_11.rgba ? 1 : 0) * weight11);
		half4 blendWeight = lerp(lerp(weight00, matchWeight10, uv_frac.x), lerp(matchWeight01, matchWeight11, uv_frac.x), uv_frac.y);

		float2 dx = ddx(uv1);
		float2 dy = ddy(uv1);
		float md = max(dot(dx, dx), dot(dy, dy)) * _BaseMapSize * _BaseMapSize;
		outData_1 = CalculateTerrainMapData_Mipmap(uv1, id_00.r, md);
		outData_2 = CalculateTerrainMapData_Mipmap(uv1, id_00.g, md);
		outData_3 = CalculateTerrainMapData_Mipmap_Simple(uv1, id_00.b, md);
		outData_4 = CalculateTerrainMapData_Mipmap_Simple(uv1, id_00.a, md);
		*/
		half4 blendWeight = SAMPLE_TEXTURE2D(_WeightSplat, sampler_WeightSplat, GetHalfPixelUV(uv1, _IDSplatTexSize * 2));
		float2 dx = ddx(uv1);
		float2 dy = ddy(uv1);
		float md = max(dot(dx, dx), dot(dy, dy)) * _BaseMapSize * _BaseMapSize;
		outData_1 = CalculateTerrainMapData_Mipmap(uv1, id_00.r, md);
		outData_2 = CalculateTerrainMapData_Mipmap(uv1, id_00.g, md);
		outData_3 = CalculateTerrainMapData_Mipmap_Simple(uv1, id_00.b, md);
		outData_4 = CalculateTerrainMapData_Mipmap_Simple(uv1, id_00.a, md);
		outData_final = BlendTerrainMap(outData_1, outData_2, outData_3, outData_4, blendWeight);
		
		half4 main_color = outData_final.albedo;
		half3 normalTS_0 = outData_final.normalTS;
		half4 albedo = main_color;
        
		half4 ao_m_s_e = SAMPLE_TEXTURE2D(_CombinedAO, sampler_CombinedAO, input.uvCombinedAO.xy);
	
		half occlusion = 1;
		half metallic = outData_final.metallic;
		half smoothness = outData_final.smoothness;
		half emission = ao_m_s_e.a;
		
		half3 normalTS = normalTS_0;

#if defined(_DIRT_ON) && !defined(_LOW_DETAIL)
		{
			// 脏迹
			//half4 var_dirt = SAMPLE_TEXTURE2D(_DirtTex, sampler_DirtTex, input.uvDirt.xy);
			half4 var_dirt = _DirtTex.Sample(sampler_DirtTex, input.uvDirtAndExtra.xy);
			half dirtFactor = var_dirt.a;	//SAMPLE_TEXTURE2D(_DirtMaskTex, sampler_DirtMaskTex, input.uvDirt.zw);
			// ao_m_s_e (只取gb通道用)
			//half4 ao_m_s_e_dirt = SAMPLE_TEXTURE2D(_DirtCombinedAO, sampler_DirtCombinedAO, input.uvDirtExtra.xy);
			// metallic
			half metallic_dirt = saturate(_DirtMetal /*ao_m_s_e_dirt.g * _DirtCombinedScaledParams.g*/);
			metallic = lerp(metallic, metallic_dirt, dirtFactor);
			// smoothness
			half smoothness_dirt = saturate((1-_DirtSmoothness) /*(1 - ao_m_s_e_dirt.b) * _DirtCombinedScaledParams.b*/);	//输出的贴图b通道是粗糙度,这里反成光滑度
			smoothness = lerp(smoothness, smoothness_dirt, dirtFactor);
			// albedo
			half3 albedo_dirt = _DirtColor.rgb * var_dirt.rgb;
			albedo.rgb = lerp(albedo.rgb, albedo_dirt, dirtFactor);
			// normal
			//half4 nDirt = SAMPLE_TEXTURE2D(_DirtBumpMap, sampler_DirtBumpMap, input.uvDirtExtra); //input.uvDirtExtra.zw);
			half4 nDirt = _DirtBumpMap.Sample(sampler_DirtTex, input.uvDirtAndExtra.zw);
			half3 normalTS_Dirt = UnpackNormalScale(nDirt, _DirtBumpScale) * facing;
			normalTS_Dirt = half3(normalTS_0.xy + normalTS_Dirt.xy, normalTS_0.z * normalTS_Dirt.z);
			normalTS = lerp(normalTS, normalTS_Dirt, dirtFactor);
		}
#endif
#if defined(_TOPDETAIL_ON) && !defined(_LOW_DETAIL)
		{
			// 顶部细节
			//half4 var_top = SAMPLE_TEXTURE2D(_TopTex, sampler_TopTex, input.uvTop.xy);
			half4 var_top = _TopTex.Sample(sampler_TopTex, input.uvTop.xy);
			if (_TopMaskTex_UseUV2 > 0)
			    var_top.a =  _TopTex.Sample(sampler_TopTex, input.uvTop.zw).a;
				//var_top.a = SAMPLE_TEXTURE2D(_TopTex, sampler_TopTex, input.uvTop.zw).a;
			half3x3 T2W_Matrix  = half3x3(input.tangentWS, input.bitangentWS, input.normalWS);
			half3 normalWS = TransformTangentToWorld(normalTS_0, T2W_Matrix);
			float topFactor = saturate(pow(saturate(normalWS.y) + _TopOffset, _TopPower) * _TopIntensity);
			topFactor *= var_top.a ;	//SAMPLE_TEXTURE2D(_TopMaskTex, sampler_TopMaskTex, input.uvTop.zw);
			// ao_m_s_e (只取gb通道用)
			//half4 ao_m_s_e_top = SAMPLE_TEXTURE2D(_TopCombinedAO, sampler_TopCombinedAO, input.uvTop.xy);
			// metallic
			half metallic_top = saturate(_TopMetal /*ao_m_s_e_top.g * _TopCombinedScaledParams.g*/);
			metallic = lerp(metallic, metallic_top, topFactor);
			// smoothness
			half smoothness_top = saturate((1-_TopSmoothness) /*(1 - ao_m_s_e_top.b) * _TopCombinedScaledParams.b*/);	//输出的贴图b通道是粗糙度,这里反成光滑度
			smoothness = lerp(smoothness, smoothness_top, topFactor);
			// albedo
			half3 albedo_top = _TopColor.rgb * var_top.rgb;
			albedo.rgb = lerp(albedo.rgb, albedo_top, topFactor);
			// normal
			//half4 nTop = SAMPLE_TEXTURE2D(_TopBumpMap, sampler_TopBumpMap, input.uvTop.xy);
			half4 nTop = _TopBumpMap.Sample(sampler_TopTex, input.uvTop.xy);
			half3 normalTS_Top = UnpackNormalScale(nTop, _TopBumpScale) * facing;
			normalTS_Top = half3(normalTS_0.xy + normalTS_Top.xy, normalTS_0.z * normalTS_Top.z);
			normalTS = lerp(normalTS, normalTS_Top, topFactor);
		}
#endif
		outSurfaceData.albedo = albedo.rgb;
		outSurfaceData.alpha = albedo.a;

		outSurfaceData.occlusion = occlusion;
		outSurfaceData.metallic = metallic;
		outSurfaceData.smoothness = smoothness;

#ifdef _ENABLE_EMISSIONTEX_ON
		{
			half4 emission_sample = SAMPLE_TEXTURE2D(_EmissionTexture, sampler_EmissionTexture, input.uvEmissionAndUV2.xy);
			outSurfaceData.emission = emission_sample.rgb * _EmissionColor.rgb * _Emissive_Intensity;
			if (_UseEmissionAlphaMask)
			{
				half3 mask_color = (1 - emission_sample.a) + (emission_sample.a * _EmissionMaskColor.rgb) * _EmissionMaskColorIntensity;
				outSurfaceData.albedo *= mask_color;
			}
		}				
#else
		{
			float3 emission_main = main_color.rgb * _EmissionColor.rgb * _Emissive_Intensity;
			float3 emission_co = emission * (albedo + _EmissionColor).rgb * _Emissive_Intensity;
			outSurfaceData.emission = _MainTexAsEmissionTex ? emission_main : emission_co;
		}
#endif
		outSurfaceData.normalTS = normalTS;

		return outSurfaceData;
	}

	half4 MaskUV2(half4 sourceColor, half2 uv)
	{
	    half4 maskColor = SAMPLE_TEXTURE2D(_UV2Mask, sampler_UV2Mask, TRANSFORM_TEX(uv, _UV2Mask));
	    half clipVal;
	    if(_MASK_UV2_ChannelMask == 0)  // R
	    {
	        clipVal = maskColor.r;
	    }
	    else if(_MASK_UV2_ChannelMask == 1) // G
	    {
	        clipVal = maskColor.g;
	    }
	    else if(_MASK_UV2_ChannelMask == 2) //B
	    {
	        clipVal = maskColor.b;
	    }
	    else
	    {   
	        clipVal = maskColor.a;;
	    }
	    
	    half factor_alph = 1 - clipVal;
        sourceColor.a *= factor_alph;
        clip(sourceColor.a - 0.01);
        sourceColor.a = saturate(sourceColor.a - 0.01);
		return sourceColor;
	}

	half4 OutputSceneObjectStandardColor(VaryingsSceneObject input, FASurfaceData surfaceData, half facing = 1)
	{
		//Varyings input = input.varyingsBase;
		#if defined(_ALPHATEST_ON)
			clip(surfaceData.alpha - _Cutoff);
		#endif
	

		float3 normalWS = TransformTangentToWorld(surfaceData.normalTS, half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
		normalWS = normalize(normalWS) * facing;

		float3 positionWS = input.positionWSAndFogFactor.xyz;
		float3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);

		FABRDFData brdfData;
		InitializeFABRDFData(surfaceData, brdfData);

#if _ENABLE_SHADING_DEBUG
			return OutputDebugColor(surfaceData, brdfData);
#endif

		#ifdef LIGHTMAP_ON
			half3 bakedGI = FASampleLightmap(input.uvAndUvLM.zw, normalWS);
		#else
			half3 bakedGI = lerp(SampleSH(normalWS), max(0, _CharacterAmbientColor.rgb), _UseCharacterAmbient);
		#endif

		#if _MAIN_LIGHT_SHADOWS
		#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
		float4 shadowCoord = input.shadowCoord;
		Light mainLight = GetMainLight(shadowCoord);
		#endif
		#elif _MAIN_LIGHT_SHADOWS_CASCADE
		float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
		Light mainLight = GetMainLight(shadowCoord);
		#else
			Light mainLight = GetMainLight();
		#endif
		
		if(!_EnableURPShadowMapping)
            mainLight.shadowAttenuation = 1;

		float2 uvScreen = GetNormalizedScreenSpaceUV(input.positionCS);

		#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
			AmbientOcclusionFactor aoFactor = CustomGetScreenSpaceAmbientOcclusion(uvScreen);
			mainLight.color *= aoFactor.directAmbientOcclusion;
			surfaceData.occlusion = min(surfaceData.occlusion, aoFactor.indirectAmbientOcclusion);
		#endif

		// half atten = clamp(mainLight.shadowAttenuation, _CombinedScaledParams.w, 1);

		
		float2 offsetuv = input.uvAndUvLM.xy + mainLight.direction * 0.01 * _SeaGrassShadowOffset;
		offsetuv = (offsetuv - half2(_MinBoundX, _MinBoundY)) / _BoundSize;
		offsetuv = clamp(offsetuv, 0, 1);
		half seagrassmask = SAMPLE_TEXTURE2D_LOD(_SeaGrassDistrobutionMask, sampler_SeaGrassDistrobutionMask, offsetuv, 0).x;
		half disCmr = length(positionWS - GetCameraPositionWS());
		seagrassmask *= 1 - smoothstep(_SeaGrassShadowFadeDis - 5, _SeaGrassShadowFadeDis , disCmr);
		
		half vegAtten = (1 - seagrassmask * _SeaGrassShadowDark);
		vegAtten = clamp(vegAtten, 0, 1);
		half atten = min(mainLight.shadowAttenuation, vegAtten);
		mainLight.shadowAttenuation = clamp(atten, _CombinedScaledParams.w, 1);;

		half3 color = FAGlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS, uvScreen, atten);
		
#ifdef LIGHTMAP_ON
		half grey = Luminance(bakedGI);//bakedGI.r * 0.29 + bakedGI.g * 0.59 + bakedGI.b * 0.12;
#else
		half grey = 1;
#endif
		mainLight.color = lerp(mainLight.color * grey, mainLight.color, smoothstep(0.0, 0.2, grey));
		color += FALightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);
		
		//#ifdef _ADDITIONAL_LIGHTS
			//half4 shadowMask = half4(1, 1, 1, 1);
			//uint2 grid;
			//uint additionalLightsCount = ForwardPlusGetAdditionalLightsCount(input.positionCS, grid);
			//Light light;
			//for (int i = 0; i < additionalLightsCount; ++i)
			//{
			//	ForwardPlusGetAdditionalLight(i, grid, positionWS, light);

			//	#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
			//		light.color *= aoFactor.directAmbientOcclusion;
			//	#endif
			//	light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
			//	color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
			//}
		//#endif
#ifdef _FORWARD_PLUS_Z_BINING
		//方向光单独处理，因为方向光肯定会计算，不受culling影响，没必要走tile、zbin那套判断。
			bool isMatch;
			for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_LIGHTS); lightIndex++)
			{
				Light light = ForwardPlusGetAdditionalLight(lightIndex, positionWS, isMatch);
				if(!_EnableURPShadowMapping)
                    light.shadowAttenuation = 1;
				if (isMatch)
				{
					#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
						light.color *= aoFactor.directAmbientOcclusion;
					#endif
					light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
					color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
				}
			}
			ClusteredLightLoop cll = ClusteredLightLoopInit(uvScreen, positionWS);
			while (ClusteredLightLoopNextWord(cll)) {
				while (ClusteredLightLoopNextLight(cll)) { 
					uint lightIndex = ClusteredLightLoopGetLightIndex(cll);
					Light light = ForwardPlusGetAdditionalLight(lightIndex, positionWS, isMatch);
					if(!_EnableURPShadowMapping)
                        light.shadowAttenuation = 1;
					if (isMatch)
					{
						#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
							light.color *= aoFactor.directAmbientOcclusion;
						#endif
						light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
						color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
					}
				}
			}
#else
			// URP Lighting
			uint pixelLightCount = GetAdditionalLightsCount();
			for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
			{
				Light light = GetAdditionalLight(lightIndex, positionWS);
				
				if(!_EnableURPShadowMapping)
				    light.shadowAttenuation = 1;
                    
                    
				#if defined(_CUSTOM_SCREEN_SPACE_OCCLUSION)
					light.color *= aoFactor.directAmbientOcclusion;
				#endif
				light.color = lerp(light.color * grey, light.color, smoothstep(0.0, 0.2, grey));
				color += FALightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
			}
#endif

		color += surfaceData.emission;

		half alpha = 1.0;
		#if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
			alpha = surfaceData.alpha;
		#endif

		#ifdef _DISSOLVE_ON
		    half2 dissolve_uv = input.uvAndUvLM.xy;
		    if (_DissolveMaskTex_UseUV2 == 1)  // UV2
		    {
		        dissolve_uv = input.uvEmissionAndUV2.zw;
		    } 
		    else if(_DissolveMaskTex_UseUV2 == 2) // 世界坐标
		    {
		        float2 posWS = float2(positionWS.x, positionWS.z); 
		        if(_DissolveMaskTex_Dir == 1)
		        {
		            posWS = float2(positionWS.x, positionWS.y); 
		        }
		        else if(_DissolveMaskTex_Dir == 2)
		        {
		            posWS = float2(positionWS.y, positionWS.z); 
		        }
		        dissolve_uv.x = (posWS.x - _DissolveMaskTex_Range_X) / (_DissolveMaskTex_Range_Y - _DissolveMaskTex_Range_X);
		        dissolve_uv.y = (posWS.y - _DissolveMaskTex_Range_Z) / (_DissolveMaskTex_Range_W - _DissolveMaskTex_Range_Z);
		    }   
		    //if (_SoftDissolve > 0)
		    //    return DissolveColorWithSoftEdge(half4(color, alpha), dissolve_uv);
		    //else
		          //color = DissolveColor(color, dissolve_uv);  
		          
		    half4 texColor = SAMPLE_TEXTURE2D(_DissolveMask, sampler_DissolveMask, TRANSFORM_TEX(dissolve_uv, _DissolveMask));  
		    half clipVal;
		    if(_DissolveMask_ChannelMask == 0)  // R
            {
                clipVal = texColor.r;
            }
            else if(_DissolveMask_ChannelMask == 1) // G
            {
                clipVal = texColor.g;
            }
            else if(_DissolveMask_ChannelMask == 2) //B
            {
                clipVal = texColor.b;
            }
            else
            {   
                clipVal = texColor.a;;
            }
            half edgeColorLength = _EdgeColorLength;
            half4 edgeColor = _EdgeColor;
            clip(_DissolvePercent - clipVal);
            half edgeRange = step(_DissolvePercent - edgeColorLength, clipVal);
            float2 rampUV = float2(saturate((clipVal - (_DissolvePercent - edgeColorLength)) * (any(edgeColorLength) ? 1 / edgeColorLength : 0)),0.0);
            half4 rampColor = PARTILE_TEXTURE2D(_RampMask, sampler_RampMask, TRANSFORM_TEX(rampUV, _RampMask), _RampMask_ChannelMask);//.rgb;
            //half3 rampColor = SAMPLE_TEXTURE2D(_RampMask, sampler_RampMask, TRANSFORM_TEX(rampUV, _RampMask)).rgb;
            color =  lerp(color,(edgeColor * rampColor).rgb,edgeRange);      

		#endif

		#ifdef _MASK_UV2_ON
			return MaskUV2(half4(color, alpha), input.uvEmissionAndUV2.zw);
		#endif
		#ifdef _WIREFRAME_ON
            float2 width = (float2(( 1.0 - _WireframeEdgeWidth ) , ( 1.0 - _WireframeEdgeWidth )));
        	float2 rectUV = ( abs( (input.uvAndUvLM.xy * 2.0 - 1.0) ) - width );
        	float2 wireframeUV = ( 1.0 - ( rectUV / fwidth( rectUV ) ) );
        	float wireframe = ( 1.0 - saturate( min( wireframeUV.x , wireframeUV.y ) ) );
        	float2 radius = (float2(( 1.0 - _WireframeDotRadius ) , ( 1.0 - _WireframeDotRadius )));
        	float2 restDotUV = ( abs( (input.uvAndUvLM.xy * 2.0 - 1.0) ) - radius );
        	float2 dotUV = ( 1.0 - ( restDotUV / fwidth( restDotUV ) ) );
        
        	float3 wireframeColor = ( ( _WireframeEdgeColor * wireframe ) + ( saturate( ( 1.0 - max( dotUV.x , dotUV.y ) ) ) * _WireframeDotColor ) ).rgb;
        	#ifdef _ALPHATEST_ON
        	    clip( alpha - 0.5 );
        	#endif

        	color += wireframeColor;
        	alpha = wireframe * _WireframeEdgeColor.a;
        #endif
        
        #ifdef _HEIGHTGRADIENT_ON
            half4 hightTexColor = PARTILE_TEXTURE2D(_HeightGradientMaskTex, sampler_HeightGradientMaskTex, input.uvHeightGradient, _HeightGradientMaskTex_ChannelMask);
            half4 heightColor = half4( _HeightGradientColor.rgb * _HeightGradientIntensity, 1) * hightTexColor * 2.5;
            color += heightColor;
        #endif
        
        float4 final_color = half4(color, alpha);

		return final_color;
	}

	half4 OutputSceneObjectPBRColor(VaryingsSceneObject input, half facing = 1)
	{
		FASurfaceData surfaceData = InitializeFASurfaceDataCustom(input);
		
		half4 color = OutputSceneObjectStandardColor(input, surfaceData, facing);
		
#if _ENABLE_HEIGHT_FOG_SHADING_DEBUG
		return OutputHeightFogColor(input.fogColor.xyz, input.fogColor.w);
#endif

#ifdef _PIXELFOG_ON
		CustomMixFogColor(input.positionWSAndFogFactor.xyz, input.fogColor.xyz, input.fogColor.w);
#endif
		
		color.rgb = lerp(input.fogColor.xyz, color.rgb, input.fogColor.w);
		return color;
	}

	half4 SceneObjectFragment(VaryingsSceneObject inputSceneObject, half facing : VFACE) : SV_Target
	{
		return OutputSceneObjectPBRColor(inputSceneObject, facing);
	}

#endif
