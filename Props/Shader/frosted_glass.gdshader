shader_type spatial;
render_mode cull_disabled;
// source: https://godotshaders.com/shader/frosted-glass/

uniform float distortion_size = 0.4;
uniform float alpha : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
//uniform sampler2D albedo;
uniform sampler2D glass;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D texture_ambient_occlusion : hint_default_white, filter_linear_mipmap,repeat_enable;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform vec4 ao_texture_channel;
uniform float ao_light_affect;
uniform float normal_scale : hint_range(-16,16);
varying vec2 mod_uv;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void vertex() {
	//UV=UV*uv1_scale.xy+uv1_offset.xy;
}

void fragment() {
	vec2 d = texture(glass, UV).xy - vec2(0.5);
	mod_uv = (SCREEN_UV + d * distortion_size);
	
	//vec3 albedo_sup_text = mix(texture(SCREEN_TEXTURE, SCREEN_UV + d * distortion_size).rgb, texture(texture_albedo, SCREEN_UV + d * distortion_size).rgb, 0.5);
	//ALBEDO = albedo_sup_text;
	
	ALBEDO = texture(SCREEN_TEXTURE, mod_uv).rgb;
	ALPHA *= alpha;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,mod_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex;
	
	//NORMAL_MAP = texture(glass,mod_uv).rgb;
	//NORMAL_MAP_DEPTH = normal_scale;
	
	//AO = dot(texture(texture_ambient_occlusion,mod_uv),ao_texture_channel);
	//AO_LIGHT_AFFECT = ao_light_affect;
}