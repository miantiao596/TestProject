# About Rendering


# Using Rendering


# Technical details
## Requirements

This plugin is compatible with the following versions of the Unity Editor:
* 2022.3 and later (recommended)

# Structure
- Editor 存储Unity编辑器下的脚本、资源，不参与打包，如ShaderGUI，编辑器工具等。
- Runtime 存储Unity运行时下的脚本、资源，会参与打包，如Monobehaviour、运行时需要的材质球等。
- Shaders 存储着色器相关文件，因为着色器主要是静态资源，所以未被项目或者Runtime内资源引用到的着色器，也不会参与打包。
- Textures 存储上述资源中会用到的相关贴图，原理同Shaders。
- ThirdParty 存储修改过的第三方插件。
