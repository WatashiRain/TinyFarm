shader_type canvas_item;
render_mode unshaded;

uniform float sway_strength : hint_range(0.0, 5.0, 0.1) = 1.5;
uniform float sway_speed : hint_range(0.1, 4.0, 0.05) = 1.2;
uniform float phase_offset : hint_range(0.0, 6.283, 0.01) = 0.0;
uniform bool use_world_position_phase = false;

void vertex() {
	float top_weight = 1.0 - clamp(UV.y, 0.0, 1.0);
	top_weight *= top_weight;
	float spatial_phase = use_world_position_phase
		? dot(MODEL_MATRIX[3].xy, vec2(0.173, 0.117))
		: 0.0;
	float instance_phase = phase_offset + spatial_phase;
	float breeze = sin(TIME * sway_speed + instance_phase);
	float secondary_breeze = sin(TIME * sway_speed * 0.47 + instance_phase * 1.7) * 0.25;
	VERTEX.x += (breeze + secondary_breeze) * sway_strength * top_weight;
}
