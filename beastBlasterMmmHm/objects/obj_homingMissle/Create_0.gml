if (live_call()) return live_result;

event_inherited();

bulletDamage = 5 + irandom(2);
bulletSize = 4 + irandom(2);

homingLock = noone;
age = 0;

sound = audio_play_sound(snd_rocketLoop, 0, 1);

miniSmoke = part_type_create();
part_type_life(miniSmoke, 120, 400);
part_type_shape(miniSmoke, pt_shape_square);
part_type_size(miniSmoke, .04, .05, .001, 0);
part_type_size_x(miniSmoke, .15, .15, .001, 0);
part_type_alpha3(miniSmoke, 1, .25, 0);
part_type_color2(miniSmoke, #777777, #aaaaaa);
part_type_gravity(miniSmoke, .0003, 135);
part_type_direction(miniSmoke, 0, 360, 0, 0);
part_type_speed(miniSmoke, 0, .04, 0, .02);

hit = function() {
	
	//TODO get data from what has been hit to create other sorts of explosion effects, for example hitting open sand would
	// give different debris than hitting cement or dirt, this doesn't include cars and such with their own particle yield
	// but does determine the ratios of what particles are created for which outcomes in some way
	
	audio_play_sound_at(choose(snd_crispExplosion), x, y, 0, 600, 2000, 1, 0, 0, 2,,random_range(.7, 1.3));
	
	script_burstPartSpawners(x, y, 3, 180, point_direction(0, 0, xChange, yChange), 2 * bulletLevel, .94, -2, 12, sbDustFloat, .2, 1, 1, 2);
	
	part_type_speed(sbDust, 0.15, .9, -.013, 0);
	part_type_speed(sbDustErupt, .4, 1.2, -.007, 0);
	part_type_speed(shimmer, .8, .9, -.012, 0);
	part_type_speed(debris, .8, 3.2, -.004, 0);
	part_type_size(debris, .03, .05, 0, 0);
	
	part_particles_create(sys, x, y, sbDustErupt, bulletSize * 14 /* * bulletDamage*/);
	part_particles_create(sys, x, y, sbDust, bulletSize * 10 /* * bulletDamage*/);
	part_particles_create(sys, x, y, shimmer, bulletSize * 10 /* * bulletDamage*/);
	part_particles_create(sys, x, y, debris, bulletSize * 3 /* * bulletDamage*/);
	
	script_drawDebris(spr_sandSprayDecalCrater, 0, x, y, 2, 2, irandom(360), c_white, .4) 
	
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