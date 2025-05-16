///@desc Simply sets the joint position (as given by mid points in nodeArray for an individual limb), doesn't draw, doesn't set orgins or clamp distance
///@param nodeArray
///@param segmentLength
///@param endDist
///@param endDir
///@param facingCos
///@param joints
///@param bendDirGoal This is the direction to bend towards, in any 90 degree bending system it must choose to bend +90 or -90 from the original angle, this is the angle that it will prefer when bending
function script_setIKJoints(nodeArray, segmentLength, endDist, endDir, facingCos, bendDirGoal = 270) { // which direction they bend for up or down angles
	live_auto_call

	var _joints =  array_length(nodeArray) - 2;  //_limbCount > 1 ? array_length(nodeArray) : array_length(nodeArray[_limbI]);
	var _jointOutDist = sqrt(max(sqr(segmentLength) - sqr(endDist / 2), 0)); // outwardness of joint

	var _limbMidX = (nodeArray[0][0] + nodeArray[_joints + 1][0]) / 2; // joint + 1 gives you the last point
	var _limbMidY = (nodeArray[0][1] + nodeArray[_joints + 1][1]) / 2; // visual mid point simply between hip and foot
	var _limbMidZ = (nodeArray[0][2] + nodeArray[_joints + 1][2]) / 2; // visual mid point simply between hip and foot
	
	var _jointOffX = dcos(endDir - 90) * facingCos * _jointOutDist;
	var _jointOffY = -dsin(endDir - 90) * sign(facingCos) * _jointOutDist; // final joint positions ( the flipping from going up to down is the sign(facing) here!! 
	//var _jointOffZ = -dsin(endDir - 90) * sign(facingCos) * _jointOutDist;
	
	nodeArray[_joints][0] = _limbMidX + _jointOffX;
	nodeArray[_joints][1] = _limbMidY + _jointOffY;
	nodeArray[_joints][2] = _limbMidZ;// + _jointOffZ;
}