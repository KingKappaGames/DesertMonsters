///@desc Draws the "weapon" (a gun in this game) sprite stack
///@param sprite
///@param position {ARRAY} This is the position of the weapon as an array of x,y,ect The good thing about arrays is they're pass by reference so you can do a lot of manipulation tricks with them
///@param angle The direction to aim the weapon sprite when drawing, duh
///@param holdDownAngleAdjust This is added to the angle when holding down (if you pass it, it will be applied, but pass them both for reasons..)
function script_drawWeapon(sprite, position, angle, holdDownAngleAdjust, surfOffX = -1, surfOffY = -1) {
	live_auto_call
	var _gunLayers = sprite_get_number(sprite);
	var _yAdd = -3; // the up push of each layer
	var _cos = dcos(angle);
	
	var _x = position[0];
	var _y = position[1] - position[2] * .7;
	for(var _i = 0; _i < _gunLayers; _i++) {
		draw_sprite_ext(sprite, _i, _x - surfOffX, _y - surfOffY  + _yAdd * _i, .65 + abs(_cos) * .35, 1, angle + holdDownAngleAdjust, c_white, 1);
	}
	
	gunTipPosition[0] = _x + _cos * gunLength;
	gunTipPosition[1] = _y - dsin(angle) * gunLength - gunTipHeightOff; // position to position with layer offset for sprite stacking y and length push forwards from gun origin to tip, hopefully
	gunTipPosition[2] = position[2] + gunTipHeightOff; // height not taken into account for shot position so do y and height separately i guess?
}