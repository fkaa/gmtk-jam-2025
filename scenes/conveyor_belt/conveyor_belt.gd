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

var receiving_plate_idx = 5;


func _ready() -> void:
	for p in plates.get_children():
		_all_plates.append(p as PlateOnBelt)

func _process(delta: float) -> void:
	var y_rotation_last = plates.rotation.y
	plates.rotation.y += belt_speed * delta
	# If we've rotated 1/6 rotation, update receiving plate and spawn a filth
	var rotation_increment_offset=(PI/3)/2
	if floor((y_rotation_last+rotation_increment_offset) / (PI/3)) < floor((plates.rotation.y+rotation_increment_offset) / (PI/3)):
		receiving_plate_idx -= 1
		receiving_plate_idx %= _all_plates.size()
		_spawn_random_thing()
	
func _spawn_random_thing():
	var receiving_plate = _all_plates[receiving_plate_idx]
	var random_thing = DIRTY_STUFF.pick_random().instantiate()
	receiving_plate.add_item(random_thing)
