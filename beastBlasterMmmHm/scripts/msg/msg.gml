function msg(variableToOutput, variableName = "msg: ", callLocation = 0){
	if(callLocation == 0) {
		show_debug_message(variableName + ": " + string(variableToOutput) + "                         Hint... " + string(object_get_name(object_index)) + " and " + string(event_type) + ", Good luck!");
	} else {
		show_debug_message(variableName + ": " + string(variableToOutput) + "  |  Called from " + string(callLocation));
	}
}