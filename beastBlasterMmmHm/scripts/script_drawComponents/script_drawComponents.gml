///@desc Written to simply take the component count and use all the local variables but edit to a more modular system is neede, this basically is just a way to centralize the code and not have to duplicate it
function script_drawComponents(startComponentI, leanAheadX, leanAheadY, jostle, cosFacing, moveDir, frontDraw){
	var _counter = 0;
	var _componentCount = array_length(bodyComponents);
	var _x = 0, _y = 0;
	var _bodyOut = 14; // standard body distance? OR should this be a value in the array?
	var _ang = 0;
	for(var _i = startComponentI; _i < _componentCount; _i++) {
		var _bodyPart = bodyComponents[_i];
		_ang = (directionFacing + _bodyPart[2]) % 360;
		_bodyOut = _bodyPart[4];
		if(!frontDraw || (_ang > 3 && _ang < 177)) { // so maybe I shouldn't but this puts them further back than flat, a slightly behind thing by 3 degrees will go in front, this is maybe to give them a bit of covering thickness? But I do kind of hate the canabalistic effect of forcing up here.
			var _netAngle = moveDir + _bodyPart[2];
			var _imageInfo = _bodyPart[1];
			_x = x + leanAheadX + dcos(_netAngle) * _bodyOut;
			_y = y + leanAheadY - dsin(_netAngle) * _bodyOut * .6 + _bodyPart[3] + jostle;
			var _compress = 1;
			if(!is_array(_bodyPart[0])) { // single sprite
				if(_bodyPart[8] != 1) {
					_compress = dsin(_netAngle + _bodyPart[7]) * (1 - _bodyPart[8]);
					_compress += _bodyPart[8] * sign(_compress);
				}
				var _directionImg = floor(((((_netAngle + _bodyPart[10]) + 360) / 360) % 1) * (array_length(_imageInfo)));
				draw_sprite_ext(_bodyPart[0], is_array(_imageInfo) ? _imageInfo[_directionImg] : _imageInfo, _x, _y, _bodyPart[5] * _compress, _bodyPart[6], 0, _bodyPart[9], 1);
				//draw behind components?
			} else { // drawing limbs!
				var _limb = _bodyPart[11][_bodyPart[12]]; // store the reference to the array that holds the arrays at this index that holds the nodes of this limb for drawing with, specify the collection and where in that collection, basically
			
				#region place arms on gun via IK
				_limb[0][0] = _x;
				_limb[0][1] = _y;
				_limb[0][2] = 0; // set the two knowns, origin and gun position (the end)
	
				_limb[2][0] = weaponPosition[0];
				_limb[2][1] = weaponPosition[1];
				_limb[2][2] = 0; //TODO height of gun is relevant but maybe y can do this ? But then it's faked and will surely break at some point
			
				var _limbDist = point_distance(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
				var _limbDir = point_direction(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
			
				script_setIKJoints(_limb, _limb[0][limbNode.len], _limbDist, _limbDir, cosFacing);
				#endregion
		
				script_drawIKLimb(_limb, _bodyPart);
			}
			_counter++;
		} else {
			break;
		}
	}
	
	return _counter; // just return to add
}