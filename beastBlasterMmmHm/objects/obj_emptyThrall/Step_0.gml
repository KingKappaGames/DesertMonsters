if (live_call()) return live_result;

if(irandom(12000) == 0) {
	audio_play_sound_at(choose(snd_FaintIntervalShooting, snd_SoftExplosionSemiDistant, snd_EchoedDistantBurstFire, snd_SoftMachineFire), x, y, 0, 500, 1500, 1, 0, 0);
}

#region AI combat behaviors

if(alive == 1 && !ragdolling) {
	if(instance_exists(agroId) && agroId.alive) {
		if(irandom(32) == 0) { // only update the intent and behavior 4 times a second			
			if(irandom(2) == 0) {
				aimingDownSights = irandom(1);
				
				var _agroList = ds_list_create();
				collision_circle_list(x, y, 1000, obj_enemy, false, true, _agroList, true);
				var _count = ds_list_size(_agroList);
				for(var _i = 0; _i < _count; _i++) {
					var _enemy = _agroList[| _i];
					
					if(_enemy.friendly != friendly && _enemy.alive) {
						agroId = _enemy;
						break;
					}
				}
			}
			
			if(irandom(21) == 0) {
				strafeDir *= -1;
			}
			
			focusX = agroId.x;
			focusY = agroId.y;
			
			var _dist = point_distance(x, y, focusX, focusY);
			var _dir = point_direction(x, y, focusX, focusY);
			
			var _approachSpeed = clamp(sqrt(_dist / 370) - 1.5, -1, 1.3);
			
			var _approachAngle = (2 - _approachSpeed) * 32 * strafeDir;
			
			xChange = dcos(_dir + _approachAngle) * _approachSpeed;
			yChange = -dsin(_dir + _approachAngle) * _approachSpeed;
			
			
			
			if(_dist < 750) {
				if(irandom(1) == 0) {
					aimingDownSights = true;
					script_shootBulletScan(gunTipPosition[0], gunTipPosition[1], _dir, focusX, focusY, bulletType,, gunAccuracy + burstSpread, shotSound, gunDamageMult, true);
					burstSpread += .02;
					gunShakeX -= dcos(_dir) * gunRecoil;
					gunShakeY -= dsin(_dir) * gunRecoil;
					//if(ammoCurrent < 1) {
					//	startReload(); // i don't like having the last shot auto reload, cooler if it just makes the bullet click and all
					//}
					shotTimer = 0;
				}
				if(irandom(120) == 0) {
					script_shootBullet(x, y, 12 / 4, _dir, obj_missile,, 12 / 4 * (100 / point_distance(x, y, agroId.x, agroId.y)),,.40);
				}
			}
		}
	} else {
		if(irandom(50) == 0) {
			var _agroList = ds_list_create();
			collision_circle_list(x, y, 1600, obj_enemy, false, true, _agroList, true);
			var _count = ds_list_size(_agroList);
			for(var _i = 0; _i < _count; _i++) {
				var _enemy = _agroList[| _i];
				if(_enemy.friendly != friendly && _enemy.alive) {
					agroId = _enemy;
				}
			}
		}
		if(friendly) {
			if(irandom(18) == 0) {
				var _player = instance_nearest(x, y, obj_playerSoldier);
				if(_player != noone) {
					followId = _player;
					
					focusX = _player.x + _player.xChange * 16;
					focusY = _player.y + _player.xChange * 16;
					
					var _dist = point_distance(x, y, focusX, focusY);
					var _dir = point_direction(x, y, focusX, focusY);
			
					var _approachSpeed = clamp(_dist / 120 - 1, -1.8, 1.8);
					
					if(abs(_approachSpeed) < .3) {
						_approachSpeed = 0;
					}
			
					xChange = dcos(_dir) * _approachSpeed;
					yChange = -dsin(_dir) * _approachSpeed;
				
					var _avoidXChange = 0;
					var _avoidYChange = 0;
			
					var _avoidList = ds_list_create();
					collision_circle_list(x, y, 30, obj_enemy, false, true, _avoidList, true);
					var _count = ds_list_size(_avoidList);
					if(_count > 0) {
						var _avoidDir = 0;
						var _avoidDist = 0;
						for(var _i = 0; _i < _count; _i++) { 
							var _enemy = _avoidList[| _i];
							_avoidDir = point_direction(_enemy.x, _enemy.y, x, y);
							_avoidDist = point_distance(_enemy.x, _enemy.y, x, y);
							
							_avoidXChange += dcos(_avoidDir) / sqrt(_avoidDist);
							_avoidYChange -= dsin(_avoidDir) / sqrt(_avoidDist);
						}
			
						_avoidXChange /= _count;
						_avoidYChange /= _count; // push enemies away with normalized average / 100 for distance to speed
				
						xChange += _avoidXChange;
						yChange += _avoidYChange;
					}
				
					ds_list_destroy(_avoidList);
				}
			}
		}
		
		if(!instance_exists(followId)) {
			if(irandom(30) == 0 && (xChange != 0 || yChange != 0)) {
				if(point_distance(x, y, travelToGoalX, travelToGoalY) < 20) {
					xChange = 0;
					yChange = 0;
				} else if(irandom(360) == 0) {
					startTravelToPoint(travelToGoalX, travelToGoalY); // reset direction and seeking because I don't calculate corrections to path otherwise
				}
			} else if(irandom(300) == 0) {
				startTravelToPoint(x + choose(irandom_range(-1000, -200), irandom_range(200, 1000)), y + choose(irandom_range(-800, -200), irandom_range(200, 800)))
			}
		}
	}
}

#endregion

aimDir = point_direction(x, y, focusX, focusY);
aimDist = point_distance(x, y, focusX, focusY);

x += xChange;
y += yChange;
z += zChange;

previousSpeed = currentSpeed;
currentSpeed = point_distance(0, 0, xChange, yChange);

previousDir = currentDir;
currentDir = point_direction(0, 0, xChange, yChange);
if(is_nan(currentDir)) {
	currentDir = 270;
}

script_mdlStep();

	
ammoCurrent = ammoMax; // clean

depth = -((y + feetOffY) - global.depthOffset);



debugClamp *= 1 + (keyboard_check(ord("U")) - keyboard_check(ord("J"))) * .0035;
debugOverStep *= 1 + (keyboard_check(ord("I")) - keyboard_check(ord("K"))) * .0035;
debugPushAhead *= 1 + (keyboard_check(ord("O")) - keyboard_check(ord("L"))) * .0035;