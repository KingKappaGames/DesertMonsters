if (live_call()) return live_result;

event_inherited();

#region player values
bodySprite = spr_bodyVultureCoat;

directionFacing = 0;

moveSpeed = .024;
speedDecay = .98;

xChange = 0;
yChange = 0;

#endregion

#region camera
camX = camera_get_view_x(view_camera[0]);
camY = camera_get_view_y(view_camera[0]);
camera_set_view_size(view_camera[0], 480, 270);
#endregion

#region gun and bullet values
gunType = 0;

#region gun in hand values
gunSprite = spr_pistol;
gunX = x;
gunY = y;
gunHoldDistance = 30;
gunHoldDirection = 0;
gunAimRange = 95;
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
	live_auto_call
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
	} else if(type == 3) {
		bulletType = obj_rocket;
		shotSpeed = 15;
		gunDamageMult = 1;
		gunAccuracy = .05;

		shotSound = snd_rpgLaunch;
		reloadSound = snd_largePistolReload;
		emptyShotSound = snd_emptyRifle;

		shotTimeLimit = 35; // frames per fire
		reloadingDelay = 320;
		ammoMax = 1;
		gunAutomatic = 0;
		
		gunSprite = spr_rpg; //visual bits
		gunHoldDistance = 5;
		gunRecoil = 6.5;
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

weaponControls = function() {
	var _aimDir = point_direction(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex));
	if(!gunHeldDown) { // gun aimed down for safety aka not in position to shoot because not aiming at target
		if(reloadingTimer == 0) {
			if(ammoCurrent > 0) {
				if(input_check_pressed("leftClick", playerIndex) || (gunAutomatic == 1 && input_check("leftClick", playerIndex))) {
					if(asset_has_any_tag(bulletType, "scan", asset_object)) {
						script_shootBulletScan(x, y, _aimDir, input_cursor_x(playerIndex), input_cursor_y(playerIndex), bulletType,, gunAccuracy + burstSpread, shotSound, gunDamageMult);
						burstSpread += .02;
						gunShakeX += dcos(_aimDir) * gunRecoil;
						gunShakeY += dsin(_aimDir) * gunRecoil;
						ammoCurrent--;
						//if(ammoCurrent < 1) {
						//	startReload(); // i don't like having the last shot auto reload, cooler if it just makes the bullet click and all
						//}
						shotTimer = 0;
					} else {
						script_shootBullet(x, y, shotSpeed, _aimDir, bulletType,, shotSpeed * (100 / point_distance(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex))),, gunAccuracy, , gunDamageMult);
						burstSpread += .02;
						gunShakeX += dcos(_aimDir) * gunRecoil;
						gunShakeY += dsin(_aimDir) * gunRecoil;
						ammoCurrent--;
						shotTimer = 0;
					}
				}
				if(input_check_released("rightClick", playerIndex)) {
					script_shootBullet(x, y, shotSpeed / 2, _aimDir, obj_basicBullet,, shotSpeed / 2 * (100 / point_distance(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex))),,.12);
					shotTimer = 0;
				}
				if(input_check_released("middleClick", playerIndex)) {
					script_shootBullet(x, y, shotSpeed / 4, _aimDir, obj_missile,, shotSpeed / 4 * (100 / point_distance(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex))),,.30);
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
legSegLen = 33;

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
	trackLen = (spd * 14) / clamp(sqrt(spd * .29), .25, 2.4);
}

setFeetAtTrackBase = function(speedMoving) { // god i hate built in speed variable
	var _trackProg = dsin(legRotation);
	
	var _trackXToEnd = dcos(trackDir) * trackLen;
	var _trackYToEnd = -dsin(trackDir) * trackLen;
	
	var _trackAhead = speedMoving * .17;
	
	footLX = lTrackX + _trackXToEnd * (_trackProg + _trackAhead);
	footLY = lTrackY + _trackYToEnd * (_trackProg + _trackAhead);
	
	footRX = rTrackX + _trackXToEnd * (-_trackProg + _trackAhead);
	footRY = rTrackY + _trackYToEnd * (-_trackProg + _trackAhead);
}

raiseFeetOffTrack = function(spd) {
	footLY += clamp(dsin(legRotation + 270), -99, 0) * (power(1 + spd, 1.25) - 1) * 9;
	footRY += clamp(dsin(legRotation + 90), -99, 0) * (power(1 + spd, 1.25) - 1) * 9;
}

placeFeetFull = function(dir, spd) {
	setTrack(dir, spd);
	setFeetAtTrackBase(spd);
	raiseFeetOffTrack(spd);
	
	return "Calm down or you will have no sun and no rain";
}
#endregion

#region arm arrays, more of a loose structure to mirror the component settings
limbLength = 20;
limbArray = [  [[x, y, trackHeight], [x, y, trackHeight], [x, y, trackHeight]], [[x, y, trackHeight], [x, y, trackHeight], [x, y, trackHeight]]]; // 2 arms for now in nested structure, arms, nodes, coords in that nesting
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
///@param viewAngle The direction of the view of the image, for backpacks it would straight out aka 0, for something that sticks away and scales that way 90 would be "away" and the range 0 - 180 not -90 to 90, depends on the flatness of your perspective
///@param viewCompressionMin The minimum horizontal visual scale that can be had based on the view angles, backpacks might be .4 for 40% width at off angle view
///@param color The color blend to apply, standard stuff
///@param imgRotationAdjust The angle to add to the view angle when getting the image for angle based images
addToBodyComponents = function(sprite, image, rotationRelative, height, distance, xscale, yscale, viewAngle, viewCompressionMin, color = c_white, imgRotationAdjust = 0) {
	array_push(bodyComponents, [sprite, image, rotationRelative, height, distance, xscale, yscale, viewAngle, viewCompressionMin, color, imgRotationAdjust]);
}

///@desc Adds an array listing to the components array, note though that with this because you are describing a limb with multiple segments all the drawing values will be arrays representing joint to limb tip (hand, foot, whatever). So the position is the origin of the limb but the sprite, scale, img ect are arrays of each segment
///@param spriteArr The sprites to use
///@param imageArr The sprite images to use
///@param rotationRelative This is the off set from straight forward to draw the component
///@param height The y offset to draw this component with
///@param distance The distance from the player this item should rotate at unaffected by angle compression
///@param xscaleArr The horizontal scale of the images
///@param yscaleArr The vertical scale of the images
///@param viewAngle The direction of the view of the image, for backpacks it would straight out aka 0, for something that sticks away and scales that way 90 would be "away" and the range 0 - 180 not -90 to 90, depends on the flatness of your perspective
///@param viewCompressionMin The minimum horizontal visual scale that can be had based on the view angles, backpacks might be .4 for 40% width at off angle view
///@param colorArr The color blend to apply, standard stuff
///@param imgRotationAdjust The angle to add to the view angle when getting the image for angle based images
///@param limbArrRef The array reference to seek a limb with the index below, so you pass like, armArray from your own code, and below index 3 means armArray[3] should contain a node set that this drawing can use
///@param limbIndex The index in the limb array that this component relates to (as described in limb array ref param above)
addLimbToBodyComponents = function(spriteArr, imageArr, rotationRelative, height, distance, xscaleArr, yscaleArr, viewAngle, viewCompressionMin, colorArr = c_white, imgRotationAdjust = 0, limbArrRef, limbIndex) { // these limbs still need to adhere to rotation and position values because the sorting will use it the same way for all, or I can change it but seems easy enough as is
	array_push(bodyComponents, [spriteArr, imageArr, rotationRelative, height, distance, xscaleArr, yscaleArr, viewAngle, viewCompressionMin, colorArr, imgRotationAdjust, limbArrRef, limbIndex]); // limbSegLen array?
}

#endregion

#endregion

//var _rand = 0;
//repeat(24) {
//	//addToBodyComponents(spr_backpack, irandom(sprite_get_number(spr_backpack) - 1), ir andom(360), random_range(-7, 10), 14, 1, 1, 0, .1);
//	_rand += 15;
//	addToBodyComponents(spr_backpack, 0, _rand, 0, 20 + irandom(30), 1, 3, 0, 0, make_color_rgb(_rand / 1.5, _rand / 1.5, _rand / 1.5));
//}

//addToBodyComponents(spr_feathers, 0, 150, -1, 5, 1, 1, 50, .1, c_black);
//addToBodyComponents(spr_feathers, 1, 160, 3,  5, 1, 1, 60, .1, c_black);
//addToBodyComponents(spr_feathers, 2, 170, 3,  5, 1, 1, 70, .2, c_black);
//addToBodyComponents(spr_feathers, 3, 180, 3,  5, 1, 1, 90, .3, c_black); // feather array
//addToBodyComponents(spr_feathers, 2, 190, 3,  5, 1, 1, 110, .2, c_black);
//addToBodyComponents(spr_feathers, 1, 200, 3,  5, 1, 1, 120, .1, c_black);
//addToBodyComponents(spr_feathers, 0, 210, -1, 5, 1, 1, 130, .1, c_black);

//addToBodyComponents(spr_backpack, 10, 205, -6, 8, 3, 3, 90, .12, c_white); // dragon wings
//addToBodyComponents(spr_backpack, 10, 155, -6, 8, 3, 3, 90, .12, c_white);

////addToBodyComponents(spr_backpack, 11, 0, -25, 0, 1, 1, 0, .8, c_white);

//addToBodyComponents(spr_backpack, 8, 180, 3, 12, 1, 1, 0, 0, c_white); // ruck sack 2 parts
//addToBodyComponents(spr_backpack, 9, 115, -26, 33, 1, 1, 0, .99, c_white); // not possible with the current scaling of rotation move combined with image scaling, could add a supplement to match them up but... Sigh. Performance is already suffering...

setTurret(1);