if (live_call()) return live_result;

event_inherited();

var _images = sprite_get_number(sprite_index);
for(var _imageI = 0; _imageI < _images; _imageI++) {
	draw_sprite_ext(sprite_index, _imageI, x, y - _imageI * 4, playerScale, playerScale, playerDirection, c_white, 1);
}

//draw_rectangle(x - 18, y - 26, x + 18, y + 10, true);

var _dist = point_distance(x, y, mouse_x, mouse_y);
if(_dist > 3) {
	var _dir = point_direction(x, y, mouse_x, mouse_y);
	var _droop = clamp(sqrt(_dist / 200) * 20, 0, 90);
	
	var _sin = dsin(_droop);
	var _cos = dcos(_droop);
	var _radius = _dist / (_sin * 4); // 2x the sin is width, half that is radius (aka * 4 divide)
	var _raise = _radius * (1 - _sin);
	
	draw_arc((x + mouse_x) / 2 + dcos(_dir - 90) * _raise, (y + mouse_y) / 2 - dsin(_dir - 90) * _raise, _radius, _dir + sign(angle_difference(270, _dir)) * _droop, _dir + 180 + sign(angle_difference(270, _dir + 180)) * _droop);
}