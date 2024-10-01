if(global.cameraSplitOption == false) {
	var _xAverage = 0;
	var _yAverage = 0;

	playerCount = instance_number(obj_playerParent);
	with(obj_playerParent) {
		_xAverage += x / other.playerCount;
		_yAverage += y / other.playerCount;
	}

	camera_set_view_pos(view_camera[0], lerp(camera_get_view_x(view_camera[0]), _xAverage - camera_get_view_width(view_camera[0]) / 2, .08), lerp(camera_get_view_y(view_camera[0]), _yAverage - camera_get_view_height(view_camera[0]) / 2, .08));
} else { // split cameras // let players handle their own cameras if split
	//with(obj_playerParent) {
	//	camera_set_view_pos(view_camera[playerIndex], lerp(camera_get_view_x(view_camera[playerIndex]), x - camera_get_view_width(view_camera[playerIndex]) / 2, .08), clamp(lerp(camera_get_view_y(view_camera[playerIndex]), y - camera_get_view_height(view_camera[playerIndex]) / 2, .08), -999999, room_height - camera_get_view_height(view_camera[playerIndex])));
	//}
}