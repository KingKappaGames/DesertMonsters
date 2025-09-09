//if (live_call()) return live_result;

event_inherited();

//draw_text(x, y - 100, weaponPosition[2]);

//spine nonsense find a better place for this..
var _leanAheadX = xChange * 8; // keep consistent i suppose
var _leanAheadY = clamp(yChange, 0, 99) * 8; // keep consistent i suppose
var _leanAheadDir = point_direction(0, 0, xChange * 9, -spineMain.length + yChange); // the 30 here is the distance of the spine while standing straight up i guess? Needs to be standarized and set up proper
spineMain.angle = _leanAheadDir;

if(keyboard_check(ord("N"))) {
	spineMain.angle = point_direction(x, y, mouse_x, mouse_y); // testing cheat direction
}

var _spineX = spineMain.x;
var _spineY = spineMain.y; // setting spine locals

draw_set_alpha(.75);
//draw_circle_color(_spineX + _leanAheadX, _spineY, 16, #333333, #333333, false); // shadow! Remove when you have a better way!
draw_set_alpha(1);

var _surf = getSurf(); // the surface you draw to
var _surfMidX = surface_get_width(_surf) / 2;
var _surfMidY = surface_get_height(_surf) / 2;

surface_set_target(_surf);

draw_clear_alpha(c_white, 0);

#region bunch of things for general positioning, needs to be established first
//var _dirMoving = point_direction(x, y, mouse_x, mouse_y);
var _dirMoving = point_direction(0, 0, xChange, yChange);
directionFacing = _dirMoving;

var _viewCompress = .5 + abs(dsin(directionFacing) / 2);
var _speed = point_distance(0, 0, xChange, yChange);
var _jostle = (dsin(legRotation * .5 * (1.5 + sqrt(_speed) / 3) - 90) + .4) * sqrt(_speed) * 3;
#endregion

#region draw gun
var _heldDownAngleAdjust = 0;
if(gunHeldDown) {
	_heldDownAngleAdjust = (angle_difference(270, gunHoldDirection) / 3); // set the holding down effect if out of aim range (when aiming away hold gun down to side)
	var _upAngleDiff = angle_difference(gunHoldDirection, 90);
	if(abs(_upAngleDiff) < 90) {
		_heldDownAngleAdjust *= clamp(abs(_upAngleDiff) - 45, 0, 45) / 45; // reduce adjust as it approaches upward hold angle because pushing an up gun towards down doesn't make any sense
	}
}

weaponPosition[0] += _leanAheadX;
weaponPosition[1] += _leanAheadY + _jostle / 2; // position the gun with body movement variations

if(gunDrawBehind) {
	script_drawWeapon(gunSprite, weaponPosition, gunHoldDirection, _heldDownAngleAdjust, _spineX - _surfMidX, _spineY - _surfMidY); // draw gun in front if supposed to be in front
}

#endregion

#region draw legs and feet and body

var _cosFacing = dcos(_dirMoving);
var _sinFacing = dsin(_dirMoving);

#endregion


array_sort(bodyComponents, function(elementCurrent, elementNext, originalOrder) // sort drawing based on visual height
{             
	return (-dsin(directionFacing + elementCurrent.rotationRelative) * elementCurrent.distance) - (-dsin(directionFacing + elementNext.rotationRelative) * elementNext.distance);
	//if(is_array(elementCurrent[0])) {
	//	return elementCurrent[11][2][1] - (-dsin(directionFacing + elementNext[2]) * elementNext[4]); // the 11-2-1 is the y value of the 3rd node of the limb ( [11] )  ( limb component! )
	//} else {
	//	return (-dsin(directionFacing + elementCurrent[2]) * elementCurrent[4]) - (-dsin(directionFacing + elementNext[2]) * elementNext[4]); // normal component
	//}  // (sorting to the end the limb, instead of start (looks bad!)
});

var _counter = 0; 
//draw the components in front
_counter += script_drawComponents(0, _leanAheadX, _leanAheadY, _jostle, _cosFacing, _dirMoving, true);


//draw the rest of the body components in front of body
script_drawComponents(_counter, _leanAheadX, _leanAheadY, _jostle, _cosFacing, _dirMoving, false);

if(!gunDrawBehind) {
	script_drawWeapon(gunSprite, weaponPosition, gunHoldDirection, _heldDownAngleAdjust, _spineX - _surfMidX, _spineY - _surfMidY); // draw gun behind if supposed to be behind
}

surface_reset_target();



//var _ang = current_time / 10; 
//var _dist = (_surfMidX) * 1.4142; // the radius of the surf is the sqrt((width/2^2) + (height/2^2)) not just width / 2 but also just paste in a real for sqrt(2) which is that number
//draw_surface_ext(_surf, x + dcos(_ang + 135) * _dist, y - dsin(_ang + 135) * _dist, 1, 1, _ang, c_white, 1);
draw_surface(_surf, _spineX - _surfMidX, _spineY - _surfMidY);

draw_text(x + 100, y, feetOffY)



draw_set_color(c_black);
draw_circle(spineMain.x, spineMain.y, stepUpdateDist, true);
draw_set_color(c_white);

draw_circle(spineMain.x, spineMain.y, 2, true)
draw_circle_color(x, y, 3, c_green, c_green, false)
draw_text(x + 170, y - 20, feetOffY)

draw_circle_color(stepPositionsGoal[0][0], stepPositionsGoal[0][1], 3, c_red, c_red, false);
draw_circle_color(stepPositionsGoal[1][0], stepPositionsGoal[1][1], 3, c_red, c_red, false);

draw_circle_color(stepPositionsInitial[0][0], stepPositionsInitial[0][1], 3, c_dkgray, c_dkgray, false);
draw_circle_color(stepPositionsInitial[1][0], stepPositionsInitial[1][1], 3, c_dkgray, c_dkgray, false);

//draw_line(x + 200, spineMain.y - spineMain.height * .65, x + 200, feetY);
//draw_line_color(x + 180, y, x + 180, feetY, c_black, c_black);

draw_line(x + dcos(currentDir) * 10, y - dsin(currentDir) * 10, x, y);

var _speedChange = sqr(abs(currentSpeed - previousSpeed) * 2);
var _dirChange = sqrt(1 + (abs(currentDir - previousDir) / 22.5)) - 1;

draw_line(x + 100, y, x + 100, y - 150 * (_speedChange + _dirChange));
draw_line(x + 130, y, x + 130, y - 150 * _dirChange);
draw_line(x + 160, y, x + 160, y - 150 * _speedChange);








































