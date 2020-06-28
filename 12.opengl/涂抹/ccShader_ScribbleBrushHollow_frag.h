"															\n\
#ifdef GL_ES												\n\
precision mediump float;									\n\
#endif														\n\
                                                            \n\
varying vec4 v_fragmentColor;  // target pixel color		\n\
varying vec2 v_texCoord;  // target pixel location			\n\
                                                            \n\
uniform sampler2D CC_Texture0;  // target					\n\
uniform sampler2D CC_Texture1;	// brush					\n\
                                                            \n\
// paint point coord in target's local coord system         \n\
uniform vec2 v_texCoord1;  // brush location inside target	\n\
uniform vec2 v_texSize0;  // target tex size				\n\
uniform vec2 v_texSize1;  // brush tex size                 \n\
                                                            \n\
void main()													\n\
{															\n\
    vec4 texColorTarget = texture2D(CC_Texture0, v_texCoord);  \n\
                                                            \n\
    // tex color of brush in the given coord                \n\
    vec2 texBrushCoordLocal = (v_texCoord - v_texCoord1) * v_texSize0 / v_texSize1; \n\
    if (texBrushCoordLocal.x >= 0.0 && texBrushCoordLocal.x <= 1.0 && texBrushCoordLocal.y >= 0.0 && texBrushCoordLocal.y <= 1.0) {  \n\
        vec4 texColorBrush = texture2D(CC_Texture1, texBrushCoordLocal);  \n\
        gl_FragColor = vec4(texColorTarget.rgb, texColorTarget.a - texColorBrush.a);  \n\
    } else {                                                \n\
        gl_FragColor = texColorTarget;                      \n\
    }                                                       \n\
}                                                           \n\
";
