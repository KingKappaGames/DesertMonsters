function script_drawIKLimb(limb, bodyPart){
	for(var _limbSegI = array_length(limb) - 2; _limbSegI >= 0; _limbSegI--) { // repeat nodes - 1, so n-n+1, n+1-n+2, n+2-n+3, ect but cut off one early, 3 nodes = 2 segments
		var _limbSegStart = limb[_limbSegI];
		var _limbSegEnd = limb[_limbSegI + 1];
				
		var _segBeginX = _limbSegStart[0];
		var _segBeginY = _limbSegStart[1] - _limbSegStart[2] * .7;
		var _segEndX = _limbSegEnd[0];
		var _segEndY = _limbSegEnd[1] - _limbSegEnd[2] * .7;
			
		var _sprite = bodyPart[0][_limbSegI];
				
		var _segmentDir = point_direction(_segBeginX, _segBeginY, _segEndX, _segEndY); // visual dir, not horizontal dir
		var _lengthMultX = point_distance(_segBeginX, _segBeginY, _segEndX, _segEndY) / sprite_get_width(_sprite);
			
		draw_sprite_ext(_sprite, bodyPart[1][_limbSegI], _segBeginX, _segBeginY, _lengthMultX, bodyPart[6][_limbSegI], _segmentDir, bodyPart[9][_limbSegI], 1);
	}
}