if (live_call()) return live_result;

event_inherited();

sbHaze = global.sandBurstHaze;
debris = global.darkDebris;
heliDust = global.heliDust
sys = global.particleSystem;

#region player values
playerAcceleration = .03;
playerTurnSpeed = 2;

playerDirection = 0;
playerDirectionChange = 0;

playerScale = 1;

xChange = 0;
yChange = 0;

prevSpeed = 0;
#endregion

#region heli stuff
bladeSpinSpeed = 0;
bladeSpinSpeedMax = 10;

bladeLength = 140;

bladeSpin = 0;

height = 0;
heightChange = 0;

heightChangeSign = 1;
#endregion

#region gun and bullet values
gunType = 0;

shotTimeLimit = 7;

bulletType = obj_basicBullet;
shotSpeed = 12;

minigunCharge = 0;
minigunChargeMax = 300;
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
	var _aimDir = point_direction(x, y - height / 4, input_cursor_x(playerIndex), input_cursor_y(playerIndex));
	live_auto_call
	if(input_check("leftClick", playerIndex)) {
		if(asset_has_any_tag(bulletType, "scan", asset_object)) {
			script_shootBulletScan(x, y - height / 4, _aimDir, input_cursor_x(playerIndex), input_cursor_y(playerIndex), bulletType,, .1);
			shotTimer = 0;
		} else {
			script_shootBullet(x, y - height / 4, shotSpeed, _aimDir, bulletType, height / 4, shotSpeed * (height / 4 / point_distance(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex))),,.13);
			shotTimer = 0;
		}
	}
	if(input_check_released("rightClick", playerIndex)) {
		script_shootBullet(x, y - height / 4, shotSpeed * .7, _aimDir, obj_rocket, height / 4, shotSpeed * .7 * (height / 4 / point_distance(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex))),,.15);
		shotTimer = 0;
	}
	if(input_check("middleClick", playerIndex)) {
		if(minigunCharge < minigunChargeMax) {
			minigunCharge += 2;
		} else {
			script_shootBulletScan(x, y - height / 4, _aimDir, input_cursor_x(playerIndex), input_cursor_y(playerIndex), obj_basicScanBullet,, .18, snd_minigunLoop, .5, 1);
			//shotTimer = shotTimeLimit; // frame delay
		}
	}
}