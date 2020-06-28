"															\n\
#ifdef GL_ES												\n\
precision mediump float;									\n\
#endif														\n\
                                                            \n\
varying vec4 v_fragmentColor;								\n\
varying vec2 v_texCoord;									\n\
															\n\
uniform sampler2D u_brushTexture ;                          \n\
uniform sampler2D u_targetTexture;	// target               \n\
uniform vec2 u_brushSize;  // brush tex size                 \n\
uniform vec2 u_targetSize;  // target tex size				\n\
uniform float u_brushOpacity;  // 0.0 ~ 1.0                 \n\
// paint point coord in target's local coord system         \n\
uniform vec2 v_targetCoord; // brush in target lb position  \n\
															\n\
void main()													\n\
{                                                           \n\
    vec4 brushColor = texture2D(u_brushTexture, v_texCoord); \n\
    if (brushColor.a <= 0.0){                               \n\
         discard;                                            \n\
    }														\n\
															\n\
// texture coord in target will draw                        \n\
vec2 texCoord2 = (u_targetSize * v_targetCoord + u_brushSize * v_texCoord) / u_targetSize;  \n\
// texture color for texture coord                          \n\
vec4 texColor1 = texture2D(u_targetTexture, texCoord2);     \n\
gl_FragColor = texColor1 * u_brushOpacity;                  \n\
}															\n\
";															


