///@desc Creates a small colored particle at the position to show where it's at
function mark(xx,yy, color = c_white){
	part_particles_create_color(global.particleSystem, xx, yy, global.debugPart, color, 1);
}