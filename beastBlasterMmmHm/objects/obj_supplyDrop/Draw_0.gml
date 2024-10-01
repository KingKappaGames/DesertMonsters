if(height < 0) {
	doLandingCrash();
	image_index = 1;
	surface_set_target(obj_manager.getDebrisSurface());
	draw_sprite_ext(sprite_index, image_index, x, y - height, 1, 1, 30 * dcos(current_time / (8 - fallSpeed)), c_white, 1);
	surface_reset_target();
	instance_destroy();
} else {
	draw_sprite_ext(sprite_index, image_index, x, y - height, 1, 1, 30 * dcos(current_time / (8 - fallSpeed)), c_white, 1);
}