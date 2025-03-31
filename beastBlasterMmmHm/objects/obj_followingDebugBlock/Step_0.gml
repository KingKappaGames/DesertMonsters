if(global.debugFollow) {
	x = mouse_x;
	y = mouse_y + yOffset;
	
	depth = -y;
}

if(keyboard_check_released(vk_insert)) {
	global.debugFollow = false;
}