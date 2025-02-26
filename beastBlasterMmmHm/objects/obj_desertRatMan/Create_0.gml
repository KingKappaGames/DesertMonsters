if (live_call()) return live_result;

event_inherited();

image_xscale = 14;
image_yscale = 20;

friendly = choose(false, false, false, true, true);
strafeDir = 1;
agroId = noone;
followId = noone;

Health = 12;
alive = 1;
recoveringStandingTimer = 0;
recoveringLimpTimer = 0;
ragdolling = 0;
airHeight = 0;
moveSpeed = 1;

hasLJ = true;
hasRJ = true;
hasLF = true;
hasRF = true;

creatureHeight = 60;

limbStrengthGeneral = 4;

die = function() {
	alive = 0;
	recoveringLimpTimer = 4320; // 20 seconds, long enough to not be relevant, tbf they don't really need to deactivate anyway... it's not laggy or anything and they get deactivated just like normal. Idk
	ragdollEnemy(); // take position data and use it to move legs and arms and body around? Fancy 3d stuff I haven't done yet
}

resetSkeleton = function() {
	recoveringLimpTimer = 0;
	ragdolling = 0;
	airHeight = 0;
	
	legSegLen = 34;

	footLX = x;
	footLY = y;
	footRX = x;
	footRY = y;

	jointLX = x;
	jointLY = y - 13; // arbitrary trying to place at natural positions
	jointRX = x;
	jointRY = y - 13;

	hipsX = x;
	hipsY = y - 30;
	
	footLXChange = 0;
	footLYChange = 0;
	footRXChange = 0;
	footRYChange = 0;
	jointLXChange = 0;
	jointLYChange = 0;
	jointRXChange = 0;
	jointRYChange = 0;
	
	prevFootLX = x;
	prevFootLY = y;
	prevFootRX = x;
	prevFootRY = y;
	prevJointLX = x;
	prevJointLY = y;
	prevJointRX = x;
	prevJointRY = y;
	prevHipsX = x;
	prevHipsY = y;
	
	hipStumbleDecay = .965;
	hipStumbleXChange = 0;
	hipStumbleYChange = 0;
	hipStumbleX = 0;
	hipStumbleY = 0;

	hipYBob = 0;
}

hurt = function(damageDone, kbDir = -1, bleed = 1) {
	if(bleed) {
		part_particles_create(sys, x, y - 4, blood, clamp(3 * sqr(damageDone - 2) + 5, 0, 40));
		script_createMeatDebris(x, y, 1, 1, kbDir, -1, round(damageDone / 2) + irandom(damageDone + 1), 15);
	}
	
	if(kbDir != -1) {
		//startTravelToPoint(x + dcos(kbDir + random_range(-50, 50)) * irandom_range(80, 150), y - dsin(kbDir + random_range(-50, 50)) * irandom_range(80, 150));
		
		var _kbX = dcos(kbDir) * damageDone;
		var _kbY = dsin(kbDir) * damageDone;
		
		//xChange += _kbX * .1;
		//yChange -= _kbY * .1;
		
		hipStumbleXChange += _kbX * .6;
		hipStumbleYChange -= _kbY * .6;
	}
	
	if(alive == 1) {
		Health -= damageDone;
	
		if(Health <= 0) {
			die();
		} else {
			if(irandom(2) == 0) {
				audio_play_sound(choose(snd_smallScreamFemale, snd_quickGruntMale), 0, 0,,,random_range(.7, 1.3));
			}
		}
	}
}

///@desc My beautiful baby boy, glorious math to bring me what I want
hurt3D = function(damage, knockback, radius, dropOffPower = 1, hitSourceId = noone) {
	if(instance_exists(hitSourceId)) {
		var _heightPreCheck = ragdolling ? groundHeight : max(footLY, footRY); // ternary for using ground height or recalculating it with foot heights (ground height only set when ragdolling)
		var _distToBody = point_distance_3d(x, _heightPreCheck, _heightPreCheck - hipsY, hitSourceId.x, hitSourceId.y, 0);
		var _knockRefStrength = power(1 - clamp(_distToBody / radius, 0, 1), dropOffPower) * knockback;
		msg(_knockRefStrength);
		msg("KNOCK ABOVE");
		if(_knockRefStrength > .5 || ragdolling) {
			ragdollEnemy(400); // no check for already ragdolling because... uh... it's the 
			
			var _partDmgs = [0, 0, 0, 0, 0]; // body, left thigh, right thigh, left shin, right shin (1 means removed)  OR // 1 - 4 = left hip, right hip, left knee, right knee (2 means sever along these parts)
			
			// ragdoll then add momentums to each joint, this is what the code below is doing
			var _distToLJ = point_distance_3d(jointLX, groundLJHeight, groundLJHeight - jointLY, hitSourceId.x, hitSourceId.y, 0);
			var _distToRJ = point_distance_3d(jointRX, groundRJHeight, groundRJHeight - jointRY, hitSourceId.x, hitSourceId.y, 0);
			var _distToLF = point_distance_3d(footLX, groundLFHeight, groundLFHeight - footLY, hitSourceId.x, hitSourceId.y, 0);
			var _distToRF = point_distance_3d(footRX, groundRFHeight, groundRFHeight - footRY, hitSourceId.x, hitSourceId.y, 0);

			if(_distToBody < radius) {
				var _dirToBody = point_direction(hitSourceId.x, hitSourceId.y, x, groundHeight);
				var _bodyHeightFactor = darctan(groundHeight / _distToBody); // a value representing how upwards this hit will send this body part, an extremely upward hit will move less x/y but have a stronger effect on height if I make a system for height..
				var _hitForce = power(1 - _distToBody / radius, dropOffPower) * knockback;
				var _heightCos = dcos(_bodyHeightFactor);
				
				xChange += dcos(_dirToBody) * _hitForce * _heightCos;
				yChange -= dsin(_dirToBody) * _hitForce * _heightCos + _hitForce * dsin(_bodyHeightFactor); // up the map plus height y
				groundYChange = -1 * dsin(_dirToBody) * _hitForce * _heightCos * .7; // then here add a up the map speed to cancel out the visual up the map position and yield a difference of height which can be checked against
				
				if(_hitForce > limbStrengthGeneral) {
					//remove body...
					_partDmgs[0] = 1;
					_partDmgs[1] = 2; // body destroyed means hips severed by default
					_partDmgs[2] = 2;
					script_createMeatDebris(hipsX, hipsY, random(_hitForce / 3), (_hitForce * (1 - _distToBody / radius)) / 4, _dirToBody, dsin(_bodyHeightFactor), 50, groundHeight - hipsY);
				}
			}
			if(hasLJ && _distToLJ < radius) {
				var _dirToLJ   = point_direction(hitSourceId.x, hitSourceId.y, jointLX, groundHeight);
				var _LJHeightFactor = darctan((groundHeight - jointLY) / _distToLJ);
				var _hitForce = power(1 - _distToLJ / radius, dropOffPower) * knockback;
				var _heightCos = dcos(_LJHeightFactor);
				
				jointLXChange += dcos(_dirToLJ) * _hitForce * _heightCos;
				jointLYChange -= dsin(_dirToLJ) * _hitForce * _heightCos + _hitForce * dsin(_LJHeightFactor);
				groundLJYChange = -1 * dsin(_dirToLJ) * _hitForce * _heightCos * .7;
				
				if(_hitForce > limbStrengthGeneral * .94) {
					//remove left thigh...
					hasLF = false;
					hasLJ = false;
					Health = 0; // if you lose a full leg you die... Pretty realistic I'd say
					_partDmgs[1] = 1;
					script_createMeatDebris((hipLX + jointLX) / 2, (hipLY + jointLY) / 2, random(_hitForce / 4), (_hitForce * (1 - _distToLJ / radius)) / 4, _dirToLJ, dsin(_LJHeightFactor), 50, groundLJHeight - jointLY);
				} else if(_hitForce > limbStrengthGeneral * .85) {
					//sever left hip...
					hasLF = false;
					hasLJ = false;
					Health = 0;
					_partDmgs[1] = 2;
					script_createMeatDebris(hipLX, hipLY, random(_hitForce / 4), (_hitForce * (1 - _distToBody / radius)) / 12, _dirToLJ, dsin(_LJHeightFactor), 5, groundHeight - hipsY);
				}
			}
			if(hasRJ && _distToRJ < radius) {
				var _dirToRJ   = point_direction(hitSourceId.x, hitSourceId.y, jointRX, groundHeight);
				var _RJHeightFactor = darctan((groundHeight - jointRY) / _distToRJ); // tangents give the angle up to the hit based on ground position and percieved height and lateral distance
				var _hitForce = power(1 - _distToRJ / radius, dropOffPower) * knockback;
				var _heightCos = dcos(_RJHeightFactor);
				
				jointRXChange += dcos(_dirToRJ) * _hitForce * _heightCos;
				jointRYChange -= dsin(_dirToRJ) * _hitForce * _heightCos + _hitForce * dsin(_RJHeightFactor);
				groundRJYChange = -1 * dsin(_distToRJ) * _hitForce * _heightCos * .7;
				
				if(_hitForce > limbStrengthGeneral * .94) {
					//remove right thigh...
					hasRF = false;
					hasRJ = false;
					Health = 0;
					_partDmgs[2] = 1;
					script_createMeatDebris((hipRX + jointRX) / 2, (hipRY + jointRY) / 2, random(_hitForce / 4), (_hitForce * (1 - _distToRJ / radius)) / 5, _dirToRJ, dsin(_RJHeightFactor), 50, groundRJHeight - jointRY);
				} else if(_hitForce > limbStrengthGeneral * .85) {
					//sever right hip...
					hasRF = false;
					hasRJ = false;
					Health = 0;
					_partDmgs[2] = 2;
					script_createMeatDebris(hipRX, hipRY, random(_hitForce / 4), (_hitForce * (1 - _distToBody / radius)) / 12, _dirToBody, dsin(_bodyHeightFactor), 5, groundHeight - hipsY);
				}
			}
			if(hasLF && _distToLF < radius) {
				var _dirToLF   = point_direction(hitSourceId.x, hitSourceId.y, footLX, groundHeight);
				var _LFHeightFactor = darctan((groundHeight - footLY) / _distToLF);
				var _hitForce = power(1 - _distToLF / radius, dropOffPower) * knockback;
				var _heightCos = dcos(_LFHeightFactor);
				
				footLXChange += dcos(_dirToLF) * _hitForce * _heightCos;
				footLYChange -= dsin(_dirToLF) * _hitForce * _heightCos + _hitForce * dsin(_LFHeightFactor);
				groundLFYChange = -1 * dsin(_distToLF) * _hitForce * _heightCos * .7;
				
				if(_hitForce > limbStrengthGeneral * .9) {
					//remove left shin...
					hasLF = false;
					_partDmgs[3] = 1;
					script_createMeatDebris((footLX + jointLX) / 2, (footLY + jointLY) / 2, random(_hitForce / 4), (_hitForce * (1 - _distToLF / radius)) / 5, _dirToLF, dsin(_LFHeightFactor), 50, groundLFHeight - footLY);
				} else if(_hitForce > limbStrengthGeneral * .8) {
					//sever left knee...
					hasLF = false;
					_partDmgs[3] = 2;
					script_createMeatDebris(jointLX, jointLY, random(_hitForce / 4), (_hitForce * (1 - _distToLF / radius)) / 12, _dirToLF, dsin(_LFHeightFactor), 5, groundLJHeight - jointLY);
				}
			}
			if(hasRF && _distToRF < radius) {
				var _dirToRF   = point_direction(hitSourceId.x, hitSourceId.y, footRX, groundHeight);
				var _RFHeightFactor = darctan((groundHeight - footRY) / _distToRF);
				var _hitForce = power(1 - _distToRF / radius, dropOffPower) * knockback;
				var _heightCos = dcos(_RFHeightFactor);
				
				footRXChange += dcos(_dirToRF) * _hitForce * _heightCos;
				footRYChange -= dsin(_dirToRF) * _hitForce * _heightCos + _hitForce * dsin(_RFHeightFactor);
				groundRFYChange = -1 * dsin(_distToRF) * _hitForce * _heightCos * .7;
				
				if(_hitForce > limbStrengthGeneral * .9) {
					//remove right shin...
					hasRF = false;
					_partDmgs[4] = 1;
					script_createMeatDebris((footRX + jointRX) / 2, (footRY + jointRY) / 2, random(_hitForce / 4), (_hitForce * (1 - _distToRF / radius)) / 5, _dirToRF, dsin(_RFHeightFactor), 50, groundRFHeight - footRY);
				} else if(_hitForce > limbStrengthGeneral * .8) {
					//sever right knee...
					hasRF = false;
					_partDmgs[4] = 2;
					script_createMeatDebris(jointRX, jointRY, random(_hitForce / 4), (_hitForce * (1 - _distToRF / radius)) / 12, _dirToRF, dsin(_RFHeightFactor), 5, groundRJHeight - jointRY);
				}
			}
			
			if(!array_equals(_partDmgs, [0, 0, 0, 0, 0]) && !array_equals(_partDmgs, [1, 1, 1, 1, 1])) { // something destroyed but not everything destroyed, do sub checks
				if(_partDmgs[0] == 1) { // body destroyed
					instance_destroy(); // destroy enemy and spawn remaining parts as loose objects... body = enemy
				}
					
				if(_partDmgs[1] == 1) { // thigh destroyed         (left)
					if(_partDmgs[3] != 1) { // only shin exists
						// spawn loose left shin 
					} // else nothing, move on
				} else if(_partDmgs[1] == 2) { // thigh disconnected
					if(_partDmgs[3] != 1) { // thigh exists, if shin exists
						if(_partDmgs[3] == 2) { // knee of this intant leg severed
							// spawn loose thigh and shin seperately
						} else {
							// spawn whole left leg together
						}
					} else { // thigh exists (severed) but not shin
						//spawn loose thigh only
					}
				} else if(_partDmgs[3] == 2) { // knee severed
					//spawn loose shin
				} else if(_partDmgs[3] == 1) { // shin destroyed
					// remove shin from otherwise intact leg (spawn nothing)
				} // else nothing (leg fully intact)
					
					
				if(_partDmgs[2] == 1) { // thigh destroyed         (right)
					if(_partDmgs[4] != 1) { // only shin exists
						// spawn loose left shin 
					} // else nothing, move on
				} else if(_partDmgs[2] == 2) { // thigh disconnected
					if(_partDmgs[4] != 1) { // thigh exists, if shin exists
						if(_partDmgs[4] == 2) { // knee of this intant leg severed
							// spawn loose thigh and shin seperately
						} else {
							// spawn whole left leg together
						}
					} else { // thigh exists (severed) but not shin
						//spawn loose thigh only
					}
				} else if(_partDmgs[4] == 2) { // knee severed
					//spawn loose shin
				} else if(_partDmgs[4] == 1) { // shin destroyed
					// remove shin from otherwise intact leg (spawn nothing)
				} // else nothing (leg fully intact)
			}
						
			if(alive == 1) {
				//Well... each limb may have it's own health no?
				Health -= damage * (1 - _distToLF / radius);
	
				if(Health <= 0) {
					die();
				} else {
					if(irandom(2) == 0) {
						audio_play_sound(choose(snd_smallScreamFemale, snd_quickGruntMale), 0, 0,,,random_range(.7, 1.3));
					}
				}
			}
		} else { 
			// only apply knock back to body via stumble?
			var _dirToBody = point_direction(hitSourceId.x, hitSourceId.y, x, _heightPreCheck);
			var _bodyHeightFactor = darctan((_heightPreCheck - hipsY) / _distToBody);
			
			hipStumbleXChange += (dcos(_dirToBody) * power(1 - clamp(_distToBody / radius, 0, 1), dropOffPower)) * knockback * dcos(_bodyHeightFactor);
			hipStumbleYChange -= (dsin(_dirToBody) * power(1 - clamp(_distToBody / radius, 0, 1), dropOffPower)) * knockback * dcos(_bodyHeightFactor);
		}
	
	}
}

ragdollEnemy = function(duration = 212) {
	recoveringLimpTimer = max(duration, recoveringLimpTimer);
	if(ragdolling == 0) {
		//turn torso rotation, arms elbow, hands, leg joint, and feet into points with their own x/y change. This x/y change would be the x/y and the hitbox would be recentered on the torso x/y as to avoid disconnects for big ragdolls. 
		
		//"height"change representing the vertical speed up and down the map, basically if you fly back or towards the camera your ground y value will increase or decrease as you travel and be clipped when you hit the ground, we're faking lateral movement to do horiztonal and height in the air movement with the x/y change values
		//show_debug_message($"left shin values adding {jointLX}, {jointRX}, {footLX}, {footRY}");
	
		#region unused until ragdoll speed vars for joints... This is seeming like a worse and worse idea but at the same time I know this must be a thing because the joints need speeds so... Ugh
		footLXChange = footLX - prevFootLX;
		footLYChange = footLY - prevFootLY;
		footRXChange = footRX - prevFootRX;
		footRYChange = footRY - prevFootRY;
		jointLXChange = jointLX - prevJointLX; // simple as yeah? (ironic..)
		jointLYChange = jointLY - prevJointLY;
		jointRXChange = jointRX - prevJointRX;
		jointRYChange = jointRY - prevJointRY;
		xChange = hipsX - prevHipsX;
		yChange = hipsY - prevHipsY;
		x = hipsX;
		y = hipsY; // hips are projected during standing and not during rd so match them up during ragdolling
		
		#region height markers and changes
		groundHeight = max(footLY, footRY); // one of your feet is on the ground at all times right? (set only during ragdoll for the first time)
		groundYChange = yChange - hipStumbleYChange; // hip stumble is purely up and down so in theory net minus z gives y no?..... Eh... Kinda?
		
		groundLFHeight = groundHeight;
		groundLFYChange = groundYChange;
		
		groundRFHeight = groundHeight;
		groundRFYChange = groundYChange;
		
		groundLJHeight = groundHeight;
		groundLJYChange = groundYChange;
		
		groundRJHeight = groundHeight;
		groundRJYChange = groundYChange;
		#endregion
		#endregion
		
		ragdolling = 1;
	}
}

#region leg stuff!!! LEG STUFF

#region leg variables
legSegLen = 34;
thighWidth = 5;
shinWidth = 3;
thighColor = #779922;
shinColor = #665500;

footLX = 0;
footLY = 0;
footRX = 0;
footRY = 0;

jointLX = 0;
jointLY = 0;
jointRX = 0;
jointRY = 0;

hipLX = 0;
hipLY = 0;
hipRX = 0;
hipRY = 0;

hipsX = 0;
hipsY = 0;

#region unused until ragdoll speed vars for joints... This is seeming like a worse and worse idea but at the same time I know this must be a thing because the joints need speeds so... Ugh
footLXChange = 0;
footLYChange = 0;
footRXChange = 0;
footRYChange = 0;
jointLXChange = 0;
jointLYChange = 0;
jointRXChange = 0;
jointRYChange = 0;
#endregion

#region prevVars for speed deduction
prevFootLX = 0;
prevFootLY = 0;
prevFootRX = 0;
prevFootRY = 0;
prevJointLX = 0;
prevJointLY = 0;
prevJointRX = 0;
prevJointRY = 0;
prevHipsX = 0;
prevHipsY = 0;
#endregion

legRotation = 0;
legRotationSpeed = 6.4;

hipYOff = 5;
hipWidth = 5;
hipYBob = 0;

#region height related values
recoveringLimpTimer = 0; // if dead then despawn or draw to surface when this expires other wise switch to standing behavior
fallGravity = .025; // adds speed to bob y when dead or rag dolling to give collapsing

groundHeight = 0;
groundLFHeight = 0;
groundRFHeight = 0;
groundLJHeight = 0;
groundRJHeight = 0;

groundYChange = 0; // value that describes down map motion while the enemy is in the air / not ragdolling...
groundLFYChange = 0;
groundRFYChange = 0;
groundLJYChange = 0;
groundRJYChange = 0;
#endregion

hipStumbleDecay = .965;
hipStumbleXChange = 0;
hipStumbleYChange = 0;
hipStumbleX = 0;
hipStumbleY = 0;

lTrackX = 0;
lTrackY = 0;
rTrackX = 0;
rTrackY = 0;
trackDir = 0;
trackLen = 0;
trackHeight = 60;
#endregion

#region leg functions
setTrack = function(dir, spd) {
	var _cos = dcos(dir + 90);
	var _sin = dsin(dir + 90);
	
	lTrackX = x + _cos * hipWidth;
	lTrackY = y + trackHeight + hipYOff - _sin * hipWidth;
	rTrackX = x - _cos * hipWidth;
	rTrackY = y + trackHeight + hipYOff + _sin * hipWidth;
	
	trackDir = dir;
	trackLen = (spd * 14) / clamp(sqrt(spd / 2), .4, 2);
}

setFeetAtTrackBase = function(speedMoving) { // god i hate built in speed variable
	var _trackProg = dsin(legRotation);
	
	var _trackXToEnd = dcos(trackDir) * trackLen;
	var _trackYToEnd = -dsin(trackDir) * trackLen;
	
	var _trackAhead = speedMoving * .1;
	
	footLX = lTrackX + _trackXToEnd * (_trackProg + _trackAhead);
	footLY = lTrackY + _trackYToEnd * (_trackProg + _trackAhead);
	
	footRX = rTrackX + _trackXToEnd * (-_trackProg + _trackAhead);
	footRY = rTrackY + _trackYToEnd * (-_trackProg + _trackAhead);
}

raiseFeetOffTrack = function(spd) {
	footLY += clamp(dsin(legRotation + 270), -99, 0) * sqrt(spd) * 10;
	footRY += clamp(dsin(legRotation + 90), -99, 0) * sqrt(spd) * 10;
}

placeFeetFull = function(dir, spd) {
	setTrack(dir, spd);
	setFeetAtTrackBase(spd);
	raiseFeetOffTrack(spd);
	
	return "Calm down or you will have no sun and no rain";
}
#endregion

#endregion

holdingPart = -1;
clickLogicDebug = function() {
	live_auto_call
	holdingPart = -1;
	if(!ragdolling) {
		ragdollEnemy(9999999);
	} else {
		var _closestPart = -1; // 0:origin, 1:hips, 2:jointLeft, 3:jointRight, 4:footLeft, 5:footRight
		var _closestDist = 9999;
		var _thisPartDist = 9999;
		
		_thisPartDist = point_distance(mouse_x, mouse_y, footLX, footLY);
		if(_closestDist > _thisPartDist) {
			_closestDist = _thisPartDist;
			_closestPart = 4;
		}
		_thisPartDist = point_distance(mouse_x, mouse_y, footRX, footRY);
		if(_closestDist > _thisPartDist) {
			_closestDist = _thisPartDist;
			_closestPart = 5;
		}
		_thisPartDist = point_distance(mouse_x, mouse_y, jointRX, jointRY);
		if(_closestDist > _thisPartDist) {
			_closestDist = _thisPartDist;
			_closestPart = 3;
		}
		_thisPartDist = point_distance(mouse_x, mouse_y, jointLX, jointLY);
		if(_closestDist > _thisPartDist) {
			_closestDist = _thisPartDist;
			_closestPart = 2;
		}
		//_thisPartDist = point_distance(mouse_x, mouse_y, hipsX, hipsY);
		//if(_closestDist > _thisPartDist) {
		//	_closestDist = _thisPartDist;
		//	_closestPart = 1;
		//}
		_thisPartDist = point_distance(mouse_x, mouse_y, x, y);
		if(_closestDist > _thisPartDist) {
			_closestDist = _thisPartDist;
			_closestPart = 0;
		}
		
		if(_closestDist < 50) {
			holdingPart = _closestPart;
		}
	}
	
}

setLegVisuals = function(thighThickness = thighWidth, shinThickness = shinWidth, thighColoring = thighColor, shinColoring = shinColor) {
	thighWidth = thighThickness;
	shinWidth = shinThickness;
	thighColor = thighColoring;
	shinColor = shinColoring;
}

clickHoldLogicDebug = function() {
	live_auto_call
	if(ragdolling) {
		if(holdingPart != -1) {
			if(holdingPart == 0) {
				x = mouse_x;
				y = mouse_y;
				xChange = 0;
				yChange = 0;
			} else if(holdingPart == 1) {
				hipsX = mouse_x;
				hipsY = mouse_y;
				xChange = 0;
				yChange = 0;
			} else if(holdingPart == 2) {
				jointLX = mouse_x;
				jointLY = mouse_y;
				jointLXChange = 0;
				jointLYChange = 0;
			} else if(holdingPart == 3) {
				jointRX = mouse_x;
				jointRY = mouse_y;
				jointRXChange = 0;
				jointRYChange = 0;
			} else if(holdingPart == 4) {
				footLX = mouse_x;
				footLY = mouse_y;
				footLXChange = 0;
				footLYChange = 0;
			} else if(holdingPart == 5) {
				footRX = mouse_x;
				footRY = mouse_y;
				footRXChange = 0;
				footRYChange = 0;
			}
		}
	}
}

prevMouseX = mouse_x;
prevMouseY = mouse_y;

setLegVisuals(choose(4, 4, 5, 6, 8, 10, 2), choose(1, 2, 3, 4, 5), random_color(), random_color());