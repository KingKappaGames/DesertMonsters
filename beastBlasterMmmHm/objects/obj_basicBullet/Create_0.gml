if (live_call()) return live_result;

event_inherited();

xChange = 0;
yChange = 0;

bulletHeight = 100;
bulletDrop = 4;
bulletDirection = 0;

bulletDamage = 1 + irandom(1);
bulletSize = 2 + irandom(2);

hit = function() {
	audio_play_sound_at(snd_smallShotHit, x, y, 0, 350, 1000, 1, 0, 0, 2);
	
	script_burstPartSpawners(x, y, 8, 180, point_direction(0, 0, xChange, yChange), 6 * bulletLevel, .88, 20, 7, sbDustFloat, .3, 1, 1.5, 1.5);
	
	part_type_speed(sbDust, 0.12, .8, -.008, 0);
	part_type_speed(sbDustErupt, .35, 1.9, -.013, 0);
	part_type_speed(debris, .3, 5, -.004, 0);
	part_type_size(debris, .04, .08, 0, 0);
	
	part_particles_create(sys, x, y, sbDustErupt, bulletSize * 8 /* * bulletDamage*/);
	part_particles_create(sys, x, y, sbDust, bulletSize * 3 /* * bulletDamage*/);
	part_particles_create(sys, x, y, debris, bulletSize /* * bulletDamage*/);
	
	#region debris surface stuff..?
	surface_set_target(manager.getDebrisSurface());
	draw_sprite_ext(spr_sandSprayDecalFlat, 0, x, y, 1, 1, irandom(360), c_white, 1);
	surface_reset_target();
	#endregion
	
	#region collisions
	
	collision_circle_list(x, y, 8 * bulletSize, obj_enemy, false, true, hitIds, false);
	
	for(var _i = ds_list_size(hitIds) - 1; _i > -1; _i--) {
		hitIds[| _i].hurt(bulletDamage);
	}
	
	#endregion
	
	instance_destroy();
}