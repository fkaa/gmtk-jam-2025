shader_type canvas_item;
uniform float current_angle;
uniform float start_angle;
void fragment()
{
	mat2 rot = mat2( vec2(cos(start_angle), -sin(start_angle)), 
				 vec2(sin(start_angle), cos(start_angle)) );
		
	vec2 pos = UV - vec2(0.5,0.5); //shift the space so that (0,0) is at the center of the sprite
	pos = rot * pos;
	float angle = atan(pos.y, pos.x) + PI;

	COLOR.a *= step(angle, current_angle);
}
