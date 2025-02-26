event_inherited();

if(fallingTimer > 0) {
	if(abs(angle_difference(image_angle, 0)) < 90) {
		image_angle += fallingDir * fallingSpeed;
	} else {
		repeat(fallingSpeed * 35) {
			part_particles_create(sys, x - irandom(140) * fallingDir, y + irandom_range(-40, 40), dust, 1);
		}
		fallingSpeed *= -.4;
	}
	
	fallingSpeed += abs(dcos(image_angle)) * .03;
	
	fallingTimer--;
	if(fallingTimer == 0) {
		script_createMeatDebris(x, y, 1, 0, 0, 0, irandom_range(3, 5), 50);
		instance_destroy();
	}
} else {
	if(angleShake > .02) {
		image_angle += dsin(current_time * 3) * angleShake;
		image_angle *= .9;
	
		angleShake *= .994;
	}
}

if(image_alpha < 1) {
	image_alpha += .03;
}

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