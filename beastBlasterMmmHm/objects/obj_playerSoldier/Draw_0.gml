if (live_call()) return live_result;

event_inherited();

#region bunch of things for general positioning, needs to be established first
//var _dirMoving = point_direction(x, y, mouse_x, mouse_y);
var _dirMoving = point_direction(0, 0, xChange, yChange);
directionFacing = _dirMoving

var _viewCompress = .5 + abs(dsin(directionFacing) / 2);
var _speed = point_distance(0, 0, xChange, yChange);
var _jostle = (dsin(legRotation * (1.5 + sqrt(_speed) / 3) - 90) + .4) * sqrt(_speed) * 3;

var _leanAheadX = xChange * 9; // keep consistent i suppose
var _leanAheadY = clamp(yChange, 0, 99) * 9; // keep consistent i suppose
#endregion

#region draw gun
var _heldDownAngleAdjust = 0;
if(gunHeldDown) {
	_heldDownAngleAdjust = (angle_difference(270, gunHoldDirection) / 3);
	var _upAngleDiff = angle_difference(gunHoldDirection, 90);
	if(abs(_upAngleDiff) < 90) {
		_heldDownAngleAdjust *= clamp(abs(_upAngleDiff) - 45, 0, 45) / 45; // reduce adjust as it approaches upward hold angle because pushing an up gun towards down doesn't make any sense
	}
}

if(gunDrawBehind) {
	var _gunLayers = sprite_get_number(gunSprite);
	var _yAdd = -3; // the up push of each layer
	
	for(var _i = 0; _i < _gunLayers; _i++) {
		draw_sprite_ext(gunSprite, _i, gunX + _leanAheadX, gunY + _leanAheadY + _yAdd * _i + _jostle / 2, .65 + abs(dcos(gunHoldDirection)) * .35, 1, gunHoldDirection + _heldDownAngleAdjust, c_white, 1);
	}
}
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
draw_set_color(c_red);
draw_line_width(_hipRX, _hipRY, _legMidRX + _jointRX, _legMidRY + _jointRY, 5); // right leg
draw_line_width(_legMidRX + _jointRX, _legMidRY + _jointRY, footRX, footRY, 3);

draw_line_width(_hipLX, _hipLY, _legMidLX + _jointLX, _legMidLY + _jointLY, 5); // left leg
draw_line_width(_legMidLX + _jointLX, _legMidLY + _jointLY, footLX, footLY, 3);

draw_circle(_legMidRX + _jointRX, _legMidRY + _jointRY, 2, false); // both knees
draw_circle(_legMidLX + _jointLX, _legMidLY + _jointLY, 2, false);
draw_set_color(c_white);
#endregion

//BODY
//draw_rectangle(x - 8 + _leanAheadX, y + _jostle + _leanAheadY - 14, x + 8 + _leanAheadX, y + 9 + _jostle + _leanAheadY, false); // BODY
//draw_sprite_ext(bodySprite, 0, x + _leanAheadX, y + _jostle + _leanAheadY, 1, 1, 0, c_white, 1); // lean body towards movement, scale based on image like everything else?


#endregion

#region body component drawing

array_sort(bodyComponents, function(elementCurrent, elementNext, originalOrder) // sort drawing based on visual height
{                
	return (-dsin(directionFacing + elementCurrent[2]) * elementCurrent[4]) - (-dsin(directionFacing + elementNext[2]) * elementNext[4]);
});

//msg(bodyComponents);

var _x = 0, _y = 0;
var _bodyOut = 14; // standard body distance? OR should this be a value in the array?
var _componentCount = array_length(bodyComponents);
var _counter = 0, _ang = 0;
for(var _i = 0; _i < _componentCount; _i++) {
	var _bodyPart = bodyComponents[_i];
	_ang = (directionFacing + _bodyPart[2]) % 360;
	_bodyOut = _bodyPart[4];
	if(_ang > 3 && _ang < 177) { // so maybe I shouldn't but this puts them further back than flat, a slightly behind thing by 3 degrees will go in front, this is maybe to give them a bit of covering thickness? But I do kind of hate the canabalistic effect of forcing up here.
		var _netAngle = _dirMoving + _bodyPart[2];
		var _imageInfo = _bodyPart[1];
		_x = x + _leanAheadX + dcos(_netAngle) * _bodyOut;
		_y = y + _leanAheadY - dsin(_netAngle) * _bodyOut * .6 + _bodyPart[3] + _jostle;
		var _compress = 1;
		if(_bodyPart[8] != 1) {
			_compress = dsin(_netAngle + _bodyPart[7]) * (1 - _bodyPart[8]);
			_compress += _bodyPart[8] * sign(_compress);
		}
		var _directionImg = floor(((((_netAngle + _bodyPart[10]) + 360) / 360) % 1) * (array_length(_imageInfo)));
		draw_sprite_ext(_bodyPart[0], is_array(_imageInfo) ? _imageInfo[_directionImg] : _imageInfo, _x, _y, _bodyPart[5] * _compress, _bodyPart[6], 0, _bodyPart[9], 1);
		//draw behind components?
		_counter++;
	} else {
		break;
	}
}

#endregion

#region draw the rest of the body components in front of body
for(var _i = _counter; _i < _componentCount; _i++) {
	var _bodyPart = bodyComponents[_i];
	_bodyOut = _bodyPart[4];
	var _netAngle = _dirMoving + _bodyPart[2];
	var _imageInfo = _bodyPart[1];
	_x = x + _leanAheadX + dcos(_netAngle) * _bodyOut;
	_y = y + _leanAheadY - dsin(_netAngle) * _bodyOut * .6 + _bodyPart[3] + _jostle;
	var _compress = 1;
	if(_bodyPart[8] != 1) {
		_compress = dsin(_netAngle + _bodyPart[7]) * (1 - _bodyPart[8]);
		_compress += _bodyPart[8] * sign(_compress);
	}
	var _directionImg = floor(((((_netAngle + _bodyPart[10]) + 360) / 360) % 1) * (array_length(_imageInfo)));
	draw_sprite_ext(_bodyPart[0], is_array(_imageInfo) ? _imageInfo[_directionImg] : _imageInfo, _x, _y, _bodyPart[5] * _compress, _bodyPart[6], 0, _bodyPart[9], 1);
}
#endregion

if(!gunDrawBehind) {
	var _gunLayers = sprite_get_number(gunSprite);
	var _yAdd = -3; // the up push of each layer
	for(var _i = 0; _i < _gunLayers; _i++) {
		draw_sprite_ext(gunSprite, _i, gunX + _leanAheadX, gunY + _leanAheadY + _yAdd * _i + _jostle / 2, .65 + abs(dcos(gunHoldDirection)) * .35, 1, gunHoldDirection + _heldDownAngleAdjust, c_white, 1);
	}
}