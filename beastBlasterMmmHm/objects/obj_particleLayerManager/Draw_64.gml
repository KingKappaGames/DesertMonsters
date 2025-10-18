/*if(live_call()) { return live_result }

draw_text(330, 320, "edge layer depth: " + string(particleLayerDepthArray[currentSysEdge]));
draw_text(330, 340, "sys spacing: " + string(sysSpacing));
draw_text(330, 360, "margin height: " + string(sysUpdateRange));
draw_text(330, 400, "systemEdge: " + string(currentSysEdge));
draw_text(330, 420, "prevCamY: " + string(previousCamY));
draw_text(330, 460, "mouseY: " + string(mouse_y));
draw_text(330, 480, "mouse layer: " + string(mouseLayer) + " and the DEPTH: " + string(particleLayerDepthArray[mouseLayer]));
draw_text(330, 500, "discrepency: " + string(-(mouse_y) - particleLayerDepthArray[mouseLayer]));
draw_text(330, 520, "camHeight: " + string(camera_get_view_height(view_camera[0])));

for(var _depthI = 1; _depthI < sysCount; _depthI++) {
	if(abs(_depthI - currentSysEdge) < 2) {
		draw_text_transformed_color(700 + dcos(_depthI * 90) * 28, _depthI * 3.3, particleLayerDepthArray[_depthI], .52, .52, 0, c_red, c_red, c_red, c_red, 1);
	} else {
		draw_text_transformed(700 + dcos(_depthI * 90) * 28, _depthI * 3.3, particleLayerDepthArray[_depthI], .45, .45, 0);
	}
	if(_depthI % 4 == 0) {
		if(_depthI == currentSysEdge) {
			draw_text_transformed_color(750 + dcos(_depthI * 90) * 28, _depthI * 3.3, _depthI, .75, .75, 0, c_red, c_red, c_red, c_red, 1);
		} else {
			draw_text_transformed(750 + dcos(_depthI * 90) * 28, _depthI * 3.3, _depthI, .5, .5, 0);
		}
	}
}

//range 0 - 5000
var _screenH = view_hport[0];
var _range = _screenH * .8;
var _sysTop = previousCamY - sysUpdateRange;
var _camY = camera_get_view_y(view_camera[0]);

var _x = 500;
draw_line_width_color(_x, _screenH * .1, _x, _screenH * .9, 10, c_white, c_white);
draw_line_width_color(_x, _screenH * .1 + _range * (_sysTop / 5000), _x, _screenH * .1 + _range * ((_sysTop + camera_get_view_height(view_camera[0]) + sysUpdateRange * 2) / 5000), 15, c_green, c_green);
draw_line_width_color(_x, _screenH * .1 + _range * (_camY / 5000), _x, _screenH * .1 + _range * ((_camY + camera_get_view_height(view_camera[0])) / 5000), 10, c_red, c_red);
//draw_line_width_color(_x, _screenH * .1, _x, _screenH * .9, 10, c_green, c_green);

var _edgeY;
for(var _edgeI = -3; _edgeI < 4; _edgeI++) {
	_edgeY = _screenH * .1 + _range * (previousEdgeY + _edgeI * sysCount * sysSpacing) / 5000;
	draw_line_width_color(_x - 50, _edgeY, _x + 50, _edgeY, 3, c_blue, c_blue);
}
var _firstY;
for(var _firstI = -3; _firstI < 4; _firstI++) {
	_firstY = _screenH * .1 + _range * (-particleLayerDepthArray[0] + (sysCount * _firstI) * sysSpacing) / 5000;
	draw_line_width_color(_x - 50, _firstY, _x + 50, _firstY, 3, c_olive, c_olive);
}
var _mouseY = _screenH * .1 + _range * (mouse_y) / 5000;
draw_line_width_color(_x - 50, _mouseY, _x + 50, _mouseY, 3, c_fuchsia, c_fuchsia);

draw_set_color(c_black);
var _depth;
for(var _i = 0; _i < sysCount; _i += 4) {
	_depth = -particleLayerDepthArray[_i] / 5000;
	draw_line(_x - 20, _screenH * .1 + _range * _depth, _x + 20 + _i * .08, _screenH * .1 + _range * _depth);
}
draw_set_color(c_white);