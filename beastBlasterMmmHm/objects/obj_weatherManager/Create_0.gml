temperature = 50; // 0 - 100 !

light = 100; // 0 - 100 !

windX = 0;
windY = 0; // wind x/y gets added to things like particles and debris 

precipitationStrength = 0; // 0 - 100

depth = 0;

setWeatherTemperature = function(temp) {
	temp = clamp(temp, 0, 100);
	temperature = temp;
	if(temp > 50) {
		var _fx = layer_get_fx("Effects");
		if(_fx == -1 || fx_get_name(_fx) != "_filter_heathaze") {
			_fx = fx_create("_filter_heathaze");
		}
		var _params = fx_get_parameters(_fx);
	    _params.g_Distort1Amount = (temp - 50) / 25; // 0 - 5/20 ish
	    _params.g_Distort2Amount = (temp - 50) / 12;

		fx_set_parameters(_fx, _params);
		
		layer_set_fx("Effects", _fx);
	} else {
		var _fx = layer_get_fx("Effects");
		if(_fx == -1 || fx_get_name(_fx) != "_filter_dots") {
			_fx = fx_create("_filter_dots");
		}
		var _params = fx_get_parameters(_fx);
	    _params.g_DotsScale = 14;
	    _params.g_DotsSize = .2;
	    _params.g_DotsSize2 = .1;
	    _params.g_DotsDisplacement = 1;
	    _params.g_DotsSpeed = .45;
	    _params.g_DotsColourSpeed = .2;
	    _params.g_DotsColours = 32;
	    _params.g_DotsPalette = spr_whiteColorPallete;
		_params.g_DotsSharpness = clamp(abs(temp - 50) * .07, 0, 2);

		fx_set_parameters(_fx, _params);
		
		layer_set_fx("Effects", _fx);
	}
}

setWeatherTemperature(temperature);