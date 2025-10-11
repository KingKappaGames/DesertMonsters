if (live_call()) return live_result;

if(keyboard_check(vk_comma)) {
	game_set_speed(60, gamespeed_fps);
} else if(keyboard_check(vk_period)) {
	game_set_speed(18, gamespeed_fps);
} else if(keyboard_check(vk_fslash)) {
	game_set_speed(9, gamespeed_fps);
} else {
	game_set_speed(144, gamespeed_fps); // the legs are moving too fast which allows for them to both jump ahead then have dead time before either needs to move again, that's what's causing the clumping
}

#region movement and move contols
var _cursorX = input_cursor_x(playerIndex);
var _cursorY = input_cursor_y(playerIndex);
var _dirToCursor = point_direction(x, y, _cursorX, _cursorY);
var _sprint = .75 + input_check("sprint", playerIndex) * .8;
var _inputs = [input_value("right", playerIndex), input_value("left", playerIndex), input_value("down", playerIndex), input_value("up", playerIndex)];
var _dirMoveStick = point_direction(0, 0, _inputs[0] - _inputs[1], _inputs[2] - _inputs[3]);
var _distMoveStick = clamp(point_distance(0, 0, _inputs[0] - _inputs[1], _inputs[2] - _inputs[3]), 0, 1);
xChange += dcos(_dirMoveStick) * moveSpeed * _sprint * _distMoveStick;
yChange -= dsin(_dirMoveStick) * moveSpeed * _sprint * _distMoveStick; // push in dir and distance of stick


x += xChange;
y += yChange;
//depth = - (y + 60); // this project doesn't use depth... YET??? Maybe, I assume when i start making trees and walls and buildings I'll switch to -y depth but for now it's simpler to do surfaces with out any depth consideration. Especially the dust and debris... That'll be a pain with surfaces unless I go full layer stacking and do what main game does... Though I don't know if I have the height for it here... Too many layers required I think.
xChange *= speedDecay;
yChange *= speedDecay;

previousSpeed = currentSpeed;
currentSpeed = point_distance(0, 0, xChange, yChange);

previousDir = currentDir;
currentDir = point_direction(0, 0, xChange, yChange);

var _speedChange = sqr(abs(currentSpeed - previousSpeed) * 5);
var _dirChange = (sqrt(1 + (abs(angle_difference(currentDir, previousDir)) / 22.5)) - 1) * 1.1;

var _prevOffY = feetOffY;
feetOffY = lerp(feetOffY, feetOffYBase * lerp(1, .85, power(currentSpeed * .75, 1.5)), .02) - min(sqrt((_speedChange + _dirChange) * 7) * 1.2, feetOffYBase * .2);
y -= feetOffY - _prevOffY;
feetY = y + feetOffY * .7;
spineMain.x = x;
spineMain.y = feetY;
spineMain.height = feetOffY; // spine represents center here, but with feet height center is not at feet, obviously

var _spineX = spineMain.x;
var _spineY = spineMain.y; // get which spine to use maybe? That would do the proper multiple spines to use functionality...

//moveSpeed += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * .001; // delete this
#endregion

#region leg stuff!!
legRotationSpeed = 4.1 * clamp(sqrt(currentSpeed / 2), .17, .85); //proportional to speed
legRotation = (legRotation + legRotationSpeed) % 360;

hipYBob = lerp(hipYBob, clamp((-1 + currentSpeed) * 7.5, -7.5, 0) + clamp((dsin(legRotation * (1.5 + sqrt(currentSpeed) / 3) - 90) + .4) * currentSpeed, -3, 15), .03);
#endregion

#region NEW LEG STUFF

stepUpdateDist = max(stepUpdateDistBase * sqrt(currentSpeed) * 1.1, 19);

//animation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% (basic overall positioning, then calculating step positions and goals and moving the legs, then calculating the animations based on the positions)

hipDir = point_direction(0, 0, xChange, yChange);
var _cosFacing = dcos(hipDir);
var _sinFacing = -dsin(hipDir);

var _legCount = array_length(stepTimings); //TODO proxy for leg count, should always line up  (get all limbs and iterate with a check for (if leg) and use that index

var _allFeetOnGround = true; // DO PROGRESS SETTING
for(var _legI = 0; _legI < _legCount; _legI++) { // check leg progresses to allow or disallow new steps in legs
	var _limbNodes = legArray[_legI];
	var _stepTiming = stepTimings[_legI];
	var _stepGoal = stepPositionsGoal[_legI];
	var _stepDuration = _stepTiming[stepTimeEnum.endTime] - _stepTiming[stepTimeEnum.startTime];
	_stepTiming[stepTimeEnum.progress] = clamp((current_time - _stepTiming[stepTimeEnum.startTime]) / (_stepDuration), 0, 1);
	if(_stepTiming[stepTimeEnum.progress] < 1) { // still in the air, then add momentum to goal as well as body, this keeps feet aligned with object movement without having to predict some crazy future point
		_stepGoal[0] += xChange;
		_stepGoal[1] += yChange; // add height?
	}
	if(_allFeetOnGround && _stepTiming[stepTimeEnum.progress] < 1) {
		
		#region containing step goals within reasonable range AND bringing in step goals when slowing down
		var _hip = _limbNodes[0]; // first node of limb (array that contains data about it)
		var _stepDist = point_distance(_hip[0], _hip[1], _stepGoal[0], _stepGoal[1]);
		if(_stepDist > stepUpdateDist) {
			var _distOverMultiply = stepUpdateDist / (_stepDist + 1);
			
			_stepTiming[stepTimeEnum.endTime] = lerp(_stepTiming[stepTimeEnum.endTime], _stepTiming[stepTimeEnum.startTime], 1 - _distOverMultiply); // reduce time for step along with distance, basically, drop your foot sooner than planned if changing course
		
			_stepGoal[0] = lerp(_hip[0], _stepGoal[0], _distOverMultiply);
			_stepGoal[1] = lerp(_hip[1], _stepGoal[1], _distOverMultiply);
		}
		#endregion
		
		_allFeetOnGround = false;
	}
}

//DO STEP AND PLACEMENTS (AFTER PROGRESSES ALL DONE)
var _maxFootDistFromNeutral = -1;
var _maxDistLeg = -1;
for(var _legI = 0; _legI < _legCount; _legI++) {
	#region setting the local values from stored variables
	var _hip = legArray[_legI][0];
	var _stepInitial = stepPositionsInitial[_legI];
	var _stepCurrent = legArray[_legI][2];
	var _stepGoal = stepPositionsGoal[_legI];
	#endregion convenience value setting ^^^
	
	#region doing the step positions and updates		
	var _stepPlacement = array_create(2, 0);
	_stepPlacement[0] = _hip[0];
	_stepPlacement[1] = _hip[1];
	
	var _progress = stepTimings[_legI][stepTimeEnum.progress];
	
	var _stepHeight = dsin(180 * _progress) * legSegLen * .9;
	
	_stepCurrent[2] = _stepHeight;
	_stepCurrent[0] = lerp(_stepInitial[0], _stepGoal[0], _progress); // move foot over range of movement according to time progress
	_stepCurrent[1] = lerp(_stepInitial[1], _stepGoal[1], _progress);
	
	if(_allFeetOnGround && _progress == 1) { // there needs to be some way to deal with changing step lengths and repositions i think, for now just not stepping when already stepping works but has a bunch of issues
		var _stepPlacementDist = point_distance(_stepCurrent[0], _stepCurrent[1], _stepPlacement[0], _stepPlacement[1]); // add the height to the value but remove it when checking distance to step
		if(_maxFootDistFromNeutral < _stepPlacementDist) {
			_maxFootDistFromNeutral = _stepPlacementDist;
			_maxDistLeg = _legI;
		}
		if(_stepPlacementDist > stepUpdateDist) {
			placeStepGoal(_legI, _stepCurrent[0], _stepCurrent[1], _stepPlacement[0], _stepPlacement[1], currentSpeed);
			_allFeetOnGround = false;
		}
	}
	
	#endregion
	
	var _footDist = point_distance_3d(_hip[0], _hip[1], _hip[2], _stepCurrent[0], _stepCurrent[1], _stepCurrent[2]);
	var _footDir = point_direction(_hip[0], _hip[1], _stepCurrent[0], _stepCurrent[1]);

	#region clamp the foot distance to leg length to create rounded extensions, more of a fix or QA check than a feature but does create mild angled foot movements too
	if(_footDist > legSegLen * 2) {
		var _distOverMultiply = (legSegLen * 2) / _footDist;
		
		_stepCurrent[0] = lerp(_hip[0], _stepCurrent[0], _distOverMultiply);
		_stepCurrent[1] = lerp(_hip[1], _stepCurrent[1], _distOverMultiply); // fancy reducing way to clamp 3d distance to hip
		_stepCurrent[2] = lerp(_hip[2], _stepCurrent[2], _distOverMultiply);
		
		_footDist = legSegLen * 2; // assume dist is now what it's been clamped to, you know?
	}
	
	//part_particles_create(global.particleSystem, _stepCurrent[0], _stepCurrent[1] - _stepCurrent[2] * .7, debugPart, 1);
	
	//msg("foot details (x,y,z,len): " + string(_stepCurrent));
	#endregion
}

if(_allFeetOnGround) {
	if(_maxFootDistFromNeutral > legSegLen * .4) {
		var _leg = legArray[_maxDistLeg];
		placeStepGoal(_maxDistLeg, _leg[2][0], _leg[2][1], _leg[0][0], _leg[0][1]);
	}
}

#endregion

#region gun placing in hand basics

var _aimToFacingDifference = angle_difference(_dirToCursor, directionFacing);
gunHoldDirection = (directionFacing + clamp(_aimToFacingDifference, -gunAimRange, gunAimRange)) % 360; // limits aiming held range to facing direction plus aiming range 
var _holdDistMult = 1;
var _mouseDist = point_distance(_spineX, _spineY, _cursorX, _cursorY);
if(abs(_aimToFacingDifference) >= gunAimRange) { // if aiming outside of range
	gunHeldDown = 1; // dont aim the gun up if not possible to aim at a given target, meh.
	_holdDistMult = .5; // heldDown = less dist
} else {
	gunHeldDown = 0; // aim normally
	
	_holdDistMult = .5 + min(_mouseDist / 220, 1.2);
}

weaponPosition[0] = _spineX + dcos(gunHoldDirection) * gunHoldDistance * _holdDistMult + gunShakeX;
weaponPosition[1] = _spineY - (dsin(gunHoldDirection) * gunHoldDistance * _holdDistMult + gunShakeY) * .7; // lower and bring in gun when not holding up
weaponPosition[2] = feetOffY - ((gunHeldDown * 6) + ((1 - gunHeldDown) * (22 - _holdDistMult * 22)));
if(point_distance(_spineX, _spineY, weaponPosition[0], weaponPosition[1]) > legSegLen * 2) {
	weaponPosition[0] = _spineX + dcos(gunHoldDirection) * 20;
	weaponPosition[1] = _spineY - dsin(gunHoldDirection) * 13;
}

if(gunHoldDirection > 0 && gunHoldDirection < 180) {
	gunDrawBehind = 1;
} else {
	gunDrawBehind = 0;
}

gunShakeX *= .95;
gunShakeY *= .95;

#endregion

#region player controls, camera, and info maintenance

if(input_check_released("reload", playerIndex)) { // reload logic
	if(reloadingTimer > 0) {
		cancelReload();
	} else {
		startReload();
	}
}

if(input_check_released("gunSwitch", playerIndex)) { // swap weapons
	setTurret(clamp((gunType + 1) % 4, 1, 99));
}

if(reloadingTimer > 0) { // reload timers and ammo logic
	reloadingTimer--;
	if(reloadingTimer == 0) {
		ammoCurrent = ammoMax;
	}
}

#region camera setting
if(global.cameraSplitOption == true) {
	camX = lerp(camX, ((x + x + _cursorX) / 3) - camera_get_view_width(view_camera[playerIndex]) / 2, .015);
	camY = lerp(camY, ((y + _cursorY) / 2) - camera_get_view_height(view_camera[playerIndex]) / 2, .02);
	camera_set_view_pos(view_camera[playerIndex], camX, camY);
}
#endregion

if(input_check_released("characterSwitch", playerIndex)) { // get in and out of plane
	var _player = instance_create_layer(x, y, "Instances", obj_playerCar);
	_player.playerIndex = playerIndex;
	instance_destroy();
	_player.setCursorActive(_player.playerIndex); // in the destroy it sets mouse back to false so this needs to be after
	exit;
}

if(burstSpread > .01) { // decay gun bloom, (inaccuracy with constant shots)
	burstSpread = burstSpread * .995 - .001;
}

if(_dirToCursor > 90 && _dirToCursor < 270) { // looking at the pointed at position with head
	head.fixedDrawAngle = 180 + (angle_difference(_dirToCursor, 180) * .5) * abs(dcos(_dirToCursor));
	head.yscale = -1 * abs(head.yscale);
} else {
	head.fixedDrawAngle = (angle_difference(_dirToCursor, 0) * .5) * abs(dcos(_dirToCursor));
	head.yscale = abs(head.yscale);
}
	
//ammoCurrent = ammoMax; // clean

event_inherited();

depth = -((y + feetOffY) - global.depthOffset);

#endregion

if(keyboard_check(ord("Y"))) {
	feetOffY += 1;
} else if(keyboard_check(ord("H"))) { // move the spine up and down but not actually..? I'm not sure where the disconnect is
	feetOffY -= 1;
}

debugClamp *= 1 + (keyboard_check(ord("U")) - keyboard_check(ord("J"))) * .0035;
debugOverStep *= 1 + (keyboard_check(ord("I")) - keyboard_check(ord("K"))) * .0035;
debugPushAhead *= 1 + (keyboard_check(ord("O")) - keyboard_check(ord("L"))) * .0035;