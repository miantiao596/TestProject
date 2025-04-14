Shader "48/Costume/Lit"
{
    Properties
    {
        [Main(SurfaceOptions, _, off, off)] _SurfaceOptionsGroup ("Surface Options", float) = 0
        [KWEnum(SurfaceOptions, Specular, _SPECULAR_SETUP, Metallic, _SPECULAR_SETUP_OFF)] _WorkflowMode("工作流模式", Float) = 1.0

        [Space(10)]
        [AdvancedHeaderProperty][Preset(SurfaceOptions, 48_Preset_BlendMode)] _Surface ("混合模式", float) = 0
        [Advanced][SubEnum(SurfaceOptions, UnityEngine.Rendering.CullMode)] _Cull ("剔除", Float) = 2
        [Advanced][SubEnum(SurfaceOptions, UnityEngine.Rendering.BlendMode)] _SrcBlend ("背景图层混合模式", Float) = 1
        [Advanced][SubEnum(SurfaceOptions, UnityEngine.Rendering.BlendMode)] _DstBlend ("前景图层混合模式", Float) = 0
        [Advanced][SubEnum(SurfaceOptions, UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha ("背景图层Alpha混合模式", Float) = 1
        [Advanced][SubEnum(SurfaceOptions, UnityEngine.Rendering.BlendMode)] _DstBlendAlpha ("前景图层Alpha混合模式", Float) = 10
        [Advanced][SubToggle(SurfaceOptions)] _ZWrite ("深度写入 ", Float) = 1
        [Advanced][SubToggle(SurfaceOptions)] _TransparentZWrite ("半透明深度写入 ", Float) = 1
        [Advanced][SubEnum(SurfaceOptions, UnityEngine.Rendering.CompareFunction)] _ZTest ("深度测试", Float) = 4 // 4 is LEqual
        [Advanced][SubEnum(SurfaceOptions, RGBA, 15, RGB, 14)] _ColorMask ("颜色遮罩", Float) = 15 // 15 is RGBA (binary 1111)

        [Space(10)]
        [SubToggle(SurfaceOptions,_DOUBLESIDED)] _EnableDoubleSided("双面渲染", Float) = 0.0
        [ShowIf(_EnableDoubleSided, Equal, 1)][Sub(SurfaceOptions)]_DoubleSidedConstants("背面法线纠正",Vector)=(1,1,-1,0)

        [Space(10)]
        [SubToggle(SurfaceOptions,_BILLBOARD)] _EnableBillBoard("广告牌", Float) = 0.0
        [ShowIf(_EnableBillBoard, Equal, 1)][Sub(SurfaceOptions)]_BillBoardScale("缩放",Range(0,1.0))=1
        
        //[AdvancedHeaderProperty][SubToggle(SurfaceOptions,_ALPHATEST_ON)] _AlphaTest("Alpha Test",Float)=0.0
        //[Advanced] _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [Space(10)]
        [SubToggle(SurfaceOptions,_ALPHATEST_ON)] _AlphaTest("Alpha剔除",Float)=0.0
        [Sub(SurfaceOptions)][ShowIf(_AlphaTest, Equal, 1)] _Cutoff ("剔除权重", Range(0.0, 1.0)) = 0.5

        [Space(10)]
        [SubToggle(SurfaceOptions,_RECEIVE_SHADOWS_ON)] _ReceiveShadows("接收阴影", Float) = 1.0

        [Main(SurfaceInputs, _, on, off)] _SurfaceInputsGroup ("Surface Inputs", float) = 0
        [Sub(SurfaceInputs)][MainTexture] _BaseMap ("基础贴图", 2D) = "white" { }
        [Sub(SurfaceInputs)][MainColor] _BaseColor("基础色", Color) = (1,1,1,1)
        [Sub(SurfaceInputs)] _AlphaControlMin("Alpha增强", Range(0,1.0)) = 0.0
        [Sub(SurfaceInputs)] _AlphaControlMax("Alpha减弱", Range(0,1.0)) = 1.0
        
        [Space(10)]
        [SubToggle(SurfaceInputs,_METALLICSPECGLOSSMAP)] _MetallicGlossMapKey("控制贴图",Float)=0.0
        //金属度贴图
        [ShowIf(_WorkflowMode, Equal, 1)][ShowIf(_MetallicGlossMapKey, Equal, 1)][Tex(SurfaceInputs)]_MetallicGlossMap("金属度贴图", 2D) = "white" {}
        [ShowIf(_WorkflowMode, Equal, 1)][ShowIf(_MetallicGlossMapKey, Equal, 0)][Sub(SurfaceInputs)]_Metallic("金属度", Range(0.0, 1.0)) = 0.0
        //高光贴图
        [ShowIf(_WorkflowMode, Equal, 0)][ShowIf(_MetallicGlossMapKey, Equal, 1)][Tex(SurfaceInputs)]_SpecGlossMap("高光贴图", 2D) = "white" {}
        [ShowIf(_WorkflowMode, Equal, 0)][ShowIf(_MetallicGlossMapKey, Equal, 0)][Sub(SurfaceInputs)]_SpecColor("高光颜色", Color) = (0.2, 0.2, 0.2)

        [Sub(SurfaceInputs)]_Smoothness("光滑度", Range(0.0, 1.0)) = 0.5
        [KWEnum(SurfaceInputs,Metallic Aplpha,_,Albedo Alpha,_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)]_SmoothnessTextureChannel("光滑度控制依赖", Float) = 0

        [Space(10)]
        [SubToggle(SurfaceInputs,_NORMALMAP)] _NormalMapKey("法线贴图开关",Float)=0.0
        [ShowIf(_NormalMapKey, Equal, 1)][Tex(SurfaceInputs, _BumpScale)][Normal]_BumpMap("法线贴图", 2D) = "bump" {}
        [HideInInspector]_BumpScale("强度", Float) = 1.0

        [Space(10)]
        [SubToggle(SurfaceInputs,_PARALLAXMAP)] _ParallaxMapKey("高度图开关",Float)=0.0
        [ShowIf(_ParallaxMapKey, Equal, 1)][Tex(SurfaceInputs, _Parallax)]_ParallaxMap("高度图", 2D) = "black" {}
        [HideInInspector] _Parallax("强度", Range(0.005, 0.08)) = 0.005

        [Space(10)]
        [SubToggle(SurfaceInputs,_OCCLUSIONMAP)] _OcclusionMapKey("AO贴图开关",Float)=0.0
        [ShowIf(_OcclusionMapKey, Equal, 1)][Tex(SurfaceInputs, _OcclusionStrength)]_OcclusionMap("AO贴图", 2D) = "white" {}
        [HideInInspector] _OcclusionStrength("强度", Range(0.0, 1.0)) = 1.0

        [Space(10)]
        [SubToggle(SurfaceInputs,_EMISSION)] _EmissionMapKey("自发光开关",Float)=0.0
        [ShowIf(_EmissionMapKey, Equal, 1)][Tex(SurfaceInputs, _EmissionColor)]_EmissionMap("自发光贴图", 2D) = "white" {}
        [HideInInspector] [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0)
        
        [Space(10)]
        [SubToggle(SurfaceInputs,_IRIDESCENCE)] _EnableIridescence("薄膜干涉", Float) = 0.0
        [ShowIf(_EnableIridescence, Equal, 1)][Sub(SurfaceInputs)]_IridescenceThickness("厚度", Range(0,1.0)) = 0.85
        [ShowIf(_EnableIridescence, Equal, 1)][Sub(SurfaceInputs)]_IridescenceIntensity("饱和度", Range(0,1.0)) = 0.1
        
        [Space(10)]
        [SubToggle(SurfaceInputs,_CLEARCOAT)] _EnableClearCoat("清漆", Float) = 0.0
        [ShowIf(_EnableClearCoat, Equal, 1)][Sub(SurfaceInputs)]_ClearCoatMask("清漆遮罩", Range(0,1.0)) = 0.1
        [ShowIf(_EnableClearCoat, Equal, 1)][Sub(SurfaceInputs)]_ClearCoatSmoothness("清漆光滑度", Range(0,1.0)) = 0.5
        
        [Space(10)]
        [SubToggle(SurfaceInputs,_MATCAP)] _EnableMaterialCapture("材质捕捉", Float) = 0.0
        [ShowIf(_EnableMaterialCapture, Equal, 1)][Sub(SurfaceInputs)][NoScaleOffset]_MatCapMap("映射贴图", 2D) = "black" {}
        
        [Space(10)]
        [SubToggle(SurfaceInputs,_CUSTOMSPECCUBEMAP)] _CustomSpecCubeMapKey("自定义环境贴图开关",Float)=0.0
        [ShowIf(_CustomSpecCubeMapKey, Equal, 1)][Sub(SurfaceInputs)][NoScaleOffset]_SpecCubeMap("环境贴图", Cube) = "white" {}
        [ShowIf(_CustomSpecCubeMapKey, Equal, 1)][Sub(SurfaceInputs)]_SpecCubeMapIntensity("强度", Float) = 1.0
        
        [Space(10)]
        [SubToggle(SurfaceInputs,_CUSTOMSH)] _CustomSHKey("自定义SH",Float)=0.0
        [ShowIf(_CustomSHKey, Equal, 1)][Sub(SurfaceInputs)]_SHAr("SHAr",Vector)=(0,0,0,0)
        [ShowIf(_CustomSHKey, Equal, 1)][Sub(SurfaceInputs)]_SHAg("SHAg",Vector)=(0,0,0,0)
        [ShowIf(_CustomSHKey, Equal, 1)][Sub(SurfaceInputs)]_SHAb("SHAb",Vector)=(0,0,0,0)
        [ShowIf(_CustomSHKey, Equal, 1)][Sub(SurfaceInputs)]_SHBr("SHBr",Vector)=(0,0,0,0)
        [ShowIf(_CustomSHKey, Equal, 1)][Sub(SurfaceInputs)]_SHBg("SHBg",Vector)=(0,0,0,0)
        [ShowIf(_CustomSHKey, Equal, 1)][Sub(SurfaceInputs)]_SHBb("SHBb",Vector)=(0,0,0,0)
        [ShowIf(_CustomSHKey, Equal, 1)][Sub(SurfaceInputs)]_SHC("SHC",Vector)=(0,0,0,1)
        
        /*************************************/
        /************Fabric Base************/
        /*************************************/
        [Main(LayerInputs, _, on, off)] _LayerMapGroup ("Fabric Base", float) = 0
        
        [Sub(LayerInputs)]
        _FabricBaseExplain ("说明%四层UV分别用于:基础贴图，平铺贴图，刺绣贴花，渐变色%三层细节贴图依次对应：编织贴图，编织/刺绣贴图，刺绣贴图", float) = 1
        
        [Space(10)]
        [AdvancedHeaderProperty][SubToggle(LayerInputs,_GRADUALCOLOR)] _GradualRamp("渐变色开关",Float)=0.0
        [Advanced][ShowIf(_GradualRamp, Equal, 1)][Sub(LayerInputs)]_GradualColor("渐变颜色", Color) = (0,0,0,0)
        [Advanced][ShowIf(_GradualRamp, Equal, 1)][Sub(LayerInputs)]_GradualStart("渐变区域缩减", Range(0,1.0)) = 0.0
        [Advanced][ShowIf(_GradualRamp, Equal, 1)][Sub(LayerInputs)]_GradualEnd("渐变区域增大", Range(0,1.0)) =1.0
        
        [Space(10)]
        [UVChannel(LayerInputs)]_UVLayer1("细节贴图UV_1", Vector) = (0,1,0,0)
        [AdvancedHeaderProperty][SubToggle(LayerInputs,_BASEMAPLAYER1)] _BaseMapLayer1Key("细节贴图颜色开关",Float)=0
        [Advanced][ShowIf(_BaseMapLayer1Key, Equal, 1)][Sub(LayerInputs)]_BaseMapLayer1("颜色贴图", 2D) = "black" {}
        [Advanced][ShowIf(_BaseMapLayer1Key, Equal, 1)][SubToggle(LayerInputs)]_UseMapAlphaLayer1("乘以贴图Alpha", Float) = 0
        [Advanced][ShowIf(_BaseMapLayer1Key, Equal, 1)][Sub(LayerInputs)]_BaseColoLayer1("颜色(Alpha为叠加强度)", Color) = (1.0,1.0,1.0,1.0)
        [Advanced][ShowIf(_BaseMapLayer1Key, Equal, 1)][Sub(LayerInputs)]_MetallicLayer1("金属度", Range(0,1.0)) = 0
        [Advanced][ShowIf(_BaseMapLayer1Key, Equal, 1)][Sub(LayerInputs)]_SmoothnessLayer1("光滑度", Range(0,1.0)) = 0.5
        
        [AdvancedHeaderProperty][SubToggle(LayerInputs,_NORMALMAPLAYER1)] _BumpMapLayer1Key("细节贴图法线开关",Float)=0
        [Advanced][ShowIf(_BumpMapLayer1Key, Equal, 1)][Sub(LayerInputs)][Normal]_BumpMapLayer1("法线贴图", 2D) = "bump" {}
        [Advanced][ShowIf(_BumpMapLayer1Key, Equal, 1)][Sub(LayerInputs)]_BumpScaleLayer1("法线强度", Float) = 1.0
        [Advanced][ShowIf(_BaseMapLayer1Key, Equal, 1)][SubToggle(LayerInputs)]_BumpAlphaBlendLayer1("使用颜色贴图Alpha混合", Float) = 0.0
        
        [Space(10)]
        [UVChannel(LayerInputs)]_UVLayer2("细节贴图UV_2", Vector) = (0,1,0,0)
        [AdvancedHeaderProperty][SubToggle(LayerInputs,_BASEMAPLAYER2)] _BaseMapLayer2Key("细节贴图颜色开关",Float)=0
        [Advanced][ShowIf(_BaseMapLayer2Key, Equal, 1)][Sub(LayerInputs)]_BaseMapLayer2("颜色贴图", 2D) = "black" {}
        [Advanced][ShowIf(_BaseMapLayer2Key, Equal, 1)][SubToggle(LayerInputs)]_UseMapAlphaLayer2("乘以贴图Alpha", Float) = 0
        [Advanced][ShowIf(_BaseMapLayer2Key, Equal, 1)][Sub(LayerInputs)]_BaseColoLayer2("颜色(Alpha为叠加强度)", Color) =(1.0,1.0,1.0,1.0)
        [Advanced][ShowIf(_BaseMapLayer2Key, Equal, 1)][Sub(LayerInputs)]_MetallicLayer2("金属度", Range(0,1.0)) = 0
        [Advanced][ShowIf(_BaseMapLayer2Key, Equal, 1)][Sub(LayerInputs)]_SmoothnessLayer2("光滑度", Range(0,1.0)) = 0.5
        
        [AdvancedHeaderProperty][SubToggle(LayerInputs,_NORMALMAPLAYER2)] _BumpMapLayer2Key("细节贴图法线开关",Float)=0
        [Advanced][ShowIf(_BumpMapLayer2Key, Equal, 1)][Sub(LayerInputs)][Normal]_BumpMapLayer2("法线贴图", 2D) = "bump" {}
        [Advanced][ShowIf(_BumpMapLayer2Key, Equal, 1)][Sub(LayerInputs)]_BumpScaleLayer2("法线强度", Float) = 1.0
        [Advanced][ShowIf(_BaseMapLayer2Key, Equal, 1)][SubToggle(LayerInputs)]_BumpAlphaBlendLayer2("使用颜色贴图Alpha混合", Float) = 0.0

        [Space(10)]
        [UVChannel(LayerInputs)]_UVLayer3("细节贴图UV_3", Vector) = (0,0,1,0)
        [AdvancedHeaderProperty][SubToggle(LayerInputs,_BASEMAPLAYER3)] _BaseMapLayer3Key("细节贴图颜色开关",Float)=0
        [Advanced][ShowIf(_BaseMapLayer3Key, Equal, 1)][Sub(LayerInputs)]_BaseMapLayer3("颜色贴图", 2D) = "black" {}
        [Advanced][ShowIf(_BaseMapLayer3Key, Equal, 1)][SubToggle(LayerInputs)]_UseMapAlphaLayer3("乘以贴图Alpha", Float) = 0
        [Advanced][ShowIf(_BaseMapLayer3Key, Equal, 1)][Sub(LayerInputs)]_BaseColoLayer3("颜色(Alpha为叠加强度)", Color) = (1.0,1.0,1.0,1.0)
        [Advanced][ShowIf(_BaseMapLayer3Key, Equal, 1)][Sub(LayerInputs)]_MetallicLayer3("金属度", Range(0,1.0)) = 0
        [Advanced][ShowIf(_BaseMapLayer3Key, Equal, 1)][Sub(LayerInputs)]_SmoothnessLayer3("光滑度", Range(0,1.0)) = 0.5

        [AdvancedHeaderProperty][SubToggle(LayerInputs,_NORMALMAPLAYER3)] _BumpMapLayer3Key("细节贴图法线开关",Float)=0
        [Advanced][ShowIf(_BumpMapLayer3Key, Equal, 1)][Sub(LayerInputs)][Normal]_BumpMapLayer3("法线贴图", 2D) = "bump" {}
        [Advanced][ShowIf(_BumpMapLayer3Key, Equal, 1)][Sub(LayerInputs)]_BumpScaleLayer3("法线强度", Float) = 1.0
        [Advanced][ShowIf(_BaseMapLayer3Key, Equal, 1)][SubToggle(LayerInputs)]_BumpAlphaBlendLayer3("使用颜色贴图Alpha混合", Float) = 0.0

        [Space(10)]
        [AdvancedHeaderProperty][SubToggle(LayerInputs,_SEQUIN)] _Sequin("亮片开关",Float)=0.0
        [Advanced][ShowIf(_Sequin, Equal, 1)][Sub(LayerInputs)]_SequinDensity("平铺大小", Float) =50.0
        [Advanced][ShowIf(_Sequin, Equal, 1)][Sub(LayerInputs)]_SequinRandomSeed("随机种子", Float) =1.0

        [Advanced][ShowIf(_Sequin, Equal, 1)][Sub(LayerInputs)]_SequinScaleMin ("最小直径", Range(0.0,1.0)) = 0.4
        [Advanced][ShowIf(_Sequin, Equal, 1)][Sub(LayerInputs)]_SequinScaleMax ("最大直径", Range(0.0,1.0)) = 0.5        
        [Advanced][ShowIf(_Sequin, Equal, 1)][SubToggle(LayerInputs,_SEQUINDEBUG)] _EnableSequinDebug("亮片形状观察", Float) = 0.0        
        [Advanced][ShowIf(_Sequin, Equal, 1)][Sub(LayerInputs)]_SequinBrightness("亮度", Float) =1.0
        
        [Advanced][ShowIf(_Sequin, Equal, 1)][Color(LayerInputs, _SequinColor1, _SequinColor2)]_SequinColor0 ("亮片颜色", Color) = (1, 1, 0, 1)
        [HideInInspector] _SequinColor1 (" ", Color) = (0, 1, 1, 1)
        [HideInInspector] _SequinColor2 (" ", Color) = (1, 0, 1, 1)


        /*************************************/
        /************Fabric Advanced************/
        /*************************************/
        [Main(FabricInputs, _MATERIAL_FABRIC, off)] _FabricInputsGroup ("Fabric Advanced", float) = 0

        [Space(10)]        
        [KWEnum(FabricInputs,Off,_, Cotton Wool, _FABRIC_COTTON,Velvet,_FABRIC_VELVET, Silk, _FABRIC_SILK)] _FabricType("衣服类型", Float) = 0.0
        [Sub(FabricInputs)]_FabricSpecColor("高光颜色", Color) = (0.2, 0.2, 0.2)
        [SubToggle(FabricInputs,_MATERIAL_FEATURE_TRANSLUCENCY)] _EnableTranslucency("透光", Float) = 0.0
        [ShowIf(_FabricType, Equal, 3)][Sub(FabricInputs)]_Anisotropy("各向异性", Range(-1.0, 1.0)) = 0.0

        [Space(10)]
        [AdvancedHeaderProperty][SubToggle(FabricInputs,_FUR)] _FurKey("绒毛开关",Float)=0.0
        [Advanced][ShowIf(_FurKey, Equal, 1)][SubToggle(FabricInputs,_GEOM_INSTANCING)]_GeomInstancing("几何Instancing", Float) = 0.0
        [Advanced][ShowIf(_FurKey, Equal, 1)][Sub(FabricInputs)]_FurPatternMap("绒毛贴图", 2D) = "white" {}
        [Advanced][ShowIf(_FurKey, Equal, 1)][Sub(FabricInputs)]_FurPatternMapControlMin("贴图增强", Range(0,1.0)) = 0.0
        [Advanced][ShowIf(_FurKey, Equal, 1)][Sub(FabricInputs)]_FurPatternMapControlMax("贴图减弱", Range(0,1.0)) = 1.0        
        [Advanced][ShowIf(_FurKey, Equal, 1)][Sub(FabricInputs)]_ShellAmount("迭代次数", Range(1,52)) = 13
        [Advanced][ShowIf(_FurKey, Equal, 1)][Sub(FabricInputs)]_FurLength("绒毛长度", Float) = 1.0
        [Advanced][ShowIf(_FurKey, Equal, 1)][Sub(FabricInputs)]_TotalShellStep("总步长", Range(0.0, 0.5)) = 0.026
        [Advanced][ShowIf(_FurKey, Equal, 1)][Sub(FabricInputs)][Enum(Linear, 0, Quadratic, 1)]_BentType("弯曲类型", Float) = 1
        [Advanced][ShowIf(_FurKey, Equal, 1)][Sub(FabricInputs)]_BaseMove("弯曲方向", Vector) = (0.0, 0.0, 0.0, 3.0)
        
        [Space(10)]
        [AdvancedHeaderProperty][SubToggle(FabricInputs,_THREADMAP)] _ThreadMapKey("编织贴图开关",Float)=0.0
        [Advanced][ShowIf(_ThreadMapKey, Equal, 1)][Sub(FabricInputs)]_ThreadMap("编织贴图", 2D) = "white" {}
        [Advanced][ShowIf(_ThreadMapKey, Equal, 1)][Sub(FabricInputs)]_ThreadAOScale("AO强度", Range(0.0, 2.0)) = 1.0
        [Advanced][ShowIf(_ThreadMapKey, Equal, 1)][Sub(FabricInputs)]_ThreadNormalScale("法线强度", Range(0.0, 2.0)) = 1.0
        [Advanced][ShowIf(_ThreadMapKey, Equal, 1)][Sub(FabricInputs)]_ThreadSmoothnessScale("光滑度", Range(0.0, 2.0)) = 1.0

        [Space(10)]
        [AdvancedHeaderProperty][SubToggle(FabricInputs,_FUZZMAP)] _FuzzMapKey("绒毛贴图开关",Float)=0.0
        [Advanced][ShowIf(_FuzzMapKey, Equal, 1)][Sub(FabricInputs)][NoScaleOffset]_FuzzMap("绒毛贴图", 2D) = "white" {}
        [Advanced][ShowIf(_FuzzMapKey, Equal, 1)][Sub(FabricInputs)]_FuzzScale("平铺大小", Float) = 1.0
        [Advanced][ShowIf(_FuzzMapKey, Equal, 1)][Sub(FabricInputs)]_FuzzIntensity("显示强度", Range(0.0, 1.0)) = 0.0
        
        [Main(ObsoleteProperties, _, off, off)] _ObsoletePropertiesGroup ("Obsolete Properties", float) = 0
        /*************************************/
        /************Detail Inputs************/
        /*************************************/
        [Space(10)]    
        [AdvancedHeaderProperty][KWEnum(ObsoleteProperties, Off, _, Mulx2, _DETAIL_MULX2,Scaled, _DETAIL_SCALED)] _DetailKey ("Detail", float) = 0
        [Advanced][ShowIf(_DetailKey, NotEqual, 0)][Sub(ObsoleteProperties)]_DetailMask("Detail Mask", 2D) = "white" {}

        [Advanced][ShowIf(_DetailKey, NotEqual, 0)][Sub(ObsoleteProperties)]_DetailAlbedoMap("Detail Albedo", 2D) = "linearGrey" {}
        [Advanced][ShowIf(_DetailKey, Equal, 2)][Sub(ObsoleteProperties)]_DetailAlbedoMapScale("Scale", Range(0.0, 2.0)) = 1.0

        [Advanced][ShowIf(_DetailKey, NotEqual, 0)][Tex(ObsoleteProperties)][Normal]_DetailNormalMap("Normal Map", 2D) = "bump" {}
        [Advanced][ShowIf(_DetailKey, NotEqual, 0)][Sub(ObsoleteProperties)]_DetailNormalMapScale("Scale", Range(0.0, 2.0)) = 1.0

        /*************************************/
        /************Advanced Options************/
        /*************************************/
        [Space(10)]
        [Main(AdvancedOptions, _, off, off)] _AdvancedOptionsGroup ("Advanced Options", float) = 0
        [KWEnum(AdvancedOptions,Off,_SPECULARHIGHLIGHTS_OFF,On,_)] _SpecularHighlights("高光开关", Float) = 1.0
        [KWEnum(AdvancedOptions,Off,_ENVIRONMENTREFLECTIONS_OFF,On,_)] _EnvironmentReflections("环境反射开关", Float) = 1.0
//        [SubToggle(AdvancedOptions,_FGDMAP)] _FGDMapKey("FGD贴图开关",Float)=0.0
//        [ShowIf(_FGDMapKey, Equal, 1)][Sub(AdvancedOptions)][NoScaleOffset]_FGDMap("FGD贴图", 2D) = "white" {}
                
        /*
        // Specular vs Metallic workflow
        _WorkflowMode("WorkflowMode", Float) = 1.0

        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap("Metallic", 2D) = "white" {}

        _SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
        _SpecGlossMap("Specular", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        _Parallax("Scale", Range(0.005, 0.08)) = 0.005
        _ParallaxMap("Height Map", 2D) = "black" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}

        [HDR] _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        _DetailMask("Detail Mask", 2D) = "white" {}
        _DetailAlbedoMapScale("Scale", Range(0.0, 2.0)) = 1.0
        _DetailAlbedoMap("Detail Albedo x2", 2D) = "linearGrey" {}
        _DetailNormalMapScale("Scale", Range(0.0, 2.0)) = 1.0
        [Normal] _DetailNormalMap("Normal Map", 2D) = "bump" {}

        // SRP batching compatibility for Clear Coat (Not used in Lit)
        [HideInInspector] _ClearCoatMask("_ClearCoatMask", Float) = 0.0
        [HideInInspector] _ClearCoatSmoothness("_ClearCoatSmoothness", Float) = 0.0

        // Blending state
        _Surface("__surface", Float) = 0.0
        _Blend("__blend", Float) = 0.0
        _Cull("__cull", Float) = 2.0
        [ToggleUI] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 1.0
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0

        [ToggleUI] _ReceiveShadows("Receive Shadows", Float) = 1.0
        // Editmode props
        _QueueOffset("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
        [HideInInspector] _Glossiness("Smoothness", Float) = 0.0
        [HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        */

    }

    SubShader
    {        
        pass
        {
            Tags { "LightMode" = "CostumeZWrite" }
            ZWrite [_TransparentZWrite]
            ColorMask 0
        }
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }
        LOD 300

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // -------------------------------------
            // Render State Commands
            Blend[_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            ZTest[_ZTest]
            ZWrite[_ZWrite]
            Cull[_Cull]
            AlphaToMask[_AlphaToMask]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            // #pragma vertex LitPassVertex
            #pragma vertex LitPassVertexGeom
            #pragma fragment LitPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON _ALPHAMODULATE_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP

            //=============================================================================//
            //=================================48Add Start=================================//
            #pragma shader_feature_local _DOUBLESIDED//双面渲染
            #pragma shader_feature_local _CUSTOMSPECCUBEMAP//自定义环境贴图
            #pragma shader_feature_local _CUSTOMSH//自定义SH

            #pragma shader_feature_local _BILLBOARD//广告牌
            #pragma shader_feature_local _IRIDESCENCE//薄膜干涉            
            #pragma shader_feature_local _MATCAP//材质捕捉
            #pragma shader_feature_local _CLEARCOAT//清漆
            
            #pragma shader_feature_local _MATERIAL_UNIVERSAL _MATERIAL_FABRIC//通用、布料
            #pragma shader_feature_local _ _FABRIC_COTTON _FABRIC_VELVET _FABRIC_SILK//棉麻、天鹅绒、丝绸
            //cotton,denim,fabric,fur,knit,laces,leather,rubber,special,wool,velvet、silk、laser
            //棉、牛仔布、织物、毛皮、针织、鞋带、皮革、橡胶、特殊、羊毛、天鹅绒、丝绸、镭射
            //棉、织物、羊毛
            //天鹅绒
            //丝绸
            //皮革            
            //毛皮
            //镭射
            #pragma shader_feature_local_fragment _MATERIAL_FEATURE_TRANSLUCENCY//透光
            // #pragma shader_feature_local_fragment _FGDMAP
            #define _FGDMAP
            
            #pragma shader_feature_local _FUR//绒毛
            #pragma shader_feature_local _THREADMAP//编织贴图
            #pragma shader_feature_local_fragment _FUZZMAP//绒毛贴图

            #pragma shader_feature_local_fragment _GRADUALCOLOR//渐变色

            #pragma shader_feature_local_fragment _SEQUIN//亮片
            #pragma shader_feature_local_fragment _SEQUINDEBUG//亮片形状观察
            

            #pragma shader_feature_local_fragment _BASEMAPLAYER1
            #pragma shader_feature_local_fragment _NORMALMAPLAYER1
            #pragma shader_feature_local_fragment _BASEMAPLAYER2
            #pragma shader_feature_local_fragment _NORMALMAPLAYER2
            #pragma shader_feature_local_fragment _BASEMAPLAYER3
            #pragma shader_feature_local_fragment _NORMALMAPLAYER3
            //==================================48Add End==================================//
            //=============================================================================//

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ _FORWARD_PLUS
            //#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            //#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"


            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"


            #include "ShaderLibrary/48LitInput.hlsl"
            #include "ShaderLibrary/48LitForwardPass.hlsl"
            #include_with_pragmas "ShaderLibrary/Geometry.hlsl"
            
            ENDHLSL
        }


        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Universal Pipeline keywords

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite[_ZWrite]
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitGBufferPassVertex
            #pragma fragment LitGBufferPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            //#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitGBufferPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ColorMask R
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // -------------------------------------
            // Universal Pipeline keywords
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // -------------------------------------
            // Render State Commands
            Cull Off

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _SPECGLOSSMAP
            #pragma shader_feature EDITOR_VISUALIZATION

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Universal2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // -------------------------------------
            // Render State Commands
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
            ENDHLSL
        }

        UsePass "URP/UT/Character/Cloth_Dyeing_Lit/SelfShadowCaster"
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "LWGUI.LWGUI"
    //    CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.LitShader"
}