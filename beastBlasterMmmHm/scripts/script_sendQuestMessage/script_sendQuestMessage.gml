function script_sendQuestMessage(messageMeaning, messageMeaningType, messageMagnitude = 1, messageSupplement = 0){
	with(obj_questWatcher) {
		getMessage(messageMeaning, messageMeaningType, messageMagnitude, messageSupplement)
	}
}