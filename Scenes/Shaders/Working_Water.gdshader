// Source: https://www.youtube.com/watch?v=7L6ZUYj1hs8
shader_type spatial;
//render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
render_mode depth_draw_always, cull_disabled;

uniform vec4 out_color : source_color = vec4(0.118, 0.604, 0.933, 1.0);
// Fresnel effect
uniform vec4 albedo2 : source_color = vec4(0.118, 0.604, 0.933, 1.0);
uniform float metallic : hint_range(0.0, 1.0) = 0.6;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;
uniform float specular : hint_range(0.0,1.0) = 0.8;

// Wave height
uniform float wave_time = 0;
uniform sampler2D wave;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;

// Varying variables
varying float height;
varying vec3 world_pos;

uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;

uniform vec2 wave_direction = vec2(2.0, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;
uniform float wave_speed : hint_range(0.0, 0.2, 0.005) = 0.05;
// How unruly the seas are
// uniform float amount : hint_range(0.2, 1.5) = 0.8;
// uniform float beer_factor = 0.2;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 color_deep : source_color;
uniform vec4 color_shallow : source_color;
// Beers Law https://en.wikipedia.org/wiki/Beer%E2%80%93Lambert_law
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;

uniform float edge_scale = 0.1;
uniform float near = 1.0;
uniform float far = 100.0;
uniform vec3 edge_color : source_color = vec3(255.0,255.0,255.0);

float fresnel(float amount_fresnel, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount_fresnel);
} 

float edge(float depth){
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_pos.xz / noise_scale + wave_time * wave_speed).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	// Depth variable and calc
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
	float depth_blend = exp((depth+VERTEX.z + depth_offset) * -beers_law);
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);
	float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);
	
	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;
	vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend_power);
	vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);
	
	// Setting edge depth calc
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;
	
	// Time calculated for wave (normal map) movement
	vec2 time = (TIME * wave_direction) * time_scale; // Movement rate of first wave
	vec2 time2 = (TIME * wave_direction2) * time_scale; // Movement rate of second wave
	// Blend normal maps into one
	//vec3 normal_blend = mix(texture(texture_normal, UV + time).rgb, texture(texture_normal2, UV + time2).rgb, 0.5);
	vec3 normal_blend = mix(texture(texture_normal, world_pos.xz / noise_scale + time).rgb, texture(texture_normal2, world_pos.xz / noise_scale + time2).rgb, 0.5);
	//vec3 normal = texture(texture_normal, UV).rgb;
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(out_color.xyz, albedo2.xyz, fresnel); // Interpolate albedo values by fresnel
	
	NORMAL_MAP = normal_blend;
	//NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	//ALBEDO = mix(surface_color.xyz, color, 0.75);
	
	vec3 depth_color_adj = mix(edge_color, color, step(edge_scale, z_dif));
	
	ALBEDO = clamp(surface_color + depth_color_adj, vec3(0.0), vec3(1.0));
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
