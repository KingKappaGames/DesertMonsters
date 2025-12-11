if (live_call()) return live_result;
	
script_mdlDrawGUI();

draw_text(view_wport[0] * .45, view_hport[0] * .8, stepTimings[0][1] - stepTimings[0][2]);
draw_text(view_wport[0] * .55, view_hport[0] * .8, stepTimings[1][1] - stepTimings[1][2]);