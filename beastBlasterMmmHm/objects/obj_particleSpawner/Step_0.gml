if (live_call()) return live_result;

x += xChange;
y += yChange + gravityChange;
xChange *= speedDecay;
yChange *= speedDecay;

if(random(1) < spawnChance) {
	part_particles_create(sys, x, y, part, spawnCount);
}

if(duration > 0) {
	duration--;
	if(duration == 0) {
		instance_destroy();	
	} 
} else if(abs(xChange) + abs(yChange) < .2) {
	instance_destroy();
}