if (live_call()) return live_result;

if(minigunCharge > 0) {
	minigunCharge--;
}

var _playerSin = dsin(playerDirection);
var _playerCos = dcos(playerDirection);
var _playerInput = input_value("up", playerIndex) - input_value("down", playerIndex);

if(height > 1) {
	xChange += _playerInput * playerAcceleration * _playerCos;
	yChange -= _playerInput * playerAcceleration * _playerSin; // forward
	
	var _turnInput = input_value("left", playerIndex) - input_value("right", playerIndex);
	playerDirectionChange += _turnInput * .007; 
	playerDirection += (playerDirectionChange + 360) % 360; // cut down to 0-360
} else {
	xChange *= .97;
	yChange *= .97;
	playerDirectionChange *= .96;
}

var _speed = point_distance(0, 0, xChange, yChange);
prevSpeed = _speed;
var _travelDir = point_direction(0, 0, xChange, yChange);

#region raising and lowering
if(input_check_pressed("drop", playerIndex)) {
	heightChangeSign *= -1; // flip direction of heli altitude change (this is mostly because I don't have the buttons for up and down and not interfere.)
	if(heightChangeSign < 0) {
		audio_play_sound(snd_lowTone, 0, 0);
	} else {
		audio_play_sound(snd_highTone, 0, 0);
	}
} else if(input_check("drop", playerIndex)) {
	heightChange -= heightChangeSign * .01;
	global.generator.updatePerlinGrid(playerIndex);
	if(height > 100) {
		depth = -1002;
	} else {
		depth = -1000;
	}
}
heightChange *= .985;
#endregion

if(_speed > .005) {
	xChange *= .994;
	yChange *= .994;
} else {
	xChange = 0;
	yChange = 0;
}
playerDirectionChange *= .999;

x += xChange; //TODO check during averaged camera that the place you're going is on screen...
y += yChange; // must be applied to all vehicle types I suppose, cars will just drive against nothing when they hit an edge, no big deal
height += heightChange;

if(height < 0) {
	height = 0;
	//damage of heightChange;
	heightChange *= -.4;
}

if(height > 1) {
	bladeSpinSpeed = lerp(bladeSpinSpeed, bladeSpinSpeedMax, .01);
} else {
	bladeSpinSpeed *= .9985;
}

bladeSpin += bladeSpinSpeed;

if(height < 100) { // near ground specials
	if(bladeSpinSpeed * (1 - height / 100) > random(4) + 1.9) { // dust effects when near ground
		var _heightFactor = 1.2 - (height / 100);
		repeat(2) {
			var _x = irandom_range(-bladeLength * (1.5 - _heightFactor) - 30, bladeLength * (1.5 - _heightFactor) + 30);
			var _y = irandom_range(-bladeLength * (1.5 - _heightFactor) - 30, bladeLength * (1.5 - _heightFactor) + 30) * .8;
			var _dustDir = point_direction(0, 0, _x, _y);
			var _dustDist = point_distance(0, 0, _x, _y);
			var _power = (1 - (_dustDist / 300)) * (bladeSpinSpeed / bladeSpinSpeedMax);
			part_type_life(heliDust, _heightFactor * 160 * _power, _heightFactor * 250 * _power);
			part_type_speed(heliDust, _heightFactor * 2.6 * _power, _heightFactor * _power * 4.1, -.04, 0);
			part_type_direction(heliDust, _dustDir - 4, _dustDir + 4, .25, 0); 
			part_particles_create(sys, x + _x, y + _y, heliDust, 1);
		}
	} 
	
	#region collisions accidents when near ground
	if(height < 50) {
		if(bladeSpinSpeed > .3) {
			if(collision_circle(x, y, bladeLength - 3, obj_enemy, false, true)) {
				var _hit = instance_nearest(x, y, obj_enemy);
				var _hitDir = point_direction(x, y, _hit.x, _hit.y) + 90;
				_hit.hurt(bladeSpinSpeed, _travelDir, true);
				bladeSpinSpeed = bladeSpinSpeed - (bladeSpinSpeed * 2 * (1 - (bladeSpinSpeed / bladeSpinSpeedMax))) - (bladeSpinSpeed * .07);
			}
		}
	}
	#endregion
}

#region camera setting
if(global.cameraSplitOption == true) {
	camera_set_view_size(view_camera[playerIndex], global.camWidthSingle * (1 + height / 800), global.camHeightSingle * (1 + height / 800));
	camera_set_view_pos(view_camera[playerIndex], x - camera_get_view_width(view_camera[playerIndex]) / 2 + xChange * 10, y - camera_get_view_height(view_camera[playerIndex]) / 2 + yChange * 10);
	input_cursor_limit_aabb(camera_get_view_x(view_camera[playerIndex]), camera_get_view_y(view_camera[playerIndex]), camera_get_view_x(view_camera[playerIndex]) + camera_get_view_width(view_camera[playerIndex]), camera_get_view_y(view_camera[playerIndex]) + camera_get_view_height(view_camera[playerIndex]), playerIndex);
} else {
	camera_set_view_size(view_camera[0], global.camera.camWidth * (1 + height / 800), global.camera.camHeight * (1 + height / 800));
	with(obj_playerParent) {
		input_cursor_limit_aabb(camera_get_view_x(view_camera[0]), camera_get_view_y(view_camera[0]), camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]), camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]), playerIndex);
	}
}
#endregion

if(input_check_released("characterSwitch", playerIndex)) {
	var _player = instance_create_layer(x, y, "Instances", obj_playerSoldier);
	_player.playerIndex = playerIndex;
	instance_destroy();
	_player.setCursorActive(_player.playerIndex); // in the destroy it sets mouse back to false so this needs to be after
	exit;
}

if(input_check_released("gunSwitch", playerIndex)) {
	setTurret((gunType + 1) % 3);
}

event_inherited();
