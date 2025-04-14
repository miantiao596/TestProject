#ifndef FA_DEPTH_NORMAL_PASS_INCLUDED
    #define FA_DEPTH_NORMAL_PASS_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "../Lib/Ut-SpaceTransforms.hlsl"
    
    struct Attributes
    {
        float4 positionOS   : POSITION;
        half4 tangentOS     : TANGENT;
        float2 texcoord     : TEXCOORD0;
        half3 normal        : NORMAL;
        float4 uv           : TEXCOORD1;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS    : SV_POSITION;
        float2 uv           : TEXCOORD1;
        half3 normalWS      : TEXCOORD2;
        half4 tangentWS    : TEXCOORD4; 
        float4	uvBump		: TEXCOORD5;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings DepthNormalsVertex(Attributes input, uint instanceID : SV_InstanceID)
    {
        Varyings output = (Varyings)0;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

        output.uv         = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.positionCS = TransformObjectToHClip(input.positionOS.xyz, instanceID);

        VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS, instanceID);
        output.normalWS = half3(normalInput.normalWS);
        float sign = input.tangentOS.w * float(GetOddNegativeScale());
        half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
        output.tangentWS = tangentWS;

#ifdef _NORMALMAP
        output.uvBump.xy = TRANSFORM_TEX(input.uv, _BumpMap);

        #ifdef _ENABLE_NORMALADD_ON
	       output.uvBump.zw = TRANSFORM_TEX(input.uv, _BumpMap2);
        #endif       
        
#endif     
       return output;
    }


    void DepthNormalsFragment(
        Varyings input
        , out half4 outNormalWS : SV_Target
)
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

 #if defined(_NORMALMAP) 
        float sgn = input.tangentWS.w;      // should be either +1 or -1
        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
        float4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uvBump.xy);
	    float3 normalTS= UnpackNormal(n) ;

        #ifdef _ENABLE_NORMALADD_ON 	            	
		  float4 n2 = SAMPLE_TEXTURE2D(_BumpMap2, sampler_BumpMap2, input.uvBump.zw);
		  float3 normalTS_2 = UnpackNormal(n2) ;
	 	  half3	normalTS_0normalTS_0 = half3(normalTS.xy + normalTS_2.xy, normalTS.z * normalTS_2.z);
	      normalTS =  normalTS_0normalTS_0;
        #endif     
        
        float3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));     
#else
        float3 normalWS = input.normalWS;
#endif       
        outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
 
    }
    //    half4 DepthNormalsFragment(Varyings input) : SV_TARGET  //原来的FA 片元着色器
    //{
    //    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    //    #if defined(_ALPHATEST_ON)
    //        Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, sampler_MainTex)).a, _Color, _Cutoff);
    //    #else
    //        Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, sampler_MainTex)).a, _Color, 0);
    //    #endif

    //    return half4(PackNormalOctRectEncode(TransformWorldToViewDir(input.normalWS, true)), 0.0, 0.0);
    //}
#endif
