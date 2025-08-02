extends Area3D
class_name WashingMachine

const BASE_WASH_TIME    = 3
const COMBO_TIME_SCALAR = 0.75

var is_cleaning        : bool
var active_combo_count : int
var current_wash_time  : float

@export var shake_camera       : CameraShake

signal score(gained: int)

@onready var cleaning_timer = $CleaningTimer
@onready var item_holder: Node3D = %ItemHolder
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var wash_particles: CPUParticles3D = %WashParticles
@onready var bubble_p_layer: AudioStreamPlayer2D = $BubblePlayer

const SCORE_FX = preload("res://scenes/score_fx/score_fx.tscn")

var items: Array[Node3D] = []

func _process(delta_time) -> void:
	pass

func _ready()-> void:
	pass

# TODO: pairs
# TODO: triplet
# TODO: quad
# TODO: combine above, eg. 2 pairs 1 triplet

func get_points(items: Array[Node3D]) -> Node3D:
	var ones = 0
	var doubles = 0
	var triples = 0
	var quads = 0
	
	var last_type = -1
	var current_same = 0
	
	for i in items:
		if i is Dish:
			if last_type == i.dish_type:
				current_same += 1
			else:
				match current_same:
					0: pass
					1: ones += 1
					2: doubles += 1
					3: triples += 1
					4: quads += 1
					_: quads += 1
				current_same = 1
			last_type = i.dish_type
	
	match current_same:
		0: pass
		1: ones += 1
		2: doubles += 1
		3: triples += 1
		4: quads += 1
		_: quads += 1
	
	var points = ones + (doubles * 2 * 2) + (triples * 3 * 3) + (quads * 4 * 4)
	
	var description = ""
	
	if quads > 0:
		description += "%d quads!! " % quads
	
	if triples > 0:
		description += "%d triples! " % triples
		
	if doubles > 0:
		description += "%d doubles" % doubles
	
	var score = SCORE_FX.instantiate()
	score.score = points
	score.description = description
	
	return score

func deposit_stack(items: Array[Node3D]):
	var points = get_points(items)
	
	var tweens = []
	var wait_between = 0.1
	for i in range(0, len(items)):
		var item = items[len(items) - 1 - i]
		item.reparent(item_holder)
		
		
		var a = get_tree().create_tween()
		a.tween_interval(1.25 + i * wait_between * 1.2)
		a.tween_callback(animate_eat)
		tweens.append(a)
		var t = get_tree().create_tween()
		t.tween_property(item, "position", Vector3(0, 1.0+(len(items)-i) * 0.35, 0), 0.5).set_trans(Tween.TRANS_CUBIC)
		##tweens.append(t)
		t.tween_property(item, "rotation", item.rotation, wait_between * 1.2 * (len(items)-i))
		t.tween_property(item, "position", Vector3.ZERO, 1.0).set_trans(Tween.TRANS_EXPO)
		t.parallel().tween_property(item, "scale", Vector3.ZERO, 1.0).set_trans(Tween.TRANS_EXPO)
		await get_tree().create_timer(wait_between).timeout
		i += 1
	
	print("awaiting tweens")
	for t in tweens:
		if t.is_running():
			await t.finished
	print("awaited tweens")
	await get_tree().create_timer(0.2).timeout
	print("not eating!")
	animation_tree.set("parameters/conditions/eat", false)
	animation_tree.set("parameters/conditions/idle", true)
	wash_particles.emitting = false
	
	add_child(points)
	
	score.emit(points.score)
	pass

func animate_eat():
	
	print("eat!!")
	shake_camera.shake(0.4, 0.1)
	#animation_player.stop()
	#animation_player.play("wash_eat")
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/eat", true)
	wash_particles.emitting = true
	
func clean_bottom_dish() -> Dish:
	var clean_dish : Dish
	clean_dish = items[0]
	items.remove_at(0)
	clean_dish.clean()
	return clean_dish
