/**
* returns {struct.__GMMapData}
*/
function __MapData() {
	
	static __white_pixel_data_2x2 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAD0lEQVR4AWL6DwVMDFAAAAAA//8tCooDAAAABklEQVQDAGvcB/1Sm89eAAAAAElFTkSuQmCC";
	static __pixel_sprite = sprite_add(__white_pixel_data_2x2, 0, false, false, 0, 0);
	static __pixel_sprite_dim = 2;
	static __map_room_width  = 0;
	static __map_room_height = 0;
	static __map_room_half_width  = 0;
	static __map_room_half_height = 0;
	static __player = noone;
	static __player_colour = c_black;
	static __objects = undefined;
	static __colours = undefined;
	static __surface = undefined;
	static __surface_circle = undefined;
	
	return static_get(__MapData);

}

__MapData();