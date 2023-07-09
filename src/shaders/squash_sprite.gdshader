// https://www.youtube.com/watch?v=BZp8DwPdj4s
shader_type canvas_item;

uniform vec2 deformation = vec2(0.0, 0.0);
uniform float sideways_deformation_factor = 5.0;

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
