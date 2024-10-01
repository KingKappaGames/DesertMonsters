if (live_call()) return live_result;

event_inherited();

var _images = sprite_get_number(sprite_index);
for(var _imageI = 0; _imageI < _images; _imageI++) {
	draw_sprite_ext(sprite_index, _imageI, x, y - _imageI * 4, playerScale, playerScale, playerDirection, c_white, 1);
}

//draw_rectangle(x - 18, y - 26, x + 18, y + 10, true);