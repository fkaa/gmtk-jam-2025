extends Node3D

const DIRTY_CUTLERY = preload("res://scenes/conveyor_belt/plate_items/dirty_cutlery.tscn")
const DIRTY_PLATE = preload("res://scenes/conveyor_belt/plate_items/dirty_plate.tscn")
const DIRTY_BOWL = preload("res://scenes/conveyor_belt/plate_items/dirty_bowl.tscn")
const DIRTY_CUP = preload("res://scenes/conveyor_belt/plate_items/dirty_cup.tscn")

const DIRTY_STUFF = [
	DIRTY_CUTLERY,
	DIRTY_PLATE,
	DIRTY_BOWL,
	DIRTY_CUP
]

@onready var plates: Node3D = $Plates

@export var belt_speed: float = 0.5

var _all_plates: Array[PlateOnBelt]

var receiving_plate_idx = 4;


func _ready() -> void:
	for p in plates.get_children():
		_all_plates.append(p as PlateOnBelt)

func _process(delta: float) -> void:
	var y_rotation_last = plates.rotation.y
	plates.rotation.y += belt_speed * delta
	# If we've rotated 1/6 rotation, update the receiving plate, take any clean dishes, then spawn dirty dishes
	const rotation_spawn_interval=PI/3
	const rotation_increment_offset_spawn=(PI/3)/2
	const rotation_increment_offset_remove=0
	# Check if its time to take any clean dishes
	if floor((y_rotation_last+rotation_increment_offset_remove) / rotation_spawn_interval) < floor((plates.rotation.y+rotation_increment_offset_remove) / rotation_spawn_interval):
		# This will happen before dirty dish spawns, update the receive index now and hold it for dirty spawn
		receiving_plate_idx -= 1
		receiving_plate_idx %= _all_plates.size()
		_all_plates[receiving_plate_idx].remove_clean_top_down()
	# Check if its time to spawn a dirty dish
	if floor((y_rotation_last+rotation_increment_offset_spawn) / rotation_spawn_interval ) < floor((plates.rotation.y+rotation_increment_offset_spawn) / rotation_spawn_interval):
		_spawn_random_thing()
	
func _spawn_random_thing():
	var receiving_plate = _all_plates[receiving_plate_idx]
	var random_thing = DIRTY_STUFF.pick_random().instantiate()
	receiving_plate.add_item(random_thing, true) # Spawn item from above
