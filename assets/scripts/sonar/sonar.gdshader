shader_type canvas_item;

uniform bool enabled;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform vec4 background_color: source_color;
uniform vec4 obstacle_color: source_color;

const vec3 white = vec3(1.0,1.0,1.0);
const vec3 black = vec3(0.0,0.0,0.0);
const vec3 green = vec3(0.0,1.0,0.0);

bool draw_ring(vec2 uv, float start, float end){
	float distance_to_center = distance(uv, vec2(0.5));
	return distance_to_center > start  && distance_to_center < end;
}


void fragment() {
	if(enabled){
		vec4 screen_color = texture(TEXTURE, UV);
		if(screen_color.a != 0.0){
			COLOR = obstacle_color;
		}else{
			COLOR = background_color;
		}

		if(distance(UV, vec2(0.5)) > 0.5){
			COLOR.a = 0.0;
		}
	}
}
