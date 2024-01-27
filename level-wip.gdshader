shader_type spatial;

uniform sampler2D map : filter_nearest;
uniform sampler2D tiles : filter_nearest;

uniform vec2 map_size = vec2(512.0, 512.0);
uniform vec2 tile_map_size = vec2(128.0, 128.0);

uniform bool skip_tiles = false;


void vertex() {
}

void fragment() {
	if (skip_tiles) {
		ALBEDO.rgb = texture(map, UV).xyz;
	} else {
		vec2 uv = UV / map_size / tile_map_size;
		vec2 offset = texture(map, uv).xy;
		uv += offset;
		ALBEDO.rgb = texture(tiles, uv).xyz;
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
