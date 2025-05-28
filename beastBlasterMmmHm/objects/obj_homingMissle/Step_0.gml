// Inherit the parent event
event_inherited();

if(instance_exists(homingLock)) {
	age++;
	bulletHeight = min(100, point_distance(x, y, homingLock.x, homingLock.y) / 10) - age / 100;
	bulletDirection = bulletDirection - sign(angle_difference(bulletDirection, point_direction(x, y, homingLock.x, homingLock.y))) * 1.5; // degrees per frame track
	var _speed = point_distance(0, 0, xChange, yChange) * .999;
	xChange = dcos(bulletDirection) * _speed;
	yChange = -dsin(bulletDirection) * _speed;
}

part_type_orientation(miniSmoke, bulletDirection, bulletDirection, 0, 0, 0);

part_particles_create(sys, x, y, miniSmoke, 1);