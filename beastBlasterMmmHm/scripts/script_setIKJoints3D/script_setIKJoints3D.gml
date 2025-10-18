///@desc Simply sets the joint position (as given by mid points in nodeArray for an individual limb), doesn't draw, doesn't set orgins or clamp distance
///@param nodeArray The geometry nodes of the limb to use for this, eg, [shoulder/hip x,y,  joint x2,y2,  foot/hand x3,y3]
///@param segmentLength How long the individual segments of the limb are
///@param endDist THREE DIMENSIONAL dist from start point to end point of limb
///@param endDir Dir from start point to end point of limb
///@param facingCos The visual compression (as a -1-1 cos output) of the limb horizontally, if facing you for example any out will be irelavant ect
///@param facingSin The visual compression (as a -1-1 cos output) of the limb vertically
///@param joints Integer count! Not a list or positions, simply the amount of bends to use
function script_setIKJoints3D(nodeArray, segmentLength, endDist, endDir, facingCos, facingSin, joints) { // which direction they bend for up or down angles
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
	
	var _endFromOriginX = _originNode[0] - _endNode[0]; // TURNS OUT THIS IS DOT PRODUCT STUFF
	var _endFromOriginY = _originNode[1] - _endNode[1];
	
	var _footAheadDist = dot_product(_endFromOriginX, _endFromOriginY, facingCos, -facingSin);

	var _kneeHeightAngle = (darctan2((_originNode[2] - _endNode[2]), _footAheadDist) - 90); 
// first step is distance which is joint out dist, the second angle is direction facing, the third angle is vertical tilt which is a nightmare to get. How to convert tilt, direction, and out dist to points I'm not sure... 

	var _kneeSin = dsin(_kneeHeightAngle); // this value could be gotten from a flipped x/y of the leg without needing to trig convert it.. maybe
	var _kneeCos = dcos(_kneeHeightAngle);

	nodeArray[1][0] = _jointX + facingCos * _jointOutDist * _kneeCos;
	nodeArray[1][1] = _jointY - facingSin * _jointOutDist * _kneeCos; // final joint positions
	nodeArray[1][2] = _jointZ + _kneeSin * _jointOutDist;
	
	//var _legIndex = array_get_index(global.players[0].legArray, nodeArray); // I should probably just pass this but who tf knows
	
	//global.players[0].kneeAnglesDebug[_legIndex] = _kneeHeightAngle;
}