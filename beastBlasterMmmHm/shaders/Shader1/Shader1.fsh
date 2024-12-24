uniform vec2 roomPosition;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
 
uniform vec2 gm_pSurfaceDimensions;
 
uniform sampler2D g_DistortTexture;
uniform vec2 g_DistortTextureDimensions;
 
uniform float g_DistortScale;
uniform float g_DistortAmount;

void main()
{
    vec2 distortCoords;
	
    distortCoords = (v_vTexcoord * gm_pSurfaceDimensions) / g_DistortTextureDimensions + roomPosition; 
    distortCoords /= g_DistortScale;
    
    vec2 distortVal = texture2D(g_DistortTexture, distortCoords).rg;
	//vec2 miniDistortVal = texture2D(g_DistortTexture, distortCoords * 3.0).rg;
	
    distortVal -= 0.50196;          // this is 128/255 (treating 128 as the centre value)   
    distortVal *=- 2.0;
    distortVal *= g_DistortAmount;
	
	//miniDistortVal -= 0.50196;          // this is 128/255 (treating 128 as the centre value)   
    //miniDistortVal *=- 2.0;
    //miniDistortVal *= (g_DistortAmount / 5.0); // mini distort is essentially a secondary pass of the distortion to create smaller ripples to augment the more general landscape distortions to eliminate gridyness and also create roughness, both are done by distortion here
    
    distortVal /= gm_pSurfaceDimensions;
    //miniDistortVal /= gm_pSurfaceDimensions;  
	
    gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord + distortVal);// + miniDistortVal);

}