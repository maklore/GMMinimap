/**
* returns {struct.__GMMapData}
*/
function __MapData() {
	
	static __white_pixel_data_2x2 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAD0lEQVR4AWL6DwVMDFAAAAAA//8tCooDAAAABklEQVQDAGvcB/1Sm89eAAAAAElFTkSuQmCC";
	static __pixel_sprite = sprite_add(__white_pixel_data_2x2, 0, false, false, 0, 0);
	static __pixel_sprite_dim = 2;
	static __map_area_top_x = 0;
	static __map_area_left_y = 0;
	static __map_area_bottom_x = room_width;
	static __map_area_right_y = room_height;
	static __map_area_half_bottom_x = undefined;
	static __map_area_half_right_y = undefined;
	static __ztest = undefined;
	static __player = undefined;
	static __player_colour = undefined;
	static __objects = undefined;
	static __colours = undefined;
	static __surface = undefined;
	static __surface_circle = undefined;
	
	return static_get(__MapData);

}

//__MapData();