if (live_call()) return live_result;

event_inherited();

var _sCos = dcos(currentDirection + 135);
var _sSin = -dsin(currentDirection + 135);
var _cos = dcos(currentDirection);
var _sin = -dsin(currentDirection);
var _sDist = point_distance(0, 0, sprite_width, sprite_height);


var _surf = -1;
for(var _imageI = 0; _imageI < image_number; _imageI++) {
	_surf = imageSet[_imageI];
	if(!surface_exists(_surf)) {
		var _backupSurf = surface_create(sprite_height, sprite_width);
		buffer_set_surface(bufferSet[_imageI], _backupSurf, 0);
		_surf = _backupSurf;
		imageSet[_imageI] = _backupSurf; // necessary or is a broken surf ref passed by ref?
	} else if(updateDrawSurfaces) {
		surface_set_target(_surf);
		draw_sprite(sprite_index, _imageI, sprite_xoffset, sprite_yoffset);
		surface_reset_target();
		
		buffer_get_surface(bufferSet[_imageI], imageSet[_imageI], 0); // store the initial forms of the image sets
		
		if(_imageI == image_number - 1) {
			updateDrawSurfaces = false; // conclude update
		}
	}
	
	draw_surface_ext(_surf, x + (scale * _sCos * _sDist / 2), y - _imageI * 4 + (scale * _sSin * _sDist / 2), scale, scale, currentDirection, c_white, 1);
}

//draw_rectangle(x - 18, y - 26, x + 18, y + 10, true);