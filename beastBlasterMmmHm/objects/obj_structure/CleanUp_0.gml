var _partCount = array_length(particleArray);
for(var _timeI = _partCount - 1; _timeI >= 0; _timeI--) {
	particleArray[_timeI][1] = current_time + 20000; // 20 second delay period til removed
}


global.particleGrinderQueue = array_concat(global.particleGrinderQueue, particleArray); // this breaks reference... Hmmmmmm
array_sort(global.particleGrinderQueue, function(pos1, pos2) {
	if(pos1[1] < pos2[1]) {
		return true;
	} else {
		return false;
	}
});