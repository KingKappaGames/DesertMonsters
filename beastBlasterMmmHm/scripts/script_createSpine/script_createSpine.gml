/// @desc Returns a spine struct to place and manipulate components around, you must set everything yourself, this struct doesn't really *do* anything itself, just holds values neat and tidy
/// @param {real} xx The x of the spine origin, will be changed as you go but set initial here I guess
/// @param {real} yy The y of the spine origin, will be changed as you go but set initial here I guess
/// @param {real} angle The angle of the spine, will be changed as you go but set initial here I guess
/// @param {real} lengthSet The length of the spine, doesn't set the distance of the components or anything but is used sometimes for connecions or whole body calculations
/// @returns {struct} Returns a spine struct
function script_createSpine(xx, yy, angleSet, anglelengthSet = 0) constructor {
	x = 0;
	y = 0;
	height = 0;
	angle = 0;
	length = 50;
	
	return self;
	//uhhh
}

