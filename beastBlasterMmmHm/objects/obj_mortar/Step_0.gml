if (live_call()) return live_result;

event_inherited();

if(irandom(4) == 0) {
	part_particles_create(sys, x, y - bulletHeight, smokeTrail, 1);
}

bulletDrop += .01;