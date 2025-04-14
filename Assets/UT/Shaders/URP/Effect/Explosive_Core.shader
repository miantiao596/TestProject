// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:4795,x:33609,y:32575,varname:node_4795,prsc:2|emission-2393-OUT,alpha-3682-OUT;n:type:ShaderForge.SFN_Tex2d,id:6074,x:32229,y:32461,ptovrint:False,ptlb:Tex_01,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2232-OUT;n:type:ShaderForge.SFN_Multiply,id:2393,x:32961,y:32681,varname:node_2393,prsc:2|A-6074-RGB,B-2053-RGB,C-797-RGB,D-9248-OUT,E-5083-OUT;n:type:ShaderForge.SFN_VertexColor,id:2053,x:32242,y:32729,varname:node_2053,prsc:2;n:type:ShaderForge.SFN_Color,id:797,x:32227,y:32941,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Vector1,id:9248,x:32227,y:33159,varname:node_9248,prsc:2,v1:2;n:type:ShaderForge.SFN_Multiply,id:798,x:32804,y:32920,varname:node_798,prsc:2|A-6074-R,B-2053-A,C-797-A;n:type:ShaderForge.SFN_ValueProperty,id:5083,x:32703,y:33162,ptovrint:False,ptlb:diff_add,ptin:_diff_add,varname:_diff_add,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Fresnel,id:7719,x:32300,y:32310,varname:node_7719,prsc:2|EXP-8573-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8573,x:32075,y:32325,ptovrint:False,ptlb:fresnel_01,ptin:_fresnel_01,varname:_fresnel_01,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_OneMinus,id:4348,x:32727,y:32298,varname:node_4348,prsc:2|IN-181-OUT;n:type:ShaderForge.SFN_Multiply,id:5853,x:33238,y:32797,varname:node_5853,prsc:2|A-822-OUT,B-798-OUT;n:type:ShaderForge.SFN_Multiply,id:181,x:32542,y:32298,varname:node_181,prsc:2|A-2029-OUT,B-7719-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2029,x:32300,y:32189,ptovrint:False,ptlb:fresnel_02,ptin:_fresnel_02,varname:_fresnel_02,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:3;n:type:ShaderForge.SFN_Clamp01,id:3682,x:33408,y:32833,varname:node_3682,prsc:2|IN-5853-OUT;n:type:ShaderForge.SFN_Tex2d,id:2637,x:32549,y:31894,ptovrint:False,ptlb:Tex_02,ptin:_Tex_02,varname:_Tex_02,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:0238fddf1fef73b4bbd5f5f1f22b0efa,ntxv:0,isnm:False|UVIN-2232-OUT;n:type:ShaderForge.SFN_Add,id:822,x:32971,y:32276,varname:node_822,prsc:2|A-2637-R,B-4348-OUT;n:type:ShaderForge.SFN_Time,id:8640,x:31187,y:31773,varname:node_8640,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:1736,x:31467,y:31956,ptovrint:False,ptlb:Tex_U,ptin:_Tex_U,varname:_Tex_U,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:9119,x:31882,y:31958,varname:node_9119,prsc:2|A-7324-OUT,B-5389-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3693,x:31446,y:32106,ptovrint:False,ptlb:Tex_V,ptin:_Tex_V,varname:_Tex_V,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Append,id:5389,x:31688,y:31995,varname:node_5389,prsc:2|A-1736-OUT,B-3693-OUT;n:type:ShaderForge.SFN_Add,id:2232,x:32256,y:31850,varname:node_2232,prsc:2|A-8995-UVOUT,B-9119-OUT;n:type:ShaderForge.SFN_Fmod,id:7324,x:31495,y:31778,varname:node_7324,prsc:2|A-8640-T,B-4270-OUT;n:type:ShaderForge.SFN_Vector1,id:4270,x:31211,y:32052,varname:node_4270,prsc:2,v1:10;n:type:ShaderForge.SFN_ScreenPos,id:3704,x:31768,y:31711,varname:node_3704,prsc:2,sctp:0;n:type:ShaderForge.SFN_Rotator,id:8995,x:32008,y:31711,varname:node_8995,prsc:2|UVIN-3704-UVOUT,ANG-4983-OUT;n:type:ShaderForge.SFN_Slider,id:4983,x:31630,y:31537,ptovrint:False,ptlb:Tex_02_rot,ptin:_Tex_02_rot,varname:_Tex_02_rot,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-2,cur:0,max:2;proporder:797-6074-5083-8573-2029-2637-1736-3693-4983;pass:END;sub:END;*/

Shader "URP/MoleGame/Effects/Explosive_Core" {
    Properties {
        [MainColor][HDR]_TintColor ("Main Color", Color) = (1,1,1,1)
        [MainTexture]_MainTex ("Main Texture", 2D) = "white" {}
        _diff_add ("Diffuse Add Parameter", Float ) = 1
        _fresnel_01 ("Fresnel Parameter 1", Float ) = 1
        _fresnel_02 ("Fresnel Parameter 2", Float ) = 3
        [SecondTexture]_Tex_02 ("Second Texture", 2D) = "white" {}
        _Tex_U ("Main Texture Speed U", Float ) = 0
        _Tex_V ("Main Texture Speed V", Float ) = 1
        _Tex_02_rot ("UV Rotate Parameter", Range(-2, 2)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0.0, 0.99)) = 0.5
        
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

        #pragma prefer_hlslcc gles
        #pragma exclude_renderers d3d11_9x
        #pragma target 3.0

        uniform sampler2D _MainTex;
        uniform sampler2D _Tex_02;

        CBUFFER_START(UnityPerMaterial)
        uniform float4 _MainTex_ST;
        uniform float4 _Tex_02_ST;

        uniform half4 _TintColor;
        uniform half _diff_add;
        uniform half _fresnel_01;
        uniform half _fresnel_02;

        uniform half _Tex_U;
        uniform half _Tex_V;
        uniform half _Tex_02_rot;
        CBUFFER_END

        struct Attributes {
            float4 positionOS : POSITION;
            half3 normalOS : NORMAL;
            half4 tangentOS    : TANGENT;
            half4 vertexColor : COLOR;
        };
        struct Varyings {
            float4 positionCS : SV_POSITION;
            float3 positionWS : TEXCOORD0;
            half3 normalWS : TEXCOORD1;
            half4 vertexColor : COLOR;
            half4 projPos : TEXCOORD2;
        };
        Varyings vert (Attributes input) {
            Varyings output = (Varyings)0;

            VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
            VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

            output.normalWS = vertexNormalInput.normalWS;
            output.positionWS = vertexInput.positionWS;
            output.positionCS = vertexInput.positionCS;

            output.projPos = ComputeScreenPos (output.positionCS);

            output.projPos.z = -vertexInput.positionVS.z;//代替 COMPUTE_EYEDEPTH(output.projPos.z);

            output.vertexColor = input.vertexColor;

            return output;
        }
        half4 frag(Varyings input, half facing : VFACE) : COLOR {
            half isFrontFace = ( facing >= 0 ? 1 : 0 );
            half faceSign = ( facing >= 0 ? 1 : -1 );
            input.normalWS = normalize(input.normalWS);
            input.normalWS *= faceSign;
            half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - input.positionWS.xyz);
            half3 normalDirection = input.normalWS;
            float2 sceneUVs = (input.projPos.xy / input.projPos.w);
////// Lighting:
////// Emissive:
            half node_8995_ang = _Tex_02_rot;
            half node_8995_spd = 1.0;
            float node_8995_cos = cos(node_8995_spd*node_8995_ang);
            float node_8995_sin = sin(node_8995_spd*node_8995_ang);
            half2 node_8995_piv = half2(0.5,0.5);
            float2 node_8995 = (mul((sceneUVs * 2 - 1).rg-node_8995_piv,float2x2( node_8995_cos, -node_8995_sin, node_8995_sin, node_8995_cos))+node_8995_piv);
            float4 node_8640 = _Time;
            float2 node_2232 = (node_8995+(fmod(node_8640.g,10.0)*float2(_Tex_U,_Tex_V)));
            half4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_2232, _MainTex));
            half3 emissive = (_MainTex_var.rgb*input.vertexColor.rgb*_TintColor.rgb*2.0*_diff_add);
            half3 finalColor = emissive;
            half4 _Tex_02_var = tex2D(_Tex_02,TRANSFORM_TEX(node_2232, _Tex_02));
                return half4(finalColor,saturate(((_Tex_02_var.r+(1.0 - (_fresnel_02*pow(1.0-saturate(dot(normalDirection, viewDirection)),_fresnel_01))))*(_MainTex_var.r*input.vertexColor.a*_TintColor.a))));
        }
    ENDHLSL

    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "StandardLit"
            Tags {
                "LightMode" = "SceneEffect"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
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
            ENDHLSL
        }

        Pass {
            Name "StandardLit"
            Tags {
                "LightMode" = "Effect"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }
    }
    CustomEditor "JTRP.ShaderDrawer.LWGUI" 
}
