if (live_call()) return live_result;

x += xChange;
y += yChange;

if(bombingDelay <= 0) {
	if(bombTimerCurrent < bombTimerMax) {
		bombTimerCurrent++;
	} else if(bombsRemaining > 0) {
		bombTimerCurrent = 0;
		bombsRemaining--;
		
		var _releaseDir = irandom(360);
		var _bomb = instance_create_layer(x, y, "Instances", bombType);
		_bomb.xChange = dcos(_releaseDir) * random(accuracy) / 200;
		_bomb.yChange = -dsin(_releaseDir) * random(accuracy) / 200;
		_bomb.bulletHeight = irandom_range(450, 550);
		_bomb.bulletDrop = .1;
		//
	} else { // no more bombs
		despawnTimer--;
		if(despawnTimer <= 0) {
			if(!(x > camera_get_view_x(view_camera[0]) && x < camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]))) { // basic on screen check, if x is within screen then don't despawn. being outside of the x guarentees that it will never be on screen upon despawn because both must be true so you only need to check one of the directions. Of course... If the plane goes vertically far away it won't despawn but that would require you staying in line with it vertically for as long as it takes... Skill issue?
				instance_destroy();
			}
		}
	}
} else {
	bombingDelay--;
}