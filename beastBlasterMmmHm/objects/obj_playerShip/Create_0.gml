if (live_call()) return live_result;

event_inherited();

#region player values
playerSpeed = 4;
playerTurnSpeed = 2;
#endregion

#region gun and bullet values
gunType = 0;

shotTimeLimit = 7;

bulletType = obj_basicBullet;
shotSpeed = 12;

airStrikeBeginningX = 0;
airStrikeBeginningY = 0;
airStrikeCharging = 0;
airStrikeCoolDown = 0;
#endregion

#region function set
//functionSetOnGroundHit = [];
//functionSetOnEnemyHit = [];
//functionSetOnTravel = [];
#endregion

#region set shooting data
setTurret = function(turretType) {
	live_auto_call
	gunType = turretType;
	
	if(turretType == 0) { // standard bullets 
		shotTimeLimit = 7;

		bulletType = obj_basicBullet;
		shotSpeed = 12;
	} else if(turretType == 1) { // missle
		shotTimeLimit = 7;

		bulletType = obj_missile;
		shotSpeed = 7;
	} else if(turretType == 2) { // nuclear options
		shotTimeLimit = 60;

		bulletType = obj_icbm;
		shotSpeed = 1;
	}
	//such and things
}
#endregion

weaponControls = function() {
	var _aimDir = point_direction(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex));
	live_auto_call
	if(input_check("leftClick", playerIndex)) {
		if(asset_has_any_tag(bulletType, "scan", asset_object)) {
			script_shootBulletScan(x, y, _aimDir, input_cursor_x(playerIndex), input_cursor_y(playerIndex), bulletType,, .1);
			shotTimer = 0;
		} else {
			script_shootBullet(x, y, shotSpeed, _aimDir, bulletType,, shotSpeed * (100 / point_distance(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex))),,.15);
			shotTimer = 0;
		}
	}
	if(input_check_released("rightClick", playerIndex)) {
		script_shootBullet(x, y, shotSpeed / 2, _aimDir, obj_missile,, shotSpeed / 2 * (100 / point_distance(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex))),,.22);
		shotTimer = 0;
	}
	if(input_check_pressed("middleClick", playerIndex)) {
		if(airStrikeCoolDown == 0) {
			airStrikeCoolDown = 288;
			airStrikeCharging = 1;
			airStrikeBeginningX = input_cursor_x(playerIndex);
			airStrikeBeginningY = input_cursor_y(playerIndex);
		}
	} else if(input_check_released("middleClick", playerIndex)) {
		if(airStrikeCharging) {
			airStrikeCharging = 0;
			if(point_distance(airStrikeBeginningX, airStrikeBeginningY, input_cursor_x(playerIndex), input_cursor_x(playerIndex)) < 120) {
				script_startAirStrike(input_cursor_x(playerIndex), input_cursor_y(playerIndex)); // point strike
			} else {
				script_startAirStrike(airStrikeBeginningX, airStrikeBeginningY, input_cursor_x(playerIndex), input_cursor_y(playerIndex), 2, 7,, 50, 288);
			}
		}
	}
}