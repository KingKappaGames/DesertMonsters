///@desc Used to create particles in the room that are assigned and managed by the depth system
///@param part The particle index/type to create
///@param xx The x position to create the particle at
///@param yy The y position to create the particle at
///@param count The amount of particles to create 
///@param color The blending of the particle to create 
///@param {REAL} depth The depth to create the particles at (defaults to depth = -y)
function script_createPartDepth(part, xx, yy, count, color = c_white, createDepth = -yy){
	gml_pragma("forceinline"); 
	
	with(global.particleSystemManager) { 
		var _layer = (currentSysEdge + (yy - previousEdgeY) div sysSpacing) % sysCount;
		if(_layer < 0) {
			_layer += sysCount;
		}
		part_particles_create_color(sysCollection[_layer], xx, yy, part, color, count); // this terniary basically just flips the modulo so that layers are either modded into the range of systems or flipped to a positive, modded, then flipped back to yield a positive modulo result either way, if you have 100 systems and want sys 170 it will cut down to 70, makes sense, if you want -170 it will flip to +170, cut down to 70, then flip back to 100 - 70 aka 30 which is correct. Maybe not ideal but it works. (it's very close to ideal if it's not anyways)
	}																										// on/below screen                                                      under screen
}

// functions like this can be useful to expand the logic for your particle creation, if you want to make versions of this script that place particles with a range of
// depths or x/y variance ect then this can be a useful thing to have. For example you might add a placementRange value in this script that then 
// adds a random amount to the x/y of each particle created, this does require looping the create function for each particle created but it's not a big deal
// It's not efficient per se but it can be very useful to simply drop a 10 into the param and create a range of particles (or range of depths, colors, speeds, ect)
// so the final function might look like:

/*

function script_createPartDepth(part, xx, yy, count, color = c_white, createDepth = -yy, xRange = 0, yRange = 0, depthRange = 0){
	repeat(count) {
		part_particles_create_color(putSysIndexHere (same as above), xx + random_range(-xRange, xRange), yy + random_range(-yRange, yRange), part, color, 1);
	}
}