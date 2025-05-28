if (live_call()) return live_result;

event_inherited();

if(instance_exists(homingLock)) {
	draw_circle_color(homingLock.x, homingLock.y, 13 + irandom(3), c_white, random_color(), true);
} else {
	homingLock = noone;
}

draw_circle_color(x, y, 5, c_red, c_blue, true);