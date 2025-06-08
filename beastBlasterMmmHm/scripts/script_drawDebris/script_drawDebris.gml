function script_drawDebris(sprite, image, roomX, roomY, scaleX, scaleY, dir, color, alpha) {
	var _manager = global.manager;
	
	surface_set_target(_manager.getDebrisSurface());
	draw_sprite_ext(sprite, image, roomX - _manager.debrisSurfaceDrawX, roomY - _manager.debrisSurfaceDrawY, scaleX, scaleY, dir, color, alpha);
	surface_reset_target();
}