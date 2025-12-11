function script_mdlCreateInit() {
	bodySprite = spr_bodyVultureCoat;
	bodyComponents = [];
	bodyComponentNextIndex = 0;
	
	directionFacing = 0;
	
	aimDir = 0;
	aimDist = 0;
	
	feetOffYBase = 74;
	feetOffY = feetOffYBase;
	feetOffX = 0; //??
	feetY = y + feetOffY;
	
	spineMain = new script_createSpine(x, y, 90, 50);
	
	legSegLen = 32;
	hipDir = 0;
	
	mdlSurfWidth = 256;
	mdlSurfHeight = 256;
	mdlSurf = -1; // draw all your components to this surf and draw the surf to the screen (for shader and effect simplicity)
	
	stepUpdateDistBase = 36;
	stepUpdateDist = stepUpdateDistBase;
	
	legArray = []; // nested structure, legs, nodes, coords (+ length, width) in that nesting
	stepPositionsInitial = []; // coords for each foot landed or come from during a step (aka 2 [x,y,z] for humans)
	stepPositionsGoal = []; // coords for each foot to land at or go to during a step (aka 2 [x,y,z] for humans)
	
	stepTimings = [[0, current_time, current_time, 0], [0, current_time, current_time, 0]]; //[progress(updated by step), startTime, endTime, speedRef] (where speed reference is the speed that the thing was moving for that step to compare against for clipping a step on speed up or extending a step in slow down.
	
	thighWidth = 20;
	shinWidth = 10; // reset down below for size of animal
	
	debugClamp = .09;
	debugOverStep = .1;
	debugPushAhead = .68;
	
	kneeAnglesDebug = [0, 0]; // debug!
	
	#region weapon holding (the model animation parts of gun logic..)
	holdingWeapon = true;

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
}

function script_mdlStep() {
	var _speedChange = sqr(abs(currentSpeed - previousSpeed) * 5);
	var _dirChange = (sqrt(1 + (abs(angle_difference(currentDir, previousDir)) / 22.5)) - 1) * 1.1;
	
	var _prevOffY = feetOffY;
	feetOffY = lerp(feetOffY, feetOffYBase * lerp(1, .89, power(currentSpeed * .75, 1.5)), .025) - min(sqrt((_speedChange + _dirChange) * 5) * 1.2, feetOffYBase * .2);
	y -= feetOffY - _prevOffY;
	feetY = y + feetOffY * .7;
	spineMain.x = x;
	spineMain.y = feetY;
	spineMain.height = feetOffY; // spine represents center here, but with feet height center is not at feet, obviously
	
	var _spineX = spineMain.x;
	var _spineY = spineMain.y; // get which spine to use maybe? That would do the proper multiple spines to use functionality...
	
	//moveSpeed += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * .001; // delete this
	#endregion
	
	#region NEW LEG STUFF
	
	stepUpdateDist = max(stepUpdateDistBase * sqrt(currentSpeed) * 1.1, 19);
	
	//animation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% (basic overall positioning, then calculating step positions and goals and moving the legs, then calculating the animations based on the positions)
	
	hipDir = point_direction(0, 0, xChange, yChange);
	
	var _legCount = array_length(stepTimings); //TODO proxy for leg count, should always line up  (get all limbs and iterate with a check for (if leg) and use that index
	
	var _allFeetOnGround = true; // DO PROGRESS SETTING
	for(var _legI = 0; _legI < _legCount; _legI++) { // check leg progresses to allow or disallow new steps in legs
		var _limbNodes = legArray[_legI];
		var _stepTiming = stepTimings[_legI];
		var _stepGoal = stepPositionsGoal[_legI];
		var _stepDuration = _stepTiming[E_step.endTime] - _stepTiming[E_step.startTime];
		_stepTiming[E_step.progress] = clamp((current_time - _stepTiming[E_step.startTime]) / (_stepDuration), 0, 1);
		if(_stepTiming[E_step.progress] < 1) { // still in the air, then add momentum to goal as well as body, this keeps feet aligned with object movement without having to predict some crazy future point
			_stepGoal[0] += xChange;
			_stepGoal[1] += yChange; // add height?
		}
		if(_allFeetOnGround && _stepTiming[E_step.progress] < 1) {
			
			#region containing step goals within reasonable range AND bringing in step goals when slowing down
			var _hip = _limbNodes[0]; // first node of limb (array that contains data about it)
			var _stepDist = point_distance(_hip[0], _hip[1], _stepGoal[0], _stepGoal[1]);
			if(_stepDist > stepUpdateDist) {
				var _distOverMultiply = stepUpdateDist / (_stepDist + 1);
				
				_stepTiming[E_step.endTime] = lerp(_stepTiming[E_step.endTime], _stepTiming[E_step.startTime], 1 - _distOverMultiply); // reduce time for step along with distance, basically, drop your foot sooner than planned if changing course
			
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
		
		var _progress = stepTimings[_legI][E_step.progress];
		
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
				script_mdlPlaceStepGoal(_legI, _stepCurrent[0], _stepCurrent[1], _stepPlacement[0], _stepPlacement[1], currentSpeed);
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
			script_mdlPlaceStepGoal(_maxDistLeg, _leg[2][0], _leg[2][1], _leg[0][0], _leg[0][1]);
		}
	}
	
	#region player control (aka move somewhere else and feed values)
	var _aimToFacingDifference = angle_difference(aimDir, directionFacing);
	gunHoldDirection = (directionFacing + clamp(_aimToFacingDifference, -gunAimRange, gunAimRange)) % 360; // limits aiming held range to facing direction plus aiming range 
	var _holdDistMult = 1;
	if(abs(_aimToFacingDifference) >= gunAimRange) { // if aiming outside of range
		gunHeldDown = 1; // dont aim the gun up if not possible to aim at a given target, meh.
		_holdDistMult = .5; // heldDown = less dist
	} else {
		gunHeldDown = 0; // aim normally
		
		_holdDistMult = .5 + min(aimDist / 220, 1.2);
	}
	#endregion
		
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
	
	if(burstSpread > .01) { // decay gun bloom, (inaccuracy with constant shots)
		burstSpread = burstSpread * .995 - .001;
	}
	
	if(aimDir > 90 && aimDir < 270) { // looking at the pointed at position with head
		head.fixedDrawAngle = 180 + (angle_difference(aimDir, 180) * .5) * abs(dcos(aimDir)); // requires "target"
		head.yscale = -1 * abs(head.yscale);
	} else {
		head.fixedDrawAngle = (angle_difference(aimDir, 0) * .5) * abs(dcos(aimDir));
		head.yscale = abs(head.yscale);
	}
}


function script_mdlDraw() {
	//draw_text(x, y - 100, weaponPosition[2]);
	
	//spine nonsense find a better place for this..
	var _leanAheadX = xChange * 8; // keep consistent i suppose
	var _leanAheadY = clamp(yChange, 0, 99) * 8; // keep consistent i suppose
	var _leanAheadDir = point_direction(0, 0, xChange * 9, -spineMain.length + yChange); // the 30 here is the distance of the spine while standing straight up i guess? Needs to be standarized and set up proper
	spineMain.angle = _leanAheadDir;
	
	var _spineX = spineMain.x;
	var _spineY = spineMain.y; // setting spine locals
	
	//draw_set_alpha(.75);
	//draw_circle_color(_spineX + _leanAheadX, _spineY, 16, #333333, #333333, false); // shadow! Remove when you have a better way!
	//draw_set_alpha(1);
	
	var _mdlSurf = script_mdlGetSurf(); // the surface you draw to
	var _surfMidX = mdlSurfWidth / 2;
	var _surfMidY = mdlSurfHeight / 2;
	
	surface_set_target(_mdlSurf);
	
	draw_clear_alpha(c_white, 0);
	
	#region bunch of things for general positioning, needs to be established first
	//var _dirMoving = point_direction(x, y, mouse_x, mouse_y);
	var _dirMoving = mouse_check_button(mb_right) ? point_direction(x, y, mouse_x, mouse_y) : point_direction(0, 0, xChange, yChange);
	directionFacing = _dirMoving;
	
	var _viewCompress = .5 + abs(dsin(directionFacing) / 2);
	var _speed = point_distance(0, 0, xChange, yChange);
	var _jostle = (dsin((stepTimings[0][E_step.progress] + stepTimings[1][E_step.progress]) * 180 * (1.5 + sqrt(_speed) / 3) - 90) + .4) * sqrt(_speed) * 1.4;
	#endregion
	
	#region draw gun
	var _heldDownAngleAdjust = 0;
	if(gunHeldDown) {
		_heldDownAngleAdjust = (angle_difference(270, gunHoldDirection) / 3); // set the holding down effect if out of aim range (when aiming away hold gun down to side)
		var _upAngleDiff = angle_difference(gunHoldDirection, 90);
		if(abs(_upAngleDiff) < 90) {
			_heldDownAngleAdjust *= clamp(abs(_upAngleDiff) - 45, 0, 45) / 45; // reduce adjust as it approaches upward hold angle because pushing an up gun towards down doesn't make any sense
		}
	}
	
	weaponPosition[0] += _leanAheadX;
	weaponPosition[1] += _leanAheadY + _jostle / 2; // position the gun with body movement variations
	
	if(gunDrawBehind) {
		script_drawWeapon(gunSprite, weaponPosition, gunHoldDirection, _heldDownAngleAdjust, _spineX - _surfMidX, _spineY - _surfMidY); // draw gun in front if supposed to be in front
	}
	
	#endregion
	
	#region draw legs and feet and body
	
	var _cosFacing = dcos(_dirMoving);
	var _sinFacing = dsin(_dirMoving);
	
	#endregion
	
	
	array_sort(bodyComponents, script_mdlSortComponents);
	
	var _counter = 0; 
	//draw the components in front
	_counter += script_drawComponents(0, _leanAheadX, _leanAheadY, _jostle, _cosFacing, _dirMoving, true);
	
	
	//draw the rest of the body components in front of body
	_counter += script_drawComponents(_counter, _leanAheadX, _leanAheadY, _jostle, _cosFacing, _dirMoving, false);
	
	if(!gunDrawBehind) {
		script_drawWeapon(gunSprite, weaponPosition, gunHoldDirection, _heldDownAngleAdjust, _spineX - _surfMidX, _spineY - _surfMidY); // draw gun behind if supposed to be behind
	}
	
	surface_reset_target();
	
	
	
	//var _ang = current_time / 10; 
	//var _dist = (_surfMidX) * 1.4142; // the radius of the surf is the sqrt((width/2^2) + (height/2^2)) not just width / 2 but also just paste in a real for sqrt(2) which is that number
	//draw_surface_ext(_surf, x + dcos(_ang + 135) * _dist, y - dsin(_ang + 135) * _dist, 1, 1, _ang, c_white, 1);
	draw_surface(_mdlSurf, _spineX - _surfMidX, _spineY - _surfMidY);
	
	//draw_text(x + 100, y, feetOffY)
	
	
	
	//draw_set_color(c_black);
	//draw_circle(spineMain.x, spineMain.y, stepUpdateDist, true);
	//draw_set_color(c_white);
	
	//draw_circle(spineMain.x, spineMain.y, 2, true)
	//draw_circle_color(x, y, 3, c_green, c_green, false)
	//draw_text(x + 170, y - 20, feetOffY)
	
	//draw_circle_color(stepPositionsGoal[0][0], stepPositionsGoal[0][1], 3, c_red, c_red, false);
	//draw_circle_color(stepPositionsGoal[1][0], stepPositionsGoal[1][1], 3, c_red, c_red, false);
	//
	//draw_circle_color(stepPositionsInitial[0][0], stepPositionsInitial[0][1], 3, c_dkgray, c_dkgray, false);
	//draw_circle_color(stepPositionsInitial[1][0], stepPositionsInitial[1][1], 3, c_dkgray, c_dkgray, false);
	
	//draw_line(x + 200, spineMain.y - spineMain.height * .65, x + 200, feetY);
	//draw_line_color(x + 180, y, x + 180, feetY, c_black, c_black);
	
	//draw_line(x + dcos(currentDir) * 10, y - dsin(currentDir) * 10, x, y);
	
	var _speedChange = sqr(abs(currentSpeed - previousSpeed) * 2);
	var _dirChange = sqrt(1 + (abs(currentDir - previousDir) / 22.5)) - 1;
	//
	//draw_line(x + 100, y, x + 100, y - 150 * (_speedChange + _dirChange));
	//draw_line(x + 130, y, x + 130, y - 150 * _dirChange);
	//draw_line(x + 160, y, x + 160, y - 150 * _speedChange);
}

function script_mdlDrawGUI() {
	draw_line(view_wport[0] * .88, 200, view_wport[0], 200);
	draw_line_width(view_wport[0] * .91, 200, view_wport[0] * .91, 200 - legArray[0][2][2], 5);
	draw_line_width(view_wport[0] * .92, 200, view_wport[0] * .92, 200 - legArray[0][1][2], 5);
	draw_line_width(view_wport[0] * .93, 200, view_wport[0] * .93, 200 - legArray[0][0][2], 5);
	draw_line_width(view_wport[0] * .96, 200, view_wport[0] * .96, 200 - legArray[1][2][2], 5);
	draw_line_width(view_wport[0] * .97, 200, view_wport[0] * .97, 200 - legArray[1][1][2], 5);
	draw_line_width(view_wport[0] * .98, 200, view_wport[0] * .98, 200 - legArray[1][0][2], 5);
	draw_text(view_wport[0] * .875, 200, "foot-knee-hip");
	draw_text(view_wport[0] * .89, 215, "Left");
	draw_text(view_wport[0] * .94, 215, "Right");
	draw_text(view_wport[0] * .89, 232, "Step height");
	
	draw_line_width(view_wport[0] * .92, 300, view_wport[0] * .92 + dcos(kneeAnglesDebug[0]) * 30, 300 - dsin(kneeAnglesDebug[0]) * 30, 3);
	draw_line_width(view_wport[0] * .96, 300, view_wport[0] * .96 + dcos(kneeAnglesDebug[1]) * 30, 300 - dsin(kneeAnglesDebug[1]) * 30, 3);
	
	var _vars = [stepUpdateDist, stepUpdateDistBase, stepTimings, legArray, debugClamp, debugPushAhead, debugOverStep];
	var _varNames = ["stepUpdateDist", "stepUpdateDistBase", "stepTimes", "legArray", "debugClamp", "debugPushAhead", "debugOverStep"];
	
	var _x = 100;
	var _y = 50;
	var _spacing = 25;
	
	var _varCount = array_length(_vars);
	for(var _i = 0; _i < _varCount; _i++) {
		draw_set_halign(fa_right);
		draw_text_transformed(_x - 10, _y + _i * _spacing, _varNames[_i], .7, .7, 0);
		draw_set_halign(fa_left);
		draw_text_transformed(_x + 10, _y + _i * _spacing, _vars[_i], .7, .7, 0);
	}
}