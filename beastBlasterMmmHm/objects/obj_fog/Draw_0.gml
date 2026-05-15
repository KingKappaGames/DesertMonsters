if (live_call()) return live_result;

if(mouse_check_button(mb_middle)) {
	drawToFogSurf(fogDrawAlpha, mouse_x, mouse_y, spr_circleGradientMask, 0, fogDrawScale, random(360), c_white);
}

//if(mouse_check_button(mb_right)) {
	//drawRemoveFromFogSurf(1, mouse_x, mouse_y, spr_circleGradient, 0, 3, random(360), random_color()); 
//}

draw();

fogDrawAlpha *= power(1.04, keyboard_check(vk_right) - keyboard_check(vk_left));
fogDrawScale *= power(1.04, keyboard_check(vk_down) - keyboard_check(vk_up));