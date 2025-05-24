///@desc Adds a struct to the components array, note though that with this because you are describing a limb with multiple segments all the drawing values will be arrays representing joint to limb tip (hand, foot, whatever). So the position is the origin of the limb but the sprite, scale, img ect are arrays of each segment
///@param The target creature to add the component to
///@param The spine within the creature to attach the component to (will then base height and angles ect off of it)
///@param spriteArr The sprites to use, array of rotations, basically if you want a visual to change sprite when turned a certain way (say a head being a face vs the back of the head when facing the camera, put it here as an array (it samples pictures as 
///@param imageArr The sprite images to use, same as above, [image_brachii, image_forearm] where the image is sampled from the sprite for that segement
///@param rotRelative This is the off set from straight forward to draw the component (positional rotation)
///@param heightSet The y offset to draw this component with (how far along the spine)
///@param distanceSet The distance from the spine this item should rotate at unaffected by angle compression
///@param xscaleArr The horizontal scale of the images (pre compressions)
///@param yscaleArr The vertical scale of the images (pre compressions)
///@param viewAngleSet The direction of the view of the image, or the rotation of the visual in place (doesn't affect position), for backpacks it would be flat aka 0, for something that sticks out (tail?) and scales that way 90 would be "away" and the range 0 - 180 not -90 to 90, depends on the flatness of your perspective
///@param viewCompressionMinimum The minimum horizontal visual scale that can be had based on the view angles, backpacks might be .4 for 40% width at off angle view
///@param colorArr The color blend to apply, standard stuff
///@param imgRotationAdjust The angle to add to the view angle when getting the image for angle based images
///@param limbArrRef The array reference to get the nodes of drawing from, since arrays are ref passed you simply pass the [node1, node2, node3] limb array from wherever it is stored and this will sample from it
///@param gunHoldOffsetArr The array reference of the offset values for this gun and hold index (a rifle has two holding locations, right? So pass the sub array of the hold positions at the desired coords)
function script_addLimbBodyComponent(creature, spineIndex, spriteArr, imageArr, rotRelative, heightSet, distanceSet, xscaleSet, yscaleSet, viewAngleSet, viewCompressionMinimum, colorSet = c_white, imgRotationAdjust = 0, limbArrRef, gunHoldOffsetArr) constructor { // these limbs still need to adhere to rotation and position values because the sorting will use it the same way for all, or I can change it but seems easy enough as is
	sprite = spriteArr;
	image = imageArr; 
	rotationRelative = rotRelative; 
	height = heightSet; 
	distance = distanceSet; 
	xscale = xscaleSet; 
	yscale = yscaleSet; 
	viewAngle = viewAngleSet; 
	viewCompressionMin = viewCompressionMinimum; 
	color = colorSet; 
	imageRotationAdjust = imgRotationAdjust; 
	
	
	array_push(creature.bodyComponents, self); // spine indexing? creature.spines[spineIndex] ?
}

///@desc Adds a struct to the components array
///@param sprite The sprite to use
///@param image The sprite image to use
///@param rotationRelative This is the off set from straight forward to draw the component
///@param height The y offset to draw this component with
///@param distance The distance from the player this item should rotate at unaffected by angle compression
///@param xscale The horizontal scale of the image
///@param yscale The vertical scale of the image
///@param viewAngle The direction of the view of the image, for backpacks it would straight out aka 0, for something that sticks away and scales that way 90 would be "away" and the range 0 - 180 not -90 to 90, depends on the flatness of your perspective
///@param viewCompressionMin The minimum horizontal visual scale that can be had based on the view angles, backpacks might be .4 for 40% width at off angle view
///@param color The color blend to apply, standard stuff
///@param imgRotationAdjust The angle to add to the view angle when getting the image for angle based images



///@desc Adds a struct to the components array, note though that with this because you are describing a limb with multiple segments all the drawing values will be arrays representing joint to limb tip (hand, foot, whatever). So the position is the origin of the limb but the sprite, scale, img ect are arrays of each segment
///@param The target creature to add the component to
///@param The spine within the creature to attach the component to (will then base height and angles ect off of it)
///@param spriteArr The sprites to use, array of segments, aka [sprite_brachii, sprite_forearm] would be describing the two segments of the arm
///@param imageArr The sprite images to use, same as above, [image_brachii, image_forearm] where the image is sampled from the sprite for that segement
///@param rotRelative This is the off set from straight forward to draw the component (positional rotation)
///@param heightSet The y offset to draw this component with (how far along the spine)
///@param distanceSet The distance from the spine this item should rotate at unaffected by angle compression
///@param xscaleArr The horizontal scale of the images (pre compressions)
///@param yscaleArr The vertical scale of the images (pre compressions)
///@param viewAngleSet The direction of the view of the image, or the rotation of the visual in place (doesn't affect position), for backpacks it would be flat aka 0, for something that sticks out (tail?) and scales that way 90 would be "away" and the range 0 - 180 not -90 to 90, depends on the flatness of your perspective
///@param viewCompressionMinimum The minimum horizontal visual scale that can be had based on the view angles, backpacks might be .4 for 40% width at off angle view
///@param colorArr The color blend to apply, standard stuff
///@param imgRotationAdjust The angle to add to the view angle when getting the image for angle based images
///@param limbArrRef The array reference to get the nodes of drawing from, since arrays are ref passed you simply pass the [node1, node2, node3] limb array from wherever it is stored and this will sample from it
///@param gunHoldOffsetArr The array reference of the offset values for this gun and hold index (a rifle has two holding locations, right? So pass the sub array of the hold positions at the desired coords)
function script_addLimbBodyComponent(creature, spineIndex, spriteArr, imageArr, rotRelative, heightSet, distanceSet, xscaleArr, yscaleArr, viewAngleSet, viewCompressionMinimum, colorArr = c_white, imgRotationAdjust = 0, limbArrRef, gunHoldOffsetArr) constructor { // these limbs still need to adhere to rotation and position values because the sorting will use it the same way for all, or I can change it but seems easy enough as is
	sprite = spriteArr;
	image = imageArr; 
	rotationRelative = rotRelative; 
	height = heightSet; 
	distance = distanceSet; 
	xscale = xscaleArr; 
	yscale = yscaleArr; 
	viewAngle = viewAngleSet; 
	viewCompressionMin = viewCompressionMinimum; 
	color = colorArr; 
	imageRotationAdjust = imgRotationAdjust; 
	limbArrayRef = limbArrRef; 
	gunHoldOffset = gunHoldOffsetArr; // hand position (limb end) should be its own thing so that the creature can freely change what/how its hands are moved, linking the hand position directly to the gun is cool but not good long term, so I should create a intermediate value that can hold the gun array OR be set on its own, say to a swinging animation if you have a free hand
	
	/*potential additions:
	absolute angle (hanging things or such non rotating components)
	movement images (changes sprite based on speed or such)
	type (could desinate what to do with this component instead of having to check the variable types to guess what to do when drawing or placing)
	rigidity (if the component wiggles or falls off, ect)
	functions? (on removal, on hit, on a certain speed reached..?)
	*/
	
	
	array_push(creature.bodyComponents, self); // spine indexing? creature.spines[spineIndex] ?
}