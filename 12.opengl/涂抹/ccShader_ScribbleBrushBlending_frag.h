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
uniform sampler2D CC_Texture1;	// target					\n\
uniform sampler2D CC_Texture2;  // canvas                   \n\
                                                            \n\
uniform float CC_alpha_value0;	// brush					\n\
uniform float CC_alpha_value1;	// target					\n\
                                                            \n\
// paint point coord in target's local coord system         \n\
uniform vec2 v_texCoord1;	    							\n\
uniform vec2 v_texCoord2;                                   \n\
uniform vec2 v_texSize0;  // brush tex size                 \n\
uniform vec2 v_texSize1;  // target tex size				\n\
uniform vec2 v_texSize2;  // canvas tex size                \n\
															\n\
uniform float CC_brushOpacity;  // 0.0 ~ 1.0        		\n\
															\n\
void main()													\n\
{															\n\
    // tex color of brush in the given coord                \n\
    vec4 texColor = texture2D(CC_Texture0, v_texCoord);		\n\
															\n\
	if (texColor.a <= CC_alpha_value0)				    	\n\
		discard;											\n\
    														\n\
    vec2 texCoord1 = (v_texCoord1 * v_texSize1 + v_texCoord * v_texSize0) / v_texSize1;  \n\
    vec4 texColor1 = texture2D(CC_Texture1, texCoord1);		\n\
                                                        	\n\
    if (texColor1.a <= CC_alpha_value1)                 	\n\
    {                                                       \n\
        discard;											\n\
    }                                                       \n\
    else													\n\
    {                                                       \n\
        vec2 texCoord2 = (v_texCoord2 * v_texSize2 + v_texCoord * v_texSize0) / v_texSize2;  \n\
        vec4 texColor2 = texture2D(CC_Texture2, texCoord2); \n\
                                                            \n\
        if (texColor2.a < 0.00001) {                        \n\
            gl_FragColor = texColor1 * CC_brushOpacity;     \n\
        } else {                                            \n\
            gl_FragColor = (texColor1 + texColor2) / 2.0;   \n\
        }                                                   \n\
        // texColor1 = texColor1 * CC_brushOpacity;  \n\
        // float ra = texColor1.a + texColor2.a * (1.0 - texColor1.a);  \n\
        // if (ra < 0.000001) {  \n\
        //     discard;  \n\
        // } else {  \n\
        //     gl_FragColor = vec4((texColor1.rgb * texColor1.a + texColor2.rgb * texColor2.a * (1.0 - texColor1.a)) / ra, ra);  \n\
        // }                                                   \n\
    }                                                       \n\
}															\n\
";
