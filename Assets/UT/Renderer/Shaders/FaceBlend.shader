Shader "48/Character/FaceBlend"
{
    Properties
    {
//        [Toggle(_VERSIONSCHANGE)]_VersionsChange("版本修改", Float) = 1
        
        [Main(FaceInputs, _, off, off)] _Face("脸部设置(Face Inputs)", Float) = 1
        [Sub(FaceInputs)][MainTexture][NoScaleOffset] _FaceMap("颜色贴图", 2D) = "black" {}
        [Sub(FaceInputs)][MainColor] _FaceColor("肤色", Color) = (1, 1, 1, 1)
        [Sub(FaceInputs)][Normal][NoScaleOffset]_FaceNormalMap("法线贴图", 2D) = "bump" {}
        [Sub(FaceInputs)][NoScaleOffset]_FaceRMASMap("控制贴图", 2D) = "black" {}

        [Main(BlushInputs, _BLUSH, off, on)] _Blush("腮红设置(Blush Inputs)", Float) = 1
        [Sub(BlushInputs)]_BlushMap_ST("UV缩放位移", Vector) = (1, 1, 0, 0)
        [SubToggle(BlushInputs)]_BlushUVMirror("UV镜像", Float) = 1
        [Sub(BlushInputs)]_BlushUVRotate("UV旋转", Range(-1,1)) = 0
        [Sub(BlushInputs)][NoScaleOffset]_BlushMap("颜色贴图", 2D) = "black" {}
        [Sub(BlushInputs)][NoScaleOffset][Normal]_BlushNormalMap("法线贴图", 2D) = "bump" {}
        [Sub(BlushInputs)][NoScaleOffset]_BlushRMASMap("控制贴图", 2D) = "black" {}
        [Sub(BlushInputs)][NoScaleOffset]_BlushTintMap("染色贴图", 2D) = "black" {}
        [Sub(BlushInputs)]_BlushTintColor1("染色色号1", Color) = (1,1,1,0)
        [Sub(BlushInputs)]_BlushTintColor2("染色色号2", Color) = (1,1,1,0)
        [Sub(BlushInputs)]_BlushTintColor3("染色色号3", Color) = (1,1,1,0)

        [Main(EyeShadowInputs, _EYESHADOW, off, on)] _EyeShadow("眼影设置(EyeShadow Inputs)", Float) = 1
        [Sub(EyeShadowInputs)]_EyeShadowMap_ST("UV缩放位移", Vector) = (1, 1, 0, 0)
        [SubToggle(EyeShadowInputs)]_EyeShadowUVMirror("UV镜像", Float) = 0
        [Sub(EyeShadowInputs)]_EyeShadowUVRotate("UV旋转", Range(-1,1)) = 0
        [Sub(EyeShadowInputs)][NoScaleOffset]_EyeShadowMap("颜色贴图", 2D) = "black" {}
        [Sub(EyeShadowInputs)][NoScaleOffset][Normal]_EyeShadowNormalMap("法线贴图", 2D) = "bump" {}
        [Sub(EyeShadowInputs)][NoScaleOffset]_EyeShadowRMASMap("控制贴图", 2D) = "black" {}
        [Sub(EyeShadowInputs)][NoScaleOffset]_EyeShadowTintMap("染色贴图", 2D) = "black" {}
        [Sub(EyeShadowInputs)]_EyeShadowTintColor1("染色色号1", Color) = (1,1,1,0)
        [Sub(EyeShadowInputs)]_EyeShadowTintColor2("染色色号2", Color) = (1,1,1,0)
        [Sub(EyeShadowInputs)]_EyeShadowTintColor3("染色色号3", Color) = (1,1,1,0)

        [Main(EyeLinerInputs, _EYELINER, off, on)] _EyeLiner("眼线设置(EyeLiner Inputs)", Float) = 1
        [Sub(EyeLinerInputs)]_EyeLinerMap_ST("UV缩放位移", Vector) = (1, 1, 0, 0)
        [SubToggle(EyeLinerInputs)]_EyeLinerUVMirror("UV镜像", Float) = 0
        [Sub(EyeLinerInputs)]_EyeLinerUVRotate("UV旋转", Range(-1,1)) = 0
        [Sub(EyeLinerInputs)][NoScaleOffset]_EyeLinerMap("颜色贴图", 2D) = "black" {}
        [Sub(EyeLinerInputs)][NoScaleOffset][Normal]_EyeLinerNormalMap("法线贴图", 2D) = "bump" {}
        [Sub(EyeLinerInputs)][NoScaleOffset]_EyeLinerRMASMap("控制贴图", 2D) = "black" {}
        [Sub(EyeLinerInputs)][NoScaleOffset]_EyeLinerTintMap("染色贴图", 2D) = "black" {}
        [Sub(EyeLinerInputs)]_EyeLinerTintColor1("染色色号1", Color) = (1,1,1,0)
        [Sub(EyeLinerInputs)]_EyeLinerTintColor2("染色色号2", Color) = (1,1,1,0)
        [Sub(EyeLinerInputs)]_EyeLinerTintColor3("染色色号3", Color) = (1,1,1,0)

        [Main(EyeBrowInputs, _EYEBROW, off, on)] _EyeBrow("眉妆设置(EyeBrow Inputs)", Float) = 1
        [Sub(EyeBrowInputs)]_EyeBrowMap_ST("UV缩放位移", Vector) = (1, 1, 0, 0)
        [SubToggle(EyeBrowInputs)]_EyeBrowUVMirror("UV镜像", Float) = 1
        [Sub(EyeBrowInputs)]_EyeBrowUVRotate("UV旋转", Range(-1,1)) = 0
        [Sub(EyeBrowInputs)][NoScaleOffset]_EyeBrowMap("颜色贴图", 2D) = "black" {}
        [Sub(EyeBrowInputs)][NoScaleOffset][Normal]_EyeBrowNormalMap("法线贴图", 2D) = "bump" {}
        [Sub(EyeBrowInputs)][NoScaleOffset]_EyeBrowRMASMap("控制贴图", 2D) = "black" {}
        [Sub(EyeBrowInputs)][NoScaleOffset]_EyeBrowTintMap("染色贴图", 2D) = "black" {}
        [Sub(EyeBrowInputs)]_EyeBrowTintColor1("染色色号1", Color) = (1,1,1,0)
        [Sub(EyeBrowInputs)]_EyeBrowTintColor2("染色色号2", Color) = (1,1,1,0)
        [Sub(EyeBrowInputs)]_EyeBrowTintColor3("染色色号3", Color) = (1,1,1,0)

        [Main(LipInputs, _LIP, off, on)] _Lip("唇妆设置(Lip Inputs)", Float) = 1
        [Sub(LipInputs)]_LipMap_ST("UV缩放位移", Vector) = (1, 1, 0, 0)
        [SubToggle(LipInputs)]_LipUVMirror("UV镜像", Float) = 0
        [Sub(LipInputs)]_LipUVRotate("UV旋转", Range(-1,1)) = 0
        [Sub(LipInputs)][NoScaleOffset]_LipMap("颜色贴图", 2D) = "black" {}
        [Sub(LipInputs)][NoScaleOffset][Normal]_LipNormalMap("法线贴图", 2D) = "bump" {}
        [Sub(LipInputs)][NoScaleOffset]_LipRMASMap("控制贴图", 2D) = "black" {}
        [Sub(LipInputs)][NoScaleOffset]_LipTintMap("染色贴图", 2D) = "black" {}
        [Sub(LipInputs)]_LipTintColor1("染色色号1", Color) = (1,1,1,0)
        [Sub(LipInputs)]_LipTintColor2("染色色号2", Color) = (1,1,1,0)
        [Sub(LipInputs)]_LipTintColor3("染色色号3", Color) = (1,1,1,0)
        [Sub(LipInputs)]_LipNormalScale("褶皱", Range(0,1)) = 1
        [Sub(LipInputs)]_LipSmoothness("光泽", Range(0,1)) = 0.5

        [Main(TattooInputs, _TATTOO, off, on)] _Tattoo("纹面设置(Tattoo Inputs)", Float) = 1
        [Sub(TattooInputs)]_TattooMap_ST("UV缩放位移", Vector) = (1, 1, 0, 0)
        [SubToggle(TattooInputs)]_TattooUVMirror("UV镜像", Float) = 0
        [Sub(TattooInputs)]_TattooUVRotate("UV旋转", Range(-1,1)) = 0
        [Sub(TattooInputs)][NoScaleOffset]_TattooMap("颜色贴图", 2D) = "black" {}
        [Sub(TattooInputs)][NoScaleOffset][Normal]_TattooNormalMap("法线贴图", 2D) = "bump" {}
        [Sub(TattooInputs)][NoScaleOffset]_TattooRMASMap("控制贴图", 2D) = "black" {}
        [Sub(TattooInputs)][NoScaleOffset]_TattooTintMap("染色贴图", 2D) = "black" {}
        [Sub(TattooInputs)]_TattooTintColor1("染色色号1", Color) = (1,1,1,0)
        [Sub(TattooInputs)]_TattooTintColor2("染色色号2", Color) = (1,1,1,0)
        [Sub(TattooInputs)]_TattooTintColor3("染色色号3", Color) = (1,1,1,0)
    }

    SubShader
    {
//        Tags { "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        ZTest Always ZWrite Off Cull Off
         
        Pass
        {
            Name "BaseColorMap"

            HLSLPROGRAM
            #pragma target 3.5

            #include "./ShaderLibrary/FaceBlend.hlsl"
           
            #pragma shader_feature_local_fragment _ _BLUSH
            #pragma shader_feature_local_fragment _ _EYESHADOW
            #pragma shader_feature_local_fragment _ _EYELINER
            #pragma shader_feature_local_fragment _ _EYEBROW
            #pragma shader_feature_local_fragment _ _LIP
            #pragma shader_feature_local_fragment _ _TATTOO


            // Shader Stages
            // #pragma vertex UnlitPassVertex
	        #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment Frag_BaseColor
            ENDHLSL
        }

        Pass
        {
            Name "NormalMap"

            HLSLPROGRAM
            #pragma target 3.5

            #include "./ShaderLibrary/FaceBlend.hlsl"

            #pragma shader_feature_local_fragment _ _BLUSH
            #pragma shader_feature_local_fragment _ _EYESHADOW
            #pragma shader_feature_local_fragment _ _EYELINER
            #pragma shader_feature_local_fragment _ _EYEBROW
            #pragma shader_feature_local_fragment _ _LIP
            #pragma shader_feature_local_fragment _ _TATTOO

            // Shader Stages
	        #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment Frag_Normal
            ENDHLSL
        }

        Pass
        {
            Name "SMOMap"

            HLSLPROGRAM
            #pragma target 3.5

            #include "./ShaderLibrary/FaceBlend.hlsl"

            #pragma shader_feature_local_fragment _ _BLUSH
            #pragma shader_feature_local_fragment _ _EYESHADOW
            #pragma shader_feature_local_fragment _ _EYELINER
            #pragma shader_feature_local_fragment _ _EYEBROW
            #pragma shader_feature_local_fragment _ _LIP
            #pragma shader_feature_local_fragment _ _TATTOO

            // Shader Stages
	        #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment Frag_SMO
            ENDHLSL
        }

        Pass
        {
            Name "AllMap"

            HLSLPROGRAM
            #pragma target 3.5

            #include "./ShaderLibrary/FaceBlend.hlsl"
           
            #pragma shader_feature_local_fragment _ _BLUSH
            #pragma shader_feature_local_fragment _ _EYESHADOW
            #pragma shader_feature_local_fragment _ _EYELINER
            #pragma shader_feature_local_fragment _ _EYEBROW
            #pragma shader_feature_local_fragment _ _LIP
            #pragma shader_feature_local_fragment _ _TATTOO

            // Shader Stages
	        #pragma vertex VertQuad
            #pragma fragment Frag_All
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"

    CustomEditor "LWGUI.LWGUI"
}