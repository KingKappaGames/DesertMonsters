if(live_call()) { return live_result }

draw_text(500, 400, "systemEdge: " + string(currentSysEdge));
draw_text(500, 420, previousCamY);
draw_text(500, 440, sysCollectionMoveSign);
draw_text(500, 460, "mouseY: " + string(mouse_y));
draw_text(500, 480, "mouse layer: " + string(mouseLayer) + " and the DEPTH: " + string(particleLayerDepthArray[mouseLayer]));
draw_text(500, 500, "discrepency: " + string(-mouse_y - particleLayerDepthArray[mouseLayer]));

for(var _depthI = 1; _depthI < sysCount; _depthI++) {
	draw_text_transformed(700 + dcos(_depthI * 90) * 28, _depthI * 3.3, particleLayerDepthArray[_depthI], .45, .45, 0);
	if(_depthI % 4 == 0) {
		draw_text_transformed(750 + dcos(_depthI * 90) * 28, _depthI * 3.3, _depthI, .45, .45, 0);
	}
}