if (live_call()) return live_result;

#region movement and move contols
var _sprint = .75 + input_check("sprint", playerIndex) * .8;
var _inputs = [input_value("right", playerIndex), input_value("left", playerIndex), input_value("down", playerIndex), input_value("up", playerIndex)];
var _dirMoveStick = point_direction(0, 0, _inputs[0] - _inputs[1], _inputs[2] - _inputs[3]);
var _distMoveStick = clamp(point_distance(0, 0, _inputs[0] - _inputs[1], _inputs[2] - _inputs[3]), 0, 1);
xChange += dcos(_dirMoveStick) * moveSpeed * _sprint * _distMoveStick;
yChange -= dsin(_dirMoveStick) * moveSpeed * _sprint * _distMoveStick; // push in dir and distance of stick

x += xChange;
y += yChange;
feetY = y + feetOffY;
//depth = - (y + 60); // this project doesn't use depth... YET??? Maybe, I assume when i start making trees and walls and buildings I'll switch to -y depth but for now it's simpler to do surfaces with out any depth consideration. Especially the dust and debris... That'll be a pain with surfaces unless I go full layer stacking and do what main game does... Though I don't know if I have the height for it here... Too many layers required I think.
xChange *= speedDecay;
yChange *= speedDecay;

//moveSpeed += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * .001; // delete this
#endregion

#region leg stuff!!
var _speed = point_distance(0, 0, xChange, yChange);

legRotationSpeed = 4.1 * clamp(sqrt(_speed / 2), .17, .85); //proportional to speed
legRotation = (legRotation + legRotationSpeed) % 360;

hipYBob = lerp(hipYBob, clamp((-1 + _speed) * 7.5, -7.5, 0) + clamp((dsin(legRotation * (1.5 + sqrt(_speed) / 3) - 90) + .4) * _speed, -3, 15), .03);

placeFeetFull(point_direction(0, 0, xChange, yChange), _speed);
#endregion

#region gun placing in hand basics

var _aimToFacingDifference = angle_difference(point_direction(x, y, input_cursor_x(playerIndex), input_cursor_y(playerIndex)), directionFacing);
gunHoldDirection = (directionFacing + clamp(_aimToFacingDifference, -gunAimRange, gunAimRange)) % 360; // limits aiming held range to facing direction plus aiming range 
var _holdDistMult = 1;
var _mouseDist = point_distance(x, y, mouse_x, mouse_y);
if(abs(_aimToFacingDifference) >= gunAimRange) { // if aiming outside of range
	gunHeldDown = 1; // dont aim the gun up if not possible to aim at a given target, meh.
	_holdDistMult = .5; // heldDown = less dist
} else {
	gunHeldDown = 0; // aim normally
	
	_holdDistMult = .5 + min(_mouseDist / 220, 1.2);
}
weaponPosition[0] = x + dcos(gunHoldDirection) * gunHoldDistance * _holdDistMult + gunShakeX;
weaponPosition[1] = feetY - (dsin(gunHoldDirection) * gunHoldDistance * _holdDistMult + gunShakeY) * .7; // lower and bring in gun when not holding up
weaponPosition[2] = feetOffY - ((gunHeldDown * 6) + ((1 - gunHeldDown) * (3 - _holdDistMult * 17)));
if(point_distance(x, feetY, weaponPosition[0], weaponPosition[1]) > limbLength * 2) {
	weaponPosition[0] = x + dcos(gunHoldDirection) * 20;
	weaponPosition[1] = feetY - dsin(gunHoldDirection) * 13;
}

if(gunHoldDirection > 0 && gunHoldDirection < 180) {
	gunDrawBehind = 1;
} else {
	gunDrawBehind = 0;
}

gunShakeX *= .95;
gunShakeY *= .95;

#endregion

if(input_check_released("reload", playerIndex)) { // reload logic
	if(reloadingTimer > 0) {
		cancelReload();
	} else {
		startReload();
	}
}

if(input_check_released("gunSwitch", playerIndex)) { // swap weapons
	setTurret(clamp((gunType + 1) % 4, 1, 99));
}

if(reloadingTimer > 0) { // reload timers and ammo logic
	reloadingTimer--;
	if(reloadingTimer == 0) {
		ammoCurrent = ammoMax;
	}
}

#region camera setting
if(global.cameraSplitOption == true) {
	camX = lerp(camX, ((x + x + input_cursor_x(playerIndex)) / 3) - camera_get_view_width(view_camera[playerIndex]) / 2, .015);
	camY = lerp(camY, ((y + input_cursor_y(playerIndex)) / 2) - camera_get_view_height(view_camera[playerIndex]) / 2, .02);
	camera_set_view_pos(view_camera[playerIndex], camX, camY);
}
#endregion

if(input_check_released("characterSwitch", playerIndex)) { // get in and out of plane
	var _player = instance_create_layer(x, y, "Instances", obj_playerCar);
	_player.playerIndex = playerIndex;
	instance_destroy();
	_player.setCursorActive(_player.playerIndex); // in the destroy it sets mouse back to false so this needs to be after
	exit;
}

if(burstSpread > .01) { // decay gun bloom, (inaccuracy with constant shots)
	burstSpread = burstSpread * .995 - .001;
}
	
//ammoCurrent = ammoMax; // clean

event_inherited();

depth = -((y + feetOffY) - global.depthOffset);