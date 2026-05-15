#macro fogAreaWidth 1920 // do not touch this unless you have a good reason, do not use this to fit it to the screen or so help me god. Use a matrix to scale it to the screen instead!!!
#macro fogAreaHeight 1080
#macro layersBufferAbove 0
#macro layersBufferBelow 30
#macro depthCompression 1

#macro fogSurfSize 2048

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_alphatestenable(true);

shader_set_live(shd_blendAddAlpha, true);
shader_set_live(shd_fog, true);

depth = -12000;

fogLayers = 96;
fogLayersHor = 192;

fogVBuff = -1;

fogTex = sprite_get_texture(spr_fogOld, 0);

timer = 0;

vertex_format_begin();

vertex_format_add_position_3d();
vertex_format_add_texcoord();
vertex_format_add_color();
vertex_format_add_custom(vertex_type_float1, vertex_usage_texcoord);

fogVFormat = vertex_format_end();

fogSurf = -1;
fogSurfCopy = -1;

fogDrawAlpha = 1;
fogDrawScale = .1;

getFogSurf = function() {
	if(!surface_exists(fogSurf)) {
		surface_depth_disable(true);
		fogSurf = surface_create(fogSurfSize, fogSurfSize);
		surface_depth_disable(false);
		
		//drawToFogSurf(1, 0, 0, spr_fogMap, 0, 1, 0, c_white, 1, false)
	}
	
	return fogSurf;
}

getFogSurfCopy = function() {
	if(!surface_exists(fogSurfCopy)) {
		surface_depth_disable(true);
		fogSurfCopy = surface_create(fogSurfSize, fogSurfSize);
		surface_depth_disable(false);
	}
	
	return fogSurfCopy;
}

surfDupeCopy = function(surf) {
	var _surf = getFogSurfCopy();
	
	surface_copy(_surf, 0, 0, surf);
	
	return _surf;
}

drawToFogSurf = function(strength, xx, yy, sprite, img = 0, scale = 1, rot = 0, col = c_white, alphaGoalMult = 1, doFlow = false) {
	live_name = "drawSuf";
	if (live_call(strength, xx, yy, sprite, img, scale, rot, col, alphaGoalMult, doFlow)) return live_result;
	
	var _fogSurf = getFogSurf();
	var _fogSurfCopy = surfDupeCopy(_fogSurf);
	
	var _removeX = (fogSurfSize * xx / (10000) + fogSurfSize * 100) % fogSurfSize; // 10000 is width of fog area in world space...
	var _removeY = (fogSurfSize * yy / (10000) + fogSurfSize * 100) % fogSurfSize; // todo replace wrapping logic here
	
	surface_set_target(_fogSurf);
	
	gpu_set_blendmode_ext(bm_one, bm_zero);
	
	//gpu_set_blendmode(bm_subtract);
	
	gpu_set_ztestenable(false);
	gpu_set_alphatestenable(false);
	
	shader_set(shd_blendAddAlpha);
	
	gpu_set_tex_repeat(true);
	
	shader_set_uniform_f(shader_get_uniform(shd_blendAddAlpha, "strength"), strength);
	shader_set_uniform_f(shader_get_uniform(shd_blendAddAlpha, "flow"), doFlow);
	
	texture_set_stage(shader_get_sampler_index(shd_blendAddAlpha, "baseSurf"), surface_get_texture(_fogSurfCopy));
	
	draw_sprite_ext(sprite, img, _removeX, _removeY, scale, scale, rot, col, alphaGoalMult);
	
	gpu_set_tex_repeat(false);
	
	shader_reset();
	
	gpu_set_blendmode(bm_normal);
	
	surface_reset_target();
	
	gpu_set_ztestenable(true);
	gpu_set_alphatestenable(true);
	
	surface_free(_fogSurfCopy);
	
	return _fogSurf;
}

drawRemoveFromFogSurf = function(strength, xx, yy, sprite, img = 0, scale = 1, rot = 0, col = c_white, alphaGoalMult = 1, doFlow = false) {
	var _fogSurf = getFogSurf();
	
	var _removeX = (fogSurfSize * xx / (10000) + fogSurfSize * 100) % fogSurfSize; // 10000 is width of fog area in world space...
	var _removeY = (fogSurfSize * yy / (10000) + fogSurfSize * 100) % fogSurfSize; // todo replace wrapping logic here
	
	surface_set_target(_fogSurf);
	
	gpu_set_ztestenable(false);
	gpu_set_alphatestenable(false);
	
	gpu_set_blendmode(bm_subtract);
	
	gpu_set_colourwriteenable(false, false, false, true); // only affects alpha channel when subtracting..?
	
	gpu_set_tex_repeat(true);
	
	draw_sprite_ext(sprite, img, _removeX, _removeY, scale, scale, rot, col, alphaGoalMult);
	
	gpu_set_tex_repeat(false);
	
	gpu_set_colourwriteenable(true, true, true, true);
	
	gpu_set_blendmode(bm_normal);
	
	surface_reset_target();
	
	gpu_set_ztestenable(true);
	gpu_set_alphatestenable(true);
	
	return _fogSurf;
}

/// @desc Function Creates a vBuff for fog handling, the scale is fogWidth and fogHeight macro, however do not change these! Which means that when you draw it to your screen you'll have to use a scale matrix to fit it the screen size!
createFog = function() {
	var _perQuadXStep = fogAreaWidth / fogLayersHor;
	var _perQuadYStep = fogAreaHeight / fogLayers;
	
	var _fogBase = 0;
	
	fogVBuff = vertex_create_buffer();

	var _z = 0; // depth based 0-1000
	
	vertex_begin(fogVBuff, fogVFormat);
	
	//var _xVariance = _perQuadXStep * .2;
	//var _leftVariance = 0;
	//var _rightVariance = irandom_range(-_xVariance, _xVariance);
	
	for(var _yy = -layersBufferAbove; _yy < fogLayers + layersBufferBelow; _yy++) {
		for(var _xx = -1; _xx <= fogLayersHor; _xx++) {
			
			//_leftVariance = _rightVariance;
			//_rightVariance = irandom_range(-_xVariance, _xVariance);
			
			_fogBase = (_yy + 1) * _perQuadYStep;
			
			_z = -_fogBase;                                           // <---- override, z is locked to base y here!!!!
			
			vertex_position_3d(fogVBuff, _xx * _perQuadXStep, _fogBase, _z);
			vertex_texcoord(fogVBuff, 0, 0);
			vertex_color(fogVBuff, c_white, 1);
			vertex_float1(fogVBuff, _fogBase);
			
			vertex_position_3d(fogVBuff, (_xx + 1) * _perQuadXStep, _fogBase, _z);
			vertex_texcoord(fogVBuff, 1, 0);
			vertex_color(fogVBuff, c_white, 1);
			vertex_float1(fogVBuff, _fogBase);
			
			vertex_position_3d(fogVBuff, (_xx + 1) * _perQuadXStep, _fogBase, _z);
			vertex_texcoord(fogVBuff, 1, 1);
			vertex_color(fogVBuff, c_white, 1);
			vertex_float1(fogVBuff, 0);
			
			vertex_position_3d(fogVBuff, (_xx + 1) * _perQuadXStep, _fogBase, _z);
			vertex_texcoord(fogVBuff, 1, 1);
			vertex_color(fogVBuff, c_white, 1);
			vertex_float1(fogVBuff, 0);
			
			vertex_position_3d(fogVBuff, _xx * _perQuadXStep, _fogBase, _z);
			vertex_texcoord(fogVBuff, 0, 1);
			vertex_color(fogVBuff, c_white, 1);
			vertex_float1(fogVBuff, 0);
			
			vertex_position_3d(fogVBuff, _xx * _perQuadXStep, _fogBase, _z);
			vertex_texcoord(fogVBuff, 0, 0);
			vertex_color(fogVBuff, c_white, 1);
			vertex_float1(fogVBuff, _fogBase);
		}
		
		_z -= _perQuadYStep;
	}
	
	//vertex_position_3d(fogVBuff, -2999, -2999, _z);
	//vertex_texcoord(fogVBuff, 0, 0);
	//vertex_color(fogVBuff, c_blue, 1);
	//vertex_float1(fogVBuff, 0);
	//
	//vertex_position_3d(fogVBuff, 2999, -2999, _z);
	//vertex_texcoord(fogVBuff, 1, 0);
	//vertex_color(fogVBuff, c_white, 1);
	//vertex_float1(fogVBuff, 0);
	//
	//vertex_position_3d(fogVBuff, 2999, 2999, _z);
	//vertex_texcoord(fogVBuff, 1, 1);
	//vertex_color(fogVBuff, c_white, 1);
	//vertex_float1(fogVBuff, 0);
	//
	//vertex_position_3d(fogVBuff, 2999, 2999, _z);
	//vertex_texcoord(fogVBuff, 1, 1);
	//vertex_color(fogVBuff, c_green, 1);
	//vertex_float1(fogVBuff, 0);
	//
	//vertex_position_3d(fogVBuff, -2999, 2999, _z);
	//vertex_texcoord(fogVBuff, 0, 1);
	//vertex_color(fogVBuff, c_white, 1);
	//vertex_float1(fogVBuff, 0);
	//
	//vertex_position_3d(fogVBuff, -2999, -2999, _z);
	//vertex_texcoord(fogVBuff, 0, 0);
	//vertex_color(fogVBuff, c_purple, 1);
	//vertex_float1(fogVBuff, 0);
	
	vertex_end(fogVBuff);
}

draw = function(top = undefined, left = undefined, width = undefined, height = undefined, depthOffset = 0) {
	live_name = "drawStuff";
	if (live_call(top, left, width, height, depthOffset)) return live_result;
	
	var _fogSurf;
	
	if(timer % 5 == 0) {
		_fogSurf = drawToFogSurf(.005, 0, 0, spr_fogMap, 0, 1, 0, c_white, 1, true);
	} else {
		_fogSurf = getFogSurf();
	}
	
	var _cam = view_camera[0];

	width ??= camera_get_view_width(_cam);
	height ??= camera_get_view_height(_cam);
	
	if(is_undefined(left)) {
		var _camX = camera_get_view_x(_cam);
		left ??= _camX - _camX % (width / fogLayersHor);
	}
	
	if(is_undefined(top)) {
		var _camY = camera_get_view_y(_cam);
		top ??= _camY - _camY % (height / fogLayers);
	}

	var _wScale = width / fogAreaWidth;
	var _hScale = height / fogAreaHeight;
	
	matrix_set(matrix_world, matrix_build(left, top, (-(top) + depthOffset) * depthCompression, 0, 0, 0, _wScale, _hScale, _hScale * depthCompression)); // might need to be shifted to bottom of screen for depth (also compress z dimension for -y * factor scaling of depth
	
	shader_set(shd_fog);
	
	shader_set_uniform_f(shader_get_uniform(shd_fog, "height"), 52 / _hScale);
	shader_set_uniform_f(shader_get_uniform(shd_fog, "time"), current_time / 1000);
	shader_set_uniform_f(shader_get_uniform(shd_fog, "col"), 1.0, 1., 1.0, .4);
	
	var _fogTex = surface_get_texture(_fogSurf);
	texture_set_stage_vs(0, _fogTex);
	
	vertex_submit(fogVBuff, pr_trianglelist, fogTex);
	
	shader_reset();
	
	matrix_set(matrix_world, matrix_build_identity());
	
	//gpu_set_ztestenable(false);
	
	surface_free(fogSurfCopy); // ??? why is it lagging to hell every time??
}

createFog();