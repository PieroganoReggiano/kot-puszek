shader_type spatial;

uniform sampler2D map : filter_nearest;
uniform sampler2D map_tile_choice : filter_nearest;
uniform sampler2D tiles : filter_nearest, source_color;

uniform vec2 map_size = vec2(512.0, 512.0);
uniform vec2 tile_map_size = vec2(512.0, 512.0);

uniform bool skip_tiles = false;

const vec2 tile_dimensions = vec2(16.0);

const uint pavement = 0x001u;
const uint street   = 0x002u;
const uint grass    = 0x003u;
const uint zebra    = 0x100u;


uint get_tile_type_from_colour(vec3 v) {
	if (skip_tiles)
		return 0u;
	if (all(greaterThan(v, vec3(0.38))) && all(lessThan(v, vec3(0.4)))) {
		return street;
	} else if (all(greaterThan(v, vec3(0.38))) && v.z > 0.99) {
		return street | zebra;
	} else if (all(greaterThan(v, vec3(0.78))) && all(lessThan(v, vec3(0.80)))) {
		return pavement;
	} else if (v.y > 0.43 && v.y < 0.44) {
		// fence
		return pavement;
	} else if (v.y > 0.99) {
		return grass;
	}
	return 0u;
}

uint get_tile_type(ivec2 coords) {
	vec3 colour = texture(map, vec2(coords) / map_size).xyz;
	return get_tile_type_from_colour(colour);
}

ivec2 auto_select_tile(ivec2 coord) {
	uint tile_type = get_tile_type(coord);
	uint tile_type_E = get_tile_type(coord + ivec2(1,0));
	uint tile_type_SE = get_tile_type(coord + ivec2(1,1));
	uint tile_type_S = get_tile_type(coord + ivec2(0,1));
	uint tile_type_SW = get_tile_type(coord + ivec2(-1,1));
	uint tile_type_W = get_tile_type(coord + ivec2(-1,0));
	uint tile_type_NW = get_tile_type(coord + ivec2(-1,-1));
	uint tile_type_N = get_tile_type(coord + ivec2(0,-1));
	uint tile_type_NE = get_tile_type(coord + ivec2(1,-1));
	if ((tile_type & 0xffu) == street) {
		if ((tile_type & 0xff00u) ==  zebra) {
			if ((tile_type_N & 0xff00u) == zebra) {
				return ivec2(1,6);
			}
			return ivec2(1,5);
		} else {
			return ivec2(1,4);
		}
	} else if (tile_type == pavement) {
		if ((tile_type_E & 0xffu) == street) {
			if ((tile_type_N & 0xffu) == street) {
				return ivec2(2,10);
			} else if ((tile_type_S & 0xffu) == street) {
				return ivec2(0,7);
			}
			return bool(coord.y & 1) ? ivec2(0,3) : ivec2(0,4);
		} else if ((tile_type_W & 0xffu) == street) {
			if ((tile_type_N & 0xffu) == street) {
				return ivec2(0,10);
			} else if ((tile_type_S & 0xffu) == street) {
				return ivec2(3,7);
			}
			return bool(coord.y & 1) ? ivec2(3,3) : ivec2(3,4);
		} else if ((tile_type_N & 0xffu) == street) {
			return ivec2(1,10);
		} else if ((tile_type_S & 0xffu) == street) {
			return ivec2(4,7);
		} else if ((tile_type_SE & 0xffu) == street) {
			return ivec2(3,10);
		} else if ((tile_type_SW & 0xffu) == street) {
			return ivec2(5,10);
		} else if ((tile_type_NW & 0xffu) == street) {
			return ivec2(4,2);
		} else if ((tile_type_NE & 0xffu) == street) {
			return ivec2(5,2);
		}
		bool cracked = coord.x % 15 == 3 && coord.y % 3 == 0;
		if (cracked) {
			return bool(coord.y & 1) ? ivec2(4,5) : ivec2(4,4);
		}
		return bool(coord.y & 1) ? ivec2(4,5) : ivec2(4,6);
	} else if (tile_type == grass) {
		return ivec2(5,1);
	}
	return ivec2(20,0);
}

void vertex() {
}

void fragment() {
	bool tile_chosen = false;
	ALBEDO = texture(map, UV).xyz;
	
	
	
	vec4 tile_choice_colour = texture(map_tile_choice, UV);
	tile_chosen = (tile_choice_colour[3] > 0.0);
	
	ivec2 tiles_count = ivec2(tile_map_size / tile_dimensions);
	
	if (!tile_chosen) {
		ivec2 tile_coords = auto_select_tile(ivec2(UV * map_size));
		tile_choice_colour = vec4(vec2(tile_coords) / 32.0, 0.0, 1.0);
		tile_chosen = true;
	}
	
	
	if (tile_chosen) {
		vec4 tile_colour = vec4(0.0);
		
		ivec2 integer_offset = ivec2(tile_choice_colour.xy * 32.0);
		vec2 offset = vec2(integer_offset) / vec2(tiles_count) * 1.0;
		
		
		vec2 uv = UV * map_size;
		uv = fract(uv);
		uv /= vec2(tiles_count);
		uv += vec2(offset);
		
		tile_colour = texture(tiles, uv);
		
		if (tile_colour[3] > 0.0)
			ALBEDO.rgb = tile_colour.rgb;
	}
	
	
}
