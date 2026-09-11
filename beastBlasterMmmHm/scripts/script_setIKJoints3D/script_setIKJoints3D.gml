///@desc Simply sets the joint position (as given by mid points in nodeArray for an individual limb), doesn't draw, doesn't set orgins or clamp distance
///@param nodeArray The geometry nodes of the limb to use for this, eg, [shoulder/hip x,y,  joint x2,y2,  foot/hand x3,y3]
///@param segmentLength How long the individual segments of the limb are
///@param endDist THREE DIMENSIONAL dist from start point to end point of limb
///@param endDir Dir from start point to end point of limb
///@param facingCos The visual compression (as a -1-1 cos output) of the limb horizontally, if facing you for example any out will be irrelavent ect
///@param facingSin The visual compression (as a -1-1 cos output) of the limb vertically
function script_setIKJoints3D(nodeArray, segmentLength, endDist, endDir, facingCos, facingSin) { // which direction they bend for up or down angles
	live_auto_call
	
	if(endDist > nodeArray[0][3] * 2) {
		endDist = nodeArray[0][3] * 2; // [0][3] is length for this node of the limb, ergo check it as a max also this is stupid //TODO fix this nonsense with mismatching distances vs the draw and step
	}
	
	var _joints =  array_length(nodeArray) - 2;  //_limbCount > 1 ? array_length(nodeArray) : array_length(nodeArray[_limbI]);
	
	//repeat for joints count? Maybe inverting in and out to replicate folding limbs like dogs and stuff?
	//var _bendAngle = 90;
	//for(var _jointI = 1; _jointI <= joints; _jointI++) { all the stuff below 
		//all the stuff below but with alternating + and - 90 degree bends
		//_bendAngle *= -1;
	//}
	
	var _jointOutDist = sqrt(max(sqr(segmentLength) - sqr(endDist / 2), 0)); // outwardness of joint (in 3d)
	
	var _originNode = nodeArray[0]; // "socket"
	var _endNode = nodeArray[_joints + 1]; // foot/hand/ect
	
	var _jointX = ((_originNode[0] + _endNode[0]) / 2);
	var _jointY = ((_originNode[1] + _endNode[1]) / 2); // visual mid point simply between hip and foot (or other limb types)
	var _jointZ = ((_originNode[2] + _endNode[2]) / 2);
	
	var _endFromOriginX = _originNode[0] - _endNode[0];
	var _endFromOriginY = _originNode[1] - _endNode[1];
	var _endFromOriginZ = _originNode[2] - _endNode[2];
	
	var _toHandDirHor = point_direction(_endFromOriginX, _endFromOriginY, 0, 0);
	
	var _jointBendAxisX = lengthdir_x(1, _toHandDirHor + 90); // add 90 to the horizontal axis to get the left right aspect of the otherwise straight "out" direction
	var _jointBendAxisY = lengthdir_y(1, _toHandDirHor + 90); // the axis that runs horizontally through the elbow or whatever joint such that the bones go around it when they bend (this is the axel of the arm, like a wheel spins, for some reason im getting confused by which axis, excuse me)
	
	var _jointPointVector = cross(_jointBendAxisX, _jointBendAxisY, 0, _endFromOriginX, _endFromOriginY, _endFromOriginZ);
	
	var _jointPointVectorLen = point_distance_3d(_jointPointVector[0], _jointPointVector[1], _jointPointVector[2], 0, 0, 0);
	
	_jointPointVector[0] *= (_jointOutDist / _jointPointVectorLen);
	_jointPointVector[1] *= (_jointOutDist / _jointPointVectorLen);
	_jointPointVector[2] *= (_jointOutDist / _jointPointVectorLen);
	
	nodeArray[1][0] = _jointX + _jointPointVector[0];
	nodeArray[1][1] = _jointY + _jointPointVector[1];
	nodeArray[1][2] = _jointZ + _jointPointVector[2];
}