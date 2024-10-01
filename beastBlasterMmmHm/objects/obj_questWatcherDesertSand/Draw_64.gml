draw_circle(40, 300 + randomDebug * 40, 5, true);

if(focused == 1) {
	if(questCurrentStage == 1) {
		draw_text(600, 50, $"Grubs destroyed: {questProgress}");
	} else if(questCurrentStage == 2) {
		draw_text(600, 50, $"In drop zone: {questProgress}");
		draw_text(600, 100, $"Distance: {point_distance(obj_playerParent.x, obj_playerParent.y, 1300, 400)}");
	}
}