///@desc This function turns a bunch of limb data into start and end x/y coordinates on screen
function script_drawLimbSegIn3d(limb, componentId, surfOffX, surfOffY, perspectiveAngleFromGroundDegrees = 45) { // I may want to default this to a magic number to save the sin and cos calls since... how often would the weapon angles change? Never..?
	live_auto_call
	
	var _segVisualLength = sprite_get_width(componentId.sprite[0]);//limb[0][3];
	//var _spineX = component.spine.x;
	var _spineY = componentId.spine.y;
	//show_debug_message(limb);
	//game_end();
	for(var _i = array_length(limb) - 1; _i > 0; _i--) { // from n - 1 to 1 (cut off 1 on either side)
		var _startNode = limb[_i - 1];
		var _endNode = limb[_i];
		
		
		var _endX = _endNode[0];
		var _startX = _startNode[0];
		var _endY = (_spineY + (_endNode[1] - _spineY) * dsin(perspectiveAngleFromGroundDegrees)) - (_endNode[2] * dcos(perspectiveAngleFromGroundDegrees)); // the height and y horiztontal each have some share of the visual...
		var _startY = (_spineY + (_startNode[1] - _spineY) * dsin(perspectiveAngleFromGroundDegrees)) - (_startNode[2] * dcos(perspectiveAngleFromGroundDegrees)); // the height and y horiztontal each have some share of the visual...
		
		
		var _visualDist = point_distance(_startX, _startY, _endX, _endY); // the perspective compression of the start and end values (dist between them basically)
		var _visualDir = point_direction(_startX, _startY, _endX, _endY);
		var _visualWidth = 0; // the perspective compression of the blade angle (the camera angle of the tilt at the held angle........ Hmmm
		
		//var _visualCompression = _visualDist / itemLength; // dist is a multiplier not a pixel length... Oops (switched to non variable in the script call below, but maybe I change my mind later)
		
		//draw_sprite_ext(componentId.sprite[_i - 1], componentId.image[_i - 1], _startX - surfOffX, _startY - surfOffY, _visualDist / _segVisualLength, componentId.yscale[_i - 1], _visualDir, componentId.color[_i - 1], 1); // this only works with left to right sprites, add an offset if you want I guess? (the compressions won't work if it's diagonally sprited...) (There are now horizontal sprites "spr_game_...  !)
		
		var _xx = _startX - surfOffX;
		var _yy = _startY - surfOffY;
		draw_set_color([c_black, c_white, c_orange][_i]);
		draw_line(_xx, _yy, _xx + dcos(_visualDir) * _visualDist, _yy - dsin(_visualDir) * _visualDist);
		draw_set_color(c_white);
	}
}