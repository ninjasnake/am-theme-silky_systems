uniform sampler2D texture;

uniform vec2 params;
const float PI = 3.14159265359;
float mult;

void main()
{
    vec4 pixel = texture2D(texture, gl_TexCoord[0].xy);
    gl_FragColor = gl_Color * pixel;
	if( params.y )
		gl_FragColor.xyz = gl_FragColor.xyz * ((sin((gl_TexCoord[0].y * params.x ) * PI ) + 1) * 0.5);
}
