shader_type spatial;
render_mode cull_disabled;

uniform sampler2D tiles : filter_nearest, source_color;

varying vec2 uv;

void vertex() {
	uv = UV / 64.0;
	uv.y *= 4.0;
	uv.x += 0.5;
	uv.y += 0.125;
	//uv.x += 6.0 / 512.0;
}

void fragment() {
	ALBEDO.rgb = texture(tiles, uv).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
