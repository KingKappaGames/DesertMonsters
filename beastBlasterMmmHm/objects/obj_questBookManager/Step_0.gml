if(keyboard_check_released(vk_escape)) {
	instance_destroy();
}

currentQuestOpen = clamp(currentQuestOpen + (keyboard_check_released(vk_right) - keyboard_check_released(vk_left)), -1, 99);

if(keyboard_check_released(ord("N"))) {
	if(currentQuestOpen > -1 && currentQuestOpen < questCount) {
		questMan.endQuest(currentQuestOpen);
		questCount--;
	}
} else if(keyboard_check_released(vk_enter)) {
	questMan.focusQuest(questListCurrent[currentQuestOpen]);
}