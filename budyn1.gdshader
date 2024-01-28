shader_type spatial;

uniform sampler2D tiles : filter_nearest;

uniform ivec2 tile_choice = ivec2(0);

uniform ivec2 tile2 = ivec2(0);
uniform float tile2_amount = 0.0;

varying vec3 uv3d;
varying vec3 uv2d;
uniform vec2 tile_map_size = vec2(512.0, 512.0);
const vec2 tile_dimensions = vec2(16.0);

void vertex() {
	uv3d = VERTEX;
	uv2d = uv3d;
	uv2d = mix(uv2d, vec3(uv3d.x, -uv3d.z, -uv3d.y), dot(NORMAL, vec3(0,1,0)));
	uv2d = mix(uv2d, vec3(uv3d.z, uv3d.y, uv3d.x), dot(NORMAL, vec3(-1,0,0)));
}

void fragment() {
	
	ivec2 serious_tile_shoice = tile_choice;
	
	if (fract(floor(uv2d.x + 1.0) / 4.0) < tile2_amount && fract(floor(uv2d.y - 1.0) / 4.0) < tile2_amount)
		serious_tile_shoice = tile2;
	
	ivec2 tiles_count = ivec2(tile_map_size / tile_dimensions);
	vec2 uv = uv2d.xy;
	uv = fract(uv);
	uv += vec2(serious_tile_shoice);
	uv /= vec2(ivec2(tiles_count.x, tiles_count.y));
	ALBEDO.rgb = texture(tiles, uv.xy).xyz;
	ALBEDO.rgb *= 0.8;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
