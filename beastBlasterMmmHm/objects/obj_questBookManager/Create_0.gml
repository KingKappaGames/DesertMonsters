if(instance_number(object_index) > 1) {
	instance_destroy();
	exit;
}

questMan = obj_questManager;
questListCurrent = questMan.activeQuests;

currentQuestOpen = -1;

questCount = array_length(questListCurrent);