shader_type canvas_item;

uniform vec4 flash_color : source_color;
uniform float flash_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	COLOR = mix(pixel_color, flash_color, flash_strength);
	COLOR.a *= pixel_color.a;
}
