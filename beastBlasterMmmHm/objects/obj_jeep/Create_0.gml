if (live_call()) return live_result;

event_inherited();

sbHaze = global.sandBurstHaze;
debris = global.darkDebris;
sys = global.particleSystem;

#region control and movement values
acceleration = .03;
turnSpeed = 2;

currentDirection = 0;
directionChange = 0;

scale = 1;

xChange = 0;
yChange = 0;

prevSpeed = 0;
#endregion

updateDrawSurfaces = true;

imageSet = array_create(image_number, 0);
bufferSet = array_create(image_number, 0);
rigiditySet = array_create(image_number, 1); // how resistant to deformation this image is (the magnitude of shader offsets)
for(var _i = 0; _i < image_number; _i++) {
	imageSet[_i] = surface_create(sprite_width, sprite_height);
	bufferSet[_i] = buffer_create(sprite_width * sprite_height * 4, buffer_fixed, 1);
}

