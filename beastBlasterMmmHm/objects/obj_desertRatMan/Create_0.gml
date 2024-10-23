if (live_call()) return live_result;

event_inherited();

image_xscale = 14;
image_yscale = 20;

Health = 12;
alive = 1;
recoveringStandingTimer = 0;
recoveringLimpTimer = 0;
ragdolling = 0;
airHeight = 0;

die = function() {
	alive = 0;
	recoveringLimpTimer = 2880; // 20 seconds, long enough to not be relevant, tbf they don't really need to deactivate anyway... it's not laggy or anything and they get deactivated just like normal. Idk
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

ragdollEnemy = function(duration = 212) {
	recoveringLimpTimer = max(duration, recoveringLimpTimer);
	if(ragdolling == 0) {
		//turn torso rotation, arms elbow, hands, leg joint, and feet into points with their own x/y change. This x/y change would be the x/y and the hitbox would be recentered on the torso x/y as to avoid disconnects for big ragdolls. 
		ragdolling = 1;
	
		groundHeight = max(footLY, footRY); // one of your feet is on the ground at all times right?
		//"height"change representing the vertical speed up and down the map, basically if you fly back or towards the camera your ground y value will increase or decrease as you travel and be clipped when you hit the ground, we're faking lateral movement to do horiztonal and height in the air movement with the x/y change values
		//show_debug_message($"left shin values adding {jointLX}, {jointRX}, {footLX}, {footRY}");
	
		#region unused until ragdoll speed vars for joints... This is seeming like a worse and worse idea but at the same time I know this must be a thing because the joints need speeds so... Ugh
		footLXChange = footLX - prevFootLX;
		footLYChange = footLY - prevFootLY;
		footRXChange = footRX - prevFootRX;
		footRYChange = footRY - prevFootRY;
		jointLXChange = jointLX - prevJointLX; // simple as yeah?
		jointLYChange = jointLY - prevJointLY;
		jointRXChange = jointRX - prevJointRX;
		jointRYChange = jointRY - prevJointRY;
		xChange = hipsX - prevHipsX;
		yChange = hipsY - prevHipsY;
		x = hipsX;
		y = hipsY;
		#endregion
		//show_debug_message($"left shin values rag doll {jointLX}, {jointRX}, {footLX}, {footRY}");
	}
}

#region leg stuff!!! LEG STUFF

#region leg variables
legSegLen = 34;

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

recoveringLimpTimer = 0; // if dead then despawn or draw to surface when this expires other wise switch to standing behavior
fallGravity = .025; // adds speed to bob y when dead or rag dolling to give collapsing
groundHeight = 0;

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