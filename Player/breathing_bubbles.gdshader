shader_type spatial;

uniform sampler2D noise_texture;
uniform sampler2D color;
uniform float smoothness : hint_range(0.0, 1.0, 0.05) = 0.1;

varying vec3 world_pos;
varying float height;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(noise_texture, VERTEX.xz * smoothness + vec2(TIME * 0.1)).r;
	VERTEX += NORMAL * height;
}

void fragment() {
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	ALPHA = fresnel;
	ROUGHNESS = 0.0f;
	ALBEDO = texture(color, world_pos.xz + vec2(TIME * 0.1)).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
