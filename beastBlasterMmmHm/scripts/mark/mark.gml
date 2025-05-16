///@desc Creates a small white particle at the position to show where it's at
function mark(xx,yy){
	part_particles_create(global.particleSystem, xx, yy, global.debugPart, 1);
}