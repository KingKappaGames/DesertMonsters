event_inherited();

if(angleShake > .02) {
	image_angle += dsin(current_time * 3) * angleShake;
	image_angle *= .9;
	
	angleShake *= .994;
}

if(image_alpha < 1) {
	image_alpha += .03;
}