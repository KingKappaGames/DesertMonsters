//if (live_call()) return live_result;

event_inherited();

questStageCount = 2;

///@desc This basically runs (or doesnt') at each progress point. This runs the event of the stage given not the next one.
questDoStageEndEvent = function(questStage = questCurrentStage) {
	//I want quest end to stay useful and not overwritten but I need modification so... nested functions
	//if stage == 1, 2, 3, ect
	if(questStage == 1) {
		repeat(12) {
			instance_create_layer(obj_playerParent.x + irandom_range(-500, 500), obj_playerParent.y + irandom_range(-300, 300), "Instances", obj_grub);
		}
	} else if(questStage == 2) {
		repeat(8) {
			instance_create_layer(obj_playerParent.x + irandom_range(-340, 340), obj_playerParent.y + irandom_range(-600, 120), "Instances", obj_supplyDrop);
		}
	}
}

///@desc This is what get's run when the quest becomes active in the game for either the first time this object or first time ever (which?) and is where intro audio or cutscenes would be run
questBeginInGame = function(/*familiar?*/) {
	audio_play_sound_at(snd_AnimalCallsFaint, obj_playerParent.x + 200, obj_playerParent.y, 0, 500, 1500, 1, 0, 0);
}

getMessage = function(messageMeaning, messageMeaningType, messageMagnitude = 1, messageSupplement = 0) { // this may be replaced with a proper broadcasting system yeah? But basically this takes messages from various places sent to the quest manager and it sends them down to active quests where each object interprets it's own meanings for itself and does whatever
	if(messageMeaning == "kill") {
		if(messageMeaningType == obj_grub) {
			if(questCurrentStage == 1) {
				questProgress += messageMagnitude;
			}
		}
	}
}

questBeginInGame();