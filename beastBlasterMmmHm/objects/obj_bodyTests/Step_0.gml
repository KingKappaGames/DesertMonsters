
for(var _i = array_length(limbArray) - 1; _i >= 0; _i--) {
	var _limb = limbArray[_i];
	script_setIKJoints(_limb, _limb[0][limbNode.len], _dist, _dir, _facingCos);
}