if (live_call()) return live_result;

#region prevVars for speed deduction (before inherited runs and adds xChange, yChange
prevFootLX = footLX;
prevFootLY = footLY;
prevFootRX = footRX;
prevFootRY = footRY;
prevJointLX = jointLX; // while ragdolling record previous's for the sake of setting speeds based on displacement
prevJointLY = jointLY;
prevJointRX = jointRX;
prevJointRY = jointRY;
prevHipsX = hipsX;
prevHipsY = hipsY;
#endregion

event_inherited();

if(irandom(12000) == 0) {
	audio_play_sound_at(choose(snd_FaintIntervalShooting, snd_SoftExplosionSemiDistant, snd_EchoedDistantBurstFire, snd_SoftMachineFire), x, y, 0, 500, 1500, 1, 0, 0);
}

if(alive == 1 && !ragdolling) {
	if(irandom(30) == 0 && (xChange != 0 || yChange != 0)) {
		if(point_distance(x, y, travelToGoalX, travelToGoalY) < 20) {
			xChange = 0;
			yChange = 0;
		} else if(irandom(360) == 0) {
			startTravelToPoint(travelToGoalX, travelToGoalY); // reset direction and seeking because I don't calculate corrections to path otherwise
		}
	} else if(irandom(300) == 0) {
		startTravelToPoint(x + choose(irandom_range(-1000, -200), irandom_range(200, 1000)), y + choose(irandom_range(-800, -200), irandom_range(200, 800)))
	}
}

#region leg stuff!!
if(alive == 1 && !ragdolling) {	// alive stuff
	#region place legs and feet
	var _leanAheadX = xChange * 9; // keep consistent i suppose
	var _leanAheadY = clamp(yChange, 0, 99) * 9; // keep consistent i suppose

	hipsX = x + _leanAheadX + hipStumbleX;
	hipsY = y + hipYBob + _leanAheadY + hipStumbleY;

	//var _dirMoving = point_direction(x, y, mouse_x, mouse_y);
	var _dirMoving = point_direction(0, 0, xChange, yChange);
	directionFacing = _dirMoving;

	var _cosFacing = dcos(_dirMoving);
	var _sinFacing = dsin(_dirMoving);

	#region set initial hip left and right positions
	hipLX = hipsX - _sinFacing * hipWidth;
	hipLY = hipsY - _cosFacing * hipWidth;
	hipRX = hipsX + _sinFacing * hipWidth;
	hipRY = hipsY + _cosFacing * hipWidth;
	#endregion

	#region get distances and directions for both feet from hip
	var _distLFoot = point_distance(hipLX, hipLY, footLX, footLY); // dist
	var _distRFoot = point_distance(hipRX, hipRY, footRX, footRY);
	var _dirLFoot = point_direction(hipLX, hipLY, footLX, footLY); // dir
	var _dirRFoot = point_direction(hipRX, hipRY, footRX, footRY);
	#endregion

	#region clamp the foot distance to leg length to create rounded extensions, more of a fix or QA check than a feature but does create mild angled foot movements too
	if(_distLFoot > legSegLen * 2) {
		footLX = hipLX + dcos(_dirLFoot) * legSegLen * 2; // left
		footLY = hipLY - dsin(_dirLFoot) * legSegLen * 2; 
		_distLFoot = legSegLen * 2;
	}
	if(_distRFoot > legSegLen * 2) {
		footRX = hipRX + dcos(_dirRFoot) * legSegLen * 2; // right
		footRY = hipRY - dsin(_dirRFoot) * legSegLen * 2;
		_distRFoot = legSegLen * 2;
	}
	#endregion

	#region getting joint positions from trig distances
	var _footLJointDist = sqrt(abs(sqr(legSegLen) - sqr(_distLFoot / 2))); // outwardness of joint
	var _footRJointDist = sqrt(abs(sqr(legSegLen) - sqr(_distRFoot / 2))); // abs does nothing here in theory but if you ever get a negative number (which again you shouldn't but hey) it'll make it positive. Presumably this negative number would be tiny and the difference would be unnoticable. Ergo abs is the easiest way to prevent the negative besides clamp with is ugly

	var _legMidLX = hipLX + (footLX - hipLX) / 2;
	var _legMidLY = hipLY + (footLY - hipLY) / 2; // visual mid point simply between hip and foot
	var _legMidRX = hipRX + (footRX - hipRX) / 2;
	var _legMidRY = hipRY + (footRY - hipRY) / 2;

	jointLX = _legMidLX + dcos(_dirLFoot + 90) * _cosFacing * _footLJointDist;
	jointLY = _legMidLY + dsin(_dirLFoot + 90) * -sign(_cosFacing) * _footLJointDist; // final joint positions
	jointRX = _legMidRX + dcos(_dirRFoot + 90) * _cosFacing * _footRJointDist; 
	jointRY = _legMidRY + dsin(_dirRFoot + 90) * -sign(_cosFacing) * _footRJointDist;
	#endregion

	#endregion
	
	var _speed = point_distance(0, 0, xChange, yChange);
	var _stumbleDist = power(point_distance(0, 0, hipStumbleX, hipStumbleY) / 10, 1.5) / 5;

	legRotationSpeed = 4.8 * clamp(sqrt(_speed / 2), .17, .85); //proportional to speed
	legRotation = (legRotation + legRotationSpeed) % 360;

	hipYBob = lerp(hipYBob, clamp((-1 + _speed) * 7.5, -7.5, 0) + clamp((dsin(legRotation * (1.5 + sqrt(_speed) / 3) - 90) + .4) * _speed, -3, 15), .03);
	#region placing stumble offset
	if(hipStumbleXChange != 0 || hipStumbleYChange != 0 || hipStumbleX != 0 || hipStumbleY != 0) {
		hipStumbleXChange = hipStumbleXChange * hipStumbleDecay + ((dcos(point_direction(hipStumbleX, hipStumbleY, 0, 0))) * _stumbleDist) / 20; // 20 switch with strength of righting, so standing out of stuns this would lower but getting pushed down this would be high as you're fighting to get back up
		hipStumbleYChange = hipStumbleYChange * hipStumbleDecay - ((dsin(point_direction(hipStumbleX, hipStumbleY, 0, 0))) * _stumbleDist) / 20;
		hipStumbleX += hipStumbleXChange;
		hipStumbleY += hipStumbleYChange + abs(hipStumbleXChange);
	
		if(abs(hipStumbleXChange) + abs(hipStumbleYChange) < .04) { // cancel out stumbling when low to clear useless code
			hipStumbleXChange = 0;
			hipStumbleYChange = 0;
		}
	}
	#endregion
	
	placeFeetFull(point_direction(0, 0, xChange, yChange), _speed);
	
	#region this checks whether it should fall over due to forces, needs to be in not ragdoll code because otherwise it'll keep going! How do i know...
	var _stumbleMag = point_distance(0, 0, hipStumbleX, hipStumbleY); // double conderation for vertical i guess
	if(_stumbleMag > 25) {
		ragdollEnemy(72 * ceil(sqrt(_stumbleMag)));
	}
	#endregion
} 
else if(recoveringLimpTimer > 0 || alive == 0) { // ragdolling stuff	
	recoveringLimpTimer--;
	if(recoveringLimpTimer == 0) { // fixing their bodies for standing up
		if(alive == 0) {
			//dead but recovered... despawn, draw to debris, stay dead but don't move? IDK
		} else {
			footLXChange = 0;
			footLYChange = 0;
			footRXChange = 0;
			footRYChange = 0;
			
			hipStumbleXChange = 0; // resetting all the dynamic things so that they can begin standing
			hipStumbleYChange = 0;
			jointLXChange = 0;
			jointLYChange = 0;
			
			jointRXChange = 0;
			jointRYChange = 0
			xChange = 0;
			yChange = 0;
			
			airHeight = 0;
			
			recoveringStandingTimer = 288;
		}
	}
	var _dirMoving = point_direction(0, 0, xChange, yChange);
	//directionFacing = _dirMoving;
	var _cosFacing = dcos(_dirMoving);
	var _sinFacing = dsin(_dirMoving);
	
	hipsX = x;
	hipsY = y;
	
	#region set initial hip left and right positions
	hipLX = hipsX - _sinFacing * hipWidth;
	hipLY = hipsY - _cosFacing * hipWidth;
	hipRX = hipsX + _sinFacing * hipWidth;
	hipRY = hipsY + _cosFacing * hipWidth;
	#endregion
	
	#region moving with speed and adding gravity
	footLYChange += fallGravity;
	footRYChange += fallGravity;
	jointLYChange += fallGravity;
	jointRYChange += fallGravity;
	yChange += fallGravity;
	
	footLX += footLXChange; 
	footLY += footLYChange; 
	footRX += footRXChange; 
	footRY += footRYChange; 
	jointLX += jointLXChange;
	jointLY += jointLYChange;
	jointRX += jointRXChange;
	jointRY += jointRYChange;
	#endregion
	
	#region ground contact for each of the five points in legs
	if(footRY > groundHeight) { // cut all speeds for that piece, all of them
		//show_debug_message("Right foot on ground");
		footRY = groundHeight;
		footRYChange *= -.5;
		footRXChange *= .7;
	}
	if(footLY > groundHeight) { // cut all speeds for that piece, all of them
		//show_debug_message("Left foot on ground");
		footLY = groundHeight;
		footLYChange *= -.5;
		footLXChange *= .7;
	}
	if(jointLY > groundHeight) { // cut all speeds for that piece, all of them
		//show_debug_message("Left joint on ground");
		jointLY = groundHeight;
		jointLYChange *= -.5;
		jointLXChange *= .7;
	}
	if(jointRY > groundHeight) { // cut all speeds for that piece, all of them
		//show_debug_message("Right joint on ground");
		jointRY = groundHeight;
		jointRYChange *= -.5;
		jointRXChange *= .7;
	}
	if(y > groundHeight) { // cut all speeds for that piece, all of them
		//show_debug_message("torso on ground");
		y = groundHeight;
		yChange *= -.5;
		xChange *= .7;
	}
	#endregion
	
	#region connecting the five points (distance wise) (4 checks, hip pulls knees in, then knees pull feet
	var _leftThighDist = point_distance(hipLX, hipLY, jointLX, jointLY);
	if(_leftThighDist > legSegLen) {
		var _dir = point_direction(hipLX, hipLY, jointLX, jointLY);
		jointLX = lerp(jointLX, hipLX, (1 - (1 / (_leftThighDist / legSegLen))) * .8); // it's ticking back and forth between like 80% up the thigh of one leg then 80% up the thigh of the other and not doing a lot else net
		jointLY = lerp(jointLY, hipLY, (1 - (1 / (_leftThighDist / legSegLen))) * .8);
		x -= hipLX - jointLX;
		y -= hipLY - jointLY;
	}
	var _rightThighDist = point_distance(hipRX, hipRY, jointRX, jointRY);
	if(_rightThighDist > legSegLen) {
		var _dir = point_direction(hipRX, hipRY, jointRX, jointRY);
		jointRX = lerp(jointRX, hipRX, (1 - (1 / (_rightThighDist / legSegLen))) * .8);
		jointRY = lerp(jointRY, hipRY, (1 - (1 / (_rightThighDist / legSegLen))) * .8);
		x -= hipRX - jointRX;
		y -= hipRY - jointRY;
	}
	var _distLShin = (point_distance(jointLX, jointLY, footLX, footLY) / legSegLen) - 1; // extension over max 0
	if(_distLShin > 0) {
		//show_debug_message($"dist running left shin {_distLShin}");
		//show_debug_message($"left shin values main {jointLX}, {jointRX}, {footLX}, {footRY}");
		footLX = lerp(footLX, jointLX, _distLShin / 2);
		jointLX = lerp(jointLX, footLX, _distLShin / 2);
		footLY = lerp(footLY, jointLY, _distLShin / 2);
		jointLY = lerp(jointLY, footLY, _distLShin / 2);
		
		jointLXChange *= .5;
		footLXChange  *= .5;
		jointLYChange *= .5;
		footLYChange  *= .5;
	}
	var _distRShin = (point_distance(jointRX, jointRY, footRX, footRY) / legSegLen) - 1; // extension over max 0
	if(_distRShin > 0) {
		//show_debug_message($"dist running right shin {_distRShin}");
		footRX = lerp(footRX, jointRX, _distRShin / 2);
		jointRX = lerp(jointRX, footRX, _distRShin / 2);
		footRY = lerp(footRY, jointRY, _distRShin / 2);
		jointRY = lerp(jointRY, footRY, _distRShin / 2);
		
		jointRXChange *= .5;
		footRXChange  *= .5;
		jointRYChange *= .5;
		footRYChange  *= .5;
	}
	#endregion
	
	#region set momentums for joints
	footLXChange =  (footLX - prevFootLX)   * .2;
	footLYChange =  (footLY - prevFootLY)   * .2;
	footRXChange =  (footRX - prevFootRX)   * .2;
	footRYChange =  (footRY - prevFootRY)   * .2;
	jointLXChange = (jointLX - prevJointLX) * .2; // simple as yeah?
	jointLYChange = (jointLY - prevJointLY) * .2;
	jointRXChange = (jointRX - prevJointRX) * .2;
	jointRYChange = (jointRY - prevJointRY) * .2;
	xChange =       (hipsX - prevHipsX)     * .2;
	yChange =       (hipsY - prevHipsY)     * .2;
	#endregion
} 
else if(recoveringStandingTimer > 0) { // standing up
	var _progress = (1 - (recoveringStandingTimer / 288)) / 60;
	
	y -= .33;
	
	footLX = lerp(footLX, x - 5, _progress);
	footLY = lerp(footLY, y + 70, _progress);
	footRX = lerp(footRX, x + 5, _progress);
	footRY = lerp(footRY, y + 70, _progress);
	
	jointLX = lerp(jointLX, x - 5, _progress);
	jointLY = lerp(jointLY, y + 32, _progress);
	jointRX = lerp(jointRX, x + 5, _progress); // semi arbitrary alligning goal skeleton with example skeleton of standing lad, not a precise science
	jointRY = lerp(jointRY, y + 32, _progress);
	
	hipsX = lerp(hipsX, x, _progress);
	hipsY = lerp(hipsY, y, _progress);
	
	hipStumbleX = lerp(hipStumbleX, 0, _progress);
	hipStumbleY = lerp(hipStumbleY, 0, _progress);
	hipYBob = lerp(hipYBob, -3, _progress);
	
	var _facingSin = dsin(directionFacing);
	var _facingCos = dcos(directionFacing);
	
	hipLX = hipsX - 5;
	hipLY = hipsY;
	hipRX = hipsX + 5;
	hipRY = hipsY;
	
	recoveringStandingTimer--;
	if(recoveringStandingTimer <= 0) {
		prevFootLX = footLX;
		prevFootLY = footLY;
		prevFootRX = footRX;
		prevFootRY = footRY;
		
		prevJointLX = jointLX;
		prevJointLY = jointLY; // allign "previous" with current for fresh start
		prevJointRX = jointRX;
		prevJointRY = jointRY;
		prevHipsX = hipsX;
		prevHipsY = hipsY;
		
		recoveringLimpTimer = 0;
		ragdolling = 0; // unset ragdolling and hopefully you will be good to start running around again
	}
}
#endregion

if(mouse_check_button_pressed(mb_left)) {
	clickLogicDebug();
} else if(mouse_check_button(mb_left)) {
	clickHoldLogicDebug();
}

if(keyboard_check_pressed(vk_home)) {
	game_set_speed(4, gamespeed_fps);
}