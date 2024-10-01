activeQuests = array_create(0, 0); // array of structs currently active and possible to access

completedQuests = array_create(0, 0); // array of structs for quests in finsihed form

currentlyShownQuest = -1; // for ease of development, I don't want there to actually be check marks or counters in the missions in the end, but for now having the missions show to the screen with distinct variables is nice.

///@desc Returns a quest struct set up for beginning the quest. Doesn't do anything with the struct, you have to add it to the right place.
///@param questName The string name of the quest
getQuest = function(questName) {
	if(questName == "mainSandHunt") {
		var _quest = {
			///data1,2,3 ect : value,
			title: "Sand hunt",
			difficulty: "Easy",
			observerIndex: obj_questWatcherDesertSand,
			activeCondition: "mainRoom" // idk what conditions apply to
		}
		return _quest;
	} else if(questName == "sideRebornInDust") {
		var _quest = {
			///data1,2,3 ect : value,
			title: "Born in the dust",
			difficulty: "Exposition",
			observerIndex: obj_questWatcher,
			activeCondition: "sideRoom" // idk what conditions apply to
		}
		return _quest;
	} else if(questName == "mainReturnToTheSea") {
		var _quest = {
			///data1,2,3 ect : value,
			title: "Journey to the sea",
			difficulty: "Medium",
			observerIndex: obj_questWatcher,
			activeCondition: "oceanRoom" // idk what conditions apply to
		}
		return _quest;
	} else if(questName == "mainSaveDarkArmy") {
		var _quest = {
			///data1,2,3 ect : value,
			title: "Save the dark army",
			difficulty: "Medium",
			observerIndex: obj_questWatcher,
			activeCondition: "nightRoom" // idk what conditions apply to
		}
		return _quest;
	}
}

///@param quest The struct of the quest to add to active quests and initialize
activateQuest = function(quest) {
	var _alreadyActivated = false;
	for(var _i = array_length(completedQuests) - 1; _i > -1; _i--) {
		if(completedQuests[_i].title == quest.title) {
			_alreadyActivated = 1;
			break;
		}
	}
	if(_alreadyActivated == 0) {
		for(var _i = array_length(activeQuests) - 1; _i > -1; _i--) {
			if(activeQuests[_i].title == quest.title) {
				_alreadyActivated = 1;
				break;
			}
		}
	}
	if(_alreadyActivated == 0) {
		array_push(activeQuests, quest); // sorting?
	}
}

///@param quest The struct of the quest to end in the list, can also be a array position of the quest list
endQuest = function(quest) {
	if(!array_contains(completedQuests, quest)) {
		if(is_struct(quest)) {
			if(currentlyShownQuest == quest) {
				focusQuest(-1);
			}
			var _pos = array_get_index(activeQuests, quest);
			array_push(completedQuests, quest); // sorting?
			array_delete(activeQuests, _pos, 1);
		} else if(is_real(quest)) {
			if(currentlyShownQuest == activeQuests[quest]) {
				focusQuest(-1);
			}
			array_push(completedQuests, activeQuests[quest]); // sorting?
			array_delete(activeQuests, quest, 1);
		}
	} else {
		//already ended?
	}
}

///@desc The function to use to start a quest and manage all the conditions of doing so
startQuest = function(questName) {
	activateQuest(getQuest(questName));
}

focusQuest = function(quest) {
	if(is_struct(quest)) {
		currentlyShownQuest = quest;
		with(obj_questWatcher) {
			if(watchedQuest == quest) {
				focused = 1;
			} else {
				focused = 0;
			}
		}
	} else if(quest == -1) {
		currentlyShownQuest = -1;
	}
}

refreshWatchers = function(refreshValue) {
	with(obj_questWatcher) {
		if(refreshValue != watchedQuest.activeCondition) {
			instance_destroy();
		}
	}
	for(var _i = array_length(activeQuests) - 1; _i > -1; _i --) {
		if(activeQuests[_i].activeCondition == refreshValue) {
			createWatcher(activeQuests[_i]);
		}
	}
}

createWatcher = function(questToWatch, supplement = -1) {
	var _alreadyExists = false;
	with(obj_questWatcher) {
		if(watchedQuest == questToWatch) { // don't create if already exists!
			_alreadyExists = true;
			break;
		}
	}
	
	if(_alreadyExists == 0) { // checked all observers and found none for this quest, make new one now
		var _questObserver = instance_create_layer(x, y, "Instances", questToWatch.observerIndex);
		_questObserver.watchedQuest = questToWatch;
		if(_questObserver.watchedQuest == currentlyShownQuest) {
			_questObserver.focused = 1;
		}
	} 
	// supplement ... ect whatever might be useful
}