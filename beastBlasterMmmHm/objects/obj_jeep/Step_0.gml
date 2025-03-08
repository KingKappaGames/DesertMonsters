if (live_call()) return live_result;

var _sin = dsin(currentDirection);
var _cos = dcos(currentDirection);

#region input and movement
var _playerInput = 0;//input_value("up", playerIndex) - input_value("down", playerIndex);

xChange += _playerInput * acceleration * _cos;
yChange -= _playerInput * acceleration * _sin; // forward

var _speed = point_distance(0, 0, xChange, yChange);
prevSpeed = _speed;
var _travelDir = point_direction(0, 0, xChange, yChange);
var _carAllignment = abs(dcos(angle_difference(_travelDir, currentDirection))); // how alligned the car is with the direction it's traveling

var _frontBackCorrectionNeeded = 0;
if(abs(angle_difference(_travelDir, currentDirection)) > abs(angle_difference(_travelDir, currentDirection + 180))) { // choose which ever direction is more alligned to become the tire direction, basically, consider that if you're traveling straight backwards you are alligned but not in the right direction but still, no drifting... Consider it
	_frontBackCorrectionNeeded = 1; // back more alligned than front, flip direction
}

xChange = lerp(xChange, dcos(currentDirection + _frontBackCorrectionNeeded * 180) * _speed, power(_carAllignment, 3) * .043);
yChange = lerp(yChange, -dsin(currentDirection + _frontBackCorrectionNeeded * 180) * _speed, power(_carAllignment, 3) * .043); // drifting and sliding

if(_speed > .005) {
	xChange *= .994 + (_carAllignment / 400);
	yChange *= .994 + (_carAllignment / 400);
	
	xChange -= sign(xChange) * .005;
	yChange -= sign(yChange) * .005;
} else {
	xChange = 0;
	yChange = 0;
}

x += xChange; //TODO check during averaged camera that the place you're going is on screen...
y += yChange; // must be applied to all vehicle types I suppose, cars will just drive against nothing when they hit an edge, no big deal

if(_frontBackCorrectionNeeded == 0) {
	_frontBackCorrectionNeeded = -1;
}

var _turnInput = 0//input_value("left", playerIndex) - input_value("right", playerIndex);
directionChange += _turnInput * -_frontBackCorrectionNeeded * clamp(prevSpeed / 2, 0, 2.5) * .04 * (.2 + sqr(_carAllignment) * .8);
direction += (directionChange + 360) % 360; // cut down to 0-360
if(abs(directionChange) > .005) {
	directionChange = directionChange * (.999 - (_carAllignment / 28)) - sign(directionChange) / 1000;
} else {
	directionChange = 0;
}

if(random(15) < power(_speed, 3) * (1 - _carAllignment)) {
	part_particles_create(sys, x - _cos * 45, y + _sin * 45, sbHaze, ceil(_speed) /* * bulletDamage*/);
	if(irandom(5) == 0) {
		part_particles_create(sys, x - _cos * 45, y + _sin * 45, debris, 1 /* * bulletDamage*/); 
	}
}

#region collisions accidents
if(_speed > 1) {
	if(collision_rectangle(x - 18, y - 26, x + 18, y + 10, obj_enemy, false, true)) {
		var _hit = instance_nearest(x, y, obj_enemy); // probably the closest....
		var _hitDir = point_direction(x, y, _hit.x, _hit.y);
		xChange -= dcos(_hitDir) * _speed / 11;
		yChange += dsin(_hitDir) * _speed / 11;
		_hit.hurt(clamp(sqr(_speed / 2), 0, 5), _travelDir, true);
	}
}

var _hit = collision_rectangle(x - 15, y - 22, x + 15, y + 8, obj_palmTree, false, true);
if(instance_exists(_hit)) {
	var _hitDir = point_direction(x, y, _hit.x, _hit.y);
	xChange -= dcos(_hitDir) * _speed / 11;
	yChange += dsin(_hitDir) * _speed / 11;
	xChange *= .97;
	yChange *= .97;
	
	if(_hit.object_index == obj_palmTree) {
		_hit.hit(abs(_speed - point_distance(0, 0, xChange, yChange)));
	}
}
#endregion
#endregion

if(keyboard_check(ord("G"))) {
	currentDirection += .8;
}
if(keyboard_check(ord("H"))) {
	currentDirection -= .8;
}