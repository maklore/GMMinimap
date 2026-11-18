/**
 * Generate a minimap of set objects and colour(s) of the current room.
 * @returns {struct.GMMinimap}
 */
function GMMinimap() {
		
	/**
	* Add to an objects room start event, generate a map of instances in the current room based on set array of objects and colour(s).
	* @param {asset.GMObject | id.instance} _player Player object asset or instance id.
	* @param {constant.color} _player_colour Player colour.
	* @param {array<asset.GMObject>} _objects Object assets.
	* @param {constant.color | array<constant.color>} [_colours] Colour, or an array of colours in order of object assets. (Ignore if GMMM_object_draw_sprites enabled in config).
	*/
	static generate = function(_player, _player_colour, _objects, _colours = c_white) {
		
		static __data = __MapData();
		static __ztest = false;
		
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
		
		if GMMM_3D_game {
			
			__ztest = gpu_get_ztestenable();
			gpu_set_ztestenable(false);
		}
		
		if GMMM_tilesets_draw {
			
			var _layer = layer_get_all();
			var _layer_count = array_length(_layer);
			for (var i = 0; i < _layer_count; ++i) {
				var _layer_tilemap = layer_tilemap_get_id(_layer[i]);
				
				if _layer_tilemap != -1 {
					var _tileset = tilemap_get_tileset(_layer_tilemap);
					var _tile_width = tilemap_get_tile_width(_layer_tilemap);
					var _tile_height = tilemap_get_tile_height(_layer_tilemap);
					var _width_count = __data.__map_room_width / _tile_width;
					var _height_count = __data.__map_room_height / _tile_height;
					for (var w = 0; w < _width_count; ++w) {
						for (var h = 0; h < _height_count; ++h) {
							var _tile = tilemap_get(_layer_tilemap, w, h);
							draw_tile(_tileset, _tile, 0, _tile_width * w, _tile_height * h);
						}
					}
				}
			}
		}
		
		for (var i = 0; i < _objects_count; ++i) {
			
			var _object = __data.__objects[i];
			var _index = array_get_index(__data.__objects, _object);

		    with _object {
				
				var _xoff   = sprite_get_xoffset(sprite_index);
				var _yoff   = sprite_get_yoffset(sprite_index);
				
				if GMMM_object_draw_sprites {
					
					other.__draw_sprite_stretched_rot(sprite_index, 0, x + _xoff, y + _yoff, sprite_width, sprite_height, image_angle, c_white, 1);
				} else {
					
					var _colour = is_array(_colours) ? _colours[_index] : _colours;
					var _width  = sprite_get_width(sprite_index);
					var _height = sprite_get_height(sprite_index);
					
					sprite_set_offset(__data.__pixel_sprite, _xoff / _width * __data.__pixel_sprite_dim, _yoff / _height * __data.__pixel_sprite_dim);
					other.__draw_sprite_stretched_rot(__data.__pixel_sprite, 0, x, y, sprite_width, sprite_height, image_angle, _colour, 1);
				}
				
			}
		}
		if GMMM_3D_game {
			gpu_set_ztestenable(__ztest);
		}
		surface_reset_target();
	}
	
	/**
	* Draw generated map and player in a draw GUI event.
	* @param {real} _x			X position.
	* @param {real} _y			Y position.
	* @param {real} _width		Width.
	* @param {real} _height		Height.
	* @param {real} [_scale]	Scale.
	* @param {real} [_alpha]	Alpha.
	*/
	static draw = function(_x, _y, _width, _height, _scale = 1, _alpha = 1) {
		
		static __data = __MapData();
		static __matrix_primary = matrix_build_identity();
		static __matrix_secondary = matrix_build_identity();
		
		if is_undefined(__data.__objects) {
			exit;	
		}
		
		if !surface_exists(__data.__surface) {
			generate(__data.__player, __data.__player_colour, __data.__objects, __data.__colours);
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
		
		var _half_x = _x * 0.5;
		var _half_y = _y * 0.5;
		

		if GMMM_map_circular {
			
			if !surface_exists(__data.__surface_circle) {
				__data.__surface_circle = surface_create(_width, _height);
			}
			
			surface_set_target(__data.__surface_circle);
			draw_clear_alpha(c_black, 0);
				
			if surface_exists(__data.__surface) {
			
				if GMMM_background_enabled {
					if is_undefined(GMMM_background_sprite) {
						draw_sprite_stretched_ext(__data.__pixel_sprite, 0, 0, 0, _width, _height, GMMM_background_colour, _alpha);
					} else {
						draw_sprite_stretched_ext(GMMM_background_sprite, 0, 0, 0, _width, _height, c_white, _alpha);	
					}
				}
			
				if GMMM_map_rotate and !is_undefined(GMMM_map_rotate_angle_target) {
					
					var _scissor = gpu_get_scissor()
					var _resolution_width_scale = window_get_width() / display_get_gui_width();
					var _resolution_height_scale = window_get_height() / display_get_gui_height();
					gpu_set_scissor(0, 0, _width, _height);
					matrix_build(_half_width, _half_height, 0, 0, 0, GMMM_map_rotate_angle_target, 1, 1, 1, __matrix_secondary);
					matrix_set(matrix_world, __matrix_secondary);

					draw_surface_part_ext(__data.__surface,
										  _map_pos_x, 
										  _map_pos_y, 
										  _map_width, 
										  _map_height,
										  -_half_width, 
										  -_half_height, 
										  _scale, _scale, 
										  c_white, _alpha);
			
					matrix_set(matrix_world, __matrix_primary);
					gpu_set_scissor(_scissor);
				
				} else {
				
					draw_surface_part_ext(__data.__surface, _map_pos_x, _map_pos_y, _map_width, _map_height, 0, 0, _scale, _scale, c_white, _alpha);
				}
			}
			
			gpu_set_blendmode(bm_subtract);
			draw_sprite_stretched_ext(__data.__pixel_sprite, 0, 0, 0, _width, _height, c_black, _alpha);
			gpu_set_blendmode(bm_add);
			draw_circle_colour(_half_width, _half_height, _half_width, c_black, c_black, false);			
			gpu_set_blendmode(bm_normal);
			surface_reset_target();
			
			if surface_exists(__data.__surface_circle) {
				draw_surface(__data.__surface_circle, _x, _y);
			}
		} 
		
		if !GMMM_map_circular and surface_exists(__data.__surface) {
			
			if GMMM_background_enabled {
				if is_undefined(GMMM_background_sprite) {
					draw_sprite_stretched_ext(__data.__pixel_sprite, 0, _x, _y, _width, _height, GMMM_background_colour, _alpha);
				} else {
					draw_sprite_stretched_ext(GMMM_background_sprite, 0, _x, _y, _width, _height, c_white, _alpha);	
				}
			}
			
			if GMMM_map_rotate and !is_undefined(GMMM_map_rotate_angle_target) {
				
				var _scissor = gpu_get_scissor()
				var _resolution_width_scale = window_get_width() / display_get_gui_width();
				var _resolution_height_scale = window_get_height() / display_get_gui_height();
				gpu_set_scissor(_x * _resolution_width_scale, _y * _resolution_height_scale, _width * _resolution_width_scale, _height * _resolution_height_scale);
				matrix_build(_x + _half_width, _y + _half_height, 0, 0, 0, GMMM_map_rotate_angle_target, 1, 1, 1, __matrix_secondary);
				matrix_set(matrix_world, __matrix_secondary);

				draw_surface_part_ext(__data.__surface,
									  _map_pos_x, 
									  _map_pos_y, 
									  _map_width, 
									  _map_height,
									  -_half_width, 
									  -_half_height, 
									  _scale, _scale, 
									  c_white, _alpha);
			
				matrix_set(matrix_world, __matrix_primary);
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

		__draw_sprite_stretched_rot(__data.__pixel_sprite, 0, _player_x + _player_half_width, _player_y + _player_half_height, _player_width, _player_height, GMMM_map_rotate ? GMMM_map_rotate_angle_target : 0, __data.__player_colour, 1);
		
		if !is_undefined(GMMM_frame_set_sprite)  {
			draw_sprite_stretched_ext(GMMM_frame_set_sprite, 0, _x, _y, _width, _height, c_white, 1);
		}	

	}
	
	/**
	* Removes generated map from memory.
	*/
	static cleanup = function() {
		
		static __data = __MapData();
		
		if surface_exists(__data.__surface_circle) {
			surface_free(__data.__surface_circle);
		}
		
		if surface_exists(__data.__surface) {
			surface_free(__data.__surface);
		}
		
		__data.__objects = undefined;
		__data.__colours = undefined;
		__data.__map_room_width  = 0;
		__data.__map_room_height = 0;
		__data.__map_room_half_width  = 0;
		__data.__map_room_half_height = 0;
		__data.__surface_circle = undefined;
		__data.__surface = undefined;

		
	}
	
	
	/// @ignore
	static __draw_sprite_stretched_rot = function(sprite, subimg, _x, _y, w, h, rot, colour, alpha) {
	    draw_sprite_ext(sprite, subimg, _x, _y, w / sprite_get_width(sprite), h / sprite_get_height(sprite), rot, colour, alpha);
	}
	
	return static_get(GMMinimap);
	
}

GMMinimap();