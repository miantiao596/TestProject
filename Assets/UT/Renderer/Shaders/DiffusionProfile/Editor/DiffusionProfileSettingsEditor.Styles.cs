using System;
using UnityEngine;

namespace UnityEditor.Rendering.Universal
{
    sealed partial class DiffusionProfileSettingsEditor
    {
        static class Styles
        {
            public static readonly GUIContent scatteringLabel = EditorGUIUtility.TrTextContent("Scattering");
            public static readonly GUIContent profileScatteringColor = EditorGUIUtility.TrTextContent("Scattering Color", "控制扩散配置文件的形态，应与材质的漫反射颜色保持一致。");
            public static readonly GUIContent profileScatteringDistanceMultiplier = EditorGUIUtility.TrTextContent("Multiplier", "作为散射颜色的倍增系数，用于控制光线在材质表面下方的传播距离，同时调节滤镜算法的有效作用半径。");
            public static readonly GUIContent profileTransmissionTint = EditorGUIUtility.TrTextContent("Transmission Tint", "指定穿透物体的半透射光照的染色效果。");
            public static readonly GUIContent profileMaxRadius = EditorGUIUtility.TrTextContent("Max Radius", "由散射颜色和倍增系数定义效果的最大作用半径。当世界单位比例为1时，该值以毫米为单位。");

            public static readonly GUIContent profileWorldScale = EditorGUIUtility.TrTextContent("World Scale", "控制此扩散配置文件对应的Unity世界单位缩放比例。");
            public static readonly GUIContent profileIor = EditorGUIUtility.TrTextContent("Index of Refraction", "控制材质的折射特性，数值越大镜面反射的强度越高。");

            public static readonly GUIContent subsurfaceScatteringLabel = EditorGUIUtility.TrTextContent("Subsurface Scattering only");
            public static readonly GUIContent smoothnessMultipliers = EditorGUIUtility.TrTextContent("Dual Lobe Multipliers", "两个镜面反射波瓣平滑度的倍增参数");

            public static readonly GUIContent transmissionLabel = EditorGUIUtility.TrTextContent("Transmission only");
            public static readonly GUIContent profileTransmissionMode = EditorGUIUtility.TrTextContent("Transmission Mode", "• Post-Scatter：在次表面散射通道完成后，HDRP 将反照率应用于材质。这意味着反照率纹理的内容不会模糊。此模式适合用于因次表面散射而已经有一定模糊程度的扫描数据和照片。\n• Pre- and Post-Scatter：在次表面散射通道之前和之后两次以不完整的形式应用反照率。这样实际上会使反照率模糊，从而使外观更柔和、更自然。");
            public static readonly GUIContent profileMinMaxThickness = EditorGUIUtility.TrTextContent("Thickness Remap Values (Min-Max)", "设置厚度值的范围（以毫米为单位），对应厚度贴图中存储的[0, 1]范围内的纹理元素值。");
            public static readonly GUIContent profileThicknessRemap = EditorGUIUtility.TrTextContent("Thickness Remap (Min-Max)", profileMinMaxThickness.tooltip);


            public static readonly GUIContent profilePreview0 = EditorGUIUtility.TrTextContent("Diffusion Profile Preview");
            public static readonly GUIContent profilePreview1 = EditorGUIUtility.TrTextContent("显示从中心光源位置散射的光线比例。与图像边界的距离对应于最大半径 (Max Radius)。");
            public static readonly GUIContent transmittancePreview0 = EditorGUIUtility.TrTextContent("Transmittance Preview");
            public static readonly GUIContent transmittancePreview1 = EditorGUIUtility.TrTextContent("显示通过游戏对象的光线比例，具体取决于 Thickness Remap (mm) 的值。");
            public static GUIStyle miniBoldButton => s_MiniBoldButton.Value;
            static readonly Lazy<GUIStyle> s_MiniBoldButton = new ( () => new GUIStyle(GUI.skin.label)
            {
                alignment = TextAnchor.MiddleCenter,
                fontSize = 10,
                fontStyle = FontStyle.Bold
            });
        }
    }
}
