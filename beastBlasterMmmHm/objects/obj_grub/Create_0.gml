//if (live_call()) return live_result;

event_inherited();

image_xscale = 60;
image_yscale = 25;

Health = 12;

moveSpeed = .2;

die = function() {
	script_sendQuestMessage("kill", obj_grub, 1);
	alive = 0;
	instance_destroy();
}

friendly = false;