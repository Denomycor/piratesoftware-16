shader_type canvas_item;

uniform vec4 color: source_color;

void fragment() {
	if(distance(UV, vec2(0.5)) > 0.5){
		COLOR.a = 0.0;
	}else{
		COLOR = color;
	}
}


