shader_type canvas_item;
uniform float current_angle;
uniform float start_angle;
uniform bool flip;
void fragment()
{
	mat2 rot = mat2( vec2(cos(start_angle), -sin(start_angle)), 
				 vec2(sin(start_angle), cos(start_angle)) );
		
	vec2 pos = UV - vec2(0.5,0.5); //shift the space so that (0,0) is at the center of the sprite
	if (flip) {
		pos.x = -pos.x;
	}
	pos = rot * pos;
	float angle = atan(pos.y, pos.x) + PI; //Need to add PI here? I think i did something wrong in the rotation matrix...

	COLOR.a *= step(current_angle, angle);
}
