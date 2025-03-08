//draw_sprite_ext(spr_tree, round(dsin(current_time)), x, y, 1, 2, image_angle, c_white, image_alpha);

var _branchAcrossId = noone; // values for drawing across branches on a sub branch
var _branchAcrossDist = 0;
var _branchWidthCos = 0;
var _branchWidthSin = 0;

var _structureNodeCount = array_length(structureNodes);
for(var _sNodeI = _structureNodeCount - 1; _sNodeI >= 0; _sNodeI--) {
	var _node = structureNodes[_sNodeI];
	var _connection = _node.connectedTo;
	
	var _nodeThickness = _node.thickness;
	var _connectionThickness = treeThicknessMax;
	
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
	
		draw_line_width_color(_node.x, _node.y, _cNodeX, _cNodeY, _nodeThickness, _endColor, _comingFromColor);
		draw_circle_color(_cNodeX, _cNodeY, _nodeThickness / 2, _comingFromColor, _comingFromColor, false);
	
		_branchAcrossDist += _nodeThickness / 2; // add other half of the distance
	
		if(_node.brushed) {
			if(_connection != -1) {
				draw_circle_color(_node.x, _node.y, 2 + _node.connectionDist * 1, _endColor, #ffbbbb, false);
				//draw_circle_color((_node.x + _connection.x) / 2, (_node.y + _connection.y) / 2, 3 + _node.connectionDist * 1.25, _endColor, #ffbbbb, false);
			}
		}
	} else {
		draw_line_width_color(x, y, _node.x, _node.y, _nodeThickness, c_white, c_white);
	}
	
	//draw_set_color(c_green);
	//draw_set_alpha(.75);
	//draw_circle(_node.x, _node.y, _node.connectionBreakDist, true);
	//draw_set_color(c_white);
	//draw_set_alpha(1);
	
	//draw_set_color(c_green);
	//draw_set_alpha(.75);
	//draw_text_transformed(_node.x, _node.y, _node.connectionRigidity, .5, .5, 0);
	//draw_set_color(c_white);
	//draw_set_alpha(1);
}

//draw_set_color(c_purple);
//var _theoryNodes = [];
//for(var _sNodeI = 0; _sNodeI < _structureNodeCount; _sNodeI++) {
//	var _node = structureNodes[_sNodeI];
	
//	var _theoryConnectionI = 0;
	
//	if(_node.connectedTo == -1) {
//		array_push(_theoryNodes, [_node.x, _node.y, _node.connectionDir]);
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
//draw_set_color(c_white);


//draw_line_width_color(x, y, x + dcos(image_angle + 90) * 100, y - dsin(image_angle + 90) * 100, 10, image_blend, #dddd88)
//draw_circle_color(x, y - 100, 25, c_green, c_olive, false);

//draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);