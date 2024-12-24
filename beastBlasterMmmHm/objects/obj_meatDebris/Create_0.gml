sys = global.particleSystem;
bloodPart = global.blood;

image_index = irandom(image_number - 1);
image_blend = c_red;
spin = random_range(-7, 7);

image_xscale = random(1);
image_yscale = random(1);

xChange = 0;
yChange = 0;
heightChange = 0;

height = 0;

durationDestroy = 1440; // some amount of time that's too much to stick around for