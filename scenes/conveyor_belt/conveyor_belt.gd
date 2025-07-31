extends Node3D

@onready var plates: Node3D = $Plates

@export var belt_speed: float = 0.5

func _process(delta: float) -> void:
	plates.rotation.y += belt_speed * delta
