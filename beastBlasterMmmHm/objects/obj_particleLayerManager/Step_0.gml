if (live_call()) return live_result;

var _camY = (camera_get_view_y(view_camera[0]) div sysSpacing) * sysSpacing; // cam is correctly rounded to 4
var _depthChange = abs(previousCamY - _camY) // depth change ranges 0 - 100 in 4s (correct)

if(_depthChange >= (sysUpdateRange div sysSpacing) * sysSpacing / 2) { // margins are updated when they reach half the size, this is arbitrary
	
	var _stepSign = sign(_camY - previousCamY); // which way to iterate the list updating depths
	var _previousEdge = currentSysEdge; // last updated index (working)
	var _goalEdge = round((_camY - sysUpdateRange / 2 - depthOrigin) / sysSpacing) % sysCount; // goal update index (move to this from _previousEdge) (unecessary?)
	if(_goalEdge < 0) {
		_goalEdge += sysCount; // goal edge working (goes up to number - 1 which makes sense i think)
	}
	
	if(_depthChange < sysSpacing * sysCount) { // partial wrap
		
		var _updateEdgeY = (_camY - sysUpdateRange / 2);
		if(_stepSign == 1) {   
			_updateEdgeY += sysSpacing * sysCount - sysUpdateRange; // sys range * 2?
		}
		
		var _updateDepth = -(((_updateEdgeY) div sysSpacing + 1) * sysSpacing) + depthOrigin; // round the depth and offset by origin (also the first layer is 0 so -1 to the count when multiplying)
		var _updatePos = _previousEdge; // if undoing move back on step before starting to hit current entry
		repeat(_depthChange / sysSpacing) { // amount of layers traversed (because of check this is sure to be less than total count)
			part_system_depth(sysCollection[_updatePos], _updateDepth);
			particleLayerDepthArray[_updatePos] = _updateDepth;
			if(irandom(0) == 0) {
				//msg($"The {_updatePos}th system was set to a depth of {_updateDepth}");
			}
			
			_updateDepth -= _stepSign * sysSpacing;
			_updatePos = (_updatePos + _stepSign) % sysCount;
			if(_updatePos < 0) {
				_updatePos = sysCount - 1;
			}
		}
		
		if(_stepSign == -1) {
			part_system_depth(sysCollection[_updatePos], _updateDepth);
		}
	} else { // the whole loop has been cycled in one update, update from your current position backwards the entire list as to not skip anything, by mod over steps (the function does this, i mean)
		setCollectionPosition();
	}
	
	previousCamY = _camY; // plain value, no adjustments (equal to camera y)
	previousEdgeY = previousCamY - sysUpdateRange;
	currentSysEdge = _goalEdge;
	
	if(depthOrigin < previousEdgeY) { // if layers being looped higher than origin (in depth)
		sysCollectionMoveSign = 1;
	} else {
		sysCollectionMoveSign = -1;
	}
}

var _layerAdd = round(((mouse_y - (previousEdgeY)) - depthOrigin) / sysSpacing) - 1; // the mouse layer is accurate
//var _sysIndex = ((currentSysEdge + sysCollectionMoveSign * _layerAdd) + sysCount) % sysCount;
var _sysIndex = (currentSysEdge + _layerAdd) % sysCount;
if(_sysIndex < 0) {
	_sysIndex = sysCount + (_sysIndex - 1);
}
mouseLayer = _sysIndex;

if(mouse_check_button(mb_left)) {
	script_createPartDepth(part, mouse_x, mouse_y, 10, make_color_rgb(mouse_y % 256, 0, 0));
}

if(mouse_check_button_released(mb_right)) {
	global.players[0].y += 5000;
}