if(live_call()) { return live_result }

draw_text(430, 320, "edge layer depth: " + string(particleLayerDepthArray[currentSysEdge]));
draw_text(430, 340, "sys spacing: " + string(sysSpacing));
draw_text(430, 360, "margin height: " + string(sysUpdateRange));
draw_text(430, 400, "systemEdge: " + string(currentSysEdge));
draw_text(430, 420, "prevCamY: " + string(previousCamY));
draw_text(430, 440, "sys move dir (absolute): " + string(sysCollectionMoveSign));
draw_text(430, 460, "mouseY: " + string(mouse_y));
draw_text(430, 480, "mouse layer: " + string(mouseLayer) + " and the DEPTH: " + string(particleLayerDepthArray[mouseLayer]));
draw_text(430, 500, "discrepency: " + string(-(mouse_y) - particleLayerDepthArray[mouseLayer]));
draw_text(430, 520, "camHeight: " + string(camera_get_view_height(view_camera[0])));

for(var _depthI = 1; _depthI < sysCount; _depthI++) {
	draw_text_transformed(700 + dcos(_depthI * 90) * 28, _depthI * 3.3, particleLayerDepthArray[_depthI], .45, .45, 0);
	if(_depthI % 4 == 0) {
		draw_text_transformed(750 + dcos(_depthI * 90) * 28, _depthI * 3.3, _depthI, .45, .45, 0);
	}
}