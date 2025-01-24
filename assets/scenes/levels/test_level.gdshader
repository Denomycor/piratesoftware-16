shader_type canvas_item;

uniform sampler2D sand_texture;
uniform sampler2D ground_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 sand = texture(sand_texture, UV);
	vec4 ground = texture(ground_texture, UV);

	vec3 light_color = vec3(0.749, 0.588, 0.427);
	vec3 dark_color = vec3(0.976, 0.690, 0.400);

	float factor = mix(0.4, 0.6, ground.r);

	vec3 test = sand.rgb * factor;

	vec4 noise = vec4(test, 1.0);

	COLOR = noise;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
}
