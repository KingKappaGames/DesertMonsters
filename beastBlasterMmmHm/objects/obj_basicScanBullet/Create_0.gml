if (live_call()) return live_result;

event_inherited();

bulletSize = 1 + irandom(1);
bulletPierce = 1 + irandom(1);
bulletDamage = 1;

goalX = 0;
goalY = 0;
shotDir = 0;

tracer = false;

hit = function(hitX, hitY, hitId = noone, finalHit = false, hardness = 0) {
	if(instance_exists(hitId)) {
		if(object_is_ancestor(hitId.object_index, obj_enemy)) {
			var _dist = point_distance(x, y, hitId.x, hitId.y);
			var _xHit = x + dcos(shotDir) * (_dist + irandom_range(-hitId.image_xscale / 2, hitId.image_xscale / 2));
			var _yHit = y - dsin(shotDir) * (_dist + irandom_range(-hitId.image_xscale / 2, hitId.image_xscale / 2));
			
			if(finalHit) {
				script_burstParticlesConcentrated(_xHit, _yHit, global.bloodSpray, 15, shotDir + 180 + irandom_range(-50, 50), 100, 3, 1, 1)
			} else { // pierced
				script_burstParticlesConcentrated(_xHit, _yHit, global.bloodSpray, 20, shotDir, 45, 3, 3, 1)
			}
			
			hitId.hurt(bulletDamage, shotDir, 1);
		}	
	} else {
		script_burstPartSpawners(hitX, hitY, 5, 180, shotDir, 6 * bulletLevel, .9, 15, 1, sbDustFloat, .5, 1, 1, .5);
		
		part_type_speed(sbDust, 0.12, .8, -.008, 0);
		part_type_speed(sbDustErupt, .35, 1.7, -.013, 0); // this is a mess and should be based on hardness and materials hit.. ?
		part_type_speed(debris, .3, 5, -.004, 0);
		part_type_size(debris, .04, .08, 0, 0);
	
		part_particles_create(sys, hitX, hitY, sbDustErupt, bulletSize * 1 /* * bulletDamage*/);
		part_particles_create(sys, hitX, hitY, sbDust, bulletSize * 1 /* * bulletDamage*/);
		if(finalHit && random(3) < hardness) {
			part_particles_create(sys, hitX, hitY, debris, 1 /* * bulletDamage*/);
		}
	}
}