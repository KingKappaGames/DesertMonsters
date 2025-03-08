//draw_rectangle(x - 5, y + 2, x + 5, y - 6, false)
//draw_rectangle(x - 3, y + 7, x + 3, y - 4, false)
//draw_rectangle(x - 4, y - 2, x + 4, y - 7, false)
//draw_line(x - 3, y + 7, x - 3, y + 7 + 8 * (current_time % 500) / 500);
//draw_line(x + 3, y + 7, x + 3, y + 7 + 8 * (1 - (current_time % 500) / 500));

//draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true)

if (live_call()) return live_result;

//draw thigh and calf segments and circle to round the knee and close visual gap

if(hasRJ) {
	draw_line_width_color(hipRX, hipRY, jointRX, jointRY, thighWidth, thighColor, thighColor); // right leg
	if(hasRF) {
		draw_line_width_color(jointRX, jointRY, footRX, footRY, shinWidth, shinColor, shinColor);
	}
	draw_circle_color(jointRX, jointRY, thighWidth / 2, thighColor, thighColor, false); // right knee
}
//TODO I should be using 3d drawing to draw the legs, the cross overs and specifics of the legs are really finicky and won't look good if they're done wrong so at LEAST the leg positions should be drawn accurately with a 3d render script (which I already have of course.) perhaps everything should be 3d especially if some things are going to be 3d. It would make it simpler to just remake the project using 3d logic if everythings going to be using 3d roughly anyway...
if(hasLJ) {
	draw_line_width_color(hipLX, hipLY, jointLX, jointLY, thighWidth, thighColor, thighColor); // left leg
	if(hasLF) {
		draw_line_width_color(jointLX, jointLY, footLX, footLY, shinWidth, shinColor, shinColor);
	}
	draw_circle_color(jointLX, jointLY, thighWidth / 2, thighColor, thighColor, false); // left knee
}

draw_circle(hipsX, hipsY, 12, false);

//draw_text(x, y - 100, yChange);

draw_set_alpha(.3);
draw_circle_color(x, groundHeight, 15, c_dkgray, c_gray, false);
draw_set_alpha(1);

//draw_line(x - 20, groundHeight, x + 20, groundHeight);
//draw_line(x - 20, groundLFHeight, x + 20, groundLFHeight);
//draw_line(x - 20, groundRFHeight, x + 20, groundRFHeight);
//draw_line(x - 20, groundLJHeight, x + 20, groundLJHeight);
//draw_line(x - 20, groundRJHeight, x + 20, groundRJHeight);