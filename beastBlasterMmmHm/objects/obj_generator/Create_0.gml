randomize();

depth = 3000;

global.generator = id;

seed = round(random_range(1000000,10000000));

#macro blockSize 24 // the size of the color blocks on screen in pixels
#macro valueRange 10000 // the breadth of the features in the map, scale
#macro bufferBlockCount 6

debugX = 0;
debugY = 0;
debugWidth = 0;
debugHeight = 0;


width = round(camera_get_view_width(view_camera[0]) / blockSize) + bufferBlockCount * 2;
height = round(camera_get_view_height(view_camera[0]) / blockSize) + bufferBlockCount * 2;

updatePerlinGrid = function(playerIndex = 0) {
	ds_grid_destroy(grid); 
	
	width = round(camera_get_view_width(view_camera[playerIndex]) / blockSize) + bufferBlockCount * 2;
	height = round(camera_get_view_height(view_camera[playerIndex]) / blockSize) + bufferBlockCount * 2;
	
	grid = ds_grid_create(width, height);
	
	surface_free(perlinSurf);
	
	perlinSurf = surface_create(width * blockSize, height * blockSize);
}

grid = ds_grid_create(width, height);

updateLastX = 0;
updateLastY = 0;
updatePerlin = true;

perlinSurf = surface_create(width * blockSize, height * blockSize);

getSurf = function() {
	if(!surface_exists(perlinSurf)) {
		perlinSurf = surface_create(width * blockSize, height * blockSize);
		updatePerlin = true;
	}
	
	return perlinSurf;
}

generate();



