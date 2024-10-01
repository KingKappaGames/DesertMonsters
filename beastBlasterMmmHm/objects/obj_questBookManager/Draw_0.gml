draw_set_alpha(.4);
var _camX = camera_get_view_x(view_camera[0]);
var _camY = camera_get_view_y(view_camera[0]);
var _camWidth = camera_get_view_width(view_camera[0]);
var _camHeight = camera_get_view_height(view_camera[0]);
draw_rectangle_color(_camX + 40, _camY + 40, _camX + _camWidth - 40, _camY + _camHeight - 40, c_grey, c_grey, c_grey, c_grey, false);
draw_set_alpha(1);

if(currentQuestOpen > -1 && currentQuestOpen < questCount) {
	draw_text_transformed(_camX + 100, _camY + 100, questListCurrent[currentQuestOpen].title, 4, 4, 0);
	draw_text_transformed(_camX + 100, _camY + 300, "Challenge: " + string(questListCurrent[currentQuestOpen].difficulty), 2, 2, 0);
} else {
	draw_text_transformed(_camX + _camWidth / 3, _camY + _camHeight * .75  - 100, "More journies await you", 4, 4, 0);
}

draw_text(_camX, _camY + 20, $"Active quest count: {questCount}");
draw_text(_camX + 200, _camY + 20, $"Completed quest count: {array_length(obj_questManager.completedQuests)}");