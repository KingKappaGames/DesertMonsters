if(questCurrentStage == 1) {
	if(questProgress >= 10) {
		advanceStage();
	}
} else if(questCurrentStage == 2) {
	if(obj_playerParent.x < 1400 && obj_playerParent.x > 1200 && obj_playerParent.y < 500 && obj_playerParent.y > 300) {
		questProgress = 1;
		if(irandom(700) == 0) { // this should be a timer and the quests should have gap periods between stages probably for delays
			advanceStage();
		}
	} else {
		questProgress = 0;
	}
}

if(keyboard_check_released(vk_end)) {
	questProgress++;
}