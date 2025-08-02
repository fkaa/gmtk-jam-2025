extends Camera3D
class_name CameraShake
var shake_intensity
var is_shaking
@onready var shake_timer = $ShakeTimer

func _process(delta_time):
	if (is_shaking):
		var time = shake_timer.wait_time - shake_timer.time_left
		h_offset = shake_intensity * (randf() - 0.5) * sin(((PI/2)/shake_timer.wait_time)*time)
		v_offset = shake_intensity * (randf() - 0.5) * sin(((PI/2)/shake_timer.wait_time)*time)
		
		

func shake(intensity : float, duration : float):
	is_shaking = true
	shake_intensity = intensity
	shake_timer.wait_time = duration
	shake_timer.start()

func _on_shake_timer_timeout() -> void:
	is_shaking = false
	h_offset = 0
	v_offset = 0
