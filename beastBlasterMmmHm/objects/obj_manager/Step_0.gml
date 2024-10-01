if (live_call()) return live_result;

#region sound control kiinda ...
if(keyboard_check_released(ord("M"))) {
	global.muted -= .25;
	if(global.muted < 0) {
		global.muted = 1;
	}
	audio_group_set_gain(audiogroup_default, global.muted, 1000);
}
#endregion

#region surface saving
surfaceTimer++;
if(surfaceTimer > 1200) { // save current debris surface to buffer
	surfaceTimer = 0;
	var _surface = getDebrisSurface();
	buffer_get_surface(debrisSurfaceBuffer, _surface, 0);
}
#endregion

#region enemy spawning
if(instance_count < 50) {
	if(irandom(1200) == 0) {
		if(instance_exists(obj_playerParent)) {
			var _player = global.players[irandom(array_length(global.players) - 1)];
			var _spawnX = clamp(_player.x + choose(irandom_range(-1200, -camWidth * .6), irandom_range(camWidth * .6, 1200)), -2500, 2500);
			var _spawnY = clamp(_player.y + choose(irandom_range(-1200, -camHeight * .6), irandom_range(camHeight * .6, 1200)), -2500, 2500);

			repeat(power(choose(1, 1, 1, 2, 2, 3), 2)) {
				var _enemy = instance_create_layer(_spawnX + irandom_range(-100, 100), _spawnY + irandom_range(-100, 100), "Instances", choose(obj_desertRatMan, obj_desertRatMan, obj_desertRatMan, obj_grub));
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
        var _old_player = _status.__new_connections[_i]; // is this supposed to be disconnections?
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
	instance_activate_object(obj_enemy);
	instance_destroy(obj_enemy);
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