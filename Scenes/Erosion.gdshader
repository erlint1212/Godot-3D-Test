shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

// REMEBER, BLACK WILL BLOCK THE IMAGE
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : 
	source_color,
	filter_linear_mipmap,
	repeat_enable;

uniform sampler2D noise;

uniform vec2 distortion_tiling = vec2(1.0, 1.0);
uniform float erosion_max_offset = 1.0;
uniform float scale : hint_range(0.01, 10) = 0.35;
uniform float distortion_intensity = 0.1;

void vertex() {
	UV = UV;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
	
	vec4 erosion_tex = texture(noise, base_uv);
	
	float erosion_min = (sin(TIME * 2.0) + 1.0) * 0.5;
	float erosion_max = erosion_min + erosion_max_offset;
	float erosion_val = smoothstep(erosion_min, erosion_max, erosion_tex.r);
	
	ALPHA *= erosion_val;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
