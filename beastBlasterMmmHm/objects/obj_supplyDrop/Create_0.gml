height = irandom_range(1000, 1200);
fallSpeed = random_range(.3, 1.7);

sandBloom = global.sandBurstDust;

doLandingCrash = function(landingSpeed = fallSpeed) {
	part_type_speed(global.sandBurstDust, 0.15, 2.7, -.013, 0);
	part_particles_create(global.particleSystem, x, y, global.sandBurstDust, 25 * landingSpeed * ((landingSpeed + 1) / 2));
}