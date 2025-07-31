extends Node3D

func _process(delta: float) -> void:
	var time_in_sec: float = Time.get_ticks_msec() / 1000.0
	scale.x = 1.0+((1.0+cos(position.y*200.0 + time_in_sec*5.0)/2.0) * 0.5)
	scale.y = 1.0+((1.0+sin(position.y*200.0 + time_in_sec*5.0)/2.0) * 0.5)
