if (live_call()) return live_result;

draw_set_alpha(clamp(.5 - (height / 800), 0, 1));
draw_circle_color(x, y, height / 4 + 20, c_black, c_gray, false);
draw_set_alpha(1);

event_inherited();

var _adjustedY = y - height / 4;
var _scaleMult = 1 + height / 800

var _images = sprite_get_number(sprite_index);
for(var _imageI = 0; _imageI < _images; _imageI++) {
	draw_sprite_ext(sprite_index, _imageI, x, _adjustedY - _imageI * 3, playerScale * _scaleMult, playerScale * _scaleMult, playerDirection, c_white, 1);
}

var _bladeSpeedSlowness = (1 - (bladeSpinSpeed / bladeSpinSpeedMax));
var _bladeOriginY = _adjustedY - image_number * 3;
draw_line_width(x, _bladeOriginY, x + dcos(bladeSpin) * (bladeLength - 12 * _bladeSpeedSlowness) * _scaleMult, _bladeOriginY - (dsin(bladeSpin) * (bladeLength / 2 - (6 * _bladeSpeedSlowness)) - _bladeSpeedSlowness * 12) * _scaleMult, 3 * _scaleMult);
draw_line_width(x, _bladeOriginY, x + dcos(bladeSpin + 90) * (bladeLength - 12 * _bladeSpeedSlowness) * _scaleMult, _bladeOriginY - (dsin (bladeSpin + 90) * (bladeLength / 2 - (6 * _bladeSpeedSlowness)) - _bladeSpeedSlowness * 12) * _scaleMult, 3 * _scaleMult);
draw_line_width(x, _bladeOriginY, x + dcos(bladeSpin + 180) * (bladeLength - 12 * _bladeSpeedSlowness) * _scaleMult, _bladeOriginY - (dsin(bladeSpin + 180) * (bladeLength / 2 - (6 * _bladeSpeedSlowness)) - _bladeSpeedSlowness * 12) * _scaleMult, 3 * _scaleMult);
draw_line_width(x, _bladeOriginY, x + dcos(bladeSpin + 270) * (bladeLength - 12 * _bladeSpeedSlowness) * _scaleMult, _bladeOriginY - (dsin(bladeSpin + 270) * (bladeLength / 2 - (6 * _bladeSpeedSlowness)) - _bladeSpeedSlowness * 12) * _scaleMult, 3 * _scaleMult);

//draw_rectangle(x - 18, y - 26, x + 18, y + 10, true);

//draw_text(x, _adjustedY + 100, height);