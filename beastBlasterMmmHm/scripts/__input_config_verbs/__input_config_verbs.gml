// Feather disable all

//This script contains the default profiles, and hence the default bindings and verbs, for your game
//
//  Please edit this macro to meet the needs of your game!
//
//The struct return by this script contains the names of each default profile.
//Default profiles then contain the names of verbs. Each verb should be given a binding that is
//appropriate for the profile. You can create bindings by calling one of the input_binding_*()
//functions, such as input_binding_key() for keyboard keys and input_binding_mouse() for
//mouse buttons

function __input_config_verbs()
{
    return {
         keyboard_and_mouse:
        {
            up:    [input_binding_key(vk_up),    input_binding_key("W")],
            down:  [input_binding_key(vk_down),  input_binding_key("S")],
            left:  [input_binding_key(vk_left),  input_binding_key("A")], // move cardinals
            right: [input_binding_key(vk_right), input_binding_key("D")],
            
            characterSwitch:  input_binding_key(vk_space),
            reload:  input_binding_key("R"),
			gunSwitch: input_binding_key("Q"), // player controls
			drop: input_binding_key("X"),
            sprint: input_binding_key(vk_shift),
            
            //No aiming verbs since we use the mouse for that (see below for aiming verb examples)
            leftClick: input_binding_mouse_button(mb_left),
            rightClick: input_binding_mouse_button(mb_right), // mouses and attack things
            middleClick: input_binding_mouse_button(mb_middle),
            
            escape: input_binding_key(vk_escape),
			control: input_binding_key(vk_control),
			cameraChange: input_binding_key("C"), // managment controls
			restart: input_binding_key(vk_f8),
			fullscreen: input_binding_key("F"),
        },
        
        gamepad:
        {
            up:    [input_binding_gamepad_axis(gp_axislv, true),  input_binding_gamepad_button(gp_padu)],
            down:  [input_binding_gamepad_axis(gp_axislv, false), input_binding_gamepad_button(gp_padd)], // move cardinals
            left:  [input_binding_gamepad_axis(gp_axislh, true),  input_binding_gamepad_button(gp_padl)],
            right: [input_binding_gamepad_axis(gp_axislh, false), input_binding_gamepad_button(gp_padr)],
            
            characterSwitch:  input_binding_gamepad_button(gp_stickr),
            reload:  input_binding_gamepad_button(gp_face3),
            gunSwitch:  input_binding_gamepad_button(gp_face4), // player misc control buttons
			drop: input_binding_gamepad_button(gp_stickl),
            //crouch: input_binding_gamepad_button(gp_face2), // we still have b and a xbox faces
			sprint: input_binding_gamepad_button(gp_shoulderl),
            
            aimUp:    input_binding_gamepad_axis(gp_axisrv, true),
            aimDown:  input_binding_gamepad_axis(gp_axisrv, false), // aiming on controller
            aimLeft:  input_binding_gamepad_axis(gp_axisrh, true),
            aimRight: input_binding_gamepad_axis(gp_axisrh, false),
			
            leftClick:     [input_binding_gamepad_button(gp_shoulderrb)],
            rightClick:     [input_binding_gamepad_button(gp_shoulderr)], // mouses and attacks
            middleClick:     [input_binding_gamepad_button(gp_shoulderlb)],
			
            escape: input_binding_gamepad_button(gp_start),
            control: input_binding_gamepad_button(gp_select),
			cameraChange: input_binding_gamepad_button(gp_padu), // managment things
			restart: input_binding_gamepad_button(gp_padd),
			fullscreen: input_binding_gamepad_button(gp_padr),
        },
    };
}