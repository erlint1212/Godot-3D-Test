shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

// REMEBER, BLACK WILL BLOCK THE IMAGE
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : 
	source_color,
	filter_linear_mipmap,
	repeat_enable;

uniform sampler2D noise;

uniform vec2 tiling = vec2(1.0, 1.0);
uniform vec2 offset;

uniform vec2 uv_tiling_offset_speed;
uniform float scale : hint_range(0.01, 10) = 0.35;

vec2 polar_coordinates(vec2 base_uv, vec2 center, float zoom, float repeat)
{
	//base_uv -= 0.5;
	//base_uv *= 2.0;
	float angle = atan(base_uv.y, base_uv.x) / (2.0 * PI);
	float dist = length(vec2(
		base_uv.x,
		base_uv.y
	));
	
	vec2 polar_uv = vec2(
		angle,
		dist
	);
	return polar_uv;
}

void vertex() {
	vec2 polar_uv = polar_coordinates(UV.xy, vec2(0.5), 0.3, 1.0);
	UV = polar_uv * tiling + offset * TIME;
	
	// Called for every vertex the material is visible on.
}

void fragment(){
	vec2 base_uv = UV;
	//base_uv -= 0.5;
	//base_uv *= 2.0;
	base_uv *= (1.0/scale);
	
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
}
