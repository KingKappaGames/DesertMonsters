///@desc Written to simply take the component count and use all the local variables but edit to a more modular system is neede, this basically is just a way to centralize the code and not have to duplicate it
function script_drawComponents(startComponentI, leanAheadX, leanAheadY, jostle, cosFacing, moveDir, frontDraw){
	live_auto_call
	spineAngle += .1;
	
	var _spineAngle = spineAngle;
	var _counter = 0; // index counter for main component drawing loop (continues outside this function, hence why it's returned by this)
	var _componentCount = array_length(bodyComponents);
	
	var _x = 0, _y = 0;
	var distance = 14; // standard body distance? OR should this be a value in the array?
	var _ang = 0;
	
	var _surf = getSurf();
	var _surfMidX = surface_get_width(_surf) / 2;
	var _surfMidY = surface_get_height(_surf) / 2;
	var _surfOffX = x - _surfMidX;
	var _surfOffY = y - _surfMidY;
	
	for(var _i = startComponentI; _i < _componentCount; _i++) {
		with(bodyComponents[_i]) { // with struct for component (variable scoping)
			_ang = (other.directionFacing + rotationRelative) % 360;
			if(!frontDraw || (_ang > 3 && _ang < 177)) { // so maybe I shouldn't but this puts them further back than flat, a slightly behind thing by 3 degrees will go in front, this is maybe to give them a bit of covering thickness? But I do kind of hate the canabalistic effect of forcing up here.
				var _netAngle = moveDir + rotationRelative;
				var _imageInfo = image;
				_x = _surfMidX + leanAheadX + dcos(_netAngle) * distance + dcos(_spineAngle) * height;
				_y = _surfMidY + leanAheadY - dsin(_netAngle) * distance * .6 + jostle - dsin(_spineAngle) * height;   // applying sin/cos to height offset created some strange results because of sprite positions, perhaps drawing the body to a surface then rotating would be better? Correcting for absolute angle by removing body angle.. I dunno.
				var _compress = 1;
				if(!is_array(sprite)) { // single sprite
					if(viewCompressionMin != 1) {
						_compress = dsin(_netAngle + viewAngle) * (1 - viewCompressionMin);
						_compress += viewCompressionMin * sign(_compress);
					}
				
					var _sprite = -1;
					var _image = -1;
					if(is_array(sprite)) {
						var _directionIndex = floor(((((_netAngle + imageFromRotationAdjust) + 360) / 360) % 1) * (array_length(_imageInfo))); // set image/sprite from rotations
						_sprite = sprite[_directionIndex];
						_image = image[_directionIndex];
					} else {
						_sprite = sprite;
						_image = image;
					}
				
					draw_sprite_ext(sprite, _image, _x, _y, xscale * _compress, yscale, _spineAngle - 90, color, 1);
					//draw behind components?
				} else { // drawing limbs!
					var _limb = limbArrayRef; // store the reference to the array that holds the arrays at this index that holds the nodes of this limb for drawing with, specify the collection and where in that collection, basically
					var _weaponOffsets = gunHoldOffsets; // the specific hold position (relative) for this hand to go to
			
					#region place arms on gun via IK
					_limb[0][0] = _surfOffX + _x;
					_limb[0][1] = _surfOffY + _y + other.feetOffY; // WEAPON POSITION AND ECT SHOULD BE A STRUCT AS WELL, LIKE IN MAIN GAME (perhaps the weapon could store the animations for using it in its own struct data? Hm, probably just item curves and what not like the other items)
					_limb[0][2] = other.feetOffY + height; // * dsin(leanAngle); ??? height angle // set the two knowns, origin and gun position (the end)
				
					_limb[2][0] = other.weaponPosition[0] + _weaponOffsets[0] * dcos(other.gunHoldDirection); // x
					_limb[2][1] = other.weaponPosition[1] + _weaponOffsets[1] * dsin(other.gunHoldDirection); // y (duh)
					_limb[2][2] = other.weaponPosition[2] + _weaponOffsets[2]; // height //TODO height of gun is relevant but maybe y can do this ? But then it's faked and will surely break at some point
				
					var _limbDist = point_distance(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
					var _limbDir = point_direction(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
			
					script_setIKJoints(_limb, _limb[0][limbNode.len], _limbDist, _limbDir, cosFacing);
					#endregion
		
					script_drawIKLimb(_limb, self, x - _surfMidX, y - _surfMidY); // surf position top left at x
				}
				_counter++;
			} else {
				break;
			}
		}
	}
	
	return _counter; // just return to add
}