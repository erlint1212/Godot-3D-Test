shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

// REMEBER, BLACK WILL BLOCK THE IMAGE
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : 
	source_color,
	filter_linear_mipmap,
	repeat_enable;

uniform sampler2D noise;

uniform vec2 uv_tiling_offset_speed;
uniform float scale : hint_range(0.01, 10) = 0.35;

void vertex() {
	UV = UV;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 tiling = uv_tiling_offset_speed.xy;
	vec2 offset_speed = uv_tiling_offset_speed.zw;
	
	vec2 base_uv = UV;
	base_uv -= 0.5;
	base_uv *= 2.0;
	
	float angle = atan(base_uv.y, base_uv.x) / (2.0 * PI);
	float dist = length(vec2(
		base_uv.x,
		base_uv.y
	));
	
	vec2 polar_uv = vec2(
		angle,
		dist
	);
	
	vec2 offset = offset_speed * TIME;
	
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
