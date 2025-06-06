if (live_call()) return live_result;

event_inherited();

//draw_text(x, y - 100, weaponPosition[2]);

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
var _jostle = (dsin(legRotation * (1.5 + sqrt(_speed) / 3) - 90) + .4) * sqrt(_speed) * 3;

var _leanAheadX = xChange * 8; // keep consistent i suppose
var _leanAheadY = clamp(yChange, 0, 99) * 8; // keep consistent i suppose
var _leanAheadDir = point_direction(0, 0, xChange * 9, -spineMain.length + yChange); // the 30 here is the distance of the spine while standing straight up i guess? Needs to be standarized and set up proper
spineMain.angle = _leanAheadDir;
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
	script_drawWeapon(gunSprite, weaponPosition, gunHoldDirection, _heldDownAngleAdjust, spineMain.x - _surfMidX, spineMain.y - _surfMidY); // draw gun in front if supposed to be in front
}

mark(weaponPosition[0], weaponPosition[1])
#endregion

#region draw legs and feet and body

var _cosFacing = dcos(_dirMoving);
var _sinFacing = dsin(_dirMoving);

#region set initial hip left and right positions
var _hipLX = x + _leanAheadX - _sinFacing * hipWidth;
var _hipLY = y + hipYOff + _jostle + _leanAheadY - _cosFacing * hipWidth;
var _hipRX = x + _leanAheadX + _sinFacing * hipWidth;
var _hipRY = y + hipYOff + _jostle + _leanAheadY + _cosFacing * hipWidth;
#endregion

#region get distances and directions for both feet from hip
var _distLFoot = point_distance(_hipLX, _hipLY, footLX, footLY); // dist
var _distRFoot = point_distance(_hipRX, _hipRY, footRX, footRY);
var _dirLFoot = point_direction(_hipLX, _hipLY, footLX, footLY); // dir
var _dirRFoot = point_direction(_hipRX, _hipRY, footRX, footRY);
#endregion

#region clamp the foot distance to leg length to create rounded extensions, more of a fix or QA check than a feature but does create mild angled foot movements too
if(_distLFoot > legSegLen * 2) {
	footLX = _hipLX + dcos(_dirLFoot) * legSegLen * 2; // left
	footLY = _hipLY - dsin(_dirLFoot) * legSegLen * 2; 
	_distLFoot = legSegLen * 2;
}
if(_distRFoot > legSegLen * 2) {
	footRX = _hipRX + dcos(_dirRFoot) * legSegLen * 2; // right
	footRY = _hipRY - dsin(_dirRFoot) * legSegLen * 2;
	_distRFoot = legSegLen * 2;
}
#endregion

#region getting joint positions from trig distances
var _footLJointDist = sqrt(clamp(sqr(legSegLen) - sqr(_distLFoot / 2), 0, 999999)); // outwardness of joint
var _footRJointDist = sqrt(clamp(sqr(legSegLen) - sqr(_distRFoot / 2), 0, 999999)); // please stop returning negatives to the sqrt functions -managment

var _legMidLX = _hipLX + (footLX - _hipLX) / 2;
var _legMidLY = _hipLY + (footLY - _hipLY) / 2; // visual mid point simply between hip and foot
var _legMidRX = _hipRX + (footRX - _hipRX) / 2;
var _legMidRY = _hipRY + (footRY - _hipRY) / 2;

var _jointLX = dcos(_dirLFoot + 90) * _cosFacing * _footLJointDist;
var _jointLY = dsin(_dirLFoot + 90) * -sign(_cosFacing) * _footLJointDist; // final joint positions
var _jointRX = dcos(_dirRFoot + 90) * _cosFacing * _footRJointDist; 
var _jointRY = dsin(_dirRFoot + 90) * -sign(_cosFacing) * _footRJointDist;
#endregion

#region draw thigh and calf segments and circle to round the knee and close visual gap

var _offX = x - _surfMidX;
var _offY = y - _surfMidY;

draw_set_color(c_red);
draw_line_width(_hipRX - _offX, _hipRY - _offY, _legMidRX + _jointRX - _offX, _legMidRY + _jointRY - _offY, 5); // right leg
draw_line_width(_legMidRX + _jointRX - _offX, _legMidRY + _jointRY - _offY, footRX - _offX, footRY - _offY, 3);

draw_line_width(_hipLX - _offX, _hipLY - _offY, _legMidLX + _jointLX - _offX, _legMidLY + _jointLY - _offY, 5); // left leg
draw_line_width(_legMidLX + _jointLX - _offX, _legMidLY + _jointLY - _offY, footLX - _offX, footLY - _offY, 3);

draw_circle(_legMidRX + _jointRX - _offX, _legMidRY + _jointRY - _offY, 2, false); // both knees
draw_circle(_legMidLX + _jointLX - _offX, _legMidLY + _jointLY - _offY, 2, false);
draw_set_color(c_white);
#endregion



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
	script_drawWeapon(gunSprite, weaponPosition, gunHoldDirection, _heldDownAngleAdjust, spineMain.x - _surfMidX, spineMain.y - _surfMidY); // draw gun behind if supposed to be behind
}

surface_reset_target();

//var _ang = current_time / 10; 
//var _dist = (_surfMidX) * 1.4142; // the radius of the surf is the sqrt((width/2^2) + (height/2^2)) not just width / 2 but also just paste in a real for sqrt(2) which is that number
//draw_surface_ext(_surf, x + dcos(_ang + 135) * _dist, y - dsin(_ang + 135) * _dist, 1, 1, _ang, c_white, 1);
draw_surface(_surf, x - _surfMidX, y - _surfMidY);