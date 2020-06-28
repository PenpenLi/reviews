"                                           \n\
#ifdef GL_ES                                \n\
precision mediump float;                    \n\
#endif                                      \n\
                                            \n\
uniform sampler2D u_texture;                \n\
varying vec2 v_texCoord;                    \n\
varying vec4 v_fragmentColor;               \n\
                                            \n\
void main(void)                             \n\
{                                           \n\
    vec4 col = texture2D(u_texture, v_texCoord);                \n\
    // the following code is taken from example                 \n\
    //   Convert to greyscale using NTSC weightings             \n\
    //   float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));  \n\
    gl_FragColor = vec4(col.rgb * 0.7, col.a * 0.95);           \n\
}                                           \n\
";
