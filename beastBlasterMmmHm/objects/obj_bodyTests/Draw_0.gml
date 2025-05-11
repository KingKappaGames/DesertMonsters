#region body component drawing

array_sort(bodyComponents, function(elementCurrent, elementNext, originalOrder) // sort drawing based on visual height
{                
	return (-dsin(directionFacing + elementCurrent[2]) * elementCurrent[4]) - (-dsin(directionFacing + elementNext[2]) * elementNext[4]);
});

//msg(bodyComponents);

var _x = 0, _y = 0;
var _bodyOut = 14; // standard body distance? OR should this be a value in the array?
var _componentCount = array_length(bodyComponents);
var _counter = 0, _ang = 0;
for(var _i = 0; _i < _componentCount; _i++) {
	var _bodyPart = bodyComponents[_i];
	_ang = (directionFacing + _bodyPart[2]) % 360;
	_bodyOut = _bodyPart[4];
	if(_ang > 3 && _ang < 177) { // so maybe I shouldn't but this puts them further back than flat, a slightly behind thing by 3 degrees will go in front, this is maybe to give them a bit of covering thickness? But I do kind of hate the canabalistic effect of forcing up here.
		var _netAngle = _dirMoving + _bodyPart[2];
		var _imageInfo = _bodyPart[1];
		_x = x + _leanAheadX + dcos(_netAngle) * _bodyOut;
		_y = y + _leanAheadY - dsin(_netAngle) * _bodyOut * .6 + _bodyPart[3] + _jostle;
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
	
			_limb[2][0] = gunX;
			_limb[2][1] = gunY;
			_limb[2][2] = 0; //TODO height of gun is relevant but maybe y can do this ? But then it's faked and will surely break at some point
			
			var _limbDist = point_distance(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
			var _limbDir = point_direction(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
			
			var _limbOutDist = sqrt(clamp(sqr(limbLength) - sqr(_limbDist / 2), 0, 999999)); // outwardness of joint

			var _limbMidX = (_limb[0][0] + _limb[2][0]) / 2;
			var _limbMidY = (_limb[0][1] + _limb[2][1]) / 2; // visual mid point simply between start and end of limb

			var _armBendAngleSign = 1 - (abs(angle_difference(_limbDir + 90, 270)) > 90) * 2;
			//draw_text(x + 70, y - 20, _limbDir);
			//draw_text(x + 50, y, angle_difference(_limbDir - 90, 270));
			//draw_text(x + 50, y + 20, _armBendAngleSign);

			var _jointX = _limbMidX + dcos(_limbDir + 90 * _armBendAngleSign) * abs(_cosFacing) * _limbOutDist;
			var _jointY = _limbMidY - dsin(_limbDir + 90 * _armBendAngleSign) * _limbOutDist; // final joint positions
			
			//draw_line(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
			//var _col = [c_blue, c_red][.5 + _armBendAngleSign / 2];
			//draw_line_color((_limb[0][0] + _limb[2][0]) / 2, (_limb[0][1] + _limb[2][1]) / 2, _jointX, _jointY, _col, _col);

			_limb[1][0] = _jointX;
			_limb[1][1] = _jointY;
			_limb[1][2] = 0;
			#endregion
			
			for(var _limbSegI = array_length(_limb) - 2; _limbSegI >= 0; _limbSegI--) { // repeat nodes - 1, so n-n+1, n+1-n+2, n+2-n+3, ect but cut off one early, 3 nodes = 2 segments
				var _limbSegStart = _limb[_limbSegI];
				var _limbSegEnd = _limb[_limbSegI + 1];
				
				var _segBeginX = _limbSegStart[0];
				var _segBeginY = _limbSegStart[1] - _limbSegStart[2] * .7;
				var _segEndX = _limbSegEnd[0];
				var _segEndY = _limbSegEnd[1] - _limbSegEnd[2] * .7;
				
				var _sprite = _bodyPart[0][_limbSegI];
				
				var _segmentDir = point_direction(_segBeginX, _segBeginY, _segEndX, _segEndY); // visual dir, not horizontal dir
				var _lengthMultX = point_distance(_segBeginX, _segBeginY, _segEndX, _segEndY) / sprite_get_width(_sprite);
				
				draw_circle(_segEndX, _segEndY, 5, true);
				
				//msg(_lengthMultX);
				
				draw_sprite_ext(_sprite, _bodyPart[1][_limbSegI], _segBeginX, _segBeginY, _lengthMultX, _bodyPart[6][_limbSegI], _segmentDir, _bodyPart[9][_limbSegI], 1);
			}
		}
		_counter++;
	} else {
		break;
	}
}

#endregion

#region draw the rest of the body components in front of body
for(var _i = _counter; _i < _componentCount; _i++) {
	var _bodyPart = bodyComponents[_i];
	_bodyOut = _bodyPart[4];
	var _netAngle = _dirMoving + _bodyPart[2];
	var _imageInfo = _bodyPart[1];
	_x = x + _leanAheadX + dcos(_netAngle) * _bodyOut;
	_y = y + _leanAheadY - dsin(_netAngle) * _bodyOut * .6 + _bodyPart[3] + _jostle;
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
	
		_limb[2][0] = gunX;
		_limb[2][1] = gunY;
		_limb[2][2] = 0; //TODO height of gun is relevant but maybe y can do this ? But then it's faked and will surely break at some point
			
		var _limbDist = point_distance(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
		var _limbDir = point_direction(_limb[0][0], _limb[0][1], _limb[2][0], _limb[2][1]);
			
		var _limbOutDist = sqrt(clamp(sqr(limbLength) - sqr(_limbDist / 2), 0, 999999)); // outwardness of joint

		var _limbMidX = (_limb[0][0] + _limb[2][0]) / 2;
		var _limbMidY = (_limb[0][1] + _limb[2][1]) / 2; // visual mid point simply between start and end of limb

		var _armBendAngleSign = 1 - (abs(angle_difference(_limbDir + 90, 270)) > 90) * 2;

		var _jointX = _limbMidX + dcos(_limbDir + 90 * _armBendAngleSign) * abs(_cosFacing) * _limbOutDist;
		var _jointY = _limbMidY - dsin(_limbDir + 90 * _armBendAngleSign) * _limbOutDist; // final joint positions
		
		//draw_text(x - 70, y - 20, _limbDir);
		//draw_text(x - 50, y, angle_difference(_limbDir - 90, 270));
		//draw_text(x - 50, y + 20, _armBendAngleSign);

		_limb[1][0] = _jointX;
		_limb[1][1] = _jointY;
		_limb[1][2] = 0;
		#endregion
			
		for(var _limbSegI = array_length(_limb) - 2; _limbSegI >= 0; _limbSegI--) { // repeat nodes - 1, so n-n+1, n+1-n+2, n+2-n+3, ect but cut off one early, 3 nodes = 2 segments
			var _limbSegStart = _limb[_limbSegI];
			var _limbSegEnd = _limb[_limbSegI + 1];
				
			var _segBeginX = _limbSegStart[0];
			var _segBeginY = _limbSegStart[1] - _limbSegStart[2] * .7;
			var _segEndX = _limbSegEnd[0];
			var _segEndY = _limbSegEnd[1] - _limbSegEnd[2] * .7;
			
			var _sprite = _bodyPart[0][_limbSegI];
				
			var _segmentDir = point_direction(_segBeginX, _segBeginY, _segEndX, _segEndY); // visual dir, not horizontal dir
			var _lengthMultX = point_distance(_segBeginX, _segBeginY, _segEndX, _segEndY) / sprite_get_width(_sprite);
			
			draw_sprite_ext(_sprite, _bodyPart[1][_limbSegI], _segBeginX, _segBeginY, _lengthMultX, _bodyPart[6][_limbSegI], _segmentDir, _bodyPart[9][_limbSegI], 1);
		}
	}
	_counter++;
}
#endregion