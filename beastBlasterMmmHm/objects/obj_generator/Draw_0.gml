if(updatePerlin) {
	updatePerlin = false;
	var _height = 0;

	surface_set_target(getSurf()); //TODO draw the old perlin surface offset to the grid position then redraw the gaps like the generator but for drawing!!
//old redrawing method 2.2 ms of lag for drawing the draw event (this event) in vm
	for(var i = 0; i < width; i++) {
	    for(var j = 0; j < height; j++) {
			_height = grid[# i, j];
			if(_height > valueRange * 1.0) {
				draw_sprite_ext(spr_perlinBlock, 0, i*blockSize,j*blockSize, 1, 1, 0, #f0bf90, 1);
			} else if(_height > valueRange * .80) {
				draw_sprite_ext(spr_perlinBlock, 0, i*blockSize,j*blockSize, 1, 1, 0, #f0bf7a, 1);
			} else if(_height > valueRange * .60) { 
				draw_sprite_ext(spr_perlinBlock, 0, i*blockSize,j*blockSize, 1, 1, 0, #c99751, 1);
			} else if(_height > valueRange * .55) {
				draw_sprite_ext(spr_perlinBlock, 0, i*blockSize,j*blockSize, 1, 1, 0, #9e763e, 1);
			} else if(_height > valueRange * .40) {
				draw_sprite_ext(spr_perlinBlock, 0, i*blockSize,j*blockSize, 1, 1, 0, #5e4c33, 1);
			} else if(_height > valueRange * .37) {
				draw_sprite_ext(spr_perlinBlock, 0, i*blockSize,j*blockSize, 1, 1, 0, #aa2400, 1); // thin band
			} else if(_height > valueRange * .25) {
				draw_sprite_ext(spr_perlinBlock, 0, i*blockSize,j*blockSize, 1, 1, 0, #5e4c33, 1);
			} else if(_height > valueRange * .21) {
				draw_sprite_ext(spr_perlinBlock, 0, i*blockSize,j*blockSize, 1, 1, 0, #483a23, 1);
			} else if(_height > valueRange * .13) {
				draw_sprite_ext(spr_perlinBlock, 0, i*blockSize,j*blockSize, 1, 1, 0, #3e4c23, 1);
			} else {
				draw_sprite_ext(spr_perlinBlock, 0, i*blockSize,j*blockSize, 1, 1, 0, #4d3f5c, 1);
			}
	    }
	}
	
	surface_reset_target();

	draw_set_color(c_white);
}


var _distortionWidth = sprite_get_width(spr_distort_smoothnoise);
var _distortionHeight = sprite_get_height(spr_distort_smoothnoise);

var _sandWidth = sprite_get_width(spr_sandTexture);
var _sandHeight = sprite_get_height(spr_sandTexture);

var _gridX = y div blockSize * blockSize;
var _gridY = x div blockSize * blockSize;

#region shader 1 (blur!) ###############################################################################################
shader_set(shd_desertDistortAndTexture);

shader_set_uniform_f(shader_get_uniform(shd_desertDistortAndTexture, "roomPositionDistort"), (x - (x - updateLastX)) / _distortionWidth, (y - (y - updateLastY)) / _distortionHeight);

shader_set_uniform_f(shader_get_uniform(shd_desertDistortAndTexture, "gm_pSurfaceDimensions"), surface_get_width(perlinSurf), surface_get_height(perlinSurf));

var texture = sprite_get_texture(spr_distort_smoothnoise, 0);
var register = shader_get_sampler_index(shd_desertDistortAndTexture, "g_DistortTexture");
texture_set_stage(register, texture);
gpu_set_texrepeat_ext(register, true);


shader_set_uniform_f(shader_get_uniform(shd_desertDistortAndTexture, "g_DistortTextureDimensions"), _distortionWidth, _distortionHeight);

shader_set_uniform_f(shader_get_uniform(shd_desertDistortAndTexture, "g_DistortScale"), 1.50);
shader_set_uniform_f(shader_get_uniform(shd_desertDistortAndTexture, "g_DistortAmount"), 38.0);
shader_set_uniform_f(shader_get_uniform(shd_desertDistortAndTexture, "g_DistortOffset"), 0.0, 0.0);

//Sand texture stuff
shader_set_uniform_f(shader_get_uniform(shd_desertDistortAndTexture, "roomPositionSand"), (x - (x - updateLastX)) / _sandWidth, (y - (y - updateLastY)) / _sandHeight);
var _sandTexture = sprite_get_texture(spr_sandTexture, 0);
var _sandRegister = shader_get_sampler_index(shd_desertDistortAndTexture, "g_sandTexture");
texture_set_stage(_sandRegister, _sandTexture);
gpu_set_texrepeat_ext(_sandRegister, true);

shader_set_uniform_f(shader_get_uniform(shd_desertDistortAndTexture, "g_sandTextureDimensions"), _sandWidth, _sandHeight);
shader_set_uniform_f(shader_get_uniform(shd_desertDistortAndTexture, "g_sandTextureOpacity"), .32);
#endregion ###############################################################################################################################



draw_surface(getSurf(), updateLastX, updateLastY); // round draw positions to grid spaces

gpu_set_texrepeat_ext(register, false);
gpu_set_texrepeat_ext(_sandRegister, false); 

shader_reset();