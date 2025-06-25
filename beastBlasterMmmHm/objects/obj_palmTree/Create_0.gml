event_inherited();

sys = global.particleSystem;
dust = global.sandBurstDustFloat;

image_alpha = 0;

Health = 91.5;
angleShake = 0;

fallingTimer = 0;
fallingDir = 0;
fallingSpeed = 0;

///@desc Sorta works..?
hurt3D = function(damage, knockback, radius, dropOffPower = 1, hitSourceId = noone) {
	if(instance_exists(hitSourceId)) {
		var _hitX = hitSourceId.x;
		var _hitY = hitSourceId.y;
		
		knockback *= .25;
		
		var _nodeCount = array_length(structureNodes);
		for(var _hitI = 0; _hitI < _nodeCount; _hitI++) {
			var _node = structureNodes[_hitI];
			with(_node) {
				var _dist = point_distance(x, y, _hitX, _hitY);
				var _dir = point_direction(_hitX, _hitY, x, y);
				
				var _pushFinal = knockback * power(1 - (_dist / radius), dropOffPower) / (connectionRigidity + .1);
				
				xChange = _pushFinal * dcos(_dir);
				yChange = _pushFinal * -dsin(_dir);
			}
		}
	}
}
//hurt3D = function(damage, knockback, radius, dropOffPower = 1, hitSourceId = noone) {
//	if(damage > 1) {
//		Health -= sqrt(damage);
//	} else {
//		Health -= sqr(damage);
//	}
	
//	angleShake += damage;
	
//	if(Health <= 0) {
//		var _hitDir = instance_exists(hitSourceId) ? point_direction(hitSourceId.x, hitSourceId.y, x, y) : irandom(360); // im getting freaky with these terniarys
		
//		fallingTimer = 432;
//		fallingDir = (_hitDir > 90 && _hitDir < 270) ? 1 : -1;
//		fallingSpeed = damage / 12;
//	}
//}

hit = function(damageAmount, hitDir) {
	if(damageAmount > 1) {
		Health -= sqrt(damageAmount);
	} else {
		Health -= sqr(damageAmount);
	}
	
	angleShake += damageAmount;
	
	if(Health <= 0) {
		fallingTimer = 432;
		fallingDir = hitDir > 90 && hitDir < 270 ? -1 : 1;
		fallingSpeed = damageAmount / 100;
	}
}

										// the connected nodes V
//x/y/height, xChange/yChange/heightChange, weight, rigidity, [[dir, dist, rigidity, distRigidity]] ]
structureNodes = [];
extraNodes = [];

treeThicknessMax = 28;

gravityForce = .01;

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

		currentAngle = connectedToId.currentAngle + (angleToConnection - 180); // this value is the angle of the connection TO the current node after all the extra stuff and other nodes have done their compound slumping and leaning... This is calculated!
		connectedTo = connectedToId;
		
		connectionRigiditySet ??= (power(thicknessSet, 3) * .00025) / (sqrt(clamp(distToConnection / 8, 1, 99))); // lerp value (  pos = lerp(pos, goalPos, rigidity)  )
		connectionBreakDistSet ??= (30 + (distToConnection * 3)) / power(clamp(thicknessSet - .3, 0, 999), .25);
		
		connectionRigidity = connectionRigiditySet;
		connectionBreakDist = connectionBreakDistSet;
		connectionDir = angleToConnection + 90;
		connectionDist = distToConnection;
	} else { // no connection
		connectedTo = -1;
		
		connectionRigidity = 0;
		connectionBreakDist = 0;
		if(angleToConnection != undefined) {
			connectionDir = angleToConnection;
			currentAngle = angleToConnection;
		} else {
			connectionDir = 90;
			currentAngle = 90;
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

breakNode = function(firstNode) { // why are random nodes breaking through out when this happens?
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

var _height = 0;
var _y = y;
var _x = x;

var _totalThickness = treeThicknessMax;
var _outness = 1; // step counter for splits, 1 as base to like, 6 for 6 splits away and the end

var _weight = 1;

var _first = new addNode(1, _totalThickness, -1, 90,,,, _x, _y, _height);

var _newlyAdded = [_first];
var _addedHold = [];

while(array_length(_newlyAdded) > 0) { // for as long as there are new growths check their splitting
	for(var _i = array_length(_newlyAdded) - 1; _i >= 0; _i--) {
		var _sourceNode = _newlyAdded[_i];
		var _branchThickness = _sourceNode.thickness; // total usable thickness for this branch to split
		if(_branchThickness >= 2) {
			var _splits = irandom_range(1, ceil(power(_branchThickness, .5)) * ((_height + 15) / (_height + 50)));
			var _splitThicknesses = script_splitRandom(_branchThickness, _splits, _branchThickness / 5);
			for(var _branchI = 0; _branchI < _splits; _branchI++) {
				var _thickLengthMult = power(_splitThicknesses[_branchI] / 10, .2) + .5;
				var _splitNode = new addNode(clamp(sqr(_splitThicknesses[_branchI] / 2), .5, 99999), _splitThicknesses[_branchI] * .85, _sourceNode, ,,,, _sourceNode.x + irandom_range(-20, 20) * _thickLengthMult, _sourceNode.y + irandom_range(-48, -10) * _thickLengthMult, _height);

				array_push(_addedHold, _splitNode);
			}
		}
		
		_height += 20;
	}
	
	_newlyAdded = _addedHold;
	_addedHold = [];
}

/* I think the first kind of building I should make is actually trees, dead trees or palm trees that wave around
like they are in wind or bobbing ect and they can get wiggled by bombs and nukes and ect. They would have multiple
segments that bent together and could break apart into pieces with particles and such to show leaves being knocked
off or pieces being broken away. These pieces could then fall to the ground and maybe become debris?

segments could try and lower towards a y value of "ground" but their direction could be restricted by the segment they
connect to so if segment one is leaning 10 degrees right then segment two would be drawn super tightly to only hang say 
15 degrees different so 25 degrees and then segement three would be 25+15=40 degrees. I think this both makes the tree 
look like it's under weight and also balances the "physics" to make it seem like it's flexible and has realistic connections
perhaps the breaking conditions could be segment to segment angle differences above 20 degrees including ground. This would 
directly make the warping of the tree related to it's breaking. It would also use IK to link sections and create the pull
that let's the gravity work against something. Sounds sick. The leaves could be IK or just drawn shapes with random wag
for the degree of shake that their segment is under. Trying to avoid lag of course.. Should be easy to cull these though.

*/