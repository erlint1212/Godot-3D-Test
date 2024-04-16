shader_type spatial;

uniform vec4 out_color : source_color = vec4(0.118, 0.604, 0.933, 1.0);
// How unruly the seas are
uniform float amount : hint_range(0.2, 1.5) = 0.8;
uniform float beer_factor = 0.2;
uniform sampler2D depth_texture : source_color, hint_depth_texture;

float generatedOffset(float x, float z, float val1, float val2, float time){
	//float amount = 0.8;
	float speed = 1.0;
	
	float radiansX = ((mod(x + z * x * val1, amount)/ amount) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * PI;
	float radiansZ = ((mod(val2*(x*z + z*x), amount)/ amount) + (time * speed)* 2.0 * mod(x, 2.0)) * 2.0 * PI;
	
	return amount * 0.5 * (sin(radiansZ) * cos(radiansX));
}

vec3 applyDistortion(vec3 vertex, float time){
	float xd = generatedOffset(vertex.x, vertex.z, 0.2, 0.1, time);
	float yd = generatedOffset(vertex.x, vertex.z, 0.1, 0.3, time);
	float zd = generatedOffset(vertex.x, vertex.z, 0.15, 0.2, time);
	return vertex + vec3(xd, yd, zd);
}

void vertex() {
	VERTEX = applyDistortion(VERTEX, TIME * 0.1);
	// Called for every vertex the material is visible on.
	
}

void fragment() {
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	METALLIC = 0.6;
	SPECULAR = 0.5;
	ROUGHNESS = 0.2;
	ALBEDO = out_color.xyz;
	
	float depth = texture(depth_texture, SCREEN_UV).r;
	
	depth = depth * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	depth = depth + VERTEX.z;
	
	depth = exp(-depth * beer_factor);
	ALPHA = clamp(1.0 - depth, 0.0, 1.0);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
