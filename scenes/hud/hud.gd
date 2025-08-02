class_name Hud
extends TextureRect

var shader: ShaderMaterial

func _ready() -> void:
	shader = material as ShaderMaterial
	shader.set_shader_parameter("start_angle", PI/2)

func _process(delta: float) -> void:
	pass
	
func update_timer_display(wash_timer: Timer) -> void:
	var progress = (wash_timer.wait_time - wash_timer.time_left) / wash_timer.wait_time
	shader.set_shader_parameter("current_angle", 2*PI*(progress))
	
	
