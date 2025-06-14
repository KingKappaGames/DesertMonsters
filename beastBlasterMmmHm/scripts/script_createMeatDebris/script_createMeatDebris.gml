function script_createMeatDebris(xx, yy, radialSpeed, pushSpeed, pushDir, pushVertical, amount, heightSet = 1) {
	var _speedRandHold = 0;
	var _randDir = 0;
	var _randHeight = 0; // set some things before the big loops for performances sake
	var _piece = noone;
	
	repeat(amount) {
		_speedRandHold = random(radialSpeed);
		
		_randDir = irandom(360);
		_randHeight = random(1);
		_piece = instance_create_layer(xx, yy, "Instances", obj_meatDebris);
		_piece.xChange = (dcos(_randDir) * _speedRandHold * (1 - sqrt(_randHeight))) + (dcos(pushDir) * pushSpeed);
		_piece.yChange = -1 * (   (dsin(_randDir) * _speedRandHold * (1 - sqrt(_randHeight))) + (dsin(pushDir) * pushSpeed) + pushVertical   );
		_piece.heightChange = (sqrt(_randHeight) * _speedRandHold) + pushVertical;
		
		if(heightSet != 1) {
			_piece.height = heightSet;
		}
	}
}