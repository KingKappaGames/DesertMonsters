///@desc Simply sets the joint position (as given by mid points in nodeArray for an individual limb), doesn't draw, doesn't set orgins or clamp distance
///@param nodeArray
///@param segmentLength
///@param endDist
///@param endDir
///@param facingCos
///@param joints
///@param bendDirGoal This is the direction to bend towards, in any 90 degree bending system it must choose to bend +90 or -90 from the original angle, this is the angle that it will prefer when bending
function script_setIKJoints(nodeArray, segmentLength, endDist, endDir, facingCos, bendDirGoal = 270){ // which direction they bend for up or down angles
	//var _limbCount = 1;
	//if(is_array(nodeArray[0][0])) { // (if is multiple limbs) limb n, node n, > this value is an array of coords and sizes, if it's a single limb this value will have already hit those (X-limb-X node > value > no array and thus it's not multiple limbs
	//	_limbCount = array_length(nodeArray);
	//}
	
	//for(var _limbI = 0; _limbI < _limbCount; _limbI++) {
		//var _limb = nodeArray[_limbI];
		var _joints =  array_length(nodeArray) - 2;  //_limbCount > 1 ? array_length(nodeArray) : array_length(nodeArray[_limbI]);
		var _jointOutDist = sqrt(max(sqr(segmentLength) - sqr(endDist / 2), 0)); // outwardness of joint

		var _limbMidX = (nodeArray[0][0] + nodeArray[_joints + 1][0]) / 2; // joint + 1 gives you the last point
		var _limbMidY = (nodeArray[0][1] + nodeArray[_joints + 1][1]) / 2; // visual mid point simply between hip and foot
	
		var _jointFacingDir = 1 - (abs(angle_difference(bendDirGoal, endDir + 90)) > 90) * 2; // if the bend angle would be on the wrong side of the leg with this value then flip it (1 to -1 relative to the +90)

		var _jointOffX = dcos(endDir + 90 * _jointFacingDir) * facingCos * _jointOutDist;
		var _jointOffY = dsin(endDir + 90 * _jointFacingDir) * -sign(facingCos) * _jointOutDist; // final joint positions
	
		nodeArray[_joints][0] = _limbMidX + _jointOffX;
		nodeArray[_joints][1] = _limbMidY + _jointOffY;
	//}
}