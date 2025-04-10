if(keyboard_check(vk_space)) {
	seed = round(random_range(1000000,10000000));
	generate(); 
}

x = camera_get_view_x(view_camera[0]) - blockSize * bufferBlockCount;
y = camera_get_view_y(view_camera[0]) - blockSize * bufferBlockCount;

if((abs(x - updateLastX) > blockSize * bufferBlockCount * .8) || (abs(y - updateLastY) > blockSize * bufferBlockCount * .8)) { // moving since last frame
	var _prevUpdateX = updateLastX;
	var _prevUpdateY = updateLastY;
	
	updateLastX = (x div blockSize) * blockSize;
	updateLastY = (y div blockSize) * blockSize;
	
	generate(clamp(_prevUpdateX - updateLastX, 0, width * blockSize), clamp(_prevUpdateY - updateLastY, 0, height * blockSize), clamp(updateLastX - _prevUpdateX, 0, width * blockSize), clamp(updateLastY - _prevUpdateY, 0, height * blockSize));
}

var _camWidth = camera_get_view_width(view_camera[0]) / 2;
var _camHeight = camera_get_view_height(view_camera[0]) / 2;
with(obj_mapVisual) {
	if(point_distance(x, y, other.x + _camWidth, other.y + _camHeight) > _camWidth * 2) {
		instance_destroy();
	}
}
