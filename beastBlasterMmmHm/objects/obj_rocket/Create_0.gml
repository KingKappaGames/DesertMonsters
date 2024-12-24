if (live_call()) return live_result;

event_inherited();

bulletDamage = 5 + irandom(2);
bulletSize = 4 + irandom(2);

hit = function() {
	
	//TODO get data from what has been hit to create other sorts of explosion effects, for example hitting open sand would
	// give different debris than hitting cement or dirt, this doesn't include cars and such with their own particle yield
	// but does determine the ratios of what particles are created for which outcomes in some way
	
	audio_play_sound_at(choose(snd_crispExplosion), x, y, 0, 600, 2000, 1, 0, 0, 2,,random_range(.7, 1.3));
	
	script_burstPartSpawners(x, y, 5, 180, point_direction(0, 0, xChange, yChange), 2 * bulletLevel, .94, -2, 20, sbDustFloat, .2, 1, 1, 2);
	
	part_type_speed(sbDust, 0.15, 1.5, -.013, 0);
	part_type_speed(sbDustErupt, .4, 2.4, -.007, 0);
	part_type_speed(shimmer, .8, 1.4, -.012, 0);
	part_type_speed(debris, .8, 5, -.004, 0);
	part_type_size(debris, .04, .09, 0, 0);
	
	part_particles_create(sys, x, y, sbDustErupt, bulletSize * 14 /* * bulletDamage*/);
	part_particles_create(sys, x, y, sbDust, bulletSize * 10 /* * bulletDamage*/);
	part_particles_create(sys, x, y, shimmer, bulletSize * 10 /* * bulletDamage*/);
	part_particles_create(sys, x, y, debris, bulletSize * 3 /* * bulletDamage*/);
	
	#region debris surface stuff..?
	surface_set_target(manager.getDebrisSurface());
	draw_sprite_ext(spr_sandSprayDecalCrater, 0, x, y, 2, 2, irandom(360), c_white, .4);
	surface_reset_target();
	#endregion
	
	hitIds = ds_list_create();
	#region collisions
	
	collision_circle_list(x, y, 25 * bulletSize, obj_enemy, false, true, hitIds, false);
	
	for(var _i = ds_list_size(hitIds) - 1; _i > -1; _i--) {
		//hitIds[| _i].hurt(irandom(bulletDamage), point_direction(x, y, hitIds[| _i].x, hitIds[| _i].y));
		hitIds[| _i].hurt3D(irandom(bulletDamage), 5, 25 * bulletSize, 2, id);
	}
	
	#endregion
	
	instance_destroy();
}