/// @desc Function Creates a fanned burst of particles with decreasing speed and likelyhood towards the edges of the range
/// @param {real} xSpawn X position to spawn
/// @param {real} ySpawn Y position to spawn
/// @param {id.particletype} partType The particle id
/// @param {real} partCount How many parts to create
/// @param {real} directionOverall The base direction, sans range
/// @param {real} directionRange The width of the angle burst to add each step
/// @param {real} rangeSteps How many times to expand by the range both directions
/// @param {real} [speedOverall]=-1 The speed of the burst, roughly
/// @param {bool} [speedWithDirection]=false A bool to decrease the speed along with the direction, else it'll use the same speed for every direction
/// @param {id.particlesystem} [sysUsed]=sys Particle system reference
function script_burstParticlesConcentrated(xSpawn, ySpawn, partType, partCount, directionOverall, directionRange, rangeSteps, speedOverall = -1, speedWithDirection = false, sysUsed = sys){
	if(speedOverall != -1) {
		part_type_speed(partType, speedOverall * .4, speedOverall, -speedOverall / 300, 0);
	}
	
	for(var _i = rangeSteps; _i > 0; _i--) {
		part_type_direction(partType, directionOverall - directionRange * (_i / rangeSteps), directionOverall + directionRange * (_i / rangeSteps), 0, 0);
		if(speedWithDirection) {
			part_type_speed(partType, speedOverall * .2 * (1 - (_i / (rangeSteps + 1))), speedOverall * (1 - (_i / (rangeSteps + 1))), 0, 0);
		}
		part_particles_create(sysUsed, xSpawn, ySpawn, partType, partCount / rangeSteps);
	}
}