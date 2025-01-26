shader_type canvas_item;

uniform sampler2D sand_texture;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform vec2 our_camera_position;
uniform vec2 our_camera_zoom;


const vec2 IMAGE_RESOLUTION = vec2(3840.0, 2160.0);

const vec4 TRANSPARENT_COLOR = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, UV);
	
	// CONSTANTS
	vec2 our_resolution = vec2(1920.0, 1080.0);
	vec2 our_viewport_resolution = vec2(1920.0, 1080.0) / our_camera_zoom;

	// vector from center of screen at viewport resolution
	vec2 vec_from_center = (UV - 0.5) * our_viewport_resolution;

	// where the center of the screen is in the image
	vec2 center_pixel_of_screen = mod(our_camera_position, IMAGE_RESOLUTION);

	// where the current pixel is in the image
	vec2 current_pixel = (center_pixel_of_screen + vec_from_center) / IMAGE_RESOLUTION;

	// mod to get uv for sand texture
	vec2 sand_uv = mod(current_pixel, 1.0);

	// sand texture
	vec4 sand = texture(sand_texture, sand_uv);
	if (screen_color == TRANSPARENT_COLOR) {
		COLOR = sand;
	} else {
		COLOR = screen_color;
	}

	// COLOR += vec4(sand_uv, 0.0, 1.0) * 0.1;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
}
