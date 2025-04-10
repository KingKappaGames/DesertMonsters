event_inherited();

if(alive == 1) {
	if(irandom(200) == 0) {
		dirGoal = currentDir + irandom_range(-110, 110);
		if(irandom(30) == 0) {
			xChange = 0;
			yChange = 0;
		}
	}
	
	xChange += dcos(dirGoal) / 46;
	yChange -= dsin(dirGoal) / 46;
	xChange *= .993;
	yChange *= .993;

	
	currentDir = point_direction(0, 0, xChange, yChange);
	currentSpeed = point_distance(0, 0, xChange, yChange);
	stepUpdateDist = stepUpdateDistBase * sqrt(currentSpeed) * 1.25;
	
	x += xChange;
	y += yChange;
	
	//animation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% (basic overall positioning, then calculating step positions and goals and moving the legs, then calculating the animations based on the positions)
	
	hipDir = point_direction(0, 0, xChange, yChange);
	var _cosFacing = dcos(hipDir);
	var _sinFacing = -dsin(hipDir);
	
	var _legCount = array_length(stepPositions); // proxy for leg count, should always line up
	
	var _allFeetOnGround = true; // DO PROGRESS SETTING
	for(var _legI = 0; _legI < _legCount; _legI++) { // check leg progresses to allow or disallow new steps in legs
		var _stepTiming = stepTimings[_legI];
		var _stepGoal = stepPositions[_legI][2];
		var _stepDuration = _stepTiming[stepTimeEnum.endTime] - _stepTiming[stepTimeEnum.startTime];
		_stepTiming[stepTimeEnum.progress] = clamp((current_time - _stepTiming[stepTimeEnum.startTime]) / (_stepDuration), 0, 1);
		if(_stepTiming[stepTimeEnum.progress] < 1) { // still in the air, then add momentum to goal as well as body, this keeps feet aligned with object movement without having to predict some crazy future point
			_stepGoal[0] += xChange;
			_stepGoal[1] += yChange; // add height?
		}
		if(_allFeetOnGround && _stepTiming[stepTimeEnum.progress] != 1) {
			
			#region containing step goals within reasonable range AND bringing in step goals when slowing down
			var _hip = hipPositions[_legI];
			var _stepDist = point_distance(_hip[0], _hip[1], _stepGoal[0], _stepGoal[1]);
			if(_stepDist > stepUpdateDist) {
				var _distOverMultiply = stepUpdateDist / _stepDist;
				
				_stepTiming[stepTimeEnum.endTime] = lerp(_stepTiming[stepTimeEnum.endTime], _stepTiming[stepTimeEnum.startTime], 1 - _distOverMultiply); // reduce time for step along with distance, basically, drop your foot sooner than planned if changing course
			
				_stepGoal[0] = lerp(_hip[0], _stepGoal[0], _distOverMultiply);
				_stepGoal[1] = lerp(_hip[1], _stepGoal[1], _distOverMultiply);
			}
			#endregion
			
			_allFeetOnGround = false;
		}
	}
	
	for(var _legI = 0; _legI < _legCount; _legI++) {
		#region setting the local values from stored variables
		var _hip = hipPositions[_legI];
		var _knee = kneePositions[_legI];
		var _stepInitial = stepPositions[_legI][0];
		var _stepCurrent = stepPositions[_legI][1];
		var _stepGoal = stepPositions[_legI][2];
		var _stepTiming = stepTimings[_legI]; // not necessary ?
		#endregion convenience value setting ^^^
		
		#region doing the step positions and updates
		//temp hip calcs (no control for where the hip is?)
		_hip[0] = x + dcos(hipDir + 90 - (180 * _legI)) * hipWidth;
		_hip[1] = y - dsin(hipDir + 90 - (180 * _legI)) * hipWidth;
		_hip[2] = legSegLen * standingHeight;
		
		var _stepPlacement = array_create(2, 0);
		_stepPlacement[0] = _hip[0];
		_stepPlacement[1] = _hip[1];
		
		var _progress = stepTimings[_legI][stepTimeEnum.progress];
		
		var _stepHeight = dsin(180 * _progress) * legSegLen * .7;
		
		_stepCurrent[2] = _stepHeight;
		_stepCurrent[0] = lerp(_stepInitial[0], _stepGoal[0], _progress);
		_stepCurrent[1] = lerp(_stepInitial[1], _stepGoal[1], _progress);
		
		if(_allFeetOnGround && _progress == 1) { // there needs to be some way to deal with changing step lengths and repositions i think, for now just not stepping when already stepping works but has a bunch of issues
			var _stepPlacementDist = point_distance(_stepCurrent[0], _stepCurrent[1], _stepPlacement[0], _stepPlacement[1]); // add the height to the value but remove it when checking distance to step
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
		#endregion

		#region getting joint positions from trig distances
		var _footJointDist = sqrt(abs(sqr(legSegLen) - sqr(_footDist / 2))); // outwardness of joint
		var _footOut = point_distance(_hip[0], _hip[1], _stepCurrent[0], _stepCurrent[1]); // horizontal distance
		var _kneeHeightAngle = darctan2((_stepCurrent[2] - _hip[2]), _footOut) + 90; // horizontal dist over height diff (opposite / adjacent) > the angle relative to the flat plane along this legs direction (+ 90 for the bend)
		var _kneeSin = dsin(_kneeHeightAngle); // this value could be gotten from a flipped x/y of the leg without needing to trig convert it.. maybe
		var _kneeCos = dcos(_kneeHeightAngle);

		var _legMid = array_create(3, 0);
		_legMid[0] = ((_hip[0] + _stepCurrent[0]) / 2);
		_legMid[1] = ((_hip[1] + _stepCurrent[1]) / 2); // visual mid point simply between hip and foot
		_legMid[2] = ((_hip[2] + _stepCurrent[2]) / 2);

		_knee[0] = _legMid[0] + _cosFacing * _footJointDist * _kneeCos;
		_knee[1] = _legMid[1] + _sinFacing * _footJointDist * _kneeCos; // final joint positions
		_knee[2] = _legMid[2] - _kneeSin * _footJointDist;
		#endregion
	}
}

rootNode.x = x;
rootNode.y = y;
//rootNode.height = 
rootNode.currentAngle = currentDir;

var _structureNodeCount = array_length(structureNodes);
var _node = -1;
var _connection = -1;

var _nodeX = 0;
var _nodeY = 0;
var _connectionX = 0;
var _connectionY = 0;

var _goalX = 0;
var _goalY = 0;

var _counterGoalX = 0;
var _counterGoalY = 0;

var _forceX = 0;
var _forceY = 0;

var _counterForceX = 0;
var _counterForceY = 0;

var _mouseClick = false;
if(keyboard_check(vk_control)) {
	_mouseClick = true;
}

for(var _sNodeI = 0; _sNodeI < _structureNodeCount; _sNodeI++) {
	#region setting up locals for ref
	_node = structureNodes[_sNodeI];
	_connection = _node.connectedTo;
	
	if(_connection != -1) {
	
		_nodeX = _node.x;
		_nodeY = _node.y;
	
		_connectionX = _connection.x;
		_connectionY = _connection.y;
		#endregion
	
		var _connectedDir = point_direction(_nodeX, _nodeY, _connectionX, _connectionY); // the angle from the current node TO the connection
		var _connectedDist = point_distance(_nodeX, _nodeY, _connectionX, _connectionY);
	
		_node.currentAngle = _connectedDir - 180; // from connection to current node
		
		var _extendX = dcos(_connection.currentAngle + _node.connectionDir) * _node.connectionDist;
		var _extendY = dsin(_connection.currentAngle + _node.connectionDir) * _node.connectionDist;
	
		_goalX = _connectionX + _extendX;
		_goalY = _connectionY - _extendY;
		
		_counterGoalX = _node.x - _extendX;
		_counterGoalY = _node.y + _extendY;
	
		_forceX = lerp(0, _goalX - _nodeX, _node.connectionRigidity) + global.windStrength * (dsin(current_time / 27) / 2 + .5);
		_forceY = lerp(0, _goalY - _nodeY, _node.connectionRigidity) + global.gravityStrength * (dcos(current_time / 13) / 2 + .5);
		
		_counterForceX = lerp(0, _counterGoalX - _connectionX, _node.connectionRigidity);
		_counterForceY = lerp(0, _counterGoalY - _connectionY, _node.connectionRigidity);
	
		#region experiment stuff
		
		var _connectedId = _connection;
		var _impactedIds = []; // id plus depth of interaction (how far away it is node wise)
		var _connectDepth = 0;
		//while(_connectedId != -1) {
			//Nah I have to get off but here you basically want to iterate down the chain of each connection until the end and when this thing gets pushed go through to the end, get the length of that chain and go back through again and apply that pushing force to each node along the chain relative to their position vs max length. So the 9th out of 10 aka the one right next to the one you clicked would get 90% of the actual movement from this click and the 2nd out of ten aka the second from the root would get 20%
		//} // the other thing I need to do here is clamp the distances, yes there's the breaking question but I think there are much better ways to do that than distance offset from an expected, perhaps each node could do it's own, that is probably what I was thinking originally, sounds fine. But regardless if node b is 50 away from it's source a and it's max is 20 then pull a towards b to make up the difference, what happens when you reach peak distance aka the combined length of all segments of the chain? Hm. Screw off. (break something before the net branch stretch is great enough to pull the root up...)
		
		//_connection.xChange -= dcos(_connectedDir) * _forceX;
		//_connection.yChange += dsin(_connectedDir) * _forceY;
		
		#endregion
	
		_node.xChange += (power(abs(_forceX), .85) + .05) * sign(_forceX);
		_node.yChange += (power(abs(_forceY), .85) + .05) * sign(_forceY);
		
		var _nodeRatio = sqrt(_node.weight / _connection.weight);
		_connection.xChange += power(abs(_counterForceX), .85) * sign(_counterForceX) * 1 * _nodeRatio;
		_connection.yChange += power(abs(_counterForceY), .85) * sign(_counterForceY) * 1 * _nodeRatio;
		
		//msg(_node.weight / _connection.weight);
		
		_node.xChange = (power(abs(_node.xChange) + 1, clamp(.97 + _node.connectionRigidity / 6, .97, .99)) - 1) * sign(_node.xChange);
		_node.yChange = (power(abs(_node.yChange) + 1, clamp(.97 + _node.connectionRigidity / 6, .97, .99)) - 1) * sign(_node.yChange);
		//_connection.xChange = (power(abs(_connection.xChange) + 1, .91) - 1) * sign(_connection.xChange);
		//_connection.yChange = (power(abs(_connection.yChange) + 1, .91) - 1) * sign(_connection.yChange);
	
		_node.x += _node.xChange / _node.weight;
		_node.y += _node.yChange / _node.weight;
		
		if(_mouseClick) { // move points to mouse
			if(point_distance(mouse_x, mouse_y, _node.x, _node.y) < 20) {
				_node.x = mouse_x;
				_node.y = mouse_y;
				
				_mouseClick = false;
			}
		}
		
		if(point_distance(_nodeX, _nodeY, _goalX, _goalY) > _node.connectionBreakDist) {
			breakNode(_sNodeI);
			_structureNodeCount = array_length(structureNodes)
			//var _dir = point_direction(_nodeX, _nodeY, _connectionX, _connectionY);
			//_node.x = _connectionX + dcos(_dir + 180) * _node.connectionDist * 2;
			//_node.y = _connectionY - dsin(_dir + 180) * _node.connectionDist * 2;
		}
	}
}

depth = -(y - global.depthOffset) + 40;