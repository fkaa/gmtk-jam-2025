shader_type spatial;

render_mode blend_add, unshaded;

uniform vec4 color : source_color;

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a * (0.5-UV.y);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
