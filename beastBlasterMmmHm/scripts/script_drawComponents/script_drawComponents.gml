///@desc Written to simply take the component count and use all the local variables but edit to a more modular system is neede, this basically is just a way to centralize the code and not have to duplicate it
function script_drawComponents(startComponentI, leanAheadX, leanAheadY, jostle, moveDir, frontDraw){
	live_auto_call
	
	#region spine value setting 
	var _spineX = 0;
	var _spineY = 0;
	var _spineHeight = 0;
	var _spineLength = 0;
	var _spineAngle = 0;
	with(spineMain) { // with set because faster or something idk
		_spineX = x;
		_spineY = y;
		_spineHeight = height;
		_spineLength = length;
		_spineAngle = angle;
	}
	
	var _spineCos = dcos(_spineAngle);
	var _spineSin = dsin(_spineAngle);
	#endregion
	
	var _counter = 0; // index counter for main component drawing loop (continues outside this function, hence why it's returned by this)
	var _componentCount = array_length(bodyComponents);
	
//	spineAngle += .2;
	
	var _x = 0, _y = 0, _heightY = 0;
	var _ang = 0;
	
	var _mdlSurf = script_mdlGetSurf();
	var _surfMidX = mdlSurfWidth / 2;
	var _surfMidY = mdlSurfHeight / 2; 
	var _surfOffX = _spineX - _surfMidX; 
	var _surfOffY = _spineY - _surfMidY;
	 
	var _creatureId = id; // whatever calls this will get stored, ez 
	var _directionCos = dcos(directionFacing);
	var _directionSin = dsin(directionFacing);
	
	var _break = false;
	for(var _i = startComponentI; _i < _componentCount; _i++) {
		with(bodyComponents[_i]) { // with struct for component (variable scoping)
			_ang = (_creatureId.directionFacing + rotationRelative) % 360;
			if(!frontDraw || (_ang > 0 && _ang < 180)) {
				
				var _netAngle = moveDir + rotationRelative;
				var _compress = 1;
				var _drawAngle = fixedDrawAngle == 999 ? _spineAngle - 90 : fixedDrawAngle; // if 999 dont use, otherwise set to fixed angle
				
				var _componentHeightNet = _spineHeight + _spineSin * height; // height
				
				_x = _surfMidX + leanAheadX + dcos(_netAngle) * distance + _spineCos * height; // x/y WITHOUT height
				_y = _surfMidY + leanAheadY - dsin(_netAngle) * distance * .7 + jostle;   // applying sin/cos to height offset created some strange results because of sprite positions, perhaps drawing the body to a surface then rotating would be better? Correcting for absolute angle by removing body angle.. I dunno.
				
				
				var _imageInfo = image;
				if(!is_array(sprite)) { // single sprite
					if(viewCompressionMin != 1) {
						_compress = dsin(_netAngle + viewAngle) * (1 - viewCompressionMin);
						_compress += viewCompressionMin * sign(_compress);
					}
				
					var _sprite = -1;
					var _image = -1;
					if(is_array(sprite)) { // sprite is array
						var _directionIndex = floor(((((_netAngle + imageFromRotationAdjust) + 360) / 360) % 1) * (array_length(_imageInfo))); // set image/sprite from rotations
						_sprite = sprite[_directionIndex];
						if(is_array(image)) { // both are arrays
							_image = image[_directionIndex];
						} else {
							_image = image;
						}
					} else if(is_array(image)) { // image only is array
						var _directionIndex = floor(((((_netAngle + imageFromRotationAdjust) + 360) / 360) % 1) * (array_length(_imageInfo))); // set image/sprite from rotations
						_sprite = sprite;
						_image = image[_directionIndex];
					} else {  // neither arrays
						_sprite = sprite;
						_image = image;
					}
				
					draw_sprite_ext(_sprite, _image, _x, _y - _componentHeightNet * .7, xscale * _compress, yscale, _drawAngle, color, 1);
					//draw behind components?
				} else { // drawing limbs!
					var _limb = limbArrayRef; // store the reference to the array that holds the arrays at this index that holds the nodes of this limb for drawing with, specify the collection and where in that collection, basically
			
					#region place arms on gun via IK
					var _socket = _limb[0];
					
					_socket[0] = _surfOffX + _x;
					_socket[1] = _surfOffY + _y; // WEAPON POSITION AND ECT SHOULD BE A STRUCT AS WELL, LIKE IN MAIN GAME (perhaps the weapon could store the animations for using it in its own struct data? Hm, probably just item curves and what not like the other items)
					_socket[2] = _componentHeightNet; // * dsin(leanAngle); ??? height angle // set the two knowns, origin and gun position (the end)
					
					var _extremity = _limb[2];
					
					if(limbType == limbTypes.arm) { // if arm apply arm movements or... something..
						var _weaponPos = _creatureId.weaponPosition;
						var _weaponHoldDir = _creatureId.weaponHoldDirection;
						var _cos = dcos(_weaponHoldDir);
						var _sin = -dsin(_weaponHoldDir);
						
						
						_extremity[0] = _weaponPos[0] + weaponHoldOffsets[0] * _cos - weaponHoldOffsets[1] * _sin; // x
						_extremity[1] = _weaponPos[1] + weaponHoldOffsets[1] * _cos - weaponHoldOffsets[0] * -_sin; // y (duh)
						_extremity[2] = _weaponPos[2] + weaponHoldOffsets[2]; // height //TODO height of gun is relevant but maybe y can do this ? But then it's faked and will surely break at some point
					}
				
					var _limbDir = point_direction(_socket[0], _socket[1], _extremity[0], _extremity[1]);
					if(limbType == limbTypes.leg) {
						var _limbDist = point_distance_3d(_socket[0], _socket[1], _socket[2], _extremity[0], _extremity[1], _extremity[2]); // no respect for non 3 length limbs..
						var _limbLen = _socket[limbNode.len];
						
						script_setIKJoints3DLeg(_limb, _limbLen, _limbDist, _limbDir, _directionCos, _directionSin);
						script_drawLimbSegIn3d(_limb, self, _creatureId.spineMain.x - _surfMidX, _creatureId.spineMain.y - _surfMidY);
					} else {
						var _limbDist = point_distance_3d(_socket[0], _socket[1], _socket[2], _extremity[0], _extremity[1], _extremity[2]); // no respect for non 3 length limbs..
						var _limbLen = _socket[limbNode.len];
						
						script_setIKJoints3D(_limb, _limbLen, _limbDist, _limbDir, _directionCos, 1 - _directionSin);
						script_drawLimbSegIn3d(_limb, self, _creatureId.spineMain.x - _surfMidX, _creatureId.spineMain.y - _surfMidY,, true);
					}
					#endregion
				}
				_counter++;
			} else {
				_break = true;
				break;
			}
		}
		
		if(_break) { break; } // can't bail two loops at once?
	}
	
	return _counter; // just return to add
}