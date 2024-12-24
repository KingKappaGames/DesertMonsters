/*var _camY = camera_get_view_y(view_camera[0]);
var _depthChange = abs(previousCamY - _camY);

if(_depthChange > sysUpdateRange) {
	
	var _sysCollection = global.sysCollection;
	
	var _stepSign = sign(_camY - previousCamY); // which way to iterate the list updating depths
	var _previousEdge = currentSysEdge; // last updated index
	var _goalEdge = round((_camY - sysUpdateRange - layerCreateOrigin) / sysSpacing) % sysCount; // goal update index (move to this from _previousEdge) (unecessary?)
	if(_goalEdge < 0) {
		_goalEdge += sysCount;
	}
	
	if(_depthChange < sysSpacing * sysCount) {
		
		var _updateDepth = -(round((previousCamY - sysUpdateRange) / sysSpacing) * sysSpacing + _previousEdge * sysSpacing) + depthOrigin;
		var _updatePos = _previousEdge; // if undoing move back on step before starting to hit current entry
		repeat(abs(round(previousCamY / sysSpacing) - round(_camY / sysSpacing))) { // amount of layers traversed (because of check this is sure to be less than total count)
			part_system_depth(_sysCollection[_updatePos], _updateDepth);
			
			_updateDepth += _stepSign * sysSpacing;
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
			
			_updateDepth += _stepSign * sysSpacing;
			_updatePos = (_updatePos - _stepSign) % sysCount;
			if(_updatePos < 0) {
				_updatePos = sysCount - 1;
			}
		}
	}
	
	previousCamY = camera_get_view_y(view_camera[0]); // plain value, no adjustments (equal to camera y)
	currentSysEdge = _goalEdge;
	
	if(layerCreateOrigin < previousCamY - sysUpdateRange) { // if layers being looped higher than origin (in depth)
		sysCollectionMoveSign = 1;
	} else {
		sysCollectionMoveSign = -1;
	}
}

var _sysAll = global.sysCollection;
var _layerAdd = round(((_camY - sysUpdateRange) - layerCreateOrigin) / sysSpacing);
part_particles_create_color(_sysAll[((currentSysEdge + sysCollectionMoveSign * (_layerAdd)) + sysCount) % sysCount], mouse_x, mouse_y, part, make_color_rgb(mouse_y % 256, 0, 0), 1);