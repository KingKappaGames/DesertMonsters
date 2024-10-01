event_inherited();

if(alive == 1) {
	if(irandom(30) == 0 && (xChange != 0 || yChange != 0)) {
		if(point_distance(x, y, travelToGoalX, travelToGoalY) < 20) {
			xChange = 0;
			yChange = 0;
		} else if(irandom(360) == 0) {
			startTravelToPoint(travelToGoalX, travelToGoalY); // reset direction and seeking because I don't calculate corrections to path otherwise
		}
	} else if(irandom(300) == 0) {
		startTravelToPoint(x + choose(irandom_range(-1000, -200), irandom_range(200, 1000)), y + choose(irandom_range(-800, -200), irandom_range(200, 800)))
	}
}