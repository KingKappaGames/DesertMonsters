if (live_call()) return live_result;

draw_text_transformed(10 + playerIndex * 110, 10, $"X: {x} / Y: {y}", .5, .5, 0);
draw_text_transformed(10, 24, fps_real, .5, .5, 0);
draw_text_transformed(10, 44, fps, .5, .5, 0);