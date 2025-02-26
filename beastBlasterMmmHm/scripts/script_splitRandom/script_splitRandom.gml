///@desc This script takes a given value and splits it into completely random chunks that add up to the whole. You can also specify if the chunks should not be below a certain size.
function script_splitRandom(total, sections, minimumGap){
	if(sections > 1) {
		var _pieces = [];
		var _resultPieces = array_create(sections, 0);
		var _availableRange = total - (sections * minimumGap);
	
		repeat(sections - 1) {
			array_push(_pieces, random(_availableRange));
		}
	
		array_sort(_pieces, function(elm1, elm2)
		{
		    return elm1 - elm2;
		});
	
		for(var _i = 0; _i < sections; _i++) {
			if(_i == sections - 1) { // last section from last point to end
				_resultPieces[_i] = _availableRange - _pieces[_i - 1];
			} else if(_i > 0) {
				_resultPieces[_i] = _pieces[_i] - _pieces[_i - 1];
			} else {
				_resultPieces[_i] = _pieces[_i];
			}
		
			_resultPieces[_i] += minimumGap;
		}
		
		return _resultPieces;
	} else if(sections > 0) {
		return [total];
	} else {
		return -1;
	}
}