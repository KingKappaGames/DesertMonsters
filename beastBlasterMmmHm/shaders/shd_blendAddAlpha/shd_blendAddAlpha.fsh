varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D baseSurf;

uniform float strength;

uniform float flow;

void main() {
	vec4 baseCol = texture2D( baseSurf, v_vTexcoord );
	vec4 addColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	float settleStrength = 1.0;
	if(flow > 0.0) {
		float rand = (fract(sin(4917.157 * (v_vTexcoord.x + v_vTexcoord.y)) * 2478.553)) * 842.283; // inline simple random radians
	
		float alpha = texture2D( baseSurf, vec2(v_vTexcoord.x + cos(rand) * .0075, v_vTexcoord.y + sin(rand) * .007) ).a;
		alpha += texture2D( baseSurf, vec2(v_vTexcoord.x - cos(rand * 22.82582) * .0075, v_vTexcoord.y - sin(rand * 22.82582) * .007) ).a; // why do i have to sample two positions, I didn't in the other project for this exact same effect??? UGHHH

		settleStrength = clamp(alpha, 0., 1.0);
		
		settleStrength = pow(addColor.a, 1.) * (max(0.0, pow(alpha, 2.4) - .001));
		
		float changeStrength = strength * settleStrength;
		float changeCull = ceil(changeStrength); // this will either be 1 or 0, so it will basically toggle off changing if the strength is literally 0 (as in areas not touching other fog and so without source for spreading) but otherwise leave unchanged
		
		float rChange = (addColor.r - baseCol.r);
		rChange = changeCull * sign(rChange) * max(.0039215686, abs(rChange * changeStrength));
		
		float gChange = (addColor.g - baseCol.g);
		gChange = changeCull * sign(gChange) * max(.0039215686, abs(gChange * changeStrength));
		
		float bChange = (addColor.b - baseCol.b);
		bChange = changeCull * sign(bChange) * max(.0039215686, abs(bChange * changeStrength));
		
		float aChange = (addColor.a - baseCol.a);
		aChange = changeCull * sign(aChange) * max(.0039215686, abs(aChange * changeStrength));
		
		//gl_FragColor = baseCol + vec4(rChange, gChange, bChange, aChange);
		gl_FragColor = baseCol + vec4(rChange, gChange, bChange, aChange);
	} else {
		gl_FragColor = mix(baseCol, addColor, strength);
	}
	
    //gl_FragColor = baseCol;//max(ceil(1.0) * .005, strength * settleStrength));
    //gl_FragColor = mix(baseCol, addColor, .02);
	//gl_FragColor = vec4(alph, alph, alph, .01);
}
