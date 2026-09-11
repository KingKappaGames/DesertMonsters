/// @desc Function Turns a relative 3d point on a body ect into a 2d point in screen space
/// @param {any*} originY This is the y of the thing you're coming from. This isn't an actual 3d renderer so you must provide an anchor Y value to give the system some accuracy by default, to make the fake work.
/// @param {any*} xx 
/// @param {real} yy 
/// @param {real} zz 
/// @param {real} [perspectiveAngleFromGroundDegrees]=45 Description
function scr_get2DFrom3DPoint(originY, xx, yy, zz, perspectiveAngleFromGroundDegrees = 45) {
	var _x = xx;
	var _y = originY + (yy - originY) * dsin(perspectiveAngleFromGroundDegrees) - zz * dcos(perspectiveAngleFromGroundDegrees);
	
	return [_x, _y];
}