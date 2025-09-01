/*var _vars = [stepUpdateDist, stepUpdateDistBase, stepTimings, legArray, debugClamp, debugPushAhead, debugOverStep];
var _varNames = ["stepUpdateDist", "stepUpdateDistBase", "stepTimes", "legArray", "debugClamp", "debugPushAhead", "debugOverStep"];

var _x = 100;
var _y = 50;
var _spacing = 25;

var _varCount = array_length(_vars);
for(var _i = 0; _i < _varCount; _i++) {
	draw_set_halign(fa_right);
	draw_text_transformed(_x - 10, _y + _i * _spacing, _varNames[_i], .7, .7, 0);
	draw_set_halign(fa_left);
	draw_text_transformed(_x + 10, _y + _i * _spacing, _vars[_i], .7, .7, 0);
}

/*

stepUpdateDistBase = 36;
stepUpdateDist = stepUpdateDistBase;

legArray = [  [[x, y, 0, legSegLen], [x, y, 0, legSegLen], [x, y, 0, legSegLen]], [[x, y, 0, legSegLen], [x, y, 0, legSegLen], [x, y, 0, legSegLen]]]; // 2 LEGS for now in nested structure, legs, nodes, coords (+ length, width) in that nesting
stepPositionsInitial = [ [x, y, 0], [x, y, 0] ]; // coords for each foot landed or come from during a step (aka 2 [x,y,z] for humans)
stepPositionsGoal = [ [x, y, 0], [x, y, 0] ]; // coords for each foot to land at or go to during a step (aka 2 [x,y,z] for humans)

stepTimings = [[0, current_time, current_time, 0], [0, current_time, current_time, 0]]; //[progress(updated by step), startTime, endTime, speedRef] (where speed reference is the speed that the thing was moving for that step to compare against for clipping a step on speed up or extending a step in slow down.

thighWidth = 20;
shinWidth = 10; // reset down below for size of animal
