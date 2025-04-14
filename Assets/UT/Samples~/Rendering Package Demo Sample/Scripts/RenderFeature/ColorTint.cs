using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;



namespace UT.Rendering
{
    // 自定义组件
    [VolumeComponentMenu("Showcase-PostProcessing/Color Tint")]

    public class ColorTint : ShowcaseProcessing
    {

        // 创建材质制定Shader路径
        private Material mMaterial;
        private const string mShaderName = "Showcase/ColorTint";

        // 设置颜色参数
        public BoolParameter useTint = new BoolParameter(false);
        public BoolParameter useAddOn = new BoolParameter(false);
        public ColorParameter ColorChange = new ColorParameter(Color.white, true);
        public ColorParameter ColorAddOn = new ColorParameter(Color.white, true);

        //private bool bUseTint = useTint.value; 

        // 是否应用后处理
        public override bool IsActive() => mMaterial != null && (IsColorFilterActive());
        // 判断设置颜色
        private bool IsColorFilterActive() => useTint == true || useAddOn == true;

        // 设置渲染流程中的注入点
        public override BasicInjectionPoint InjectionPoint => BasicInjectionPoint.AfterPostProcess;
        public override int OrderInInjectionPoint => 15;

        //public void OnValidate()
        //{
        //    if (useTint == false) ColorChange.overrideState = false;
            
        //}

        // 配置当前后处理 创建对应的材质
        public override void Setup()
        {
            if (mMaterial == null)

                mMaterial = CoreUtils.CreateEngineMaterial(mShaderName);
        }



        // 执行渲染逻辑
        public override void Render(CommandBuffer cmd, ref RenderingData renderingData, RTHandle source, RTHandle destination)
        {
            if (mMaterial == null) return;
            if (useTint == true)
            {
                mMaterial.SetColor("_ColorTint", ColorChange.value);
            }
            else
            {
                //Debug.Log(ColorChange.overrideState);
                ColorChange.overrideState = false;
                //Debug.Log(ColorChange.overrideState);
                //mMaterial.SetColor("_ColorTint", ColorChange.value);
            }

            mMaterial.SetColor("_ColorAdjust", ColorAddOn.value);
            cmd.Blit(source, destination, mMaterial, 0);
        }
        

        // 清理临时RT
        public override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
            CoreUtils.Destroy(mMaterial);

        }


    }

}
