#region jsdoc
///@desc This is a script to create a directional explosion with particle spawners
///@param burstX            The x of where the burst will originate
///@param burstY            The y of where the burst will originate
///@param burstSpeed        How fast the pieces will fly away at maximum, range affected by burst amplitude
///@param burstSpread       The width of the cone on the direction of dir in both directions so 180 gives circle adding, 30 gives 60 degree cone
///@param dir               The direction of travel of the system, affects the over all movement of the resulting burst as flat adding to speed
///@param dirSpeed          The speed to move along dir direction, this is essentially the flat adjust of all the resulting fragments speed
///@param speedDecay        The amount 0-1 to slow the spawners every frame
///@param duration		    The length of time the spawners exist OR -2 to represent that they should stop spawning when they are no long moving fast enough
///@param spawnerCount      The amount of pieces (or spawners) to result from the burst		   
///@param partSpawn	        The particle asset to spawn with the spawners
///@param partSpawnChance	The decimal 0-1 chance that the spawners spawn a particle every frame
///@param partSpawnCount	The amount of particles to spawn if the spawners do spawn something
///@param burstAmplify		The contrasting that the speed should have, instead of linearly 0-1 they arc up and most would move slow and a few would move fast. The range is from 0 to max speed
///@param upwardAdjust      The upward speed added, USE POSITIVES FOR UP, tries to replicate the fact that the ground is down and thus resulting movement will be generally up
///@param yBias             The degree that the speeds of burst only apply to y, 0 is normal radial, 1 is just y axis variance. (eq is x *= 1 - bias)
#endregion
function script_burstPartSpawners(burstX, burstY, burstSpeed, burstSpread, dir, dirSpeed, speedDecay, duration, spawnerCount, partSpawn, partSpawnChance, partSpawnCount, burstAmplify = 1, upwardAdjust = -1, yBias = 0){
	//live_auto_call
	var _xFlat = dcos(dir) * dirSpeed;
	var _yFlat = -dsin(dir) * dirSpeed;
	
	repeat(spawnerCount) { 
		var _spawner = instance_create_layer(burstX, burstY, "Instances", obj_particleSpawner);
		var _dirAdjust = dir + irandom_range(-burstSpread, burstSpread);
		var _speedCurved = power(random(1), burstAmplify);
		
		_spawner.xChange = _xFlat + dcos(_dirAdjust) * _speedCurved * burstSpeed * (1 - yBias);
		_spawner.yChange = _yFlat - upwardAdjust - dsin(_dirAdjust) * _speedCurved * burstSpeed;

		_spawner.speedDecay = speedDecay;
		if(duration == -2) {
			_spawner.duration = logn(2 - speedDecay, abs(point_distance(0, 0, _spawner.xChange, _spawner.yChange))); // the speed decay can be represented by the amount of multiplications it would take to reach the speed and thus inversely how long it takes to slow down
		} else {
			_spawner.duration = duration;
		}

		_spawner.part = partSpawn;
		_spawner.spawnChance = partSpawnChance;
		_spawner.spawnCount = partSpawnCount;
	}
}