if (live_call()) return live_result;

x += (input_check("right", playerIndex) - input_check("left", playerIndex)) * playerSpeed;
y -= (input_check("up", playerIndex) - input_check("down", playerIndex)) * playerSpeed;

#region camera setting
if(global.cameraSplitOption == true) {
	camera_set_view_pos(view_camera[playerIndex], x - camera_get_view_width(view_camera[playerIndex]) / 2, y - camera_get_view_height(view_camera[playerIndex]) / 2 - 210);

	var _camMidX = camera_get_view_x(view_camera[playerIndex]) + camera_get_view_width(view_camera[playerIndex]) / 2;
	var _camMidY = camera_get_view_y(view_camera[playerIndex]) + camera_get_view_height(view_camera[playerIndex]) / 2;
}
#endregion

if(input_check_released("characterSwitch", playerIndex)) {
	var _player = instance_create_layer(x, y, "Instances", obj_playerSoldier);
	_player.playerIndex = playerIndex;
	instance_destroy();
	_player.setCursorActive(_player.playerIndex); // in the destroy it sets mouse back to false so this needs to be after
	exit;
}

if(input_check_released("gunSwitch", playerIndex)) {
	setTurret((gunType + 1) % 3);
}

event_inherited();