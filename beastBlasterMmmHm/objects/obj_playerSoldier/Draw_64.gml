if (live_call()) return live_result;
	
script_mdlDrawGUI();

draw_text(view_wport[0] * .45, view_hport[0] * .8, stepTimings[0][1] - stepTimings[0][2]);
draw_text(view_wport[0] * .55, view_hport[0] * .8, stepTimings[1][1] - stepTimings[1][2]);

draw_text(view_wport[0] * .55, view_hport[0] * .75, ragdolling);
draw_text(view_wport[0] * .55, view_hport[0] * .78, recoveringLimpTimer);
draw_text(view_wport[0] * .55, view_hport[0] * .81, recoveringStandingTimer);
draw_text(view_wport[0] * .55, view_hport[0] * .84, [spineMain.x, spineMain.y, spineMain.z]);
draw_text(view_wport[0] * .55, view_hport[0] * .87, [spineMain.tipX, spineMain.tipY, spineMain.tipZ]);

draw_text_transformed(view_wport[0] * .05, view_hport[0] * .95, ragdollLegNodesSpeed, .8, .8, 0);