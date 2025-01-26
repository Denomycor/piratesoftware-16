shader_type canvas_item;

uniform sampler2D sand_texture;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform vec2 our_camera_position;
uniform vec2 our_camera_zoom;

uniform vec2 shadow_offset;

// Dusty Fog
uniform vec3 dustColor;
uniform sampler2D fog_noise;
uniform float dustIntensity;

const vec2 IMAGE_RESOLUTION = vec2(3840.0, 2160.0);

const vec4 TRANSPARENT_COLOR = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {


	vec4 screen_color = texture(SCREEN_TEXTURE, UV);
	
	vec4 final_color = vec4(0);

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
		final_color = sand;
		vec2 shadow_offset_scaled = shadow_offset * our_camera_zoom;
		vec4 screen_color_offset = texture(SCREEN_TEXTURE, UV + shadow_offset_scaled);
		if (screen_color_offset != TRANSPARENT_COLOR) {
			final_color -= vec4(0.2, 0.2, 0.2, 0.0);
		}
	} else {
		final_color = screen_color;
	}

	// Dusty Fog
	float fog_noise_value = texture(fog_noise, sand_uv).r;

	float fog_by_area_x = cos((our_camera_position.x + vec_from_center.x) / 10000.0);
	float fog_by_area_y = sin((our_camera_position.y + vec_from_center.y) / 10000.0);

	float fog_by_area = min(max(0.0, (fog_by_area_x * fog_by_area_y) + .1), .3);


	vec4 dustOverlay = vec4(dustColor, fog_by_area) * fog_noise_value * dustIntensity;

	COLOR = mix(final_color, dustOverlay, dustOverlay.a);

	// if (dustOverlay.a > 0.0) {
	// 	COLOR = vec4(1.0, 0.0, 0.0, dustOverlay.a);
	// }

	// COLOR += dustOverlay;
	// COLOR += vec4(sand_uv, 0.0, 1.0) * 0.1;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
}
