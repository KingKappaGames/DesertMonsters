event_inherited();

sys = global.particleSystem;
dust = global.sandBurstDustFloat;

sprite_index = choose(spr_reeds, spr_bush, spr_tuft);
image_alpha = 1;
image_index = irandom(image_number);
image_xscale = 1;
image_yscale = 1;

Health = 91.5;
height = 0;

///@desc Sorta works..?
hurt3D = function(damage, knockback, radius, dropOffPower = 1, hitSourceId = noone) {
	if(instance_exists(hitSourceId)) {
		var _hitX = hitSourceId.x;
		var _hitY = hitSourceId.y;
		
		//var _nodeCount = array_length(structureNodes);
		//for(var _hitI = 0; _hitI < _nodeCount; _hitI++) {
		//	var _node = 
		//	var _dist = point_distance(
		//}
	}
}


hit = function(damageAmount, hitDir) {
	if(damageAmount > 1) {
		Health -= sqrt(damageAmount);
	} else {
		Health -= sqr(damageAmount);
	}
}