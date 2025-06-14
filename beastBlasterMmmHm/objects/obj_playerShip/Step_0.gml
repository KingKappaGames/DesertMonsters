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

if(keyboard_check_released(ord("B"))) {
	instance_create_depth(x + 100, y - 200, depth, obj_structure);
}

if(keyboard_check_released(ord("N"))) {
	var _hitList = ds_list_create();
	collision_circle_list(mouse_x, mouse_y, 700, obj_structure, false, true, _hitList, false); // hit structures //TODO remove at some point or find a better place for it
	for(var _i = ds_list_size(_hitList) - 1; _i > -1; _i--) {
		//_hitList[| _i].hurt(irandom(bulletDamage), point_direction(x, y, _hitList[| _i].x, _hitList[| _i].y)); 
		var _hit = _hitList[| _i];
		var _distFalloff = clamp(1 - (point_distance(mouse_x, mouse_y, _hit.x, _hit.y) / 700), 0, 10);
		var _hitDir = point_direction(mouse_x, mouse_y, _hit.x, _hit.y);
		_hit.damageStructure(_distFalloff * 2, 0, _hitDir, 2 * _distFalloff);
	}
	ds_list_destroy(_hitList);
}

if(input_check_released("characterSwitch", playerIndex)) {
	var _player = instance_create_layer(x, y, "Instances", obj_playerHeli);
	_player.playerIndex = playerIndex;
	instance_destroy();
	_player.setCursorActive(_player.playerIndex); // in the destroy it sets mouse back to false so this needs to be after
	exit;
}

if(input_check_released("gunSwitch", playerIndex)) {
	setTurret((gunType + 1) % 4);
}

event_inherited();