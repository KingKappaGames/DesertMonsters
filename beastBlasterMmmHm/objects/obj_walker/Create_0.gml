//if (live_call()) return live_result;

enum legSides {
	right, // 0
	left // 1
}

event_inherited();

image_xscale = 60;
image_yscale = 25;

Health = 30;

moveSpeed = .2;

currentSpeed = .3;
currentDir = 0;
dirGoal = 0;

xChange = random_range(-.3, .3);
yChange = random_range(-.3, .3);

friendly = false;

//animation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hipWidth = 15;
hipDir = 0; // reset down below based on size of animal

legSegLen = 72;
standingHeight = 1.7; // multiple of leg seg len

stepUpdateDistBase = 42;
stepUpdateDist = stepUpdateDistBase;

hipPositions = [[x, y, 0], [x, y, 0]]; // right 0 left 1
kneePositions = [[x, y, 0], [x, y, 0]]; // right = 0, left = 1, following hand numbering in main game
stepPositions = [[[x, y, 0], [x, y, 0], [x, y, 0]], [[x, y, 0], [x, y, 0], [x, y, 0]]]; // origin x/y PLUS current x/y PLUS end x/y (groups of groups of 3 x/y's for each case, initial, current, goal

stepTimings = [[0, current_time, current_time, 0], [0, current_time, current_time, 0]]; //[progress(updated by step), startTime, endTime, speedRef] (where speed reference is the speed that the thing was moving for that step to compare against for clipping a step on speed up or extending a step in slow down.

thighWidth = 20;
shinWidth = 10; // reset down below for size of animal

placeStepGoal = function(legIndex, currentX, currentY, goalX, goalY, moveSpeed = -1) { // goal here is the desired place to step to below the creature, not the ultimate target (with this goal added to prediction dist)
	////live_auto_call
	var _goalPos = stepPositions[legIndex][2]; // this goal IS the actual step goal used to place the foot
	var _previousStepPos = stepPositions[legIndex][0]; // this goal IS the actual step goal used to place the foot
	if(moveSpeed == -1) {
		moveSpeed = point_distance(0, 0, xChange, yChange);
	}
	
	_previousStepPos[0] = _goalPos[0];
	_previousStepPos[1] = _goalPos[1];
	
	_goalPos[0] = x + clamp((goalX - currentX) * .26, -legSegLen * .65, legSegLen * .65) + xChange * legSegLen; // this takes into acount the dist from previous step, the leg length, the duration of the step, add more for accuracy perhaps
	_goalPos[1] = y + clamp((goalY - currentY) * .26, -legSegLen * .65, legSegLen * .65) + yChange * legSegLen;
	
	var _stepAhead = point_distance(x, y, _goalPos[0], _goalPos[1]);
	//msg(point_distance(currentX, currentY, _goalPos[0], _goalPos[0]));
	
	var _stepTime = (_stepAhead / (moveSpeed * 2)) * (game_get_speed(gamespeed_microseconds) / 1000) * 3 * (legSegLen / 100); // how many frames to reach this point (as the body/center) should put the foot at the end of it's step (in real life steps cross from behind and in front then pause for half the time, thus the step is 2x as fast or more than the body since it's only moving half the time) 
	
	setStepTimings(legIndex, _stepTime, moveSpeed);
}

setStepTimings = function(legIndex, duration, speedRef) {
	var _timeInfo = stepTimings[legIndex];
	_timeInfo[3] = speedRef;
	_timeInfo[2] = current_time + duration; // step end time
	_timeInfo[1] = current_time; // current time duh
	_timeInfo[0] = 0; // step (expected!) progress set (starts at 0)
}

die = function() {
	alive = 0;
	instance_destroy();
}


										// the connected nodes V
//x/y/height, xChange/yChange/heightChange, weight, rigidity, [[dir, dist, rigidity, distRigidity]] ]
structureNodes = [];
extraNodes = [];

rootThickness = irandom_range(23, 80);

thighWidth = rootThickness * .75 + 3;
shinWidth = rootThickness * .45 + 2;
hipWidth = rootThickness * .5;
legSegLen = rootThickness * 1.65 + 10;
stepUpdateDist = legSegLen * .8;

///@desc With this you can add a node that has its own values and the values that describe how it attaches to the node it's connected to. You must either give the dir/dist connection or an x/y/z. The alternative will be auto filled by the one you do give.
///@param weightSet The heaviness of this node, both in resistance to moving and returning and force applied via gravity?
///@param thicknessSet The width of this node, this determines the drawing thickness / visual but also this nodes propensity for splitting into further nodes
///@param connectedToId The node this node is connecting to, -1 FOR NONE aka the origin!!
///@param angleToConnection If you have this pass in the dir and it will be used to fill out positions (angle from this node to the connected node!)
///@param distToConnection If you have this pass in the dist and it will be used to fill out positions
///@param connectionRigiditySet A value used as a lerp so .001 would be .1% of the distance to the goal per frame (in speed!!)
///@param connectionBreakDistSet Pixels until this node breaks with the connected node
///@param xx Optional x coord to spawn this node to and align it's goal with
///@param yy Optional y coord to spawn this node to and align it's goal with
///@param zz Optional height/z coord to spawn this node to and align it's goal with
addNode = function(weightSet, thicknessSet, connectedToId, angleToConnection = undefined, distToConnection = undefined, connectionRigiditySet = undefined, connectionBreakDistSet = undefined, xx = undefined, yy = undefined, zz = undefined) constructor {
	if(connectedToId != -1) { // struct goal exists for connection
		angleToConnection ??= point_direction(xx, yy, connectedToId.x, connectedToId.y); // if angles and distances are undefined then calculate them with positions
		distToConnection ??= point_distance(xx, yy, connectedToId.x, connectedToId.y);
	
		var _cos = dcos(angleToConnection - 180); // get the angle out from the connection instead of to it
		var _sin = dsin(angleToConnection - 180);
	
		xx ??= connectedToId.x + _cos * distToConnection;
		yy ??= connectedToId.y - _sin * distToConnection;
		zz ??= connectedToId.height - _sin * (distToConnection / 3);

		currentAngle = angleToConnection - 180; // this value is the angle of the connection TO the current node after all the extra stuff and other nodes have done their compound slumping and leaning... This is calculated!
		connectedTo = connectedToId;
		
		var _angleDif = angle_difference(angleToConnection - 180, connectedTo.currentAngle);
		
		connectionRigiditySet ??= (power(thicknessSet, 3) * .00025) / (sqrt(clamp(distToConnection / 8, 1, 99))); // lerp value (  pos = lerp(pos, goalPos, rigidity)  )
		connectionBreakDistSet ??= (30 + (distToConnection * 3)) / power(clamp(thicknessSet - .3, 0, 999), .25);
		
		connectionRigidity = connectionRigiditySet;
		connectionBreakDist = connectionBreakDistSet;
		connectionDir = _angleDif;
		connectionDist = distToConnection;
	} else { // no connection
		connectedTo = -1;
		
		connectionRigidity = 0;
		connectionBreakDist = 0;
		if(angleToConnection != undefined) {
			connectionDir = angleToConnection;
			currentAngle = angleToConnection;
		} else {
			connectionDir = 0;
			currentAngle = 0;
		}
		connectionDist = 0;
	}
	
	x = xx;
	y = yy;
	height = zz;
	
	xChange = 0;
	yChange = 0;
	heightChange = 0;
	
	weight = weightSet;
	thickness = thicknessSet;
	
	if(thickness < 2) {
		brushed = true;
	} else {
		brushed = false;
	}
	
	array_push(other.structureNodes, self);
	
	return self;
}

breakNode = function(firstNode) {
	var _breakFromNodes = [structureNodes[firstNode]];
	var _breakFromNodesHold= [];
	//var _removedNodes = [structureNodes[firstNode]];
	var _removedIndexs = [firstNode];
	
	var _startArrow = instance_create_depth(structureNodes[firstNode].connectedTo.x, structureNodes[firstNode].connectedTo.y, -5000, obj_pointerDebug);
	_startArrow.pointX = structureNodes[firstNode].x;
	_startArrow.pointY = structureNodes[firstNode].y;
	
	while(array_length(_breakFromNodes) != 0) { // the nodes in question, (to get their connections)
		var _nextLayerNodes = array_length(_breakFromNodes);
		for(var _i = 0; _i < _nextLayerNodes; _i++) { // go through all current nodes and check if any nodes in the total are their connections
			var _totalNodeCount = array_length(structureNodes);
			for(var _searchI = 0; _searchI < _totalNodeCount; _searchI++) {
				if(structureNodes[_searchI].connectedTo == _breakFromNodes[_i]) {
					
					var _arrow = instance_create_depth(_breakFromNodes[_i].x, _breakFromNodes[_i].y, -5000, obj_pointerDebug);
					_arrow.pointX = structureNodes[_searchI].x;
					_arrow.pointY = structureNodes[_searchI].y;
					
					//array_push(_removedNodes, structureNodes[_searchI]);
					array_push(_removedIndexs, _searchI);
					array_push(_breakFromNodesHold, structureNodes[_searchI]);
				}
			}
		}
		
		array_sort(_removedIndexs, true);
		for(var _removeArrI = array_length(_removedIndexs) - 1; _removeArrI >= 0; _removeArrI--) {
			array_delete(structureNodes, _removedIndexs[_removeArrI], 1);
		}
		
		_removedIndexs = [];
		_breakFromNodes = _breakFromNodesHold;
		_breakFromNodesHold= [];
	}
}

rootNode = new addNode(0, 40, -1, 0,,,, x, y, legSegLen * 2);

var _prevNode = rootNode;
var _width = rootThickness;
var _step = 1;
repeat(10) {
	_prevNode = new addNode(_width / 2, 5 + _width, _prevNode,,, _width / 200, 999, x - _step * rootThickness, y, rootNode.height);
	_width -= rootThickness / 10;
	_step++;
	
	if(_step == 2) {
		msg(_prevNode);
	}
}

var _chest = new addNode(rootThickness * .5, rootThickness * 1.4, rootNode,,, .24, 999, x + rootThickness * 2.4, y, rootNode.height + rootThickness * .6); // chest (hip to chest)
var _neck = new addNode(rootThickness * .3, rootThickness * .8, _chest,,, .16, 999, _chest.x + rootThickness * .5, _chest.y, _chest.height + rootThickness * .2); // neck (chest to neck base)
var _skullTop = new addNode(rootThickness * .3, rootThickness * .7, _neck,,, .16, 999, _neck.x + rootThickness * .8, _neck.y, _neck.height + rootThickness * .1); // skull (neck base to skull tip top)
var _skullBottom = new addNode(rootThickness * .15, rootThickness * .7, _neck,,, .13, 999, _neck.x + rootThickness * .7, _neck.y, _neck.height + rootThickness * -.1); // skull (neck base to skull tip bottom)

debugArr = [["updateDist", stepUpdateDist], ["updateDistBase", stepUpdateDistBase], ["currentSpeed", currentSpeed]];