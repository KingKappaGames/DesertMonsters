function script_calculate3dEndPoints(spinAngle, liftAngle, length) {
	var height = lengthdir_y(length, liftAngle); // height
	var hyp = lengthdir_x(length, liftAngle); // The horizontal component of the height offset that get's passed to the x and y's below as horizontal length
	var horizontal = lengthdir_x(hyp, spinAngle); // x
	var vertical = lengthdir_y(hyp, spinAngle); // y

    return [horizontal, vertical, height];
}