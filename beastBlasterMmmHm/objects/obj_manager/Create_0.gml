if (live_call()) return live_result;

sprite_set_live(spr_robeParts, true);

randomize();
window_set_cursor(cr_none);

input_source_mode_set(INPUT_SOURCE_MODE.JOIN);
input_join_params_set(1, 4, "escape", undefined, true)

surface_depth_disable(true);

global.manager = id;
global.players = []; // set below

global.depthOffset = 0;

depth = 50;

audio_falloff_set_model(audio_falloff_exponent_distance);
audio_listener_orientation(0, -1, 0, 0, 0, -1); 
global.muted = 0;
audio_group_set_gain(audiogroup_default, .4, 0);

global.windStrength = 0;
global.gravityStrength = 0;

enum limbNode { // values for limb nodes to ref (in array!)
	xx, 
	yy, 
	zz, 
	len, 
	thickness 
}

fakeRoom = "mainRoom"; // this is for the quest set up for checking rooms

camWidth = camera_get_view_width(view_camera[0]);
camHeight = camera_get_view_height(view_camera[0]);

#region debris surface set up
surfaceTimer = 0;
debrisSurfaceBuffer = buffer_create(67108864, buffer_fixed, 1);
debrisSurface = surface_create(2048, 2048);
buffer_set_surface(debrisSurfaceBuffer, debrisSurface, 0);

getDebrisSurface = function() { // IF SURFACE NOT WORKING CHECK ROOM DEPTH OF BACKGROUND
	if(surface_exists(debrisSurface)) {
		return debrisSurface;
	} else {
		debrisSurface = surface_create(2048, 2048);
		buffer_set_surface(debrisSurfaceBuffer, debrisSurface, 0);
		return debrisSurface;
	}
}
#endregion

#region particles (long as hell)
global.particleSystem = part_system_create();
sys = global.particleSystem;
part_system_depth(global.particleSystem, -1001);
part_system_draw_order(sys, false);

#region basic sand burst
global.sandBurstDust = part_type_create();
sbDust = global.sandBurstDust;
part_type_life(sbDust, 85, 160);
part_type_shape(sbDust, pt_shape_square);
part_type_size(sbDust, .1, .2, .001, 0);
part_type_alpha2(sbDust, .75, 0);
part_type_color_mix(sbDust, #ffdE2F, #736600);
part_type_direction(sbDust, 0, 360, 0, 0);
part_type_orientation(sbDust, 0, 360, 0, 0, 0);
part_type_speed(sbDust, 0.15, .75, -.015, 0);
#endregion

#region erupting dust, vertically inclined angle because I can't seem to adjust the direction on the fly... Or im stupid
global.sandBurstDustErupt = part_type_create();
sbDustErupt = global.sandBurstDustErupt;
part_type_life(sbDustErupt, 85, 160);
part_type_shape(sbDustErupt, pt_shape_square);
part_type_size(sbDustErupt, .06, .24, 0, 0);
part_type_alpha2(sbDustErupt, .8, 0);
part_type_color_mix(sbDustErupt, #E2CE2F, #938620);
part_type_direction(sbDustErupt, 30, 150, 0, 0);
part_type_orientation(sbDustErupt, 0, 360, 0, 0, 0);
part_type_speed(sbDustErupt, .4, 1.1, -.004, 0);
part_type_gravity(sbDustErupt, .008, 270);
#endregion

#region dust float for spawners
global.sandBurstDustFloat = part_type_create();
sbDustFloat = global.sandBurstDustFloat;
part_type_life(sbDustFloat, 110, 210);
part_type_shape(sbDustFloat, pt_shape_square);
part_type_size(sbDustFloat, .1, .25, .0016, 0);
part_type_alpha2(sbDustFloat, .5, 0);
part_type_color_mix(sbDustFloat, #EaCE2F, #807510);
part_type_direction(sbDustFloat, 0, 360, 0, 0);
part_type_orientation(sbDustFloat, 0, 360, 0, 0, 0);
part_type_speed(sbDustFloat, 0, .3, -.004, 0);
#endregion

#region floaty dust for nuke haze i suppose
global.sandBurstHaze = part_type_create();
sbHaze = global.sandBurstHaze;
part_type_life(sbHaze, 400, 1200);
part_type_shape(sbHaze, pt_shape_square);
part_type_size(sbHaze, .1, .4, .0035, 0);
part_type_alpha2(sbHaze, .3, 0);
part_type_color_mix(sbHaze, #EaCE2F, #807510);
#endregion

#region shockwave edge
global.shockwaveLead = part_type_create();
shockwaveLead = global.shockwaveLead;
part_type_life(shockwaveLead, 200, 240);
part_type_shape(shockwaveLead, pt_shape_square);
part_type_size(shockwaveLead, .2, .4, 0, 0);
part_type_alpha2(shockwaveLead, 1, 0);
part_type_color1(shockwaveLead, #ddbb40);
part_type_direction(shockwaveLead, 0, 360, 0, 0);
part_type_orientation(shockwaveLead, 0, 360, 0, 0, 0);
part_type_speed(shockwaveLead, 5, 5, -.002, 0);
part_type_step(shockwaveLead, -120, sbHaze);
#endregion

#region dark chunk debris
global.darkDebris = part_type_create();
darkDebris = global.darkDebris;
part_type_life(darkDebris, 200, 340);
part_type_shape(darkDebris, pt_shape_line);
part_type_size(darkDebris, .02, .12, 0, 0);
part_type_alpha2(darkDebris, 1, .3);
part_type_color_mix(darkDebris, #555555, #000000);
part_type_direction(darkDebris, 0, 360, 0, 0);
part_type_orientation(darkDebris, 0, 360, .8, 30, 0);
part_type_speed(darkDebris, 0.6, 2, -.002, 0);
part_type_gravity(darkDebris, .006, 270);
#endregion

#region shimmer burst
global.shimmer = part_type_create();
shimmer = global.shimmer;
part_type_life(shimmer, 24, 29);
part_type_shape(shimmer, pt_shape_square);
part_type_size(shimmer, .23, .5, 0, 0);
part_type_alpha2(shimmer, .35, 0);
part_type_color3(shimmer, #ffffff, #301500, #130b06);
part_type_direction(shimmer, 0, 360, 0, 0);
part_type_orientation(shimmer, 0, 360, 0, 0, 0);
part_type_speed(shimmer, 0.2, 1.8, 0, 0);
part_type_blend(shimmer, true);

#endregion

#region nuclear shimmer
global.nuclearShimmer = part_type_create();
nukeShimmer = global.nuclearShimmer;
part_type_life(nukeShimmer, 900, 1500);
part_type_shape(nukeShimmer, pt_shape_square);
part_type_size(nukeShimmer, 0, .5, .006, 0);
part_type_alpha2(nukeShimmer, .2, 0);
part_type_color3(nukeShimmer, #ffffff, #301500, #130b06);
part_type_direction(nukeShimmer, 0, 360, 0, 0);
part_type_orientation(nukeShimmer, 0, 360, 0, 0, 0);
part_type_speed(nukeShimmer, .3, 2, -.06, 0);
part_type_blend(nukeShimmer, true);
part_type_gravity(nukeShimmer, .04, 90);
#endregion

#region darkout contrast particle
global.darkout = part_type_create();
darkout = global.darkout;
part_type_life(darkout, 1200, 1200);
part_type_shape(darkout, pt_shape_disk);
part_type_size(darkout, 90, 90, 0, 0);
part_type_alpha2(darkout, .4, 0);
part_type_color1(darkout, #000000);
#endregion

#region blood
global.blood = part_type_create();
blood = global.blood;
part_type_life(blood, 60, 100);
part_type_shape(blood, pt_shape_square);
part_type_size(blood, .03, .09, 0, 0);
part_type_alpha2(blood, .6, 0);
part_type_color_mix(blood, #bb0000, #330000);
part_type_direction(blood, 0, 180, 0, 0);
part_type_orientation(blood, 0, 360, 0, 0, 0);
part_type_speed(blood, 0.18, 1.6, -.012, 0);
part_type_gravity(blood, .02, 270);
#endregion

#region blood spray
global.bloodSpray = part_type_create();
bloodSpray = global.bloodSpray;
part_type_life(bloodSpray, 40, 90);
part_type_shape(bloodSpray, pt_shape_square);
part_type_size(bloodSpray, .02, .13, 0, 0);
part_type_alpha2(bloodSpray, .4, 0);
part_type_color_mix(bloodSpray, #bb0000, #330000);
part_type_direction(bloodSpray, 0, 180, 0, 0);
part_type_orientation(bloodSpray, 0, 0, 0, 0, 0);
part_type_speed(bloodSpray, 0.18, 1.6, -.012, 0);
#endregion

#region floaty smoke for trails and whisps
global.smokeTrail = part_type_create();
smokeTrail = global.smokeTrail;
part_type_life(smokeTrail, 120, 400);
part_type_shape(smokeTrail, pt_shape_square);
part_type_size(smokeTrail, .0, .05, .003, 0);
part_type_alpha3(smokeTrail, 1, .25, 0);
part_type_color2(smokeTrail, #777777, #aaaaaa);
part_type_gravity(smokeTrail, .0015, 135);
part_type_direction(smokeTrail, 0, 360, 0, 0);
part_type_speed(smokeTrail, 0, .08, 0, .03);
part_type_orientation(smokeTrail, 0, 360, .5, 3, 0);
#endregion

#region floaty smoke for haze, hangs around for longer and doesn't blow?
global.smokeHaze = part_type_create();
smokeHaze = global.smokeHaze;
part_type_life(smokeHaze, 400, 1000);
part_type_shape(smokeHaze, pt_shape_square);
part_type_size(smokeHaze, .1, .3, .0035, 0);
part_type_alpha3(smokeHaze, 0, .2, 0);
part_type_color2(smokeHaze, #777777, #aaaaaa);
#endregion

#region erupting flares
global.eruptClods = part_type_create();
eruptClods = global.eruptClods;
part_type_size(eruptClods, .05, .4, -.0005, 0);
part_type_alpha1(eruptClods, 1);
part_type_shape(eruptClods, pt_shape_line);
part_type_direction(eruptClods, 45, 135, 0, 0);
part_type_orientation(eruptClods, 0, 0, 0, 0, 1);
part_type_speed(eruptClods, 1.1, 4.3, 0, 0);
part_type_life(eruptClods, 70, 280);
part_type_gravity(eruptClods, .010, 270);
part_type_step(eruptClods, -6, smokeTrail);
#endregion

#region helicopter wake
global.heliDust = part_type_create();
heliDust = global.heliDust;
part_type_life(heliDust, 196, 300);
part_type_shape(heliDust, pt_shape_square);
part_type_size(heliDust, .1, .1, .008, 0);
part_type_alpha2(heliDust, .9, 0);
part_type_color1(heliDust, #d5cA89);
part_type_orientation(heliDust, 0, 360, 0, 0, 0);
#endregion

#endregion

#region enum crap

enum stepTimeEnum {
	progress = 0,
	startTime = 1,
	endTime = 2,
	speedRef = 3
}

#endregion

///@desc This uses deactivation and object type deleting to clear all map visuals that don't fall within the generation area (generate in, delete out, this keeps a balanced border to the generator)
clearMapVisuals = function() {
	var _generator = global.generator;
	var _camX = _generator.updateLastX;
	var _camY = _generator.updateLastY;
	
	instance_activate_object(obj_mapVisual);
	instance_deactivate_region(_camX - blockSize * bufferBlockCount / 2, _camY - blockSize * bufferBlockCount / 2, global.generator.width * blockSize + blockSize * bufferBlockCount / 2, global.generator.height * blockSize + blockSize * bufferBlockCount / 2, true, true);
	instance_destroy(obj_mapVisual);
	instance_activate_object(obj_mapVisual);
	
	instance_activate_object(obj_gmlive); // gmlive's controller object
	instance_activate_object(obj_playerParent);
	instance_activate_object(obj_questManager)
	instance_activate_object(obj_questWatcher) 
	instance_activate_object(obj_questBookManager)
	instance_activate_object(obj_weatherManager)
	instance_activate_object(input_controller_object); // inputs controller
	instance_activate_object(obj_camera);
	instance_activate_object(obj_particleLayerManager);
	instance_activate_object(obj_generator);
	
	instance_activate_region(_camX - blockSize * bufferBlockCount / 2, _camY - blockSize * bufferBlockCount / 2, global.generator.width * blockSize + blockSize * bufferBlockCount / 2, global.generator.height * blockSize + blockSize * bufferBlockCount / 2, true);
}

deactivateThings = function() {	
	instance_deactivate_all(true);
	var _checkI = 0;
	repeat(4) {
		if(view_visible[_checkI]) {
			instance_activate_region(camera_get_view_x(view_camera[_checkI]) - 1400, camera_get_view_y(view_camera[_checkI]) - 1400, camera_get_view_width(view_camera[_checkI]) + 2800, camera_get_view_height(view_camera[_checkI]) + 2800, true);
		}
		_checkI++;
	}
	instance_activate_object(obj_gmlive); // gmlive's controller object
	instance_activate_object(obj_playerParent);
	instance_activate_object(obj_questManager)
	instance_activate_object(obj_questWatcher) 
	instance_activate_object(obj_questBookManager)
	instance_activate_object(obj_weatherManager)
	instance_activate_object(input_controller_object); // inputs controller
	instance_activate_object(obj_camera);
	instance_activate_object(obj_particleLayerManager);
	instance_activate_object(obj_generator);
}

switchRoomFake = function(roomDestination) {
	fakeRoom = roomDestination;
	obj_questManager.refreshWatchers(roomDestination);
}

//global.player = instance_create_layer(x, y, "Instances", obj_playerShip);

//var _off = -200;
//repeat(20) {
//	var _yuh0 = instance_create_layer(x, y, "Instances", obj_followingDebugBlock);
//	_yuh0.yOffset = _off;
//	_off += 20;
//}
