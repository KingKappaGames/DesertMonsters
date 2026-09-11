function script_mdlCreateInit() {
	bodySprite = spr_bodyVultureCoat;
	bodyComponents = [];
	bodyComponentNextIndex = 0;
	
	directionFacing = 0;
	aimingDownSights = false;
	
	focusX = 0;
	focusY = 0;
	
	aimDir = 0;
	aimDist = 0;
	
	z = 0;
	zprevious = z;
	
	xChange = 0;
	yChange = 0;
	zChange = 0;
	
	feetOffYBase = 74;
	feetOffY = feetOffYBase;
	feetOffX = 0; //??
	feetY = y + feetOffY;
	
	spineMain = new script_createSpine(x, y, 50, 0, 90);
	
	legSegLen = 32;
	hipDir = 0;
	
	alive = true;
	
	ragdolling = false;
	recoveringStandingTimer = 0;
	recoveringLimpTimer = 0; // if dead then despawn or draw to surface when this expires other wise switch to standing behavior
	ragdollGravity = -.08; // adds speed to bob y when dead or rag dolling to give collapsing
	
	stumbleXChange = 0;
	stumbleYChange = 0;
	stumbleX = 0;
	stumbleY = 0;
	stumbleDecay = .97;
	
	mdlSurfWidth = 256;
	mdlSurfHeight = 256;
	mdlSurf = -1; // draw all your components to this surf and draw the surf to the screen (for shader and effect simplicity)
	
	stepUpdateDistBase = 36;
	stepUpdateDist = stepUpdateDistBase;
	
	#region NEW LEG STUFF, set up component functions and arrays for reference
	legSegLen = 32;

	stepUpdateDistBase = 35;
	stepUpdateDist = stepUpdateDistBase;
	
	legArray = [  [[x, y, 0, legSegLen, true], [x, y, 0, legSegLen, true], [x, y, 0, legSegLen, true]], [[x, y, 0, legSegLen, true], [x, y, 0, legSegLen, true], [x, y, 0, legSegLen, true]]]; // 2 LEGS for now in nested structure, legs, nodes, coords (+ length, width) in that nesting E_legInfo
	legArrayPrev = [];
	stepPositionsInitial = [ [x, y, 0], [x, y, 0] ]; // coords for each foot landed or come from during a step (aka 2 [x,y,z] for humans)
	stepPositionsGoal = [ [x, y, 0], [x, y, 0] ]; // coords for each foot to land at or go to during a step (aka 2 [x,y,z] for humans)
	
	stepTimings = [[0, current_time, current_time, 0], [0, current_time, current_time, 0]]; //[progress(updated by step), startTime, endTime, speedRef] (where speed reference is the speed that the thing was moving for that step to compare against for clipping a step on speed up or extending a step in slow down.
	
	ragdollLegNodesSpeed = [  [[0, 0, 0], [0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0], [0, 0, 0]] ]; // xyz speed in each node of each leg...
	
	thighWidth = 20;
	shinWidth = 10; // reset down below for size of animal
	
	debugClamp = .09;
	debugOverStep = .1;
	debugPushAhead = .68;
	
	#endregion
	
	kneeAnglesDebug = [0, 0]; // debug!
	
	#region weapon holding (the model animation parts of gun logic..)
	holdingWeapon = true;

	gunSprite = spr_pistol;
	weaponPosition = [x, y, feetOffY]; // use arrays (structs??) to store positions both for simplicty (i guess?) but more importantly for reference passing, being able to give the component system the item 
	weaponHoldOffsetss = [[0, 0, 0], [0, 0, 0]]; // the sub arrays here are hand locations relative to the x/y of the gun (must be rotated and scaled if applicable)
	gunHoldDistance = 30;
	weaponHoldDirection = 0;
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
	live_auto_call
	
	zprevious = z;
	
	with(spineMain) {
		xPrev = x;
		yPrev = y;
		zPrev = z;
	}
	
	legArrayPrev = variable_clone(legArray);
	
	if(!ragdolling) {
	
		var _speedChange = sqr(abs(currentSpeed - previousSpeed) * 5);
		var _dirChange = (sqrt(1 + (abs(angle_difference(currentDir, previousDir)) / 22.5)) - 1) * 1.1;
		
		stumbleX += stumbleXChange;
		stumbleY += stumbleYChange;
		stumbleXChange -= stumbleX * .004;
		stumbleYChange -= stumbleY * .004;
		stumbleXChange *= stumbleDecay;
		stumbleYChange *= stumbleDecay;
		
		if(point_distance(0, 0, stumbleX, stumbleY) > 50) {
			audio_play_sound(snd_BasicShotWeak, 0, 0);
			
		}
		
		var _prevOffY = feetOffY;
		feetOffY = lerp(feetOffY, feetOffYBase * lerp(1, .89, power(currentSpeed * .75, 1.5)), .015) - min(sqrt((_speedChange + _dirChange) * 5) * 1.25, feetOffYBase * .2);
		y -= feetOffY - _prevOffY;
		feetY = y + feetOffY * .7;
		spineMain.x = x + stumbleX;
		spineMain.y = feetY + stumbleY;
		spineMain.z = feetOffY; // spine represents center here, but with feet height center is not at feet, obviously
		
		var _spineX = spineMain.x;
		var _spineY = spineMain.y; // get which spine to use maybe? That would do the proper multiple spines to use functionality...
		
		//moveSpeed += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * .001; // delete this
		#endregion
		
		#region NEW LEG STUFF
		
		stepUpdateDist = max(stepUpdateDistBase * sqrt(currentSpeed) * 1. * (1 - min(.01, _speedChange / 3/*maxSpeed*/) * 50.0), 14 - clamp(sqrt(_dirChange) * 50, 0.0, 14));
		
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
		var _maxFootDistFromNeutral = -1; // hold var
		var _maxDistLeg = -1;
		var _forceLegUpdates = []; // if legs are super out of position then ommit the one leg at a time rule and update multiple (this stores leg index for those that should be forced if not already updating)
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
			
			var _stepHeight = dsin(180 * _progress) * legSegLen * .9 * sqrt(clamp(currentSpeed / 1.6 - .3, 0, 1)); // TODO max speed comparison somehow
			
			_stepCurrent[2] = _stepHeight;
			_stepCurrent[0] = lerp(_stepInitial[0], _stepGoal[0], _progress); // move foot over range of movement according to time progress
			_stepCurrent[1] = lerp(_stepInitial[1], _stepGoal[1], _progress);
			
			 // there needs to be some way to deal with changing step lengths and repositions i think, for now just not stepping when already stepping works but has a bunch of issues
			var _stepPlacementDist = point_distance(_stepCurrent[0], _stepCurrent[1], _stepPlacement[0], _stepPlacement[1]); // add the height to the value but remove it when checking distance to step
			if(_maxFootDistFromNeutral < _stepPlacementDist) {
				_maxFootDistFromNeutral = _stepPlacementDist;
				_maxDistLeg = _legI;
			}
			if(_allFeetOnGround && _progress == 1 && _stepPlacementDist > stepUpdateDist) {
				script_mdlPlaceStepGoal(_legI, _stepCurrent[0], _stepCurrent[1], _stepPlacement[0], _stepPlacement[1], currentSpeed, _speedChange);
				_allFeetOnGround = false;
			} else if(_stepPlacementDist > legSegLen * 2.35) { // force update dist for really out of place limbs, maybe even trigger ragdolls if you screw it up enough?
				script_mdlPlaceStepGoal(_legI, _stepCurrent[0], _stepCurrent[1], _stepPlacement[0], _stepPlacement[1], currentSpeed, _speedChange); // super off legs don't trigger on ground bool, maybe?
			}
			
			#endregion
			
			var _footDist = point_distance_3d(_hip[0], _hip[1], _hip[2], _stepCurrent[0], _stepCurrent[1], _stepCurrent[2]);
			var _footDir = point_direction(_hip[0], _hip[1], _stepCurrent[0], _stepCurrent[1]);
		
			#region clamp the foot distance to leg length to create rounded extensions, more of a fix or QA check than a feature but does create mild angled foot movements too
			if(_footDist > legSegLen * 2.) {
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
		
		//if(_allFeetOnGround) {
			//if(_maxFootDistFromNeutral > legSegLen * 2.) {
				//var _leg = legArray[_maxDistLeg];
				//script_mdlPlaceStepGoal(_maxDistLeg, _leg[2][0], _leg[2][1], _leg[0][0], _leg[0][1]);
			//}
		//}
		
		#region player control (aka move somewhere else and feed values)
		var _aimToFacingDifference = angle_difference(aimDir, directionFacing);
		weaponHoldDirection = (directionFacing + clamp(_aimToFacingDifference, -gunAimRange, gunAimRange)) % 360; // limits aiming held range to facing direction plus aiming range 
		var _holdDistMult = 1;
		if(abs(_aimToFacingDifference) >= gunAimRange) { // if aiming outside of range
			gunHeldDown = 1; // dont aim the gun up if not possible to aim at a given target, meh.
			_holdDistMult = .5; // heldDown = less dist
		} else {
			gunHeldDown = 0; // aim normally
			
			_holdDistMult = .5 + min(aimDist / 220, 1.2);
		}
		#endregion
			
		weaponPosition[0] = _spineX + dcos(weaponHoldDirection) * gunHoldDistance * _holdDistMult + gunShakeX;
		weaponPosition[1] = _spineY - (dsin(weaponHoldDirection) * gunHoldDistance * _holdDistMult + gunShakeY) * .7; // lower and bring in gun when not holding up
		weaponPosition[2] = feetOffY - ((gunHeldDown * 6) + ((1 - gunHeldDown) * (22 - _holdDistMult * 22)));
		if(point_distance(_spineX, _spineY, weaponPosition[0], weaponPosition[1]) > legSegLen * 2) {
			weaponPosition[0] = _spineX + dcos(weaponHoldDirection) * 20;
			weaponPosition[1] = _spineY - dsin(weaponHoldDirection) * 20;
		}
		
		if(weaponHoldDirection > 0 && weaponHoldDirection < 180) {
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
	} else { // RAGDOLLING
		if(recoveringLimpTimer > 0) { // ragdolling stuff	
			recoveringLimpTimer--;
			if(recoveringLimpTimer == 0) { // fixing their bodies for standing up
				if(!alive) {
					//dead but recovered... despawn, draw to debris, stay dead but don't move? IDC
					instance_destroy();
				} else {
					script_mdlRagdollStopMotion();
					
					recoveringStandingTimer = 288;
				}
			}
			//var _dirMoving = point_direction(0, 0, xChange, yChange);
			//directionFacing = _dirMoving;
			//var _cosFacing = dcos(_dirMoving);
			//var _sinFacing = dsin(_dirMoving); // hip stuff that isn't workable right now
			
			#region moving with speed and adding gravity
			for(var _nodeSpeedsZ = array_length(ragdollLegNodesSpeed) - 1; _nodeSpeedsZ >= 0; _nodeSpeedsZ--) {
				var _leg = ragdollLegNodesSpeed[_nodeSpeedsZ];
				for(var _node = array_length(_leg) - 1; _node >= 0; _node--) {
					_leg[_node][2] += ragdollGravity;
				}
			}
			zChange += ragdollGravity;
			
			#region ground contact for each of the five points in legs (do inbetween adding speeds because otherwise this will get overridden by the change being used later. Prevent movement, don't fix what's already happened. You know the deal.)
			
			
			var _leg, _node, _legNodeSpeeds;
			for(var _legI = array_length(legArray) - 1; _legI >= 0; _legI--) {
				_leg = legArray[_legI];
				_legNodeSpeeds = ragdollLegNodesSpeed[_legI]; // does this currently grab the hip and knee speeds and not the knee and foot? I want severing to happen at the top of the segment but speeds are the ends... Hmm, idk if it's even broken tho TODO
				for(var _nodeI = 1; _nodeI < 3; _nodeI++) { // note that this loop is weird because feet don't need to be checked for existance atm (only hip and knee can be severed, keeping foot severing open as an option but not used currently)  (( also it's hard coded for 3 joint segments, idk if i'll ever expand this to have wacky limbs but it's simple if so)
					_node = _leg[_nodeI];
					
					if(!_leg[_nodeI - 1][E_legInfo.connected]) {
						break; // abandon rest of node calculations for this limb since an upstream node is missing (and thus all after...)
					} else {
						var _nodeSpeed = _legNodeSpeeds[_nodeI];
						if(_node[E_legInfo.z] + _nodeSpeed[2] < 0) { // z is ground height but since it is actually height 0 works fine, maybe switch to some kind of height mapped system in some crazy future case but for now nahh
							_node[E_legInfo.z] = 0.1; // clamp to floor
							_nodeSpeed[0] *= MDL_ragdollBounceFriction;
							_nodeSpeed[1] *= MDL_ragdollBounceFriction;
							_nodeSpeed[2] *= MDL_ragdollBounceStrength; // vertical component
						}
					
						_node[E_legInfo.x] += _nodeSpeed[0];
						_node[E_legInfo.y] += _nodeSpeed[1]; // with the node ahead of you pulling on next you are good to apply next nodes speed. This could also be sep out to it's own for loop but it's faster to leave it here until it needs to be sep
						_node[E_legInfo.z] += _nodeSpeed[2];
					}
				}
			}
			
			if(z + zChange < 0) { // cut all speeds for that piece, all of them
				z = 0;
				xChange *= MDL_ragdollBounceFriction;
				yChange *= MDL_ragdollBounceFriction;
				zChange *= MDL_ragdollBounceStrength;
			}
			
			x += xChange;
			y += yChange; // when ragdolling your xyz is the actual hip pos vs before xyz is standing pos and hip xyz are your hip pos.. duh
			z += zChange;
			
			weaponPosition[0] = x;
			weaponPosition[1] = y;
			weaponPosition[2] = z;
			#endregion
			
			#region set initial hip left and right positions (i think this might be handled by the draw components draw? Because it manually sets the hip positions to the component position on the spine there and uses the joint and extremity positions that are already there. So.. hips are already covered?
			//var _hipR = legArray[0][0];
			//var _hipL = legArray[1][0];
			//
			//_hipR[0] = x + lengthdir_x(directionFacing, directionFacing); // should probably use spine direction once exists..?
			//_hipR[1] = y + lengthdir_y(directionFacing, directionFacing); // this is not entirely correct! But i'm just placeholdering the hip rotation position setting because i'm not sure i want actual 3d position
			//_hipR[2] = z; // TODO i think these values are supposed to be setting the hip node position to the spines position, but the overall xyz becomes spine xyz when ragdolling so use xyz
			#endregion
			
			#region connecting the five points (distance wise) (4 checks, hip pulls knees in, then knees pull feet
			
			for(var _legI = array_length(legArray) - 1; _legI >= 0; _legI--) { // these vars already exist, little awkward but eh
				_leg = legArray[_legI];
				_legNodeSpeeds = ragdollLegNodesSpeed[_legI]; // does this currently grab the hip and knee speeds and not the knee and foot? I want severing to happen at the top of the segment but speeds are the ends... Hmm, idk if it's even broken tho TODO
				for(var _nodeI = 0; _nodeI < 2; _nodeI++) { // note that this loop ends one short because feet don't need to be checked for existance atm (only hip and knee can be severed, keeping foot severing open as an option but not used currently)  (( also it's hard coded for 3 joint segments, idk if i'll ever expand this to have wacky limbs but it's simple if so)
					_node = _leg[_nodeI];
					
					if(!_node[E_legInfo.connected]) {
						break; // abandon rest of node calculations for this limb since an upstream node is missing (and thus all after...)
					} else {
						var _nextNode = _leg[_nodeI + 1];
						var _nodeSpeed = _legNodeSpeeds[_nodeI];
						var _nextNodeSpeed = _legNodeSpeeds[_nodeI + 1];
						
						var _distConnection = point_distance_3d(_node[E_legInfo.x], _node[E_legInfo.y], _node[E_legInfo.z], _nextNode[E_legInfo.x], _nextNode[E_legInfo.y], _nextNode[E_legInfo.z]); // rebuld to be a position setting plus displacement to speed set up!!
					
						var _limbSegLen = _node[E_legInfo.length];
					
						if(_distConnection > _limbSegLen) {
							var _nodeToNextVec = [_nextNode[E_legInfo.x] - _node[E_legInfo.x], _nextNode[E_legInfo.y] - _node[E_legInfo.y], _nextNode[E_legInfo.z] - _node[E_legInfo.z]];
					 		var _distMult = _limbSegLen / _distConnection;
							
							var _nextNodePrev = [_nextNode[E_legInfo.x], _nextNode[E_legInfo.y], _nextNode[E_legInfo.z]];
							
							_nextNode[E_legInfo.x] = _node[E_legInfo.x] + (_nodeToNextVec[0] * _distMult);
							_nextNode[E_legInfo.y] = _node[E_legInfo.y] + (_nodeToNextVec[1] * _distMult);
							_nextNode[E_legInfo.z] = _node[E_legInfo.z] + (_nodeToNextVec[2] * _distMult);
							
							_legNodeSpeeds[_nodeI + 1] = [_nextNode[E_legInfo.x] - _nextNodePrev[E_legInfo.x], _nextNode[E_legInfo.y] - _nextNodePrev[E_legInfo.y], _nextNode[E_legInfo.z] - _nextNodePrev[E_legInfo.z]]; // set the speeds based on delta position after the shifting (which is what speed is, either speed creates delta pos or delta pos belies speed)
						}
					}
				}
			}
			
			
			var _ragdollMoveDir = point_direction(0, 0, xChange, yChange);
			var _ragdollMoveHorSpd = point_distance(0, 0, xChange, yChange);
			var _ragdollMovePitch = point_direction(0, 0, _ragdollMoveHorSpd, zChange + 10); // + 10 to keep it usually in the upright position and avoid jittering across origin
			spineMain.setFromDirs(_ragdollMoveDir, _ragdollMovePitch);
			
			//xChange = x - xprevious; // last of the speed momentum sets (the others are above in the foot and joint positioner)
			//yChange = y - yprevious;
			//zChange = z - zPrev;
		} else if(recoveringStandingTimer > 0) {
			recoveringStandingTimer--;
			
			if(recoveringStandingTimer == 0) {
				//end ragdoll
				ragdolling = false;
			}
		}
			
		spineMain.x = x;
		spineMain.y = y;
		spineMain.z = z;
	}
}


function script_mdlDraw() {
	//draw_text(x, y - 100, weaponPosition[2]);
	
	//spine nonsense find a better place for this..
	var _leanAheadX = xChange * 8; // keep consistent i suppose
	var _leanAheadY = yChange * 6; // keep consistent i suppose
	
	with(spineMain) {
		updatePosTip(tipX + _leanAheadX, tipY + _leanAheadY, tipZ + length); // +5 is to return to standing straight sooner
		lengthAssert();
	}
	
	//var _leanAheadDir = point_direction(0, 0, xChange * 9, -spineMain.length + yChange); // the 30 here is the distance of the spine while standing straight up i guess? Needs to be standarized and set up proper
	//spineMain.angle = _leanAheadDir;
	
	var _spineX = spineMain.x;
	var _spineY = spineMain.y; // setting spine locals
	
	//draw_set_alpha(.75);
	//draw_circle_color(_spineX + _leanAheadX, _spineY, 16, #333333, #333333, false); // shadow! Remove when you have a better way!
	//draw_set_alpha(1);
	
	var _mdlSurf = script_mdlGetSurf(); // the surface you draw to
	var _surfMidX = mdlSurfWidth / 2;
	var _surfMidY = mdlSurfHeight / 2;
	
	surface_set_target(_mdlSurf);
	
	gpu_set_ztestenable(true);
	gpu_set_zwriteenable(true);
	
	draw_clear_alpha(c_white, 0);
	
	#region bunch of things for general positioning, needs to be established first
	//var _dirMoving = point_direction(x, y, mouse_x, mouse_y);
	var _dirMoving = aimingDownSights ? point_direction(x, y, mouse_x, mouse_y) : point_direction(0, 0, xChange, yChange);
	directionFacing = _dirMoving;
	
	var _viewCompress = .5 + abs(dsin(directionFacing) / 2);
	var _speed = point_distance(0, 0, xChange, yChange);
	var _jostle = (dsin((stepTimings[0][E_step.progress] + stepTimings[1][E_step.progress]) * 180 * (1.5 + sqrt(_speed) / 3) - 90) + .4) * sqrt(_speed) * 1.4;
	#endregion
	
	#region draw gun
	var _heldDownAngleAdjust = 0;
	if(gunHeldDown) {
		_heldDownAngleAdjust = (angle_difference(270, weaponHoldDirection) / 3); // set the holding down effect if out of aim range (when aiming away hold gun down to side)
		var _upAngleDiff = angle_difference(weaponHoldDirection, 90);
		if(abs(_upAngleDiff) < 90) {
			_heldDownAngleAdjust *= clamp(abs(_upAngleDiff) - 45, 0, 45) / 45; // reduce adjust as it approaches upward hold angle because pushing an up gun towards down doesn't make any sense
		}
	}
	
	weaponPosition[0] += clamp(_leanAheadX, -40, 40); // in theory should be arm length * 2 but eh
	weaponPosition[1] += clamp(_leanAheadY, -40, 40) + _jostle / 2; // position the gun with body movement variations
	
	if(gunDrawBehind) {
		script_drawWeapon(gunSprite, weaponPosition, weaponHoldDirection, _heldDownAngleAdjust, _spineX - _surfMidX, _spineY - _surfMidY); // draw gun in front if supposed to be in front
	}
	
	#endregion
	
	array_sort(bodyComponents, script_mdlSortComponents);
	
	var _counter = 0; 
	//draw the components in front
	_counter += script_drawComponents(0, _leanAheadX, _leanAheadY, _jostle, _dirMoving, true);
	
	
	//draw the rest of the body components in front of body
	_counter += script_drawComponents(_counter, _leanAheadX, _leanAheadY, _jostle, _dirMoving, false);

	if(!gunDrawBehind) {
		script_drawWeapon(gunSprite, weaponPosition, weaponHoldDirection, _heldDownAngleAdjust, _spineX - _surfMidX, _spineY - _surfMidY); // draw gun behind if supposed to be behind
	}
	
	surface_reset_target();
	
	
	
	//var _ang = current_time / 10; 
	//var _dist = (_surfMidX) * 1.4142; // the radius of the surf is the sqrt((width/2^2) + (height/2^2)) not just width / 2 but also just paste in a real for sqrt(2) which is that number
	//draw_surface_ext(_surf, x + dcos(_ang + 135) * _dist, y - dsin(_ang + 135) * _dist, 1, 1, _ang, c_white, 1);
	draw_surface(_mdlSurf, _spineX - _surfMidX, _spineY - _surfMidY);
	
	//draw_text(x + 100, y, feetOffY)
	
	
	
	draw_set_color(c_black);
	draw_circle(spineMain.x, spineMain.y, stepUpdateDist, true);
	draw_set_color(c_white);
	
	draw_circle_color(spineMain.x, spineMain.y, 2, c_blue, c_blue, true)
	draw_circle_color(x, y, 3, c_green, c_green, false)
	draw_text(x + 170, y - 20, feetOffY)
	
	draw_circle_color(stepPositionsGoal[0][0], stepPositionsGoal[0][1], 3, c_red, c_red, false);
	draw_circle_color(stepPositionsGoal[1][0], stepPositionsGoal[1][1], 3, c_red, c_red, false);
	
	draw_circle_color(stepPositionsInitial[0][0], stepPositionsInitial[0][1], 3, c_dkgray, c_dkgray, false);
	draw_circle_color(stepPositionsInitial[1][0], stepPositionsInitial[1][1], 3, c_dkgray, c_dkgray, false);
	
	draw_line(x + 200, spineMain.y - spineMain.z * .65, x + 200, feetY);
	draw_line_color(x + 180, y, x + 180, feetY, c_black, c_black);
	
	draw_line(x + dcos(currentDir) * 10, y - dsin(currentDir) * 10, x, y);
	
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