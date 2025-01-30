shader_type canvas_item;

// --- Uniforms --- //
uniform vec2 speed = vec2(0.0, 0.0);

// --- Functions --- //
void fragment() {
	COLOR = texture(TEXTURE, mod(UV + TIME * -speed, 1.0));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
