// MDL (model) scripts, prefeixed with script_mdl (local scope to mdl instances)

function script_mdlGetSurf() {
	if(!surface_exists(mdlSurf)) {
		mdlSurf = surface_create(mdlSurfWidth, mdlSurfHeight); // recreate if lost (no need to buffer store this since it's updating every frame anyway, (i think? Perhaps certain effects cause problems and need a more direct solution, doubt it though)
	}
	
	return mdlSurf;
}

function script_mdlPlaceStepGoal(legIndex, currentX, currentY, goalX, goalY, moveSpeed = -1) { // goal here is the desired place to step to below the creature, not the ultimate target (with this goal added to prediction dist)
	//live_auto_call
	var _goalPos = stepPositionsGoal[legIndex]; // this goal IS the actual step goal used to place the foot
	var _previousStepPos = stepPositionsInitial[legIndex]; // this goal IS the actual step goal used to place the foot
	var _leg = legArray[legIndex];
	if(moveSpeed == -1) {
		moveSpeed = point_distance(0, 0, xChange, yChange);
	}
	
	_previousStepPos[0] = _goalPos[0];
	_previousStepPos[1] = _goalPos[1];
	
	
	
	_goalPos[0] = _leg[0][0] + clamp((goalX - currentX) * debugOverStep, -legSegLen * debugClamp, legSegLen * debugClamp) + xChange * legSegLen * debugPushAhead; // this takes into acount the dist from previous step, the leg length, the duration of the step, add more for accuracy perhaps
	_goalPos[1] = _leg[0][1] + clamp((goalY - currentY) * debugOverStep, -legSegLen * debugClamp, legSegLen * debugClamp) + yChange * legSegLen * debugPushAhead;
	
	var _stepAhead = point_distance(_leg[0][0], _leg[0][1], _goalPos[0], _goalPos[1]);
	//msg(point_distance(currentX, currentY, _goalPos[0], _goalPos[0]));
	
	var _stepTime = (_stepAhead + 3) / (moveSpeed + .1) * (game_get_speed(gamespeed_microseconds) / 1000) * 2; // how many frames to reach this point (as the body/center) should put the foot at the end of it's step (in real life steps cross from behind and in front then pause for half the time, thus the step is 2x as fast or more than the body since it's only moving half the time) 
	
	//msg("stepDuration: " + string(_stepTime));
	
	script_mdlSetStepTimings(legIndex, _stepTime, moveSpeed);
}

function script_mdlSetStepTimings(legIndex, duration, speedRef) {
	var _timeInfo = stepTimings[legIndex];
	_timeInfo[3] = speedRef;
	_timeInfo[2] = current_time + duration; // step end time
	_timeInfo[1] = current_time; // current time duh
	_timeInfo[0] = 0; // step (expected!) progress set (starts at 0)
	
	//msg("step timing sets: " + string(duration));
}

function script_mdlResetSkeleton() { // the reason this is all set existing instead of just array copy or something is because we don't want to break the pointers to the arrays! There are other ways to do this of course but this works for now
	live_auto_call
		
	msg("HELLO RESETTING SKELETON")
	
	stumbleXChange = 0;
	stumbleYChange = 0;
	stumbleX = 0;
	stumbleY = 0;
	
	var _limbArr = 0;
	var _segArr = 0;
	for(var _limb = array_length(legArray) - 1; _limb >= 0; _limb--) { // legs...
		//_limbArr = legArray[_limb];
		//
		//for(var _node = 0; _node < 3; _node++) {
			//_segArr = _limbArr[0];
			//
			//_segArr[0] = x;
			//_segArr[1] = y;
			//_segArr[2] = .5 * _node * feetOffY; // height is 0..? should be 0, .5, 1, * height no?
		//}
		
		var _timings = stepTimings[_limb];
		_timings[0] = 0;
		_timings[1] = current_time;
		_timings[2] = current_time;
		_timings[3] = 0;
		
		//var _stepPosInit = stepPositionsInitial[_limb];
		//_stepPosInit[0] = x;
		//_stepPosInit[1] = y + feetOffY * .8;
		//_stepPosInit[2] = 0;
		
		var _stepPosGoal = stepPositionsGoal[_limb];
		_stepPosGoal[0] = x;
		_stepPosGoal[1] = y + feetOffY * .8;
		_stepPosGoal[2] = 0;
	}
	
	for(var _limb = array_length(limbArray) - 1; _limb >= 0; _limb--) { // arms
		_limbArr = limbArray[_limb];
		
		for(var _node = 0; _node < 3; _node++) {
			_segArr = _limbArr[0];
			
			_segArr[0] = x;
			_segArr[1] = y;
			_segArr[2] = 0; // height is 0..? should be 0, .5, 1, * height no?
		}
	}
}

script_mdlRagdoll = function(duration = 212) {
	recoveringLimpTimer = max(duration, recoveringLimpTimer);
	if(!ragdolling) {
		//turn torso rotation, arms elbow, hands, leg joint, and feet into points with their own x/y change. This x/y change would be the x/y and the hitbox would be recentered on the torso x/y as to avoid disconnects for big ragdolls. 
		
		//"height"change representing the vertical speed up and down the map, basically if you fly back or towards the camera your ground y value will increase or decrease as you travel and be clipped when you hit the ground, we're faking lateral movement to do horiztonal and height in the air movement with the x/y change values
		//show_debug_message($"left shin values adding {jointLX}, {jointRX}, {footLX}, {footRY}");
	
		#region unused until ragdoll speed vars for joints... This is seeming like a worse and worse idea but at the same time I know this must be a thing because the joints need speeds so... Ugh
		
		var _leg = 0;
		var _legPrev = 0;
		var _nodesSpeed = 0;
		var _nodeSpeeds = 0;
		var _nodePos = 0;
		var _nodePosPrev = 0;
		for(var _i = array_length(legArray) - 1; _i >= 0; _i--) {
			_leg = legArray[_i];
			_legPrev = legArrayPrev[_i];
			_nodesSpeed = ragdollLegNodesSpeed[_i];
			
			for(var _nodeI = array_length(_leg) - 1; _nodeI >= 0; _nodeI--) {
				_nodeSpeeds = _nodesSpeed[_nodeI];
				_nodePos = _leg[_nodeI];
				_nodePosPrev = _legPrev[_nodeI];
				
				_nodeSpeeds[0] = _nodePos[0] - _nodePosPrev[0];
				_nodeSpeeds[1] = _nodePos[1] - _nodePosPrev[1];
				_nodeSpeeds[2] = _nodePos[2] - _nodePosPrev[2];
			}
		}
		
		xChange = spineMain.x - spineMain.xPrev;
		yChange = spineMain.y - spineMain.yPrev;
		zChange = spineMain.height - spineMain.zPrev;
		
		x = spineMain.x;
		y = spineMain.y; // hips are projected during standing and not during rd so match them up during ragdolling
		z = spineMain.height;
		#endregion
		
		ragdolling = true;
	}
}

function script_mdlRagdollStopMotion() {
	stumbleX = 0;
	stumbleY = 0; // not sure we even need this stuff (stuble vs ragdoll?) but it may keep lingering stuble strength from going into the next get up
	stumbleXChange = 0;
	stumbleYChange = 0;
	
	var _leg = 0;
	var _nodeSpeed = 0;
	for(var _legI = array_length(ragdollLegNodesSpeed) - 1; _legI >= 0; _legI--) {
		_leg = ragdollLegNodesSpeed[_legI];
		for(var _nodeI = array_length(_leg) - 1; _nodeI >= 0; _nodeI--) {
			_nodeSpeed = _leg[_nodeI];
			_nodeSpeed[0] = 0;
			_nodeSpeed[1] = 0;
			_nodeSpeed[2] = 0;
		}
	}
	
	xChange = 0;
	yChange = 0;
	zChange = 0;
}

function script_mdlSortComponents(componentCurrent, componentNext) {
	var _sortDif = (-dsin(directionFacing + componentCurrent.rotationRelative) * componentCurrent.distance) - (-dsin(directionFacing + componentNext.rotationRelative) * componentNext.distance) * 1;
		
	if(abs(_sortDif) > 1) {
		return _sortDif;
	}
		
	return componentCurrent.index - componentNext.index;
		
	//if(is_array(elementCurrent[0])) {
	//	return elementCurrent[11][2][1] - (-dsin(directionFacing + elementNext[2]) * elementNext[4]); // the 11-2-1 is the y value of the 3rd node of the limb ( [11] )  ( limb component! )
	//} else {
	//	return (-dsin(directionFacing + elementCurrent[2]) * elementCurrent[4]) - (-dsin(directionFacing + elementNext[2]) * elementNext[4]); // normal component
	//}  // (sorting to the end the limb, instead of start (looks bad!)
}