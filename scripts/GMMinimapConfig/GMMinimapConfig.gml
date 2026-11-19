//**			GMMinimap config				  **//
//--------------------------------------------------//

//If game uses ztestenable set to true.
#macro GMMM_3D_game						false
//--------------------------------------------------//

//Set true if map should rotate.
#macro GMMM_map_rotate					false

//Set the variable target for angle.
#macro GMMM_map_rotate_angle_target		undefined

//Set true for circular map.
#macro GMMM_map_circular				true
//--------------------------------------------------//

//Set frame sprite.
#macro GMMM_frame_set_sprite			GMMM_map_circular ? sprFrame_circular : sprFrame
//--------------------------------------------------//

//Set true if using a background.
#macro GMMM_background_enabled			true

//Set background colour, ignored if sprite is used.
#macro GMMM_background_colour			c_black

//Set background sprite.
#macro GMMM_background_sprite			undefined
//--------------------------------------------------//

//Set true to draw tilesets.
#macro GMMM_tilesets_draw				true
//--------------------------------------------------//