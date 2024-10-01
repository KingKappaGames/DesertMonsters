draw_circle(40, 300 + randomDebug * 40, 5, true);

if(focused == 1) {
	draw_text(600, 50, clamp(questProgress, 0, 20000000));
}