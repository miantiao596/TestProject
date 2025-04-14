#ifndef FA_SCENE_SHADOW_INPUT_MACRO
	#define FA_SCENE_SHADOW_INPUT_MACRO
	
	// ��ɫ����Ӱ
	#define SCENE_SHADOW_INPUT \
    float   _EnableSelfShadowMapping; \
    half    _SelfShadowIntensity; \
    //float   _SelfShadowMappingDepthBias;
    float   _EnableURPShadowMapping; \
    half    _IgnoreMainShadowAtten;
#endif