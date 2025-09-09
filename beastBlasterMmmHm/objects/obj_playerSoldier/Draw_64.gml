var _vars = [stepUpdateDist, stepUpdateDistBase, stepTimings, legArray, debugClamp, debugPushAhead, debugOverStep];
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