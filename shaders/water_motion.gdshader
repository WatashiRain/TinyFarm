shader_type canvas_item;
render_mode unshaded;

uniform vec4 deep_color : source_color = vec4(0.12, 0.49, 0.56, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.25, 0.70, 0.67, 1.0);
uniform vec4 highlight_color : source_color = vec4(0.80, 0.96, 0.82, 1.0);
uniform float motion_speed : hint_range(0.1, 2.0, 0.05) = 0.55;
uniform float sparkle_amount : hint_range(0.0, 1.0, 0.05) = 0.35;

void fragment() {
	float time = TIME * motion_speed;
	float broad_wave = sin(UV.x * 20.0 + time + sin(UV.y * 12.0)) * 0.5 + 0.5;
	float fine_wave = sin(UV.y * 34.0 - time * 0.7 + UV.x * 9.0) * 0.5 + 0.5;
	float mix_amount = 0.12 + broad_wave * 0.14 + fine_wave * 0.05;
	vec3 water = mix(deep_color.rgb, shallow_color.rgb, mix_amount);

	float sparkle_field = sin(UV.x * 79.0 + time * 1.4) * sin(UV.y * 67.0 - time);
	float sparkle_gate = max(0.0, sin(time * 0.72 + UV.x * 8.0 + UV.y * 5.0));
	float sparkle = smoothstep(0.965, 1.0, sparkle_field * sparkle_gate) * sparkle_amount;
	water = mix(water, highlight_color.rgb, sparkle);

	COLOR = vec4(water, 1.0);
}
