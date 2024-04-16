shader_type spatial;
render_mode cull_disabled;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;

uniform vec3 wind_direction = vec3(0,0,-1);
uniform float wind_scale = 4.0;
uniform float wind_speed = 1.0;

uniform sampler2D WindNoise;

varying vec3 worldPos;

vec2 random2(vec2 p) {
	return fract(sin(vec2(
		dot(p, vec2(127.32, 231.4)),
		dot(p, vec2(12.3, 146.3))
	)) * 231.23);
}

float worley2( vec2 p) {
	float dist = 1.0;
	vec2 i_p = floor(p);
	vec2 f_p = fract(p);
	for(int y=-1; y<1; y++) {
		for(int x=-1;x<1;x++) {
			vec2 n = vec2(float(x), float(y));
			vec2 diff = n + random2(i_p + n) - f_p;
			dist = min(dist, length(diff));
		}
	}
	return dist;
}

void vertex() {
	// Local space -> World space
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 vertex = VERTEX;
	vec3 wind_direction_normalized = normalize(wind_direction);
	//float wind = pow(worley2(worldPos.xy), 2.0);
	VERTEX.xz += (UV - vec2(0,1))*texture(WindNoise, UV * TIME * 0.25).r * 0.1;
	
}

void fragment() {
	vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb;
	// UV places such that y will be along the blades length
	// Noice randomises color to make the grass look more natural
	ALBEDO = mix(color, color2, UV.y) * mix(color, color2, noiseLevel.r);
	// Fix issue of normals from both faces facing the same way
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}
