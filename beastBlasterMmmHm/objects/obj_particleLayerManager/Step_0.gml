//if (live_call()) return live_result;

if(mouse_check_button_released(mb_middle)) {
	global.players[0].y += 500;//choose(irandom(300), irandom(2000));
}

if(keyboard_check_released(ord("R"))) {
	global.players[0].y = 1000;
}

moveCollection();


var _layerAdd = round(((mouse_y - (previousEdgeY))) / sysSpacing) - 1; // the mouse layer is accurate
var _sysIndex = (currentSysEdge + _layerAdd) % sysCount;
if(_sysIndex < 0) {
	_sysIndex = sysCount + (_sysIndex - 1);
}
mouseLayer = _sysIndex;

if(keyboard_check(vk_control)) {
	script_createPartDepth(drawPart, mouse_x, mouse_y, 10, make_color_rgb(mouse_y % 256, 0, 0));
}