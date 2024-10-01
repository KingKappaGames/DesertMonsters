function script_shootBulletScan(shotX, shotY, shotDir, shotGoalX, shotGoalY, bulletType, funcPassing = [], shotVariance = 0, shotSound = -1, damageMult = 1) {
	live_auto_call
	
	if(shotSound == -1) {
		audio_play_sound(snd_PuffyRifleShot, 0, 0,,,random_range(.85, 1.2));
	} else {
		audio_play_sound(shotSound, 0, 0,,,random_range(.85, 1.2));
	}
	
	var _bullet = instance_create_layer(shotX, shotY, "Instances", bulletType);
	
	_bullet.bulletLevel = clamp(point_distance(shotX, shotY, shotGoalX, shotGoalY) / 350, 0, 1);
	
	_bullet.goalX = shotGoalX + irandom_range(-250 * shotVariance * _bullet.bulletLevel, 250 * shotVariance * _bullet.bulletLevel);
	_bullet.goalY = shotGoalY + irandom_range(-250 * shotVariance * _bullet.bulletLevel, 250 * shotVariance * _bullet.bulletLevel);
	_bullet.shotDir = shotDir;
	_bullet.bulletDamage *= damageMult;
	
	#region function passing
	//uh huh
	#endregion
}