if (live_call()) return live_result;

event_inherited();

script_mdlCreateInit();

#region player values
directionFacing = 0;
currentSpeed = 0;
previousSpeed = 0;
currentDir = 0;
previousDir = 0;

moveSpeed = .024;
speedDecay = .98;

xChange = 0;
yChange = 0;

kneeAnglesDebug = [0, 0];

#endregion

surf = -1; // draw all your components to this surf and draw the surf to the screen (for shader and effect simplicity) //TODO - done!

#region camera
camX = camera_get_view_x(view_camera[0]);
camY = camera_get_view_y(view_camera[0]);

camera_set_view_size(view_camera[playerIndex], 800, 450);
#endregion

#region new body stuff
feetOffYBase = 74;
feetOffY = feetOffYBase;
feetOffX = 0; //??
feetY = y + feetOffY;

spineMain = new script_createSpine(x, y, 90, 50);
#endregion

#region gun and bullet values
gunType = 0;

#region gun in hand values
gunSprite = spr_pistol;
weaponPosition = [x, y, feetOffY]; // use arrays (structs??) to store positions both for simplicty (i guess?) but more importantly for reference passing, being able to give the component system the item 
gunHoldOffsets = [[0, 0, 0], [0, 0, 0]]; // the sub arrays here are hand locations relative to the x/y of the gun (must be rotated and scaled if applicable)
gunHoldDistance = 30;
gunHoldDirection = 0;
gunAimRange = 95;
gunHeldDown = 0;
gunLength = 10;

gunTipPosition = [0, 0, 0];


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
	//live_auto_call
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
		gunLength = 55;
		gunTipHeightOff = 12;
		script_setHoldOffsets(10, -10, 30, 5, -5, 3);
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
		gunLength = 32;
		gunTipHeightOff = 12;
		script_setHoldOffsets(0, 0, 5, 0, 0, 0);
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
		gunHoldDistance = 6;
		gunLength = 69;
		gunTipHeightOff = 10;
		script_setHoldOffsets(1, 1, 3, 25, -25, 4);
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
						script_shootBulletScan(gunTipPosition[0], gunTipPosition[1], _aimDir, input_cursor_x(playerIndex), input_cursor_y(playerIndex), bulletType,, gunAccuracy + burstSpread, shotSound, gunDamageMult, true);
						burstSpread += .02;
						gunShakeX -= dcos(_aimDir) * gunRecoil;
						gunShakeY -= dsin(_aimDir) * gunRecoil;
						ammoCurrent--;
						//if(ammoCurrent < 1) {
						//	startReload(); // i don't like having the last shot auto reload, cooler if it just makes the bullet click and all
						//}
						shotTimer = 0;
					} else {
						script_shootBullet(gunTipPosition[0], gunTipPosition[1], shotSpeed, _aimDir, bulletType,, shotSpeed * (gunTipPosition[2] / point_distance(gunTipPosition[0], gunTipPosition[1], input_cursor_x(playerIndex), input_cursor_y(playerIndex))),, gunAccuracy, , gunDamageMult);
						burstSpread += .02;
						gunShakeX -= dcos(_aimDir) * gunRecoil;
						gunShakeY -= dsin(_aimDir) * gunRecoil;
						ammoCurrent--;
						shotTimer = 0;
					}
				}
				if(input_check_released("middleClick", playerIndex)) {
					script_shootBullet(gunTipPosition[0], gunTipPosition[1], shotSpeed / 4, _aimDir, obj_missile, gunTipPosition[2], shotSpeed / 4 * (gunTipPosition[2] / point_distance(gunTipPosition[0], gunTipPosition[1], input_cursor_x(playerIndex), input_cursor_y(playerIndex))),,.30);
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

#region leg variables
legSegLen = 32;
#endregion

#region NEW LEG STUFF, set up component functions and arrays for reference
stepUpdateDistBase = 36;
stepUpdateDist = stepUpdateDistBase;

legArray = [  [[x, y, 0, legSegLen], [x, y, 0, legSegLen], [x, y, 0, legSegLen]], [[x, y, 0, legSegLen], [x, y, 0, legSegLen], [x, y, 0, legSegLen]]]; // 2 LEGS for now in nested structure, legs, nodes, coords (+ length, width) in that nesting
stepPositionsInitial = [ [x, y, 0], [x, y, 0] ]; // coords for each foot landed or come from during a step (aka 2 [x,y,z] for humans)
stepPositionsGoal = [ [x, y, 0], [x, y, 0] ]; // coords for each foot to land at or go to during a step (aka 2 [x,y,z] for humans)

stepTimings = [[0, current_time, current_time, 0], [0, current_time, current_time, 0]]; //[progress(updated by step), startTime, endTime, speedRef] (where speed reference is the speed that the thing was moving for that step to compare against for clipping a step on speed up or extending a step in slow down.

thighWidth = 20;
shinWidth = 10; // reset down below for size of animal

debugClamp = .09;
debugOverStep = .1;
debugPushAhead = .68;

#endregion

#region arm arrays, more of a loose structure to mirror the component settings
limbLength = 20;
limbArray = [  [[x, y, 0, limbLength], [x, y, 0, limbLength], [x, y, 0, limbLength]], [[x, y, 0, limbLength], [x, y, 0, limbLength], [x, y, 0, limbLength]]]; // 2 arms for now in nested structure, arms, nodes, coords in that nesting
#endregion

#region body components
bodyComponents = [];

#endregion


#region components
var _fu = 0;
//                                              only if is limb
//                                   target   spine        [limbType]       sprite(s)                 image(s)  rotRel  height   dist,  xscl          yscl     viewAng   viewComp    color          imgGetRotAdd   fixedAngDraw       limbArrRef     gunOffArrRef
_fu = new script_addBodyComponent(    id,    spineMain,                 spr_robeParts,                  [8, 1],   0,     0,        0,     1.6,           2,         0,      .6,      #3D3D29,               0,      undefined);                                          // body
head = new script_addBodyComponent(   id,    spineMain,                 spr_robeParts,                  [9, 3],   0,     31,       2,     1.6,           2,         0,      .6,      #ffaaaa,               0,      0);                                          // head
_fu = new script_addBodyComponent(    id,    spineMain,                 spr_robeParts,                  0,        85,    17,       10,    1.6,           2,         0,      .4,      #4D4D39,               0,      undefined);                                          // shoulder
_fu = new script_addBodyComponent(    id,    spineMain,                 spr_robeParts,                  0,        -85,   17,       10,    1.6,           2,         0,      .4,      #4D4D39,               0,      undefined);                                          // shoulder
_fu = new script_addLimbBodyComponent(id,    spineMain, limbTypes.arm,  [spr_armParts,   spr_armParts], [0, 0],   80,    12,       10,    [1.6, 1.6],    [2, 2],    0,      1,       [ #4D4D39, #4D4D39],   0,      undefined,         limbArray[0], gunHoldOffsets[0]); // arm arrays
_fu = new script_addLimbBodyComponent(id,    spineMain, limbTypes.arm,  [spr_armParts,   spr_armParts], [0, 0],   -80,   21,       10,    [1.6, 1.6],    [2, 2],    0,      1,       [ #4D4D39, #4D4D39],   0,      undefined,         limbArray[1], gunHoldOffsets[1]); // arm arrays
_fu = new script_addBodyComponent(    id,    spineMain,                 spr_robeParts,                  4,        0,     -3,       -6,    1.6,           2,         0,      .4,      #363622,               0,      undefined);                                          // cape
_fu = new script_addLimbBodyComponent(id,    spineMain, limbTypes.leg,  [spr_legParts,   spr_legParts], [0, 1],   80,    -10,       7,    [1.6, 1.6],    [2, 2],    0,      1,       [ #4D4D39, #4D4D39],   0,      undefined,         legArray[0], 0); // leg arrays
_fu = new script_addLimbBodyComponent(id,    spineMain, limbTypes.leg,  [spr_legParts,   spr_legParts], [0, 1],   -80,   -10,       7,    [1.6, 1.6],    [2, 2],    0,      1,       [ #4D4D39, #4D4D39],   0,      undefined,         legArray[1], 1); // leg arrays

//lag testing
//repeat(5000) {
	//new script_addBodyComponent(id, 0, spr_robeParts,  [9, 3],  irandom(360),    irandom_range(-40, 70),   irandom(50), 1.6,   2,      0,     .6,         #ffaaaa, 0); // head
	//new script_addLimbBodyComponent(id, 0, [spr_armParts, spr_armParts], [0, 0],  irandom(360),  irandom_range(-20, 30),   irandom(40), [1.6, 1.6],   [2, 2],      0,     1, [ #4D4D39, #4D4D39], 0, limbArray[irandom(1)], gunHoldOffsets[irandom(1)]); // arm arrays
//}
#endregion

setTurret(1);