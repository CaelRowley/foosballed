shader_type canvas_item;

uniform vec2 deformation = vec2(0.0, 0.0);
uniform float sideways_deformation_factor = 5.0;

uniform vec4 flash_color : source_color;
uniform float flash_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	COLOR = mix(pixel_color, flash_color, flash_strength);
	COLOR.a *= pixel_color.a;
}

void vertex() {
	vec2 deformation_strength = abs(deformation);
	float sideways_deformation = min(deformation_strength.x, deformation_strength.y);
	float sprite_width = abs(VERTEX.x);
	if(sign(VERTEX.y) != sign(deformation.y)) {
		VERTEX.x += sideways_deformation * sideways_deformation_factor * sprite_width * sign(deformation.x);
	}
	vec2 scale = 1.0 - deformation_strength;
	
	vec2 vertex_old = VERTEX;
	VERTEX.x = vertex_old.x * scale.x / scale.y;
	VERTEX.y = vertex_old.y * scale.y / scale.x;
}
