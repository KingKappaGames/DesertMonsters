global.camera = id;

playerCount = instance_number(obj_playerParent);
cameras = [];

camWidth = 960; // get view width...
camHeight = 540;
camSoloWidth = camWidth;

global.cameraSplitOption = true;
view_enabled = true;

cameras[0] = camera_create_view(0, 0, camWidth, camHeight);
view_set_camera(0, cameras[0]);	
view_visible[0] = true;
view_xport[0] = 0;
view_yport[0] = 0;
view_wport[0] = camWidth;
view_hport[0] = camHeight;

window_set_size(1920, 1080);
surface_resize(application_surface, 1920, 1080);

refreshCameras = function(split = -1) {
	if(split != -1) {
		global.cameraSplitOption = split; // don't change things
	}
	
	playerCount = instance_number(obj_playerParent);
	
	#region clear and default cameras
	var _cameraCount = array_length(cameras);
	for(var _i = _cameraCount - 1; _i >= 0; _i--) {
		view_visible[_i] = false;
		view_set_camera(_i, -1);
		camera_destroy(array_pop(cameras)); // throw that thing in the garbage collecter lololololol
	}
	camSoloWidth = camWidth;
	#endregion
	
	if(global.cameraSplitOption == true) { // only split cameras if you want splitting, obviously.. 
		for(var _i = 0; _i < playerCount; _i++) {		
			camSoloWidth = camWidth / playerCount;
			
			cameras[_i] = camera_create_view(0, 0, camSoloWidth, camHeight);
			view_set_camera(_i, cameras[_i]);
		
			view_visible[_i] = true;
			view_xport[_i] = camSoloWidth * _i;
			view_yport[_i] = 0;
			view_wport[_i] = camSoloWidth;
			view_hport[_i] = camHeight;
		}
	} else {		
		cameras[0] = camera_create_view(0, 0, camWidth, camHeight);
		view_set_camera(0, cameras[0]);
		
		view_visible[0] = true;
		view_xport[0] = 0;
		view_yport[0] = 0;
		view_wport[0] = camWidth;
		view_hport[0] = camHeight;
	}
	
	window_set_size(camWidth, camHeight);
	surface_resize(application_surface, camWidth, camHeight);
}