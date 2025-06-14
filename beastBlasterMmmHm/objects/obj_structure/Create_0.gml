event_inherited();

// NEW TEST STUFF FOR DESTRUCTABLE LEVELS OF DAMAGE OF DEBRIS/PARTICLE EMISSION WHEN DAMAGED ALONG WITH EVENT SCRIPTS FOR ON DEATH EFFECTS AND SUCH

destructionState = 0; // 0-5 or something representing the visual and logical state of the asset being broken

size = [50, 50, 30]; //xscale, yscale, height

healthMax = 10;
Health = healthMax; // damaged by weapons and explosions ect

sprite = [spr_ruins];
image = [0, 1, 2, 3];

sprite_index = sprite[0];
image_index = image[0];

resistance = 0; // maybe have some simple resistances like the armor system in main game where the types are blunt, piercing, shock, flame, and disintegration..? That kind of thing?

#region particles
var _fragDustPart = part_type_create();
part_type_life(_fragDustPart, 80, 180);
part_type_shape(_fragDustPart, pt_shape_square);
part_type_size(_fragDustPart, .1, .3, 0, 0);
part_type_alpha2(_fragDustPart, 1, 0);
part_type_color1(_fragDustPart, #ddbb40);
part_type_direction(_fragDustPart, 0, 360, 0, 0);
part_type_orientation(_fragDustPart, 0, 360, 0, 0, 0);
part_type_speed(_fragDustPart, 1, 1, -.01, 0);
part_type_gravity(_fragDustPart, .005, 270);

part_type_step(_fragDustPart, -120, global.sandBurstDustFloat);
#endregion

particleArray = [_fragDustPart]; // store unique particles to be used for this object here (main game style)

debrisRefs = []; // I think I should set up the debris system in main game to be able to hold blue prints like the particle system, these blue prints could be structs and be used to store a bunch of data about the debris
//that they lead to, so you could store size, shape, visuals, the particles they create, the quantity and bounce types and all that, (notice, not including speeds or direction, though maybe you could add filter data for speed
//multipliers or direction adding to the direction of the call
//leading into that, the direction and speed of the debris would be set using scripts for creating debris from those blueprints, so you'd call createDebris(debris1, speedMin, speedMax, dirMin, dirMax, ect) basically to
//replicate the functionality of the particle systems in game maker, and part of that is that they probably know better than I do about what values are needed to describe movement and useful controls so I'll just copy them :p

/// @desc Deal damage to a structure with direction and magnitude ect, will destroy if enough damage has been done
damageStructure = function(damage, type, direction, knockback) {
    live_auto_call
	if(Health <= damage) { // broken
		breakStructure(damage, type, direction, knockback); // forward hit info to destroy function
		return true; // true being destroyed?
	}
	
	Health -= damage;
	
	var _spriteCount = array_length(sprite);
	var _imageCount = array_length(image);
	var _healthPortion = 1 - (Health / (healthMax + .01));

	sprite_index = sprite[_spriteCount * _healthPortion];
	image_index = image[_imageCount * _healthPortion];
	
	script_createMeatDebris(x, y, .5 + knockback * .3, knockback * .4, direction, knockback * .3, sqr(damage * .2 + 1.5), random(size[0]));
	script_burstParticlesConcentrated(x + irandom_range(-size[0], size[0]), y - irandom_range(-size[1], size[1]), particleArray[0], sqr(damage) + 5, direction, 30, 2, knockback * 2, true, global.particleSystem);
	
	return false;
}

///@desc Called when the structure breaks for the last time, basically, remove it from the game and do the effects inherit to that
breakStructure = function(damage, type, direction, knockback) { // direction, force, type of break, level, damage done? What else/these do we need?
    live_auto_call
    
	script_createMeatDebris(x, y, .5 + knockback * .3, knockback * .4, direction, knockback * .3, sqr(damage * .2 + 1.5), random(size[0]));
	script_burstParticlesConcentrated(x, y, particleArray[0], sqr(damage + 1) + 5, direction, 40, 2, knockback, true, global.particleSystem);
	
	//extra effects
	
	instance_destroy();
}