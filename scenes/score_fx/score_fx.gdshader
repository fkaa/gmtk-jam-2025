shader_type spatial;

uniform sampler2D particle_texture;
render_mode unshaded;

varying flat int particle_id;

void vertex() {
   mat4 modified_model_view = VIEW_MATRIX * mat4(
        INV_VIEW_MATRIX[0],
        INV_VIEW_MATRIX[1],
        INV_VIEW_MATRIX[2],
        MODEL_MATRIX[3]
    );
    MODELVIEW_MATRIX = modified_model_view;
    particle_id = INSTANCE_ID % 16;
}

void fragment() {
	int x = particle_id % 4;
	int y = particle_id / 4;
    vec2 newUv = UV * 0.25 + vec2(float(x), float(y)) * 0.25;
	
	vec4 color = texture(particle_texture, newUv);
	
	ALPHA = color.a * COLOR.a;
    ALBEDO = color.rgb * COLOR.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
