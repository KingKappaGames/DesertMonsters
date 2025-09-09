//if (live_call()) return live_result;

sys = global.particleSystem;
blood = global.blood;

Health = 3;
alive = 1;

image_xscale = 6;
image_yscale = 8;

xChange = 0;
yChange = 0;

moveSpeed = .5;

travelToGoalX = 0;
travelToGoalY = 0;

die = function() {
	alive = 0;
	instance_destroy();
}

hurt = function(damageDone, kbDir = -1, bleed = 1) {
	Health -= damageDone;
	
	if(bleed) {
		part_particles_create(sys, x, y - 4, blood, clamp(3 * sqr(damageDone - 2) + 5, 0, 40));
	}
	
	if(Health <= 0) {
		die();
	}
	
	if(kbDir != -1) {
		show_debug_message("It do be hitting but not doing anything..");
		startTravelToPoint(x + dcos(kbDir + random_range(-50, 50)) * irandom_range(80, 150), y - dsin(kbDir + random_range(-50, 50)) * irandom_range(80, 150));
		xChange += dcos(kbDir) * damageDone * .3;
		yChange -= dsin(kbDir) * damageDone * .3;
	}
}

hurt3D = function(damage, knockback, radius, dropOffPower = 1, hitSourceId = noone) {
	hurt(damage, point_direction(hitSourceId.x, hitSourceId.y, x, y), true);
}

startTravelToPoint = function(goalX, goalY, speedTravel = moveSpeed) {
	travelToGoalX = goalX;
	travelToGoalY = goalY;
	
	var _dir = point_direction(x, y, goalX, goalY);
	
	xChange = dcos(_dir) * moveSpeed;
	yChange = -dsin(_dir) * moveSpeed;
}