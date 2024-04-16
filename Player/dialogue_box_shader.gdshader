shader_type canvas_item;
render_mode unshaded;

uniform float Amplitude : hint_range(0.0, 0.15) = 0.15;
uniform float Period = 1.0;
uniform float PhaseShift = 1.0;
uniform float UpperLimit = 1.0;
uniform float Current = 1.0;

uniform sampler2D image : 
	repeat_enable,
	filter_linear_mipmap;

uniform float tint_factor : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float fade : hint_range(0.0, 1.0, 0.1) = 1.0;

uniform vec4 mix_color : source_color;

uniform vec2 tiling = vec2(1.0, 1.0);
uniform vec2 offset;

void vertex() {
	UV = UV * tiling + offset * TIME;
	//UV = UV;
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Add distortion
	vec2 base_uv = UV;
	
	base_uv.x -= (((1.0 - base_uv.y) * Amplitude) * 
		sin(Period * (base_uv.y - (TIME * 0.016 * PhaseShift)))) * 
		clamp(1.0 - (base_uv.y * (10.0 - UpperLimit)), 0.0, 0.5) *
		Current;
	
	//Add image and tint
	vec4 main_texture = texture(image, base_uv);
	vec4 final_output = main_texture;
	
	float original_modulation = 1.0 - tint_factor;
	
	final_output.rgb = mix(main_texture.rgb * original_modulation, mix_color.rgb * tint_factor, tint_factor);
	final_output.a *= fade;
	
	//vec4 final_output_2 = texture(final_output, base_uv)
	
	COLOR = final_output.rgba;
	//COLOR = main_texture;
}