///@param startX
///@param startY
///@param endX 
///@param endY
///@param travelSpeed The pixels per frame to travel the path, not including delay to start bombing
///@param bombCount The number of bombs to drop along the path
///@param bombObject The bomb object index to use
///@param targetAccuracy This is 0 to radiusAround intended goal
function script_startAirStrike(startX, startY, endX = undefined, endY = undefined, travelSpeed = 2, bombCount = 10, bombObject = obj_mortar, targetAccuracy = 0, startPathDelay = 720){
	if(endX == undefined || endY == undefined) {
		var _dist = point_distance(startX, startY, endX, endY);
		var _dir = irandom(360);
		// do targeted fire on one location
		var _plane = instance_create_layer(startX - dcos(_dir) * startPathDelay * travelSpeed, startY + dsin(_dir) * startPathDelay * travelSpeed, "Instances", obj_bomberPlane);
		_plane.xChange = dcos(_dir) * travelSpeed;
		_plane.yChange = -dsin(_dir) * travelSpeed;
		_plane.bombsRemaining = bombCount;
		_plane.bombTimerMax = 10;
		_plane.bombType = bombObject;
		_plane.accuracy = targetAccuracy;
		
		_plane.bombingDelay = startPathDelay;
		_plane.image_angle = _dir;
	} else { // bombing line with delay
		var _dist = point_distance(startX, startY, endX, endY);
		var _dir = point_direction(startX, startY, endX, endY);
		var _plane = instance_create_layer(startX - dcos(_dir) * startPathDelay * travelSpeed, startY + dsin(_dir) * startPathDelay * travelSpeed, "Instances", obj_bomberPlane);
		_plane.xChange = dcos(_dir) * travelSpeed;
		_plane.yChange = -dsin(_dir) * travelSpeed;
		_plane.bombsRemaining = bombCount;
		_plane.bombTimerMax = _dist / (bombCount * travelSpeed);
		_plane.bombType = bombObject;
		_plane.accuracy = targetAccuracy;
		
		_plane.bombingDelay = startPathDelay;
		_plane.image_angle = _dir;
	}
}