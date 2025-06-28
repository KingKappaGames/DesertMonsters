///@desc Written to simply take the component count and use all the local variables but edit to a more modular system is neede, this basically is just a way to centralize the code and not have to duplicate it
function script_drawComponents(startComponentI, leanAheadX, leanAheadY, jostle, cosFacing, moveDir, frontDraw){
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
	
	var _surf = getSurf();
	var _surfMidX = surface_get_width(_surf) / 2;
	var _surfMidY = surface_get_height(_surf) / 2; 
	var _surfOffX = _spineX - _surfMidX; 
	var _surfOffY = _spineY - _surfMidY;
	 
	var _creatureId = id; // whatever calls this will get stored, ez 
	var _directionSin = dsin(directionFacing);
	
	for(var _i = startComponentI; _i < _componentCount; _i++) {
		with(bodyComponents[_i]) { // with struct for component (variable scoping)
			_ang = (_creatureId.directionFacing + rotationRelative) % 360;
			if(!frontDraw || (_ang > 3 && _ang < 177)) { // so maybe I shouldn't but this puts them further back than flat, a slightly behind thing by 3 degrees will go in front, this is maybe to give them a bit of covering thickness? But I do kind of hate the canabalistic effect of forcing up here.
				
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
					_limb[0][0] = _surfOffX + _x;
					_limb[0][1] = _surfOffY + _y; // WEAPON POSITION AND ECT SHOULD BE A STRUCT AS WELL, LIKE IN MAIN GAME (perhaps the weapon could store the animations for using it in its own struct data? Hm, probably just item curves and what not like the other items)
					_limb[0][2] = _componentHeightNet; // * dsin(leanAngle); ??? height angle // set the two knowns, origin and gun position (the end)
					
					if(limbType == limbTypes.arm) { // if arm apply arm movements or... something..
						_limb[2][0] = _creatureId.weaponPosition[0] + gunHoldOffset[0] * dcos(_creatureId.gunHoldDirection); // x
						_limb[2][1] = _creatureId.weaponPosition[1] + gunHoldOffset[1] * dsin(_creatureId.gunHoldDirection); // y (duh)
						_limb[2][2] = _creatureId.weaponPosition[2] + gunHoldOffset[2]; // height //TODO height of gun is relevant but maybe y can do this ? But then it's faked and will surely break at some point
					}
				
					var _limbDir = point_direction(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
					if(limbType == limbTypes.leg) {
						var _limbDist = point_distance_3d(_limb[0][0], _limb[0][1], _limb[0][2], _limb[2][0], _limb[2][1], _limb[2][2]); // no respect for non 3 length limbs..
						var _limbLen = _limb[0][limbNode.len];
						
						
						draw_text(180, 100, "dist " + string(_limbDist));
						draw_text(180, 140, "len " + string(_limbLen));
						
						script_setIKJoints3D(_limb, _limbLen, _limbDist, _limbDir, cosFacing, _directionSin);
					} else {
						var _limbDist = point_distance(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
						script_setIKJoints(_limb, _limb[0][limbNode.len], _limbDist, _limbDir, cosFacing);
					}
					#endregion
					
					script_drawIKLimb(_limb, self, _creatureId.spineMain.x - _surfMidX, _creatureId.spineMain.y - _surfMidY); // surf position top left at x
				}
				_counter++;
			} else {
				break;
			}
		}
	}
	
	return _counter; // just return to add
}