/// @desc Function Allows you to pass directions and how far and it will returns x,y,z offset from this "movement", the third axis is optional
/// @param {any*} dir The horizontal direction
/// @param {any*} dist How far to move
/// @param {any*} [pitch] The pitch (vertical angle) to move in
/// @returns {array} Returns an array of either x/y or x/y/z if pitch is given (and so 3d expected)
function translatePos(dir, dist, pitch) {
	var _x = lengthdir_x(dist, dir);
	var _y = lengthdir_y(dist, dir);
	
	var _heightFactor = dsin(pitch);
	var _hSquish = sqrt(1 - sqr(_heightFactor)); // since we have vertical distance has to be decreased horizontally to maintain net distance 
	
	_x = _x * _hSquish;
	_y = _y * _hSquish;
	var _z = _heightFactor * dist;
	
	return [_x, _y, _z];
}

