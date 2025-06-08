if (live_call()) return live_result;

event_inherited();

bulletDamage = 20;
bulletSize = 10 + irandom(5);

hit = function() {
	audio_play_sound_at(choose(snd_VeryDrawnOutGrainyExplosion, snd_drawnOutExplosion), x, y, 0, 600, 2000, 1, 0, 0);

	if(irandom(8) == 0) {
		if(!audio_is_playing(snd_AirRaidSirenLong)) {
			audio_play_sound(snd_AirRaidSirenLong, 0, 0);
		}
	}
	
	#region effects!
	
	part_type_speed(debris, 3, 13, -.04, 0);
	part_type_size(debris, .1, .25, 0, 0);
	
	part_type_speed(nukeShimmer, 0, 1, -.04, 0);
	part_type_speed(shockwaveLead, 5, 5, -.002, 0);
	
	part_particles_create(sys, x, y, nukeShimmer, bulletSize * 30 /* * bulletDamage*/);
	part_particles_create(sys, x, y, darkout, 1);
	part_particles_create(sys, x, y, debris, bulletSize * 20 /* * bulletDamage*/);
	part_particles_create(sys, x, y, shockwaveLead, bulletSize * 100 /* * bulletDamage*/);
	
	repeat(7) {
		script_drawDebris(spr_sandSprayDecalCrater, 0, x, y, 13, 13, irandom(360), c_white, .4);
	}
	script_drawDebris(spr_wideCrater, 0, x, y, 2.5, 3.3, 0, c_white, .6);
	
	#endregion
	
	#region damaging
	
	script_createShockHurter(x, y, 4.6, 200, 24, 160);
	
	camera_set_view_size(view_camera[0], 1920, 1080);
	var _func = function() {
		camera_set_view_size(view_camera[0], 960, 540);
	}
	call_later(10, time_source_units_seconds, _func);
	
	#endregion
	
	instance_destroy();
}