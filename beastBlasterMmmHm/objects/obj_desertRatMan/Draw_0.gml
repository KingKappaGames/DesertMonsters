//draw_rectangle(x - 5, y + 2, x + 5, y - 6, false)
//draw_rectangle(x - 3, y + 7, x + 3, y - 4, false)
//draw_rectangle(x - 4, y - 2, x + 4, y - 7, false)
//draw_line(x - 3, y + 7, x - 3, y + 7 + 8 * (current_time % 500) / 500);
//draw_line(x + 3, y + 7, x + 3, y + 7 + 8 * (1 - (current_time % 500) / 500));

//draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true)

if (live_call()) return live_result;

draw_circle(hipsX, hipsY, 12, false);

//draw thigh and calf segments and circle to round the knee and close visual gap
draw_line_width(hipRX, hipRY, jointRX, jointRY, 5); // right leg
draw_line_width(jointRX, jointRY, footRX, footRY, 3);

draw_line_width(hipLX, hipLY, jointLX, jointLY, 5); // left leg
draw_line_width(jointLX, jointLY, footLX, footLY, 3);

draw_circle(jointRX, jointRY, 2, false); // both knees
draw_circle(jointLX, jointLY, 2, false);


draw_text(x - 100, y, hipStumbleXChange);
draw_text(x - 100, y + 20, hipStumbleYChange);

draw_text(x - 150, y, hipStumbleX);
draw_text(x - 150, y + 20, hipStumbleY);