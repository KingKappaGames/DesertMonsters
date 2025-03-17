if (live_call()) return live_result;

depthOrigin = 0;

sysCount = 160; // count X spacing is the total screen range in room pixels that the sys manages, set this range to be your screen plus margins if particles ever move up or down within their system and would leave the locality of their layer (depth = -y) as a guess. Because their depths are popped up or down at the edges put those off screen by 10% or something
sysSpacing = 5;

sysUpdateRange = 100; // if the screen varies from the last update by this many pixels the systems will be updated (hence why the buffer space is important, among other things)

previousCamY = camera_get_view_y(view_camera[0]);
currentSysEdge = 0;
sysCollectionMoveSign = 0;

global.sysBottom = part_system_create();
part_system_depth(global.sysBottom, 1000); // bottom, where ever that is V 

global.sysTop = part_system_create();
part_system_depth(global.sysTop, -1000); // top, what ever depth that is ^

global.sysCollection = array_create(sysCount, 0);

var _sysSet = global.sysCollection;
var _depthOfInitial = -(camera_get_view_y(view_camera[0]) - sysUpdateRange) + depthOrigin;
var _sysAddI = 0;
repeat(sysCount) {
	_sysSet[_sysAddI] = part_system_create();
	part_system_depth(_sysSet[_sysAddI], _depthOfInitial - _sysAddI * sysSpacing); // down screen / positive y / less depth (negative)
	_sysAddI++;
}


layerCreateOrigin = previousCamY - sysUpdateRange;


updateLayers = function(count = -1, spacing = -1) {
	if(count != -1) {
		
	}
	
	if(spacing != -1) {
		
	}
}

part = global.sandBurstDust;

mouseLayer = 0;

particleLayerDepthArray = array_create(sysCount, 0);