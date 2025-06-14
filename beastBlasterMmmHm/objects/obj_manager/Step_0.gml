if (live_call()) return live_result;

#region sound control kiinda ...
if(keyboard_check_released(ord("M"))) {
	if(global.masterVolume != 0) {
		global.masterVolume = 0;
	} else {
		global.masterVolume = .2;
	}
	audio_group_set_gain(audiogroup_default, global.masterVolume, 250);
}
#endregion

#region surface saving
surfaceTimer++;
if(surfaceTimer > 720) { // save current debris surface to buffer
	surfaceTimer = 0;
	var _surface = getDebrisSurface();
	buffer_get_surface(debrisSurfaceBuffer, _surface, 0);
} else if(surfaceTimer == 72) {
	clearMapVisuals();
	
	#region //this doesn't need to be here I just needed a periodic call
	var _partDeleteList = global.particleGrinderQueue;
	var _removeTime = current_time;
	for(var _deleteI = array_length(_partDeleteList) - 1; _deleteI >= 0; _deleteI--) {
		if(_partDeleteList[_deleteI][1] < _removeTime) {
			part_type_destroy(_partDeleteList[_deleteI][0]);
			array_delete(_partDeleteList, _deleteI, 1); // remove part then remove array index for it
		} else {
			break; // found the first non removed, ergo stop checking down
		}
	}
	#endregion
}
#endregion

#region enemy spawning
if(instance_count < 30) {
	if(irandom(880) == 0) {
		if(instance_exists(obj_playerParent)) {
			var _player = global.players[irandom(array_length(global.players) - 1)];
			var _spawnX = clamp(_player.x + choose(irandom_range(-1200, -camWidth * .6), irandom_range(camWidth * .6, 1200)), -2500, 2500);
			var _spawnY = clamp(_player.y + choose(irandom_range(-1200, -camHeight * .6), irandom_range(camHeight * .6, 1200)), -2500, 2500);

			repeat(power(choose(1, 2, 2, 2, 3, 3), 1)) {
				var _enemy = instance_create_layer(_spawnX + irandom_range(-100, 100), _spawnY + irandom_range(-100, 100), "Instances", choose(obj_desertRatMan, obj_desertRatMan, obj_desertRatMan, obj_grub, obj_walker));
			}
		}
	}
}
#endregion

#region ambient sounds
if(irandom(5000) == 0) {
	if(!(audio_is_playing(snd_AirRaidSirenLong) || audio_is_playing(snd_ChoralFaint) || audio_is_playing(snd_CryAmbiance))) {
		audio_play_sound(choose(snd_AirRaidSirenLong, snd_AnimalCallsFaint, snd_ChoralChoppy, snd_CryAmbiance, snd_DetectorBeeping, snd_GuitarWarble, snd_QuietThumpingInDistance, snd_ChoralFaint), 0, 0);
	}
}
#endregion

#region input player changing controls
var _status = input_players_get_status();
if (_status.__any_changed)
{
    //Iterate over new players and create a new player instance for each
    for(var _i = 0; _i < array_length(_status.__new_connections); _i++)
    {
        var _new_player = _status.__new_connections[_i];

		var _otherPlayer = instance_find(obj_playerParent, irandom(instance_number(obj_playerParent) - 1));
        //Pass the player index into the new obj_playerParent instance
        var _player = instance_create_layer(0, 0, "Instances", obj_playerShip);
		_player.playerIndex = _new_player;
		_player.setCursorActive(_new_player);
		if(_otherPlayer != noone) {
			_player.x = _otherPlayer.x;
			_player.y = _otherPlayer.y;
		}
    }

    //Find any obj_playerParent instances for disconnected players and destroy them
    for(var _i = 0; _i < array_length(_status.__new_disconnections); _i++) {
        var _old_player = _status.__new_disconnections[_i];
        with(obj_playerParent) {
            if(playerIndex == _old_player) {
				instance_destroy();
			}
        }
    }
	global.camera.refreshCameras();
}
#endregion

if(input_check_released("fullscreen")) { // enter or square or x
	window_set_fullscreen(!window_get_fullscreen()); // f
}

if(input_check_released("restart")) { // just clear enemies
	var _player = 0;
	repeat(4) {
		input_player_disconnect(_player);
		_player++;
	}
	game_restart();
}

if(input_check_released("cameraChange")) {
	global.camera.refreshCameras(!global.cameraSplitOption);
}

if(keyboard_check_released(ord("7"))) {
	switchRoomFake("mainRoom")
}
if(keyboard_check_released(ord("8"))) {
	switchRoomFake("nightRoom")
}
if(keyboard_check_released(ord("9"))) {
	switchRoomFake("sideRoom")
}
if(keyboard_check_released(ord("0"))) {
	switchRoomFake("oceanRoom")
}

if(keyboard_check_released(vk_f1)) {
	var _enemy = instance_create_layer(mouse_x, mouse_y, "Instances", choose(obj_desertRatMan, obj_desertRatMan, obj_desertRatMan, obj_grub));
	_enemy.friendly = false;
}
if(keyboard_check_released(vk_f2)) {
	var _enemy = instance_create_layer(mouse_x, mouse_y, "Instances", choose(obj_desertRatMan, obj_desertRatMan, obj_desertRatMan, obj_grub));
	_enemy.friendly = true;
}
if(keyboard_check_released(vk_f3)) {
	var _enemy = instance_create_layer(mouse_x, mouse_y, "Instances", obj_walker);
	_enemy.friendly = true;
}
if(keyboard_check_released(vk_f4)) {
	var _enemy = instance_create_layer(mouse_x, mouse_y, "Instances", obj_jeep);
	_enemy.friendly = true;
}

if(abs(global.depthOffset - camera_get_view_y(view_camera[0])) > 3000) {
	global.depthOffset = camera_get_view_y(view_camera[0]) div 3000 * 3000; // set depth offset to multiples of 3000
	
	with(obj_palmTree) {
		depth = depth % 3000;
	}
}

if(keyboard_check(vk_left)) {
	global.windStrength -= .001;
}
if(keyboard_check(vk_right)) {
	global.windStrength += .001;
}
if(keyboard_check(vk_up)) {
	global.gravityStrength -= .001;
}
if(keyboard_check(vk_down)) {
	global.gravityStrength += .001;
}