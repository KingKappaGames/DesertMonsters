if (live_call()) return live_result;

event_inherited();

#region player values
directionFacing = 0;

moveSpeed = .03;
speedDecay = .98;

xChange = 0;
yChange = 0;

#endregion

#region camera
camX = camera_get_view_x(view_camera[0]);
camY = camera_get_view_y(view_camera[0]);
#endregion

#region gun and bullet values
gunType = 0;

#region gun in hand values
gunSprite = spr_pistol;
gunX = x;
gunY = y;
gunHoldDistance = 30;
gunHoldDirection = 0;
gunAimRange = 105;
gunHeldDown = 0;

gunDrawBehind = 0;

gunRecoil = 2.2;
gunShakeX = 0;
gunShakeY = 0;
#endregion

shotSound = snd_BasicShotWeak;
reloadSound = snd_largePistolReload;
emptyShotSound = snd_emptyRifle;

shotTimeLimit = 9;

bulletType = obj_basicScanBullet;
shotSpeed = 8;
gunDamageMult = 1;
gunAccuracy = .10; // decimal multiplier
burstSpread = 0; // builds up

reloadingTimer = 0;
reloadingDelay = 520;
ammoMax = 30;
ammoCurrent = 30;

gunAutomatic = 1;
#endregion

#region function set
//functionSetOnGroundHit = [];
//functionSetOnEnemyHit = [];
//functionSetOnTravel = [];
#endregion

#region gun functions
setTurret = function(type) {
	gunType = type;
	if(type == 1) {
		bulletType = obj_basicScanBullet;
		shotSpeed = 8; // not relevant
		gunDamageMult = 1;
		gunAccuracy = .09;

		shotSound = snd_PuffyRifleShot;
		reloadSound = snd_machineGunReload;
		emptyShotSound = snd_emptyRifle;

		shotTimeLimit = 9; // frames per fire
		reloadingDelay = 520;
		ammoMax = 60;
		gunAutomatic = 1;
		
		gunSprite = spr_machineGun; //visual bits
		gunHoldDistance = 13;
		gunRecoil = 2.2;
	} else if(type == 2) {
		bulletType = obj_basicScanBullet;
		shotSpeed = 10; // not relevant
		gunDamageMult = 2;
		gunAccuracy = .05;

		shotSound = snd_BasicShotWeak;
		reloadSound = snd_largePistolReload;
		emptyShotSound = snd_emptyPistol;

		shotTimeLimit = 5; // frames per fire
		reloadingDelay = 300;
		ammoMax = 12;
		gunAutomatic = 0;
		
		gunSprite = spr_pistol; //visual bits
		gunHoldDistance = 22;
		gunRecoil = 8;
	}
	
	reloadingTimer = 0; // don't bother reloading
	ammoCurrent = ammoMax;
	burstSpread = 0;
	//such and things
}

startReload = function() {
	reloadingTimer = reloadingDelay;
	audio_play_sound(reloadSound, 0, 0);
}

cancelReload = function(dropCurrentAmmo = false) {
	reloadingTimer = 0;
	audio_stop_sound(reloadSound);
	
	if(dropCurrentAmmo) {
		ammoCurrent = 0;
	}
}

weaponControls = function(aimDir) {
	if(!gunHeldDown) { // gun aimed down for safety aka not in position to shoot because not aiming at target
		if(reloadingTimer == 0) {
			if(ammoCurrent > 0) {
				if(input_check_pressed("leftClick", playerIndex) || (gunAutomatic == 1 && input_check("leftClick", playerIndex))) {
					if(asset_has_any_tag(bulletType, "scan", asset_object)) {
						script_shootBulletScan(x, y, aimDir, input_cursor_x(playerIndex), input_cursor_y(playerIndex), bulletType,, gunAccuracy + burstSpread, shotSound, gunDamageMult);
						burstSpread += .02;
						gunShakeX += dcos(aimDir) * gunRecoil;
						gunShakeY += dsin(aimDir) * gunRecoil;
						ammoCurrent--;
						//if(ammoCurrent < 1) {
						//	startReload(); // i don't like having the last shot auto reload, cooler if it just makes the bullet click and all
						//}
						shotTimer = 0;
					} else {
						script_shootBullet(x, y, shotSpeed, aimDir, bulletType,, shotSpeed * (100 / point_distance(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex))),, gunAccuracy, , gunDamageMult);
						shotTimer = 0;
					}
				}
				if(input_check_released("rightClick", playerIndex)) {
					script_shootBullet(x, y, shotSpeed / 2, aimDir, obj_basicBullet,, shotSpeed / 2 * (100 / point_distance(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex))),,.12);
					shotTimer = 0;
				}
				if(input_check_released("middleClick", playerIndex)) {
					script_shootBullet(x, y, shotSpeed / 4, aimDir, obj_missile,, shotSpeed / 4 * (100 / point_distance(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex))),,.30);
					shotTimer = 0;
				}
			} else {
				if(input_check_pressed("leftClick", playerIndex) || (gunAutomatic == 1 && input_check("leftClick", playerIndex))) {
					shotTimer = 0;
					audio_play_sound(emptyShotSound, 0, 0);
				} // , playerIndex
			}
		}
	}
}
#endregion

#region leg stuff!!! LEG STUFF

#region leg variables
legSegLen = 34;

footLX = 0;
footLY = 0;
footRX = 0;
footRY = 0;

legRotation = 0;
legRotationSpeed = 6.4;

hipYOff = 5;
hipWidth = 5;
hipYBob = 0;

lTrackX = 0;
lTrackY = 0;
rTrackX = 0;
rTrackY = 0;
trackDir = 0;
trackLen = 0;
trackHeight = 60;
#endregion

#region leg functions
setTrack = function(dir, spd) {
	var _cos = dcos(dir + 90);
	var _sin = dsin(dir + 90);
	
	lTrackX = x + _cos * hipWidth;
	lTrackY = y + trackHeight + hipYOff - _sin * hipWidth;
	rTrackX = x - _cos * hipWidth;
	rTrackY = y + trackHeight + hipYOff + _sin * hipWidth;
	
	trackDir = dir;
	trackLen = (spd * 14) / clamp(sqrt(spd / 2), .4, 2);
}

setFeetAtTrackBase = function(speedMoving) { // god i hate built in speed variable
	var _trackProg = dsin(legRotation);
	
	var _trackXToEnd = dcos(trackDir) * trackLen;
	var _trackYToEnd = -dsin(trackDir) * trackLen;
	
	var _trackAhead = speedMoving * .1;
	
	footLX = lTrackX + _trackXToEnd * (_trackProg + _trackAhead);
	footLY = lTrackY + _trackYToEnd * (_trackProg + _trackAhead);
	
	footRX = rTrackX + _trackXToEnd * (-_trackProg + _trackAhead);
	footRY = rTrackY + _trackYToEnd * (-_trackProg + _trackAhead);
}

raiseFeetOffTrack = function(spd) {
	footLY += clamp(dsin(legRotation + 270), -99, 0) * sqrt(spd) * 10;
	footRY += clamp(dsin(legRotation + 90), -99, 0) * sqrt(spd) * 10;
}

placeFeetFull = function(dir, spd) {
	setTrack(dir, spd);
	setFeetAtTrackBase(spd);
	raiseFeetOffTrack(spd);
	
	return "Calm down or you will have no sun and no rain";
}
#endregion

#region body components
bodyComponents = [];

///@desc Adds an array listing to the components array
///@param sprite The sprite to use
///@param image The sprite image to use
///@param rotationRelative This is the off set from straight forward to draw the component
///@param height The y offset to draw this component with
///@param distance The distance from the player this item should rotate at unaffected by angle compression
///@param xscale The horizontal scale of the image
///@param yscale The vertical scale of the image
///@param viewAngle The direction of the view of the image, for backpacks it would straight out aka 0
///@param viewCompressionMin The minimum horizontal visual scale that can be had based on the view angles, backpacks might be .4 for 40% width at off angle view
addToBodyComponents = function(sprite, image, rotationRelative, height, distance, xscale, yscale, viewAngle, viewCompressionMin) {
	array_push(bodyComponents, [sprite, image, rotationRelative, height, distance, xscale, yscale, viewAngle, viewCompressionMin]);
}

#endregion

#endregion


repeat(3) {
	addToBodyComponents(spr_backpack, irandom(sprite_get_number(spr_backpack) - 1), irandom(360), random_range(-7, 10), 1, 1, 0, .1);
}

var _featherI = 0;
var _featherAdd = 1;
repeat(7) {
	addToBodyComponents(spr_feathers, _featherI, 180 + _featherI * 10 - 30, -25, _featherAdd, 1, 0, .1);
	_featherI++;
	if(_featherI == 3) {
		_featherAdd = -1;
	}
}
//                  
//addToBodyComponents(spr_backpack, 0, 180, -3, 1, 1, 0, .4);
addToBodyComponents(spr_backpack, 8, 180, -6, 1, 1, 0, .1);
addToBodyComponents(spr_backpack, 0, 180, -6, 1, 1, 0, .4);

setTurret(1);