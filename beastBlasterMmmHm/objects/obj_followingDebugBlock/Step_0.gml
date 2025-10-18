if(instance_exists(obj_playerParent)) {
	if(global.debugFollow) {
		x = obj_playerParent.x + 300;
		y = obj_playerParent.y + yOffset;
		
		depth = -y;
	}
}

if(keyboard_check_released(vk_insert)) {
	global.debugFollow = false;
}