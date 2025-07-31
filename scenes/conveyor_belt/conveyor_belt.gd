extends Node3D

const DIRTY_CUTLERY = preload("res://scenes/conveyor_belt/plate_items/dirty_cutlery.tscn")
const DIRTY_PLATE = preload("res://scenes/conveyor_belt/plate_items/dirty_plate.tscn")

const DIRTY_STUFF = [
	DIRTY_CUTLERY,
	DIRTY_PLATE
]

@onready var plates: Node3D = $Plates

@export var belt_speed: float = 0.5

var _all_plates: Array[PlateOnBelt]


func _ready() -> void:
	for p in plates.get_children():
		_all_plates.append(p as PlateOnBelt)

func _process(delta: float) -> void:
	plates.rotation.y += belt_speed * delta

func _spawn_random_thing():
	var random_plate = _all_plates.pick_random()
	var random_thing = DIRTY_STUFF.pick_random().instantiate()
	
	random_plate.add_item(random_thing)


func _on_spawn_timer_timeout() -> void:
	_spawn_random_thing()
