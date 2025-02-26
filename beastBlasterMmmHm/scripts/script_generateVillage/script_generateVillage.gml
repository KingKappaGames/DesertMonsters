///@desc Generate a village of block modular design and spawn people inside, very basic for now
///@param xx x coord to spawn center at
///@param yy y coord to spawn center at
///@param type The theme of the village
///@param size The size of the village, aka, how many houses to attempt to spawn. May not actually be this many depending on availability
///@param density The spacing between houses or spawned buildings
///@param quality El calidad del pueblo, o, el nivel de technologia que este pueblo ha subido
///@param population This can either be the total population, or if a negative value is given the amount of people per spawned building

function script_generateVillage(xx, yy, type, size, density, quality, population){
	var _placeArray = []; // store nodes of created things x/y
	var _placeCount = 0;
	
	var _peoplePerBuilding = abs(population);
	if(population > 0) {
		_peoplePerBuilding = round(population / size);
	}
	
	repeat(size) {
		xx += choose(-density, density);
		yy += choose(-density, density);
		
		var _contains = false;
		for(var _i = 0; _i < _placeCount; _i++) {
			if(array_equals(_placeArray[_i], [xx, yy])) {
				_contains = true;
				break;
			}
		}
		
		if(!_contains) {
			instance_create_layer(xx, yy, "Instances", obj_desertStructure);
			repeat(_peoplePerBuilding) {
				instance_create_layer(xx + irandom_range(-80, 80), yy + irandom_range(-80, 80), "Instances", obj_desertRatMan);
			}
			array_push(_placeArray, [xx, yy]);
			_placeCount++;
		}
	}
}