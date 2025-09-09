//if (live_call()) return live_result;

draw_sprite_ext(spr_crosshair, floor((current_time % 250) / 125), input_cursor_x(playerIndex), input_cursor_y(playerIndex), 1, 1, (current_time % 720) / 2, c_red, 1);

if(input_check("control")) {
	draw_text(x, y - 50, string(playerIndex));
}