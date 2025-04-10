if (live_call()) return live_result;

// tall two leg flopper with big mouth or something idk

var _legCount = array_length(stepPositions); // proxy for leg count, should always line up
for(var _legI = 0; _legI < _legCount; _legI++) {
	var _hip = hipPositions[_legI];
	var _knee = kneePositions[_legI];
	
	//var _stepInitial = stepPositions[_legI][0];
	var _stepCurrent = stepPositions[_legI][1];
	//var _stepGoal = stepPositions[_legI][2];
	
	draw_line_width(_hip[0], _hip[1] - _hip[2] * .7, _knee[0], _knee[1] - _knee[2] * .7, thighWidth);
	draw_circle(_knee[0], _knee[1] - _knee[2] * .7, thighWidth / 2, false);
	draw_line_width(_knee[0], _knee[1] - _knee[2] * .7, _stepCurrent[0], _stepCurrent[1] - _stepCurrent[2] * .7, shinWidth);
	
	draw_set_color(c_red);
	draw_circle(stepPositions[_legI][2][0], stepPositions[_legI][2][1], 5, true);
	draw_set_color(c_white);
	
	draw_set_color(c_green);
	draw_circle(stepPositions[_legI][1][0], stepPositions[_legI][1][1], 5, true);
	draw_set_color(c_white);
	
	draw_set_color(c_blue);
	draw_circle(stepPositions[_legI][0][0], stepPositions[_legI][0][1], 5, true);
	draw_set_color(c_white);
}

//NODES AND BONE PHYSICS VVVV

var _branchAcrossId = noone; // values for drawing across branches on a sub branch
var _branchAcrossDist = 0;
var _branchWidthCos = 0;
var _branchWidthSin = 0;

var _structureNodeCount = array_length(structureNodes);
for(var _sNodeI = _structureNodeCount - 1; _sNodeI >= 0; _sNodeI--) {
	var _node = structureNodes[_sNodeI];
	var _connection = _node.connectedTo;
	
	var _nodeThickness = _node.thickness;
	var _connectionThickness = rootNode.thickness;
	
	if(_node.connectedTo != -1) {
		_connectionThickness = _node.connectedTo.thickness;
	
		_branchWidthCos = -dcos(_connection.currentAngle + 90);
		_branchWidthSin = -dsin(_connection.currentAngle + 90); // set up branch line up values
	
		if(_connection != _branchAcrossId) {
			_branchAcrossId = _connection;
			_branchAcrossDist = -_connection.thickness / 2;
		}
	
		_branchAcrossDist += _nodeThickness / 2; // add half width for center (below add other half)
		
		var _comingFromColor = make_color_rgb(255, 255 - _connectionThickness * 5, 255 - _connectionThickness * 5);
		var _endColor = make_color_rgb(255, 255 - _nodeThickness * 3, 255 - _nodeThickness * 3);
	
		var _cNodeX = _node.connectedTo.x + (_branchWidthCos * _branchAcrossDist);
		var _cNodeY = _node.connectedTo.y - (_branchWidthSin * _branchAcrossDist);
	
		draw_line_width_color(_node.x, _node.y - _node.height * .7, _cNodeX, _cNodeY - _connection.height * .7, _nodeThickness, _endColor, _comingFromColor);
		draw_circle_color(_cNodeX, _cNodeY - _connection.height * .7, _nodeThickness / 2, _comingFromColor, _comingFromColor, false);
	
		_branchAcrossDist += _nodeThickness / 2; // add other half of the distance
	
		//if(_node.brushed) {
		//	if(_connection != -1) {
		//		draw_circle_color(_node.x, _node.y - _node.height * .7, 2 + _node.connectionDist * 1, _endColor, #ffbbbb, false);
		//		//draw_circle_color((_node.x + _connection.x) / 2, (_node.y + _connection.y) / 2, 3 + _node.connectionDist * 1.25, _endColor, #ffbbbb, false);
		//	}
		//}
	}
	
	//draw_set_color(c_green);
	//draw_set_alpha(.75);
	//draw_circle(_node.x, _node.y, _node.connectionBreakDist, true);
	//draw_set_color(c_white);
	//draw_set_alpha(1);
	
	//draw_set_color(c_green);
	//draw_set_alpha(.75);
	//draw_text_transformed(_node.x, _node.y, _node.connectionDir, .5, .5, 0);
	//draw_text_transformed(_node.x + 50, _node.y, _node.currentAngle, .5, .5, 0);
	//draw_set_color(c_white);
	//draw_set_alpha(1);
}

//draw_set_color(c_purple);
//var _theoryNodes = [];
//for(var _sNodeI = 0; _sNodeI < _structureNodeCount; _sNodeI++) {
//	var _node = structureNodes[_sNodeI];
	
//	var _theoryConnectionI = 0;
	
//	if(_node.connectedTo == -1) {
//		array_push(_theoryNodes, [_node.x, _node.y, _node.currentAngle]);
//	} else {
//		_theoryConnectionI = array_get_index(structureNodes, _node.connectedTo);
//		var _netRot = _theoryNodes[_theoryConnectionI][2] + _node.connectionDir;
//		var _theoryNode = [_theoryNodes[_theoryConnectionI][0] + dcos(_netRot) * _node.connectionDist, _theoryNodes[_theoryConnectionI][1] - dsin(_netRot) * _node.connectionDist, _netRot];
		
//		array_push(_theoryNodes, _theoryNode);
//	}
	
//	if(_node.connectedTo != -1) {
//		draw_line(_theoryNodes[_sNodeI][0], _theoryNodes[_sNodeI][1], _theoryNodes[_theoryConnectionI][0], _theoryNodes[_theoryConnectionI][1]);
//	}
//}
draw_set_color(c_white);

draw_circle(x, y, stepUpdateDist, true);