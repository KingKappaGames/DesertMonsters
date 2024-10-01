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