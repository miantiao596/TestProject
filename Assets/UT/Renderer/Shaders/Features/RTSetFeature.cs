using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class SetGlobalTextureFeature : ScriptableRendererFeature
{
    private int _PreIntegratedFGD_GGXDisneyDiffuse_ID = Shader.PropertyToID("_PreIntegratedFGD_GGXDisneyDiffuse");
    public RenderTexture FGD_GGXDisneyDiffuse;
    public Texture FGD_GGXDisneyDiffuse_Texture;
    private int _PreIntegratedFGD_CharlieAndFabric_ID = Shader.PropertyToID("_PreIntegratedFGD_CharlieAndFabric");
    public RenderTexture FGD_CharlieAndFabric;
    public Texture FGD_CharlieAndFabric_Texture;
    private int _HairAzimuthalScattering_ID = Shader.PropertyToID("_HairAzimuthalScattering");
    public Texture3D HairAzimuthalScattering;
    public DiffusionProfileSettings DiffusionProfile;
    /// <inheritdoc/>
    public override void Create()
    {
        
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // Shader.SetGlobalTexture(_PreIntegratedFGD_GGXDisneyDiffuse_ID,FGD_GGXDisneyDiffuse);
        // Shader.SetGlobalTexture(_PreIntegratedFGD_CharlieAndFabric_ID,FGD_CharlieAndFabric);
        Shader.SetGlobalTexture(_PreIntegratedFGD_GGXDisneyDiffuse_ID,FGD_GGXDisneyDiffuse_Texture);
        Shader.SetGlobalTexture(_PreIntegratedFGD_CharlieAndFabric_ID,FGD_CharlieAndFabric_Texture);
        Shader.SetGlobalTexture(_HairAzimuthalScattering_ID,HairAzimuthalScattering);
        if (DiffusionProfile!=null)
        {
            Shader.SetGlobalVector(Shader.PropertyToID("_DualLobeAndDiffusePower"),DiffusionProfile.dualLobeAndDiffusePower);
            Shader.SetGlobalVector(Shader.PropertyToID("_WorldScalesAndFilterRadiiAndThicknessRemaps"),DiffusionProfile.worldScaleAndFilterRadiusAndThicknessRemap);
            Shader.SetGlobalVector(Shader.PropertyToID("_TransmissionTintsAndFresnel0"),DiffusionProfile.transmissionTintAndFresnel0);
            Shader.SetGlobalVector(Shader.PropertyToID("_ShapeParamsAndMaxScatterDists"),DiffusionProfile.shapeParamAndMaxScatterDist);
        }
    }
}


