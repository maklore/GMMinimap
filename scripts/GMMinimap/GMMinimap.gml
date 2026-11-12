function GMMinimap() {
		
	/**
	* Generate a map of coloured rectangles instances in the current room based on set tags or objects.
	* @param {asset.GMObject | id.instance} _player Player object asset or instance id.
	* @param {constant.color} _player_colour Player colour.
	* @param {array<asset.GMObject>} _objects Object assets.
	* @param {constant.color | array<constant.color>} _colours Colour or an array of colours (if using an array, recommend using an array of objects above).
	*/
	static generate = function(_player, _player_colour, _objects, _colours = c_white) {
		
		static __data = __MapData();
		
		__data.__player = _player;
		__data.__player_colour = _player_colour;
		__data.__map_room_width  = room_width;
		__data.__map_room_height = room_height;
		__data.__map_room_half_width = room_width  * 0.5;
		__data.__map_room_half_height = room_height * 0.5;
		__data.__objects ??= _objects;
		__data.__colours ??= _colours;
		
		var _objects_count = array_length(_objects);
		
		__data.__surface = surface_create(room_width, room_height);
		surface_set_target(__data.__surface);
		
		//Background colour
		draw_clear_alpha(GMMM_background_colour, GMMM_background_alpha);
		
		for (var i = 0; i < _objects_count; ++i) {
			var _object = __data.__objects[i];
			var _index = array_get_index(__data.__objects, _object);

		    with _object {
				
				var _colour = is_array(_colours) ? _colours[_index] : _colours;
				var _width  = sprite_get_width(sprite_index);
				var _height = sprite_get_height(sprite_index);
				var _xoff   = sprite_get_xoffset(sprite_index);
				var _yoff   = sprite_get_yoffset(sprite_index);
				
				sprite_set_offset(__data.__pixel_sprite, _xoff / _width * __data.__pixel_sprite_dim, _yoff / _height * __data.__pixel_sprite_dim);
				
				other.__draw_sprite_stretched_rot(__data.__pixel_sprite, 0, x, y, sprite_width, sprite_height, image_angle, _colour, 1);

			}
		}
				
		surface_reset_target();
	}
	
	/**
	* Removes generated map from memory.
	*/
	static cleanup = function() {
		
		static __data = __MapData();
		
		if surface_exists(__data.__surface) {
			surface_free(__data.__surface);
		}
		
		__data.__objects = undefined;
		__data.__colours = undefined;
		__data.__map_room_width  = 0;
		__data.__map_room_height = 0;
		__data.__map_room_half_width  = 0;
		__data.__map_room_half_height = 0;
		__data.__surface = undefined;
		
	}
	
	/**
	* Draw generated map and player.
	* @param {real} _x			X position.
	* @param {real} _y			Y position.
	* @param {real} _width		Width.
	* @param {real} _height		Height.
	* @param {real} [_scale]	Scale.
	* @param {real} [_alpha]	Alpha.
	*/
	static draw = function(_x, _y, _width, _height, _scale = 1, _alpha = 1) {
		
		static __data = __MapData();
		
		if is_undefined(__data.__objects) {
			exit;	
		}
		
		if !surface_exists(__data.__surface) { 
			generate(__data.__player, __data.__player_colour, __data.__objects, __data.__colours);
			show_debug_message("Remade map surface");
		}
		
		//Map
		var _distance_to_player = point_distance(__data.__map_room_half_width, __data.__map_room_half_height, __data.__player.x, __data.__player.y);
		var _direction_to_player = point_direction(__data.__map_room_half_width, __data.__map_room_half_height, __data.__player.x, __data.__player.y);
		var _ldirx = lengthdir_x(_distance_to_player, _direction_to_player);
		var _ldiry = lengthdir_y(_distance_to_player, _direction_to_player);
		var _scale_adjustment = 1 / _scale;
		var _half_width  = _width * 0.5;
		var _half_height = _height * 0.5;
		var _map_pos_x   = _ldirx + __data.__map_room_half_width - _half_width * _scale_adjustment;
		var _map_pos_y   = _ldiry + __data.__map_room_half_height - _half_height * _scale_adjustment;
		var _map_width   = _width * _scale_adjustment;
		var _map_height  = _height * _scale_adjustment;

		
		if surface_exists(__data.__surface) {
			
			if GMMM_rotate_map and !is_undefined(GMMM_rotate_map_angle_target) {
				var _scissor = gpu_get_scissor()
				var _resolution_width_scale = window_get_width() / display_get_gui_width();
				var _resolution_height_scale = window_get_height() / display_get_gui_height();
				gpu_set_scissor(_x, _y, _width * _resolution_width_scale, _height * _resolution_height_scale);
				if GMMM_background_alpha > 0 {
					draw_sprite_stretched_ext(__data.__pixel_sprite, 0, _x, _y, _width, _height, GMMM_background_colour, GMMM_background_alpha);
				}
				var transform_matrix = matrix_build(_x + _half_width, _y + _half_height, 0, 0, 0, GMMM_rotate_map_angle_target, 1, 1, 1);
				matrix_set(matrix_world, transform_matrix);
				draw_surface_part_ext(__data.__surface, 
									  _map_pos_x, 
									  _map_pos_y, 
									  _map_width * 2, 
									  _map_height * 2, 
									  _x - _half_width, 
									  _y - _half_height, 
									  _scale, _scale, 
									  c_white, _alpha);
			
				matrix_set(matrix_world, matrix_build_identity());
				gpu_set_scissor(_scissor);
			} else {
				draw_surface_part_ext(__data.__surface, _map_pos_x, _map_pos_y, _map_width, _map_height, _x, _y, _scale, _scale, c_white, _alpha);
			}
		}
		
		//Player
		var _player_width  = __data.__player.sprite_width * _scale;
		var _player_height = __data.__player.sprite_height * _scale;
		var _player_half_width  = _player_width * 0.5;
		var _player_half_height = _player_height * 0.5;
		var _player_x = _x + _half_width - _player_half_width;
		var _player_y = _y + _half_height - _player_half_height;
		//var _xoff   = sprite_get_xoffset(__data.__player.sprite_index);
		//var _yoff   = sprite_get_yoffset(__data.__player.sprite_index);
		//sprite_set_offset(__data.__pixel_sprite, _xoff / _player_width * __data.__pixel_sprite_dim, _yoff / _player_height * __data.__pixel_sprite_dim);
		__draw_sprite_stretched_rot(__data.__pixel_sprite, 0, _player_x + _player_half_width, _player_y + _player_half_height, _player_width, _player_height, GMMM_rotate_map ? GMMM_rotate_map_angle_target : 0, __data.__player_colour, 1);
		//draw_line(_x + _half_width, _y, _x + _half_width, _y + _height)
		//draw_line(_x, _y + _half_width, _x + _width, _y + _half_height)
	}
	
	/// @ignore
	static __draw_sprite_stretched_rot = function(sprite, subimg, _x, _y, w, h, rot, colour, alpha) {
	    draw_sprite_ext(sprite, subimg, _x, _y, w / sprite_get_width(sprite), h / sprite_get_height(sprite), rot, colour, alpha);
	}
	
	return static_get(GMMinimap);
	
}

GMMinimap();