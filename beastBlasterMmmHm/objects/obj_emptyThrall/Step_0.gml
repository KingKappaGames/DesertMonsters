if (live_call()) return live_result;


#region movement and move contols
var _cursorX = input_cursor_x(0);
var _cursorY = input_cursor_y(0);
aimDir = point_direction(x, y, _cursorX, _cursorY);
aimDist = point_distance(x, y, _cursorX, _cursorY);
var _sprint = .75 + input_check("sprint", 0) * .8;
var _inputs = [input_value("right", 0), input_value("left", 0), input_value("down", 0), input_value("up", 0)];
var _dirMoveStick = point_direction(0, 0, _inputs[0] - _inputs[1], _inputs[2] - _inputs[3]);
var _distMoveStick = clamp(point_distance(0, 0, _inputs[0] - _inputs[1], _inputs[2] - _inputs[3]), 0, 1);
xChange += dcos(_dirMoveStick) * moveSpeed * _sprint * _distMoveStick;
yChange -= dsin(_dirMoveStick) * moveSpeed * _sprint * _distMoveStick; // push in dir and distance of stick

x += xChange;
y += yChange;
//depth = - (y + 60); // this project doesn't use depth... YET??? Maybe, I assume when i start making trees and walls and buildings I'll switch to -y depth but for now it's simpler to do surfaces with out any depth consideration. Especially the dust and debris... That'll be a pain with surfaces unless I go full layer stacking and do what main game does... Though I don't know if I have the height for it here... Too many layers required I think.
xChange *= speedDecay;
yChange *= speedDecay;

previousSpeed = currentSpeed;
currentSpeed = point_distance(0, 0, xChange, yChange);

previousDir = currentDir;
currentDir = point_direction(0, 0, xChange, yChange);

script_mdlStep();

#region player controls, camera, and info maintenance
//
//if(input_check_released("reload", playerIndex)) { // reload logic
	//if(reloadingTimer > 0) {
		//cancelReload();
	//} else {
		//startReload();
	//}
//}
//
//if(input_check_released("gunSwitch", playerIndex)) { // swap weapons
	//setTurret(clamp((gunType + 1) % 4, 1, 99));
//}

//if(reloadingTimer > 0) { // reload timers and ammo logic
	//reloadingTimer--;
	//if(reloadingTimer == 0) {
		//ammoCurrent = ammoMax;
	//}
//}

	
//ammoCurrent = ammoMax; // clean

depth = -((y + feetOffY) - global.depthOffset);

#endregion

if(keyboard_check(ord("Y"))) {
	feetOffY += 1;
} else if(keyboard_check(ord("H"))) { // move the spine up and down but not actually..? I'm not sure where the disconnect is
	feetOffY -= 1;
}

debugClamp *= 1 + (keyboard_check(ord("U")) - keyboard_check(ord("J"))) * .0035;
debugOverStep *= 1 + (keyboard_check(ord("I")) - keyboard_check(ord("K"))) * .0035;
debugPushAhead *= 1 + (keyboard_check(ord("O")) - keyboard_check(ord("L"))) * .0035;