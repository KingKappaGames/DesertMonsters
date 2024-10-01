if(is_struct(currentlyShownQuest)) {
	draw_set_halign(fa_right);
	draw_text_transformed(940, view_get_hport(view_current) * .05, currentlyShownQuest.title, 3, 3, 7);
	var _currentExists = false;
	with(obj_questWatcher) {
		if(watchedQuest == other.currentlyShownQuest) {
			_currentExists = true;
		}
	}
	draw_text_transformed(920, view_get_hport(view_current) * .18, $"Active: {_currentExists}", 2, 2, -2);
	draw_set_halign(fa_left);
}