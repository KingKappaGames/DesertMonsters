function script_createShockHurter(xSpawn, ySpawn, radiusIncrease, duration, tickCount = 72, initialRadius = 15) { // also add in damage and such to this
	var _shockwave = instance_create_layer(xSpawn, ySpawn, "Instances", obj_shockwaveHurter);
	_shockwave.radiusIncrease = radiusIncrease;
	_shockwave.tickCount = tickCount;
	_shockwave.radius = initialRadius;
	_shockwave.duration = duration;
	_shockwave.durationMax = duration;
}