if (live_call()) return live_result;

event_inherited();

bulletDamage = 4 + irandom(6)
bulletSize = 5 + irandom(3);

hit = function() {
	
	//TODO get data from what has been hit to create other sorts of explosion effects, for example hitting open sand would
	// give different debris than hitting cement or dirt, this doesn't include cars and such with their own particle yield
	// but does determine the ratios of what particles are created for which outcomes in some way
	
	audio_play_sound_at(choose(snd_SoftExplosionSemiDistant, snd_StubbedExplosion, snd_BigGrindyExplosion), x, y, 0, 600, 2000, 1, 0, 0, 2);
	
	script_burstPartSpawners(x, y, 6.5, 180, 90, 4, .97, -2, 40, sbDustFloat, .4, 1, 2, 2.5, .5);
	
	part_type_speed(sbDust, .2, .9, -.003, 0);
	part_type_speed(shimmer, 1, 2, -.012, 0);
	part_type_speed(debris, .8, 4, -.004, 0);
	part_type_size(debris, .04, .11, 0, 0);
	
	part_particles_create(sys, x, y, sbDust, bulletSize * 3 /* * bulletDamage*/);
	part_particles_create_color(sys, x, y, smokingClods, c_black, bulletSize * 2 /* * bulletDamage*/);
	part_particles_create(sys, x, y, shimmer, bulletSize * 9 /* * bulletDamage*/);
	part_particles_create(sys, x, y, debris, bulletSize * 3 /* * bulletDamage*/);
	
	#region debris surface stuff..?
	surface_set_target(manager.getDebrisSurface());
	draw_sprite_ext(spr_sandSprayDecalCrater, 0, x, y, 2, 2, irandom(360), c_white, .4);
	surface_reset_target();
	#endregion
	
	hitIds = ds_list_create();
	#region collisions
	
	collision_circle_list(x, y, 12 * bulletSize, obj_enemy, false, true, hitIds, false);
	
	for(var _i = ds_list_size(hitIds) - 1; _i > -1; _i--) {
		hitIds[| _i].hurt(irandom(bulletDamage), point_direction(x, y, hitIds[| _i].x, hitIds[| _i].y));
	}
	
	#endregion
	
	instance_destroy();
}