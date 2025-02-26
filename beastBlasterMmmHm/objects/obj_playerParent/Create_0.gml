if (live_call()) return live_result;

seed = obj_generator.seed;

manager = global.manager;
array_push(global.players, id);

playerIndex = -1; // stores what player this is, used by input and cameras for which player is which
setCursorActive = function(index, forceWithController = false) {
	if(forceWithController || !input_player_using_gamepad(playerIndex)) {
		input_cursor_mouse_enabled_set(true, index); // input cursor setting
	}
}
controllerAimSensitivity = 6;

#region player values
playerSpeed = 3;
playerTurnSpeed = 2;
#endregion

#region gun and bullet values
gunType = 0;

shotTimer = 0;
shotTimeLimit = 7;

bulletType = obj_basicBullet;
shotSpeed = 12;

airStrikeBeginningX = 0;
airStrikeBeginningY = 0;
airStrikeCharging = 0;
airStrikeCoolDown = 0;
#endregion

#region camera stuff
camWidth = camera_get_view_width(view_camera[0]);
camHeight = camera_get_view_height(view_camera[0]);
#endregion

#region function set
functionSetOnGroundHit = [];
functionSetOnEnemyHit = [];
functionSetOnTravel = [];
#endregion

#region set shooting data
setTurret = function() {
	//such and things
}
#endregion

weaponControls = function() {
	//what kinds of weapons to use on what buttons, set in children
}