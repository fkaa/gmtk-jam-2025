extends Node3D

const DIRTY_CUTLERY = preload("res://scenes/conveyor_belt/plate_items/dirty_cutlery.tscn")
const DIRTY_PLATE = preload("res://scenes/conveyor_belt/plate_items/dirty_plate.tscn")
const DIRTY_BOWL = preload("res://scenes/conveyor_belt/plate_items/dirty_bowl.tscn")
const DIRTY_CUP = preload("res://scenes/conveyor_belt/plate_items/dirty_cup.tscn")
const DISH = preload("res://scenes/conveyor_belt/plate_items/dish.tscn")
const DIRTY_STUFF = [
	DIRTY_CUTLERY,
	DIRTY_PLATE,
	DIRTY_BOWL,
	DIRTY_CUP
]

@onready var belt_sfx: AudioStreamPlayer2D = $BeltSFX

signal broken

@onready var fires: Node3D = $Plates/Fires
@onready var fires2: Node3D = $BeltMesh/Fires


@onready var plates: Node3D = $Plates
@onready var belt: MeshInstance3D = $conveyor_belt/Belt
@onready var speed_label: Label3D = %SpeedLabel
@onready var score_label: Label3D = %ScoreLabel

@export var belt_speed: float = 0.5:
	set(val):
		speed_label.text = "%.2fx" % (val * 2.0)
		belt_speed = val
		

var score: int = 0:
	set(val):
		score = val
		var t = get_tree().create_tween()
		t.tween_property(score_label, "scale", Vector3(2.0, 2.0, 2.0), 0.5).set_trans(Tween.TRANS_ELASTIC)
		t.tween_callback(func():
			score_label.text = "%s" % val)
		t.tween_property(score_label, "scale", Vector3(1.0, 1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC)

var _all_plates: Array[PlateOnBelt]

var receiving_plate_idx = 4;
var belt_mat: ShaderMaterial
var exploded = false

func explode():
	if not exploded:
		broken.emit()
		fires.visible = true
		fires2.visible = true
		exploded = true
		var a = get_tree().create_tween()
		a.tween_property(self, "belt_speed", 0, 1.0).set_trans(Tween.TRANS_ELASTIC)

func _ready() -> void:
	belt_mat = belt.get_active_material(0) as ShaderMaterial
	for p in plates.get_children():
		if p is PlateOnBelt:
			_all_plates.append(p as PlateOnBelt)

func _process(delta: float) -> void:
	var y_rotation_last = plates.rotation.y
	plates.rotation.y += belt_speed * delta
	belt_mat.set_shader_parameter("belt_speed", belt_speed)
	# If we've rotated 1/6 rotation, update the receiving plate, take any clean dishes, then spawn dirty dishes
	const rotation_spawn_interval=PI/3
	const rotation_increment_offset_spawn=(PI/3)/2
	const rotation_increment_offset_remove=0
	# Check if its time to take any clean dishes
	if floor((y_rotation_last+rotation_increment_offset_remove) / rotation_spawn_interval) < floor((plates.rotation.y+rotation_increment_offset_remove) / rotation_spawn_interval):
		# This will happen before dirty dish spawns, update the receive index now and hold it for dirty spawn
		receiving_plate_idx -= 1
		if receiving_plate_idx < 0:
			receiving_plate_idx = len(_all_plates) - 1
		receiving_plate_idx %= _all_plates.size()
		#_all_plates[receiving_plate_idx].remove_clean_top_down()
	# Check if its time to spawn a dirty dish
	if floor((y_rotation_last+rotation_increment_offset_spawn) / rotation_spawn_interval ) < floor((plates.rotation.y+rotation_increment_offset_spawn) / rotation_spawn_interval):
		_spawn_random_thing()
		var idx = receiving_plate_idx - 1
		if idx < 0:
			idx = len(_all_plates) - 1
		if len(_all_plates[idx].items) >= 8:
			explode()

var dishes_spawned = 0

func _spawn_random_thing():
	var receiving_plate = _all_plates[receiving_plate_idx]
	var random_thing = DISH.instantiate()
	random_thing.dish_type = [Dish.DISH_TYPES.PLATE, Dish.DISH_TYPES.CUTLERY, Dish.DISH_TYPES.BOWL, Dish.DISH_TYPES.CUP].pick_random()
	random_thing.index = dishes_spawned
	dishes_spawned += 1
	receiving_plate.add_item(random_thing, true) # Spawn item from above
