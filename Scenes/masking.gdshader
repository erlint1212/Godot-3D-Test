shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

// REMEBER, BLACK WILL BLOCK THE IMAGE
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : 
	source_color,
	filter_linear_mipmap,
	repeat_disable;

uniform sampler2D mask;

uniform vec2 tiling = vec2(1.0, 1.0);
uniform vec2 offset;
uniform float scale : hint_range(0.01, 10) = 0.35;

void vertex() {
	//UV = UV;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 base_uv = UV*(1.0/scale);
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
	ALPHA *= texture(mask, UV*(1.0/scale)).r;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
