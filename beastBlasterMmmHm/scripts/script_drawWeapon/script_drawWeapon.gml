///@desc Draws the "weapon" (a gun in this game) sprite stack
///@param sprite
///@param position {ARRAY} This is the position of the weapon as an array of x,y,ect The good thing about arrays is they're pass by reference so you can do a lot of manipulation tricks with them
///@param angle The direction to aim the weapon sprite when drawing, duh
///@param holdDownAngleAdjust This is added to the angle when holding down (if you pass it, it will be applied, but pass them both for reasons..)
function script_drawWeapon(sprite, position, angle, holdDownAngleAdjust, surfOffX = -1, surfOffY = -1){
	var _gunLayers = sprite_get_number(sprite);
	var _yAdd = -3; // the up push of each layer
	
	for(var _i = 0; _i < _gunLayers; _i++) {
		draw_sprite_ext(sprite, _i, position[0] - surfOffX, (position[1] + _yAdd * _i) - surfOffY, .65 + abs(dcos(angle)) * .35, 1, angle + holdDownAngleAdjust, c_white, 1);
	}
}