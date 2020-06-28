"															\n\
#ifdef GL_ES												\n\
precision mediump float;									\n\
#endif														\n\
                                                            \n\
varying vec4 v_fragmentColor;								\n\
varying vec2 v_texCoord;									\n\
                                                            \n\
// suffix naming convention:                                \n\
// -- 0 or none: brush                                      \n\
// -- 1: target                                             \n\
// -- 2: canvas                                             \n\
uniform sampler2D CC_Texture0;  // brush					\n\
uniform float CC_alpha_value0;                              \n\
uniform vec2 v_texSize0;        // brush tex size           \n\
															\n\
// 0.0 ~ 1.0 (0.0 for instant erasing, 1.0 for no erase)	\n\
uniform float CC_brushOpacity;								\n\
                                                            \n\
void main()													\n\
{															\n\
	// tex color of brush in the given coord                \n\
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);     \n\
                                                            \n\
	if (texColor.a <= CC_alpha_value0)				    	\n\
		discard;											\n\
	else													\n\
		gl_FragColor = vec4(0, 0, 0, CC_brushOpacity);		\n\
}															\n\
";
