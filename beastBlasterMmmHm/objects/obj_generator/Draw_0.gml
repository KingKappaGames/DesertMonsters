if(updatePerlin) {
	var _height = 0;

	surface_set_target(getSurf());

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

var _gridX = y div blockSize * blockSize;
var _gridY = x div blockSize * blockSize;

shader_set(Shader1);

shader_set_uniform_f(shader_get_uniform(Shader1, "roomPosition"), (x - (x - updateLastX)) / _distortionWidth, (y - (y - updateLastY)) / _distortionWidth);

shader_set_uniform_f(shader_get_uniform(Shader1, "gm_pSurfaceDimensions"), surface_get_width(perlinSurf), surface_get_height(perlinSurf));


var texture = sprite_get_texture(spr_distort_smoothnoise, 0);
var register = shader_get_sampler_index(Shader1, "g_DistortTexture");
texture_set_stage(register, texture);
gpu_set_texrepeat_ext(register, true);


shader_set_uniform_f(shader_get_uniform(Shader1, "g_DistortTextureDimensions"), _distortionWidth, _distortionHeight);

shader_set_uniform_f(shader_get_uniform(Shader1, "g_DistortScale"), 10.0);
shader_set_uniform_f(shader_get_uniform(Shader1, "g_DistortAmount"), 60.0);
shader_set_uniform_f(shader_get_uniform(Shader1, "g_DistortOffset"), 0.0, 0.0);

draw_surface(getSurf(), updateLastX, updateLastY); // round draw positions to grid spaces

gpu_set_texrepeat_ext(register, false);

shader_reset();