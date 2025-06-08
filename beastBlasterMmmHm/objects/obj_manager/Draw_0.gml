var _camX = camera_get_view_x(view_camera[0]);
var _camY = camera_get_view_y(view_camera[0]);
if(point_distance(debrisSurfaceLastX, debrisSurfaceLastY, _camX, _camY) > 50) {
	var _surf = getDebrisSurface();
	var _surfHold = getHoldSurface();
	surface_copy(_surfHold, 0, 0, _surf);
	surface_set_target(_surf);
	draw_clear_alpha(c_white, 0);
	surface_reset_target();
	surface_copy(_surf, debrisSurfaceLastX - _camX, debrisSurfaceLastY - _camY, _surfHold);
	debrisSurfaceLastX = _camX;
	debrisSurfaceLastY = _camY;
	debrisSurfaceDrawX = _camX + camera_get_view_width(view_camera[0]) * .5 - debrisSurfSize * .5;
	debrisSurfaceDrawY = _camY + camera_get_view_height(view_camera[0]) * .5 - debrisSurfSize * .5;
}

draw_surface(getDebrisSurface(), debrisSurfaceDrawX, debrisSurfaceDrawY);