shader_type spatial;

uniform sampler2D belt_texture;
uniform float belt_speed;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 col = texture(belt_texture, UV + vec2(0.0, TIME * belt_speed * 2.0));
	
	ALBEDO = col.rgb;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
