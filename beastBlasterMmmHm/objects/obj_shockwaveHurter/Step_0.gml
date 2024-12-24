radius += radiusIncrease;

if(ticksCurrent >= tickCount) {
	ds_list_clear(hitIds);
	
	collision_circle_list(x, y, radius, obj_enemy, false, true, hitIds, false);
	
	for(var _i = ds_list_size(hitIds) - 1; _i > -1; _i--) {
		hitIds[| _i].hurt3D(5, 2.2, radius + 600, 1, id);
	}
	
	ticksCurrent = 0;
} else {
	ticksCurrent++;
}

duration--;
if(duration < 1) {
	instance_destroy();
	exit;
}

//camera_set_view_pos(view_camera[0], x - camera_get_view_width(view_camera[0]) / 2, y - camera_get_view_height(view_camera[0]) / 2);
//camera_set_view_size(view_camera[0], clamp(radius * 1.5, 960, 9999), clamp(radius * 13.5 / 16, 540, 9999));