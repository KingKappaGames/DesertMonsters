///@desc sets the offset values of the held weapon without breaking the array ref, embeded array references tell the component system where to draw to so if you break it it'll stop updating..
function script_setHoldOffsets(offsetX1, offsetY1, offsetZ1, offsetX2, offsetY2, offsetZ2) { // just two hands right??
	gunHoldOffsets[0][0] = offsetX1; // x
	gunHoldOffsets[0][1] = offsetY1; // y
	gunHoldOffsets[0][2] = offsetZ1; // z
	gunHoldOffsets[1][0] = offsetX2; // x
	gunHoldOffsets[1][1] = offsetY2; // y 
	gunHoldOffsets[1][2] = offsetZ2; // z
}