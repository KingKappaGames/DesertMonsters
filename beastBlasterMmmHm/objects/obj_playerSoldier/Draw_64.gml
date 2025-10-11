if (live_call()) return live_result;
	
draw_line(view_wport[0] * .88, 200, view_wport[0], 200);
draw_line_width(view_wport[0] * .91, 200, view_wport[0] * .91, 200 - legArray[0][2][2], 5);
draw_line_width(view_wport[0] * .92, 200, view_wport[0] * .92, 200 - legArray[0][1][2], 5);
draw_line_width(view_wport[0] * .93, 200, view_wport[0] * .93, 200 - legArray[0][0][2], 5);
draw_line_width(view_wport[0] * .96, 200, view_wport[0] * .96, 200 - legArray[1][2][2], 5);
draw_line_width(view_wport[0] * .97, 200, view_wport[0] * .97, 200 - legArray[1][1][2], 5);
draw_line_width(view_wport[0] * .98, 200, view_wport[0] * .98, 200 - legArray[1][0][2], 5);
draw_text(view_wport[0] * .875, 200, "foot-knee-hip");
draw_text(view_wport[0] * .89, 215, "Left");
draw_text(view_wport[0] * .94, 215, "Right");
draw_text(view_wport[0] * .89, 232, "Step height");

draw_line_width(view_wport[0] * .92, 300, view_wport[0] * .92 + dcos(kneeAngles[0]) * 30, 300 - dsin(kneeAngles[0]) * 30, 3);
draw_line_width(view_wport[0] * .96, 300, view_wport[0] * .96 + dcos(kneeAngles[1]) * 30, 300 - dsin(kneeAngles[1]) * 30, 3);
//
//var _vars = [stepUpdateDist, stepUpdateDistBase, stepTimings, legArray, debugClamp, debugPushAhead, debugOverStep];
//var _varNames = ["stepUpdateDist", "stepUpdateDistBase", "stepTimes", "legArray", "debugClamp", "debugPushAhead", "debugOverStep"];
//
//var _x = 100;
//var _y = 50;
//var _spacing = 25;
//
//var _varCount = array_length(_vars);
//for(var _i = 0; _i < _varCount; _i++) {
	//draw_set_halign(fa_right);
	//draw_text_transformed(_x - 10, _y + _i * _spacing, _varNames[_i], .7, .7, 0);
	//draw_set_halign(fa_left);
	//draw_text_transformed(_x + 10, _y + _i * _spacing, _vars[_i], .7, .7, 0);
//}