if (live_call()) return live_result;

depth = -(y - global.depthOffset);

//#region camera setting

//camera_set_view_pos(view_camera[0], x - camera_get_view_width(view_camera[0]) / 2, y - camera_get_view_height(view_camera[0]) / 2 - 210);

//var _camMidX = camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) / 2;
//var _camMidY = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) / 2;
//#endregion
#region aiming x/y controls mouse vs controller
var _camUsed = 0;
if(global.cameraSplitOption) { // don't use index if cameras being shared
	_camUsed = playerIndex;
}

if(!asset_has_tags(object_index, "camManaged", asset_object) && (!instance_exists(obj_playerHeli) || global.cameraSplitOption == true)) {
	var _camLeft = camera_get_view_x(view_camera[_camUsed]);
	var _camTop = camera_get_view_y(view_camera[_camUsed]);
	input_cursor_limit_aabb(_camLeft, _camTop, _camLeft + view_wport[_camUsed], _camTop + view_hport[_camUsed], playerIndex);
}

if(input_player_using_gamepad(playerIndex)) {
	input_cursor_set((input_value("aimRight", playerIndex) - input_value("aimLeft", playerIndex)) * controllerAimSensitivity + (x - xprevious), (input_value("aimDown", playerIndex) - input_value("aimUp", playerIndex)) * controllerAimSensitivity + (y - yprevious), playerIndex, 1);
}
#endregion

#region combat controls

if(shotTimer > shotTimeLimit) {
	weaponControls();
} else {
	shotTimer++;
}

if(airStrikeCoolDown > 0) {
	airStrikeCoolDown--;
}

#endregion

if(abs(x) + abs(y) > 0) {
	if(object_index == obj_playerShip) {
		audio_listener_position(x, y, -200);
	} else {
		audio_listener_position(x, y, -20);
	}
}

if(keyboard_check_released(vk_alt)) {
	var _enemy = instance_create_layer(x + irandom_range(-100, 100), y + irandom_range(-100, 100), "Instances", choose(obj_desertRatMan, obj_desertRatMan, obj_desertRatMan, obj_grub));
}

//if(keyboard_check_released(vk_f1)) { // hey so uh, fun fact, angle difference between two set values is SLOWER than dcos of a value... Honestly, not that surprising but I'm retarded is the point here. Yet another entry in the "just use the right tool for the job and stop trying to be clever" catalogue. ARRHRHRRHHRHG! Side note, the display sorting works :D
//	show_debug_message(current_time);
//	var _rand = irandom(360)
//	var _val = 0;
//	repeat(10000000) {
//		_val = dcos(_rand);
//	}
//	show_debug_message(current_time);
//	show_debug_message("BREAK %%%%%%%");
//	show_debug_message(current_time);
//	var _rand2 = irandom(360)
//	var _val2 = 0;
//	repeat(10000000) {
//		_val2 = angle_difference(_rand2, 90);
//	}
//	show_debug_message(current_time);
//}