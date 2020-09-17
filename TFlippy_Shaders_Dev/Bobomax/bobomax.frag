uniform sampler2D baseMap;

varying vec2 Texcoord;
varying out vec4 fragColor;

uniform float res_x;
uniform float res_y;
uniform float time;

void main() 
{
    vec2 uv = gl_FragCoord / vec2(res_x, res_y);
    vec3 col = 0.5 + 0.5*cos(time+uv.xyx+vec3(0,2,4));
    fragColor = texture2D(baseMap, Texcoord) * vec4(col, 1.0);
}