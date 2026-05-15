varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
	vec4 col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	float bright = sin(col.a * 12.566);
	
    gl_FragColor = vec4(col.a, bright, bright, 1.0);
}
