  
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main() { 
    vec4 mycolor =  v_fragmentColor*texture2D(CC_Texture0, v_texCoord);
    float gray = dot(mycolor.rgb, vec3(0.2126, 0.7152, 0.0722));
    gl_FragColor =  vec4(gray);
    gl_FragColor.a = mycolor.a;
}