x += xChange;
y += yChange;
height += heightChange;

xChange *= .998;
yChange *= .998;
heightChange *= .998;

heightChange -= .015;

image_angle += spin;

part_particles_create(sys, x + irandom_range(-2, 2), y - height + irandom_range(-2, 2), bloodPart, 1);

if(height <= 0) {
	script_drawDebris(spr_blood, irandom(sprite_get_number(spr_blood) - 1), x + irandom_range(-4, 4), y + irandom_range(-4, 4), random_range(.5, 1), random_range(.5, 1), irandom(360), c_maroon, .6) 
	script_drawDebris(sprite_index, image_index, x, y, .7, .7, irandom(360), #771f00, 1) 
	
	instance_destroy();
}

durationDestroy--;
if(durationDestroy <= 0) {
	instance_destroy();
}