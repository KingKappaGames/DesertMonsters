if (live_call()) return live_result;

var _playerSin = dsin(playerDirection);
var _playerCos = dcos(playerDirection);
var _playerInput = input_value("up", playerIndex) - input_value("down", playerIndex);

xChange += _playerInput * playerAcceleration * _playerCos;
yChange -= _playerInput * playerAcceleration * _playerSin; // forward

var _speed = point_distance(0, 0, xChange, yChange);
prevSpeed = _speed;
var _travelDir = point_direction(0, 0, xChange, yChange);
var _carAllignment = abs(dcos(angle_difference(_travelDir, playerDirection))); // how alligned the car is with the direction it's traveling

var _frontBackCorrectionNeeded = 0;
if(abs(angle_difference(_travelDir, playerDirection)) > abs(angle_difference(_travelDir, playerDirection + 180))) { // choose which ever direction is more alligned to become the tire direction, basically, consider that if you're traveling straight backwards you are alligned but not in the right direction but still, no drifting... Consider it
	_frontBackCorrectionNeeded = 1; // back more alligned than front, flip direction
}

xChange = lerp(xChange, dcos(playerDirection + _frontBackCorrectionNeeded * 180) * _speed, power(_carAllignment, 3) * .043);
yChange = lerp(yChange, -dsin(playerDirection + _frontBackCorrectionNeeded * 180) * _speed, power(_carAllignment, 3) * .043); // drifting and sliding

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

var _turnInput = input_value("left", playerIndex) - input_value("right", playerIndex);
playerDirectionChange += _turnInput * -_frontBackCorrectionNeeded * clamp(prevSpeed / 2, 0, 2.5) * .04 * (.2 + sqr(_carAllignment) * .8);
playerDirection += (playerDirectionChange + 360) % 360; // cut down to 0-360
if(abs(playerDirectionChange) > .005) {
	playerDirectionChange = playerDirectionChange * (.999 - (_carAllignment / 28)) - sign(playerDirectionChange) / 1000;
} else {
	playerDirectionChange = 0;
}

if(random(15) < power(_speed, 3) * (1 - _carAllignment)) {
	part_particles_create(sys, x - _playerCos * 45, y + _playerSin * 45, sbHaze, ceil(_speed) /* * bulletDamage*/);
	if(irandom(5) == 0) {
		part_particles_create(sys, x - _playerCos * 45, y + _playerSin * 45, debris, 1 /* * bulletDamage*/); 
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

#region camera setting
if(global.cameraSplitOption == true) {
	camera_set_view_pos(view_camera[playerIndex], x - camera_get_view_width(view_camera[playerIndex]) / 2 + xChange * 10, y - camera_get_view_height(view_camera[playerIndex]) / 2 + yChange * 10);
}
#endregion

if(input_check_released("characterSwitch", playerIndex)) {
	var _player = instance_create_layer(x, y, "Instances", obj_playerShip);
	_player.playerIndex = playerIndex;
	instance_destroy();
	_player.setCursorActive(_player.playerIndex); // in the destroy it sets mouse back to false so this needs to be after
	exit;
}

if(input_check_released("gunSwitch", playerIndex)) {
	setTurret((gunType + 1) % 3);
}

event_inherited();
