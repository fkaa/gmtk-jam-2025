extends Area3D
class_name WashingMachine

const BASE_WASH_TIME    = 3
const COMBO_TIME_SCALAR = 0.75
const QUEUE_LIMIT       = 12

var is_cleaning        : bool
var active_combo_count : int
var current_wash_time  : float
var clean_queue        : Array[Dish]
var items_being_eaten  : Array[Node3D]

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
# Add items to queue, return array of any items that couldn't fit on the queue
func deposit_stack(items: Array[Node3D]) -> Array[Node3D]:
	var points = get_points(items)
	
	var tweens = []
	var wait_between = 0.1
	var num_items_to_add = min(len(items), QUEUE_LIMIT - len(clean_queue))
	var item_idx = 0
	var initial_q_size = len(clean_queue)
	while (item_idx < num_items_to_add):
		clean_queue.push_back(items[item_idx])
		item_idx+=1
	
	if (!is_cleaning):
		is_cleaning = true
		current_wash_time = BASE_WASH_TIME
		active_combo_count = 0
		cleaning_timer.wait_time = current_wash_time
		cleaning_timer.start()
		
	
	for i in range(0, num_items_to_add):
		## go in reverse order
		var item = items[len(items) - 1]
		## reparent to holder
		item.reparent(item_holder)
		#
		
		## tween 
		#var a = get_tree().create_tween()
		#a.tween_interval(1.25 + i * wait_between * 1.2)
		## callback animate eat, need to change this
		#a.tween_callback(animate_eat)
		#tweens.append(a)
		var t = get_tree().create_tween()
		#move to wash?
		t.tween_property(item, "position", Vector3(0, 1+(initial_q_size+num_items_to_add-i)*0.25, 0), 0.5).set_trans(Tween.TRANS_CUBIC)
		###tweens.append(t)
		#t.tween_property(item, "rotation", item.rotation, wait_between * 1.2 * (len(items)-i))
		#t.tween_property(item, "position", Vector3.ZERO, 1.0).set_trans(Tween.TRANS_EXPO)
		## shrink
		#t.parallel().tween_property(item, "scale", Vector3.ZERO, 1.0).set_trans(Tween.TRANS_EXPO)
		#await get_tree().create_timer(wait_between).timeout
		#i += 1
		items.remove_at(len(items)-1)
	#
	return items
	#for t in tweens:
		#if t.is_running():
			#await t.finished
#
	#await get_tree().create_timer(0.2).timeout
#
	#animation_tree.set("parameters/conditions/eat", false)
	#animation_tree.set("parameters/conditions/idle", true)
	#wash_particles.emitting = false
	#
	#add_child(points)
	#
	#score.emit(points.score)
	pass
	
func clean_bottom_dish():
	if (clean_queue.size() == 0):
		return
	var clean_dish = clean_queue[0]
	#items_being_eaten.push_back(clean_dish)
	clean_queue.remove_at(0)
	if (clean_queue.size() > 0):
		var next = clean_queue[0]
		if next.dish_type == clean_dish.dish_type: 
			active_combo_count += 1
			current_wash_time *= COMBO_TIME_SCALAR
		else: # non-combo clean
			active_combo_count = 0
			current_wash_time = BASE_WASH_TIME
		cleaning_timer.wait_time = current_wash_time
		cleaning_timer.start()
		# animate everything in the Q moving down by .25
		for item in clean_queue:
			var t = get_tree().create_tween()
			t.tween_property(item, "position", Vector3(item.position.x, item.position.y-.25, item.position.z), 0.5)
		
	else: # nothing left to clean
		active_combo_count = 0
		current_wash_time = BASE_WASH_TIME
		is_cleaning = false
	
	# anim stuff
	var wait_between = 0.1
	# go in reverse order
	var item = clean_dish
	# reparent to holder
	item.reparent(item_holder)
	
	# tween 
	var a = get_tree().create_tween()
	a.tween_interval(1.25)
	# callback animate eat, need to change this
	a.tween_callback(animate_eat)
	var t = get_tree().create_tween()
	t.tween_property(item, "rotation", item.rotation, 1.2)
	t.tween_property(item, "position", Vector3.ZERO, 1.0).set_trans(Tween.TRANS_EXPO)
	# shrink
	t.parallel().tween_property(item, "scale", Vector3.ZERO, 1.0).set_trans(Tween.TRANS_EXPO)
	#i += 1
	#
	#for t in tweens:
		#if t.is_running():
			#await t.finished
#


	#TODO points	
	#add_child(points)
	#
	#score.emit(points.score)

func animate_eat():
	shake_camera.shake(0.4, 0.1)
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/eat", true)
	wash_particles.emitting = true
	
	await get_tree().create_timer(0.2).timeout
#
	animation_tree.set("parameters/conditions/eat", false)
	animation_tree.set("parameters/conditions/idle", true)
	wash_particles.emitting = false
	
	# free the item
	#if (items_being_eaten.size() > 0):
		#var item = items_being_eaten[0]
		#items_being_eaten.remove_at(0)
		##item.queue_free()
	
#func clean_bottom_dish() -> Dish:
	#var clean_dish : Dish
	#clean_dish = items[0]
	#items.remove_at(0)
	#clean_dish.clean()
	#return clean_dish


func _on_cleaning_timer_timeout() -> void:
	if (clean_queue.size() > 0):
		clean_bottom_dish()
	else:
		is_cleaning = false
		current_wash_time = BASE_WASH_TIME
		active_combo_count = 0
