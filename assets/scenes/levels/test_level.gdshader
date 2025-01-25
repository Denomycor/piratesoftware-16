shader_type canvas_item;

uniform sampler2D sand_texture;
uniform sampler2D normal_map_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 sand = texture(sand_texture, UV);
	vec4 normal_map = texture(normal_map_texture, UV);

	vec3 normal = normalize(normal_map.rgb * 2.0 - 1.0);
	vec3 light_dir = normalize(vec3(0.0, 0.8, 1.0));

	float factor = max(dot(normal, light_dir), 0.0);

	vec3 adjusted_sand = sand.rgb * factor;

	vec4 final_color = vec4(adjusted_sand, 1.0);

	COLOR = final_color;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
}
