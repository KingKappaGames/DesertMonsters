/// @desc Returns a spine struct to place and manipulate components around, you must set everything yourself, this struct doesn't really *do* anything itself, just holds values neat and tidy
/// @param {real} xx The x of the spine origin, will be changed as you go but set initial here I guess
/// @param {real} yy The y of the spine origin, will be changed as you go but set initial here I guess
/// @param {real} angle The angle of the spine, will be changed as you go but set initial here I guess
/// @param {real} lengthSet The length of the spine, doesn't set the distance of the components or anything but is used sometimes for connecions or whole body calculations
/// @returns {struct} Returns a spine struct
function script_createSpine(xx, yy, lengthSet, angleSet = 0, pitchSet = 0) constructor {
	x = xx;
	y = yy;
	z = 0;
	
	tipX = x;
	tipY = y;
	tipZ = z;
	
	angle = angleSet;
	pitch = pitchSet;
	
	length = lengthSet;
	
	
	xPrev = xx;
	yPrev = yy;
	zPrev = 0;
	
	static updatePos = function(xx, yy, zz) {
		x = xx;
		y = yy;
		z = zz;
		
		angle = point_direction(x, y, tipX, tipY);
		pitch = point_direction(point_distance(x, y, tipX, tipY), z, 0, 0);
	}
	
	static updatePosTip = function(xx, yy, zz) {
		tipX = xx;
		tipY = yy;
		tipZ = zz;
		
		angle = point_direction(x, y, tipX, tipY);
		pitch = point_direction(point_distance(x, y, tipX, tipY), z, 0, 0);
	}
	
	static updateCoords = function(xx, yy, zz, _tipX, _tipY, _tipZ) {
		x = xx;
		y = yy;
		z = zz;
		
		tipX = _tipX;
		tipY = _tipY;
		tipZ = _tipZ;
		
		angle = point_direction(x, y, tipX, tipY);
		pitch = point_direction(point_distance(x, y, tipX, tipY), z, 0, 0);
	}
	
	///@description Sets the spine to be straight up
	static straigten = function() {
		tipX = x;
		tipY = y;
		tipZ = z + length;
	}
	
	///@description Simply sets the tip location to be exactly the length of the spine in the direction of the current angles away from the base, basically corrects spine shrinking or stretching...
	static lengthAssert = function() {
		var _off = translatePos(angle, length, pitch);
		
		tipX = x + _off[0];
		tipY = y + _off[1];
		tipZ = z + _off[2];
	}
	
	static setFromDirs = function(dir, _pitch) {
		angle = dir;
		pitch = _pitch;
		
		var _off = translatePos(dir, _pitch);
		
		tipX = x + _off[0];
		tipY = y + _off[1];
		tipZ = z + _off[2];
	}
	
	
	
	//uhhh
}

