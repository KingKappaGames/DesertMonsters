//if (live_call()) return live_result;

watchedQuest = -1;

questProgress = 0;
questStageCount = 1;
questCurrentStage = 1;

randomDebug = random(10);

focused = 0;

///@desc This basically runs (or doesnt') at each progress point, so if there's 3 plot points to the quest then if you run stage 2's event it will run the middle event. This runs the event of the stage given not the next one.
questDoStageEndEvent = function(questStage = questCurrentStage) {
	//I want quest end to stay useful and not overwritten but I need modification so... nested functions
	//if stage == 1, 2, 3, ect
}

questEnd = function() { // fail, succeed, simply end and what happened is your fail or succeed?
	obj_questManager.endQuest(watchedQuest);
	
	instance_destroy();
}

//TODO when the quest becomes active in the game for either the first time this object (which means room restarts and game reloads) or first time ever, which would be stored in the save data, this intro to the quest code gets run. 
//Should it be per mission or per load / room enter? And if it is per game sys would there be a timer on resetting that "familiarity"? 
//And when the quest was recently seen would there be an alternative start like audio that was more re-explaining than first time intro or a little event that highlighted what happened the first time but not completely redoing the intro? 
//Could be cool and add some reactivity to the game which you know i love.
// VVV notes (^^^) for begin quest VVV
///@desc This is what get's run when the quest becomes active in the game for either the first time this object or first time ever (which?) and is where intro audio or cutscenes would be run
questBeginInGame = function() {
	show_debug_message("Runnign begin but for parent?")
}

advanceStage = function() {
	questDoStageEndEvent();
	
	questCurrentStage++;
	questProgress = 0;
	// no stages to this quest at the moment
	if(questCurrentStage > questStageCount) {
		questEnd();
	}
}

getMessage = function(messageMeaning, messageMeaningType, messageMagnitude = 1, messageSupplement = 0) { // this may be replaced with a proper broadcasting system yeah? But basically this takes messages from various places sent to the quest manager and it sends them down to active quests where each object interprets it's own meanings for itself and does whatever
	
}