if (live_call()) return live_result;

draw_set_color(#0000af);
draw_line_width(x, y - bulletHeight, x - xChange * 10, y - bulletHeight - clamp(yChange * 2 + bulletDrop * 10, -10, 10), 5);
draw_set_color(c_white);