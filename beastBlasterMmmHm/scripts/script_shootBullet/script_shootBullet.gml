function script_shootBullet(shotX, shotY, shotSpeed, shotDir, bulletType, shotHeight = 100, shotHeightDrop = 4, funcPassing = [], shotVariance = 0, damageMult = 1) {
	//live_auto_call
	
	if(bulletType != obj_basicBullet) {
		audio_play_sound(snd_SnappyShotLong, 0, 0,,,random_range(.85, 1.2));
	} else { // basic bullet
		audio_play_sound(snd_SoftMediumShot, 0, 0,,,random_range(.85, 1.2));
	}
	
	var _bullet = instance_create_layer(shotX, shotY, "Instances", bulletType);
	_bullet.xChange = dcos(shotDir) * shotSpeed * random_range(1 - shotVariance, 1 + shotVariance);
	_bullet.yChange = -dsin(shotDir) * shotSpeed * random_range(1 - shotVariance, 1 + shotVariance);
	_bullet.bulletDirection = point_direction(0, 0, _bullet.xChange, _bullet.yChange);
	_bullet.bulletHeight = shotHeight;
	_bullet.bulletDrop = shotHeightDrop * random_range(1 - shotVariance, 1 + shotVariance);
	_bullet.bulletLevel = clamp((100 - _bullet.bulletDrop * 1.33) / 100, 0, 1);
	_bullet.bulletDamage *= damageMult;
	
	if(bulletType == obj_homingMissle) {
		_bullet.homingLock = homingLock; // homing missiles coming from ship with homing variable
	}
	#region function passing
	//uh huh
	#endregion
}