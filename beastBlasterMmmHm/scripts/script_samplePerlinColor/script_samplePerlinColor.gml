function script_samplePerlinColor(xx, yy) {
	var _height = getPerlinNoise_2D(xx / blockSize, yy / blockSize, valueRange);
	
	var _color = 0;

	if(_height > valueRange * 1.0) {
		_color = #f0bf90;
	} else if(_height > valueRange * .80) {
		_color = #f0bf7a;
	} else if(_height > valueRange * .60) { 
		_color = #c99751;
	} else if(_height > valueRange * .55) {
		_color = #9e763e;
	} else if(_height > valueRange * .40) {
		_color = #5e4c33;
	} else if(_height > valueRange * .37) {
		_color = #aa2400;
	} else if(_height > valueRange * .25) {
		_color = #5e4c33;
	} else if(_height > valueRange * .21) {
		_color = #483a23;
	} else if(_height > valueRange * .16) {
		_color = #3e4c23;
	} else {
		_color = #362d21;
	}
	
	return [_color, _height];
}