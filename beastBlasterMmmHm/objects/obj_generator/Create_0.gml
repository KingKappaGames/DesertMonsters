randomize();

depth = 3000;

global.generator = id;

seed = round(random_range(1000000,10000000));

#macro blockSize 8 // the size of the color blocks on screen in pixels
#macro valueRange 10000 // the breadth of the features in the map, scale
#macro bufferBlockCount 2

debugX = 0;
debugY = 0;
debugWidth = 0;
debugHeight = 0;


width = round(camera_get_view_width(view_camera[0]) / blockSize) + bufferBlockCount * 2;
height = round(camera_get_view_height(view_camera[0]) / blockSize) + bufferBlockCount * 2;

updatePerlinGrid = function() {
	ds_grid_destroy(grid); 
	
	width = round(camera_get_view_width(view_camera[0]) / blockSize) + bufferBlockCount * 2;
	height = round(camera_get_view_height(view_camera[0]) / blockSize) + bufferBlockCount * 2;
	
	grid = ds_grid_create(width, height);
}

grid = ds_grid_create(width, height);

updateLastX = 0;
updateLastY = 0;
updatePerlin = true;

perlinSurf = surface_create(width * blockSize, height * blockSize);

getSurf = function() {
	if(!surface_exists(perlinSurf)) {
		perlinSurf = surface_create(width * blockSize, height * blockSize);
		updatePerlin = true;
	}
	
	return perlinSurf;
}

spawnMapStuff = function(spawnCount) {
	getSurf(); // refresh the perlinSurf variable
	
	var _surfWidth = surface_get_width(perlinSurf);
	var _surfHeight = surface_get_height(perlinSurf);
	
	var _x, _y, _color;
	
	var _spawn = noone;
	
	repeat(spawnCount) {
		if(irandom(1) == 0) {
			_x = choose(irandom(blockSize * bufferBlockCount), _surfWidth - irandom(blockSize * bufferBlockCount) - 1);
			_y = irandom(_surfHeight - 1);
		} else {
			_x = irandom(_surfWidth - 1);
			_y = choose(irandom(blockSize * bufferBlockCount), _surfHeight - irandom(blockSize * bufferBlockCount) - 1);
		}
	
		_color = surface_getpixel(perlinSurf, _x, _y);
		
		_spawn = noone;
	
		if(_color == #f0bf90) {// exact check? (effects don't affect the surf itself so it should be exact to what I choose as colors
			//_spawn = instance_create_layer(x + _x, y + _y, "Instances", obj_palmTree);
		} else if(_color == #f0bf90) {
			//_spawn = instance_create_layer(x + _x, y + _y, "Instances", obj_palmTree);
		} else if(_color == #c99751) { 
			if(irandom(300)) {
				_spawn = instance_create_layer(updateLastX + _x, updateLastY + _y, "Instances", obj_palmTree);
			}
		} else if(_color == #9e763e) {
			if(irandom(50)) {
				_spawn = instance_create_layer(updateLastX + _x, updateLastY + _y, "Instances", obj_palmTree);
			}
		} else if(_color == #5e4c33) {
			if(irandom(24)) {
				_spawn = instance_create_layer(updateLastX + _x, updateLastY + _y, "Instances", obj_palmTree);
			}
		} else if(_color == #483a23) {
			if(irandom(12)) {
				_spawn = instance_create_layer(updateLastX + _x, updateLastY + _y, "Instances", obj_palmTree);
			}
		} else if(_color == #3e4c23) {
			_spawn = instance_create_layer(updateLastX + _x, updateLastY + _y, "Instances", obj_palmTree);
		} else {
			if(irandom(10)) {
				_spawn = instance_create_layer(updateLastX + _x, updateLastY + _y, "Instances", obj_palmTree);
			}
		}
		
		if(_spawn != noone) {
			_spawn.image_blend = _color;
		}
	}
}

generate();



