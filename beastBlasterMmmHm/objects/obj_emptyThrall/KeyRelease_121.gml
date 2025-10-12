if (live_call()) return live_result;

//addToBodyComponents();

msg("Running redesign event");

bodyComponents = [];
								// img arrays are 0-360 lerped for the angle they draw at, use the rotation adjust to change this and pass the correct order of drawing (common would be [frontImg, backImg] then a 90 degree adjust
			
// UPDATING AREA, NOT DEFAULT, PAY ATTENTION BECAUSE EDITING THIS IS ANNOYING IF YOU"RE TRYING TO MAKE THE NORMAL ONE WORK BOZO
//                                       target  spine       sprite(s)                 image(s)  rotRel  height   dist,     xscl         yscl     viewAng   viewComp   color            imgGetRotAdd   fixedAngle     limbArrRef     gunOffArrRef
var gmliveNull = 0; // just set the constructor to something because gmlive doesn't handle constructors not returning anything I guess?
gmliveNull = new script_addBodyComponent(    id,    0,  spr_robeParts,                  [8, 1],    0,     0,        0,     1.6,           2,         0,      .6,      #3D3D29,               0);                                        // body
gmliveNull = new script_addBodyComponent(    id,    0,  spr_robeParts,                  [9, 3],    0,     22,       2,     1.6,           2,         0,      .6,      #ffaaaa,               0);                                        // head
gmliveNull = new script_addBodyComponent(    id,    0,  spr_robeParts,                  0,         85,    12,       10,    1.6,           2,         0,      .4,      #4D4D39,               0);                                        // shoulder
gmliveNull = new script_addBodyComponent(    id,    0,  spr_robeParts,                  0,         -85,   12,       10,    1.6,           2,         0,      .4,      #4D4D39,               0);                                        // shoulder
gmliveNull = new script_addLimbBodyComponent(id,    0,  [spr_armParts,   spr_armParts], [0, 0],    80,    15,       10,    [1.6, 1.6],    [2, 2],    0,      1,       [ #4D4D39, #4D4D39],   0,         undefined,   limbArray[0], gunHoldOffsets[0]); // arm arrays
gmliveNull = new script_addLimbBodyComponent(id,    0,  [spr_armParts,   spr_armParts], [0, 0],    -80,   15,       10,    [1.6, 1.6],    [2, 2],    0,      1,       [ #4D4D39, #4D4D39],   0,         undefined,   limbArray[1], gunHoldOffsets[1]); // arm arrays
gmliveNull = new script_addBodyComponent(    id,    0,  spr_robeParts,                  4,         0,     -2,       -6,    1.6,           2,         0,      .4,      #363622,               0);                                        // cape


// Okay, this system is so stupid but also works 100% 
// i've said this a dozen times but I need to make this system work properly, even build an editor to click and drag characters together so that potentially it can go out to randoms for making characters
// but it needs animation support, adding data controlled animations that can play or not play, and it needs a few extra customization techniques, maybe a depth forcing changer value

// maybe the skeleton could angle and the body drawing would draw based on those angles/with sprite rotations to match? Sound slightly complex but also laggy (minorly) but doable