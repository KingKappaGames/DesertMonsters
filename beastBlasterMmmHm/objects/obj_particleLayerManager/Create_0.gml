if (live_call()) return live_result;

global.particleSystemManager = id;

global.debugFollow = true;


sysCount = 1200; // count X spacing is the total screen range in room pixels that the sys manages, set this range to be your screen plus margins if particles ever move up or down within their system and would leave the locality of their layer (depth = -y) as a guess. Because their depths are popped up or down at the edges put those off screen by 10% or something
sysSpacing = 1;

sysUpdateRange = 200; // if the screen varies from the last update by this many pixels the systems will be updated (hence why the buffer space is important, among other things)

previousCamY = camera_get_view_y(view_camera[0]);
previousEdgeY = previousCamY - sysUpdateRange;

currentSysEdge = 0;

drawPart = part_type_create();
part_type_size(drawPart, 40, 40, 0, 0);
part_type_color1(drawPart, c_green);
part_type_life(drawPart, 99999999, 99999999);

global.sysBottom = part_system_create();
part_system_depth(global.sysBottom, 1000); // bottom, where ever that is V  (not part of the moving system! But often times you will want a particle layer that goes over everything)

global.sysTop = part_system_create();
part_system_depth(global.sysTop, -1000); // top, what ever depth that is ^ (not part of the moving system! But often times you will want a particle layer that goes under everything)

sysCollection = array_create(sysCount, 0);

var _sysSet = sysCollection;
var _depthOfInitial = -(camera_get_view_y(view_camera[0]) - sysUpdateRange);
var _sysAddI = 0;
repeat(sysCount) {
	_sysSet[_sysAddI] = part_system_create();
	part_system_depth(_sysSet[_sysAddI], _depthOfInitial - _sysAddI * sysSpacing); // down screen / positive y / less depth (negative)
	_sysAddI++;
}

///@param {REAL} borderWidth The height in pixels of the margins above and below the screen
///@param {REAL} systemSpacing The height of each layer in pixels, this being 1 means the layering DEPTH is pixel perfect, being 100 means your particles will snap to depths of 100 (the position is always correct regardless, this is a GM thing, the only thing this system does is depth, you don't need to mess with position at all)
///@param {BOOL} useCameraAsArea The normal use case for this system is wrapping depth around the camera space plus margins, if you need something else then turn this off (but then what? You'll have to custom make the else case I guess))
///@param {REAL} forceSystemCount The quantity of systems to use (will update the collection to have this many systems)
///@param {REAL} camIndex The index number for the camera to calculate positions with (default 0)
setSpacing = function(borderWidth = 20, systemSpacing = 1, useCameraAsArea = true, forceSystemCount = -1, camIndex = 0) {
	sysUpdateRange = borderWidth; // the margins above and below the screen (only really useful for preventing movement from showing off the screen (which isn't even a problem BUT the particles created when doing so will be dropped to the nearest depth.. And you'll notice that when you go far enough to see them in a position they shouldn't be (clumped on the edge vs placed along the range they were intended to have))
	sysSpacing = systemSpacing;
	
	var _systemCount = 0;
	if(useCameraAsArea) {
		if(forceSystemCount == -1) {
			_systemCount = ceil((camera_get_view_height(view_camera[camIndex]) + borderWidth * 2) / sysSpacing); // default to placing enough layers to cover camera and margins with spaced layers, though I guess there's some use for doing a different set up?
		}
	}
	
	if(forceSystemCount != -1) {
		_systemCount = forceSystemCount; // if forced, set forced count
	}
	
	var _oldSysCount = sysCount;
	sysCount = _systemCount; // finalize the layer count
	
	#region // resize the layer collection to match new count
	
	if(sysCount > _oldSysCount) { // adding systems to collection
		array_resize(sysCollection, sysCount);
		for(var _i = _oldSysCount; _i < sysCount; _i++) {
			sysCollection[_i] = part_system_create(); // create blank system
		}
	} else if(sysCount < _oldSysCount) { // removing systems from collection
		for(var _i = sysCount; _i < _oldSysCount; _i++) {
			part_system_destroy(sysCollection[_i]); //clear out the excess now
		}
		array_resize(sysCollection, sysCount);
	} // else if the same do nothing
	#endregion
	
	setCollectionPosition(); // pass values here to maintain use camera and force position values I guess (I aint doing that tho)
}

///@desc This replaces all the systems to the desired position and updates their depths to be current with this new position, this can be useful for immediate jumps or changes (like spawning in, since there's no reference point on the first frame). Note though that the system already does this when moving more than a full system at once so teleports and such changes should be handled automatically, but this is here if you need it.
///@param {BOOL} useCamera This uses the current camera to place the collection arounds
///@param {REAL} forcePosition This passes in a position instead of the camera, if for some reason you want to arrange the collection around y = 1000 when the camera is somewhere else
setCollectionPosition = function(useCamera = true, forcePosition = undefined) {
	// on spawn camera is moved after this and so this updates to wrong position
	if(useCamera) { // place the systems around the camera with the established margins
		var _holdCamY = previousCamY;
		var _holdEdge = currentSysEdge;
		
		previousCamY = (camera_get_view_y(view_camera[0]) div sysSpacing) * sysSpacing;
		//previousEdgeY = previousCamY - sysUpdateRange;
		
		var _yChange = previousCamY - _holdCamY;

		var _sysSet = sysCollection;
		var _startY = (((is_undefined(forcePosition) ? previousCamY : forcePosition) - sysUpdateRange) div sysSpacing) * sysSpacing; // rounding to a number is basically div number * number to create a 1 rounded factor of the desired round. It works.
		var _depthOfInitial = -_startY; // depth origin is negative up so adding it outside the negative means adding -200 for up 200 will decrease the depth of this position by 200 which is correct (i think)
		currentSysEdge = (currentSysEdge + (_yChange div sysSpacing)) % sysCount;
		if(currentSysEdge < 0) {
			currentSysEdge += sysCount;
		}
		var _sysAddI = currentSysEdge;
	
		var _depthSet = _depthOfInitial;
		repeat(sysCount) { // for every system
			msg(_sysAddI);
			part_system_depth(_sysSet[_sysAddI], _depthSet); // down screen / positive y / less depth (negative)
			particleLayerDepthArray[_sysAddI] = _depthSet;
			_sysAddI += 1;
			_depthSet -= sysSpacing;
			if(_sysAddI >= sysCount) { // loop position if over max while cycling
				_sysAddI = 0;
			}
		}
	}
}

moveCollection = function() { // camY here should be switched with goal screen top and you can move it as you wish, though, perhaps that would never happen anyway
	var _camY = (camera_get_view_y(view_camera[0]) div sysSpacing) * sysSpacing;
	var _depthChange = abs(previousCamY - _camY)
	
	if(_depthChange >= (sysUpdateRange div sysSpacing) * sysSpacing / 2) { // margins are updated when they reach half the size, this is arbitrary
		
		var _depthAdjustOverflow = 0;
		if(_depthChange >= sysSpacing * sysCount) { // wrapped more than a whole screen at once just jump to the set position functions instead
			setCollectionPosition();
			return;
		}
		
		var _stepSign = sign(_camY - previousCamY); // which way to iterate the list updating depths
		var _isStepForward = _stepSign == 1 ? 1 : 0;
		
		var _updateDepth = particleLayerDepthArray[currentSysEdge - _isStepForward]; // round the depth and offset by origin (also the first layer is 0 so -1 to the count when multiplying)
		
		var _updatePos = currentSysEdge - _isStepForward;
		repeat((_depthChange div sysSpacing) % sysCount) {
			_updateDepth -= _stepSign * sysSpacing;
			_updatePos = (_updatePos + _stepSign + sysCount) % sysCount;
			
			part_system_depth(sysCollection[_updatePos], _updateDepth);
			particleLayerDepthArray[_updatePos] = _updateDepth;
		}
		
		previousCamY = _camY;
		previousEdgeY = previousCamY - sysUpdateRange;
		currentSysEdge = _updatePos + _isStepForward;
	}
}



///@param drawSystems This toggles whether the paused systems should keep drawing   (not used without draw systems toggle!)
pauseAll = function(/*drawSystems = false*/) {
	var _sysSet = sysCollection; // get a ref for all systems
	var _sys = -1; // pre set a hold variable for your system
	for(var _i = sysCount - 1; _i >= 0; _i--) { // for all systems
		_sys = _sysSet[_i]; // set the system for reference convinience
		//if(!drawSystems) {
		part_system_automatic_draw(_sys, false); // pause drawing in the system, making it invisible (and not lag unnecesarily) (if you for some reason want to be able to keep drawing them then uncomment the drawSystems values here, but usually to maintain particles you store the screen to a surface for pause backgrounds, not draw everything while paused)
		//}
		part_system_automatic_update(_sys, false); // pause updating in the system, making it frozen
	}
}


///@param {BOOL} forceDrawState This forces the systems to draw or not draw after being unpaused, since sometimes you want to do drawing yourself and changing it here would be problematic for that. Set this to whatever your otherwise desired draw state is when updating (defaults to true though)
unpauseAll = function(forceDrawState = true) {
	var _sysSet = sysCollection; // get a ref for all systems
	var _sys = -1; // pre set a hold variable for your system
	for(var _i = sysCount - 1; _i >= 0; _i--) { // for all systems
		_sys = _sysSet[_i]; // set the system for reference convinience
		part_system_automatic_draw(_sys, forceDrawState); // unpause drawing in the system so that it's visible again (if allowed)
		part_system_automatic_update(_sys, true); // unpause updating in the system so that it moves again
	}
}

mouseLayer = 0;

particleLayerDepthArray = array_create(sysCount, 0);