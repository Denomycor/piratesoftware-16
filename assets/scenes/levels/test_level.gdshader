shader_type canvas_item;

uniform sampler2D noise_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 noise = texture(noise_texture, UV);

	vec3 light_color = vec3(0.749, 0.588, 0.427);
	vec3 dark_color = vec3(0.976, 0.690, 0.400);
	

	COLOR = noise;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
}
