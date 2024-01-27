shader_type spatial;

uniform sampler2D map : filter_nearest;
uniform sampler2D map_tile_choice : filter_nearest;
uniform sampler2D tiles : filter_nearest;

uniform vec2 map_size = vec2(512.0, 512.0);
uniform vec2 tile_map_size = vec2(512.0, 512.0);

uniform bool skip_tiles = false;

const vec2 tile_dimensions = vec2(16.0);

void vertex() {
}

void fragment() {
	bool tile_chosen = false;
	ALBEDO = texture(map, UV).xyz;
	
	vec4 tile_choice_colour = texture(map_tile_choice, UV);
	tile_chosen = (tile_choice_colour[3] > 0.0);
	
	ivec2 tiles_count = ivec2(tile_map_size / tile_dimensions);
	
	if (tile_chosen) {
		vec4 tile_colour = vec4(0.0);
		
		ivec2 integer_offset = ivec2(tile_choice_colour.xy * 32.0);
		vec2 offset = vec2(integer_offset) / vec2(tiles_count) * 1.0;
		
		
		vec2 uv = UV * map_size;
		uv = fract(uv);
		uv /= vec2(tiles_count);
		uv += vec2(offset);
		
		tile_colour = texture(tiles, uv);
		
		ALBEDO.rgb = tile_colour.rgb;
	}
}
