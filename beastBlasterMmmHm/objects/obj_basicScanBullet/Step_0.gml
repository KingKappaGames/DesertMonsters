if (live_call()) return live_result;

//do step once and destroy
collision_line_list(x, y, goalX, goalY, obj_enemy, false, true, hitIds, true);
var _len = ds_list_size(hitIds);
for(var _listI = 0; _listI < _len; _listI++) {
	var _hitEnemy = hitIds[| _listI];
	
	bulletPierce -= 1; // hitEnemy.toughness or getEnemyHit(angles, positions, ect); for different body parts
	show_debug_message(bulletPierce)
	
	if(bulletPierce < 1) {
		goalX = _hitEnemy.x;
		goalY = _hitEnemy.y;
	}
	
	hit(_hitEnemy.x, _hitEnemy.y, _hitEnemy, bulletPierce < 1); // hardness can be hitEnemy.toughness as described above
	
	if(bulletPierce < 1) { // ragh doing the same check twice makes me angry@!!
		break;
	}
}

if(bulletPierce > 0) {
	hit(goalX, goalY,, 1, .6);
}

instance_destroy(); // instant only one frame to live brother, pour one out, memento tiempo