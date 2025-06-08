if (live_call()) return live_result;

//draw_set_alpha(.5 + dcos((current_time % 324000) / 900) / 2);
//draw_set_alpha(light);
//draw_rectangle_color(0, 0, 1000, 800, c_black, c_black, c_black, c_black, false);
//draw_text(150, 20, $"Temperature: {temperature}");
draw_set_alpha(abs(temperature - 50) / 275);
//var _col = #bfcdff;
var _col = make_color_rgb(155 + temperature, 150, 255 - temperature);

draw_rectangle_color(0, 0, 1000, 800, _col, _col, _col, _col, false);
draw_set_alpha(1);