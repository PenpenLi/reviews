
#ifdef GL_ES												
precision mediump float;									
#endif														
                                                            
varying vec4 v_fragmentColor;								
varying vec2 v_texCoord;									
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

uniform sampler2D u_brushTexture ;                          
uniform sampler2D u_targetTexture;	// target               
uniform vec2 u_brushSize;  // brush tex size                 
uniform vec2 u_targetSize;  // target tex size				
uniform float u_brushOpacity;  // 0.0 ~ 1.0                 
// paint point coord in target's local coord system         
uniform vec2 v_targetCoord; // brush in target lb position  
															
void main()													
{                                                           
    vec4 brushColor = texture2D(u_brushTexture, v_texCoord); 
    if (brushColor.a <= 0.0){                               
         discard;                                            
    }														
															
// texture coord in target will draw                        
vec2 texCoord2 = (u_targetSize * v_targetCoord + u_brushSize * v_texCoord) / u_targetSize;
// texture color for texture coord                          
vec4 texColor1 = texture2D(u_targetTexture, texCoord2);     
gl_FragColor = texColor1 * u_brushOpacity;                  
}																													


