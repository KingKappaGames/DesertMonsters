event_inherited();

msg("HLELO");

image_alpha = 0;

Health = 1.5;

hit = function(damageAmount) {
	if(damageAmount > 1) {
		Health -= sqrt(damageAmount);
	} else {
		Health -= sqr(damageAmount);
	}
	
	if(Health <= 0) {
		script_createMeatDebris(x, y, 1, 0, 0, 0, irandom_range(3, 5), 50);
		instance_destroy();
	}
}