if(keyboard_check(vk_backspace)) {
	setWeatherTemperature(temperature + .1);
}

if(keyboard_check(vk_enter)) {
	setWeatherTemperature(temperature - .1);
}