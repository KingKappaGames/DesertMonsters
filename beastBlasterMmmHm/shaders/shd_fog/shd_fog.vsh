attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)
attribute float in_CustomData; // 0 or 1 representing whether this vertex is the base or top of the fog quad

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float height;
uniform float time;

uniform sampler2D fogMapSamp;

uniform vec4 col;

const float speed = .4;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	
	vec4 colNew = col;
	
	float heightNet = 0.0;
	
	if(in_CustomData > 1. || in_CustomData < -1.) { // height for base verts is 0, don't affect those ones
		vec4 vertPos = (gm_Matrices[MATRIX_WORLD] * object_space_pos) * .001;
		
		object_space_pos.y = in_CustomData;
		
		vec4 mapData = texture2D(fogMapSamp, clamp(mod(vertPos.xy * .1, 1.0), 0.0, 1.0));
		
		float mapHeight = max(0.0, mapData.a * 1.05 - .05); // grace where no fog shows
		
		vec4 mapCol = vec4(mapData.rgb, 1.0);
		
		float noise = 1.0 + sin(-time * speed + vertPos.x * 1.62 + vertPos.y * 50.48) * .39 + sin(time * speed * .527 + vertPos.x * 2.77 + vertPos.y * 110.348) * .235 + sin(time * speed * 1.732 + vertPos.x * 4.147 - vertPos.y * 190.482) * .14;
		
		heightNet = (height * mapHeight * noise);
		
		object_space_pos.y = object_space_pos.y - heightNet;
		
		//colNew = col * vec4(vec3(sin(vertPos.x * 5. + vertPos.y * 5.)), 1.0);
		
		//colNew = mix(colNew, mapCol, .5);
		colNew = mapCol;
	}
	
	vec4 worldPos = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	
    gl_Position = worldPos;
    
    v_vColour = in_Colour * colNew;
    v_vTexcoord = in_TextureCoord;
}
