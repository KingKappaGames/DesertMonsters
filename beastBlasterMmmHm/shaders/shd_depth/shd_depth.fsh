varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	float depth = texture2D( gm_BaseTexture, v_vTexcoord ).r;
	
    gl_FragColor = vec4(vec3(depth), 1.0);
}