
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 center;
uniform vec2 resolution;

vec2   iResolution = resolution;			// viewport resolution (in pixels)
float  iGlobalTime = CC_Time[1];           // shader playback time (in seconds)

//uniform float time;
//uniform vec2 mouse;


void plane(out float t, vec3 o, vec3 d, vec3 N, vec3 p)
{
	float temp = -((dot(N, o - p) / dot(N, d)));
	if(temp > 0.0) t = temp;
}
void raytrace(out float t, vec3 o, vec3 d)
{
	t = 10000.0;
	float temp = t;
	plane(temp, o, d, vec3(0,1,0), vec3(0, 5, 0));
	t = min(temp, t);
	plane(temp, o, d, vec3(-1,0,0), vec3(-5, 0, 0));
	t = min(temp, t);
	plane(temp, o, d, vec3(-1,0,0), vec3(5, 0, 0));
	t = min(temp, t);
	plane(temp, o, d, vec3(0,-1,0), vec3(0, -5, 0));
	t = min(temp, t);
}

void main( void ) {

	//vec2 uv = ( gl_FragCoord.xy / iResolution.xy ) * 2.0 - 1.0;
	vec2 uv = (gl_FragCoord.xy - center.xy) / iResolution.xy;

	vec3 dir = normalize(vec3(uv, 1.0));
	vec3 pos = vec3(0.0, 10.0, -10.0);
	float t = 10000.0;
	raytrace(t, pos, dir);

	gl_FragColor = vec4(t * 0.01);

}