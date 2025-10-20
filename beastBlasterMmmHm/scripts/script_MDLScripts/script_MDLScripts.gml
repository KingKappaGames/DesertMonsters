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
	
	var _stepTime = (_stepAhead + 3) / (moveSpeed + .05) * (game_get_speed(gamespeed_microseconds) / 1000) * 2; // how many frames to reach this point (as the body/center) should put the foot at the end of it's step (in real life steps cross from behind and in front then pause for half the time, thus the step is 2x as fast or more than the body since it's only moving half the time) 
	
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