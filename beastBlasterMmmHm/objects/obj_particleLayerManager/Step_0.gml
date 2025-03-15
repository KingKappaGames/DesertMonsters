if (live_call()) return live_result;

var _camY = (camera_get_view_y(view_camera[0]) div sysSpacing) * sysSpacing; // cam is correctly rounded to 4
var _depthChange = abs(previousCamY - _camY) // depth change ranges 0 - 100 in 4s (correct)

if(_depthChange > sysUpdateRange) {
	
	var _sysCollection = global.sysCollection;
	
	var _stepSign = sign(_camY - previousCamY); // which way to iterate the list updating depths
	var _previousEdge = currentSysEdge; // last updated index (working)
	var _goalEdge = round((_camY - sysUpdateRange - layerCreateOrigin) / sysSpacing) % sysCount; // goal update index (move to this from _previousEdge) (unecessary?)
	if(_goalEdge < 0) {
		_goalEdge += sysCount; // goal edge working (goes up to number - 1 which makes sense i think)
	}
	
	if(_depthChange < sysSpacing * sysCount) {
		
		var _updateCamEdgeY = (_camY - sysUpdateRange);
		//if(_stepSign == -1) {  
			_updateCamEdgeY += camera_get_view_height(view_camera[0]);
		//}
		
		var _updateDepth = -(((_updateCamEdgeY) div sysSpacing) * sysSpacing) + depthOrigin;
		var _updatePos = _previousEdge; // if undoing move back on step before starting to hit current entry
		repeat(_depthChange / sysSpacing) { // amount of layers traversed (because of check this is sure to be less than total count)
			part_system_depth(_sysCollection[_updatePos], _updateDepth);
			if(irandom(0) == 0) {
				msg($"The {_updatePos}th system was set to a depth of {_updateDepth}");
			}
			
			_updateDepth -= _stepSign * sysSpacing;
			_updatePos = (_updatePos + _stepSign) % sysCount;
			if(_updatePos < 0) {
				_updatePos = sysCount - 1;
			}
		}
		
		if(_stepSign == -1) {
			part_system_depth(_sysCollection[_updatePos], _updateDepth);
			// do previous edge's index if moving back because you need to undo your current pos if moving back but not forward
		}
	} else { // the whole loop has been cycled in one update, update from your current position backwards the entire list as to not skip anything, by mod over steps
		var _updateDepth = -round((_camY - sysUpdateRange) / sysSpacing) * sysSpacing + depthOrigin;
		var _updatePos = _goalEdge; // if undoing move back on step before starting to hit current entry
		repeat(sysCount) { // amount of layers traversed (because of check this is sure to be less than total count)
			part_system_depth(_sysCollection[_updatePos], _updateDepth);
			msg($"The {_updatePos}th system was set to a depth of {_updateDepth}");
			
			_updateDepth -= _stepSign * sysSpacing;
			_updatePos = (_updatePos - _stepSign) % sysCount;
			if(_updatePos < 0) {
				_updatePos = sysCount - 1;
			}
		}
	}
	
	previousCamY = _camY; // plain value, no adjustments (equal to camera y)
	currentSysEdge = _goalEdge;
	
	if(layerCreateOrigin < previousCamY - sysUpdateRange) { // if layers being looped higher than origin (in depth)
		sysCollectionMoveSign = 1;
	} else {
		sysCollectionMoveSign = -1;
	}
}

var _sysAll = global.sysCollection;
var _layerAdd = round(((mouse_y - sysUpdateRange) - layerCreateOrigin) / sysSpacing) - 1; // the mouse layer is accurate
//var _sysIndex = ((currentSysEdge + sysCollectionMoveSign * _layerAdd) + sysCount) % sysCount;
var _sysIndex = (_layerAdd + sysCount) % sysCount;
if(irandom(90) == 0) {
	msg(_sysIndex);
}
var _sys = _sysAll[_sysIndex]; // the goal layer is accurate, confirmed to at least 1 layer
part_particles_create_color(_sys, mouse_x, mouse_y, part, make_color_rgb(mouse_y % 256, 0, 0), 1);
if(mouse_check_button_released(mb_left)) {
	msg(_sysIndex);
}