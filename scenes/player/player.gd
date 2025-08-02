extends CharacterBody3D
class_name Player

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var plate_hold_position: Marker3D = $PlateHoldPosition

@export var move_speed: float = 1.0

var target_node: Node3D = null
var performing_action: bool = false

var action: String
var _held_items: Array[Node3D] = []

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if target_node:
		navigation_agent_3d.target_position = target_node.global_position
	
	if navigation_agent_3d.is_navigation_finished():
		velocity = Vector3.ZERO
		%WalkParticles.emitting = false
	else:
		%WalkParticles.emitting = true
		var next_pos = navigation_agent_3d.get_next_path_position()
		var move_dir = global_position.direction_to(next_pos)
		var weight = clamp(len(_held_items) / 8.0, 0, 1.0)
		var new_velocity = max(move_speed - weight * 4.0, 0) * move_dir
		
		velocity = new_velocity
		look_at(position + move_dir, Vector3.UP, true)
	move_and_slide()

func move_to_position(position: Vector3):
	target_node = null
	print("moving to floor")
	navigation_agent_3d.target_position = position
	var final_position = navigation_agent_3d.get_final_position()
	walk_sfx_timer.start()
	
func move_to_clean_plate(plate: PlateOnBelt):
	print("moving to clean plate: ", plate)
	target_node = plate
	action = "clean"
	walk_sfx_timer.start()

func move_to_plate(plate: PlateOnBelt):
	print("moving to plate: ", plate)
	target_node = plate
	action = "take"
	walk_sfx_timer.start()
	
func drop_on_plate(plate: PlateOnBelt):
	print("dropping to plate: ", plate)
	target_node = plate
	action = "drop"
	walk_sfx_timer.start()

func drop_on_washing_machine(machine: WashingMachine):
	print("dropping to machine: ", machine)
	target_node = machine
	action = "drop"
	walk_sfx_timer.start()

func _animate_take_item(item: Node3D):
	# "detach" the item's position from its parent, so we can animate it moving to us
	item.top_level = true
	
	# animate the item towards us
	var t = get_tree().create_tween()
	t.tween_property(item, "global_position", plate_hold_position.global_position, 0.25).set_trans(Tween.TRANS_EXPO)
	await t.finished

func _hold_item(item: Node3D):
	# and now we make it a child to us
	if item.get_parent():
		item.reparent(plate_hold_position)
	else:
		plate_hold_position.add_child(item)
	item.top_level = false
	item.position = Vector3.ZERO
	item.position.y = len(_held_items) * 0.25
	print(item.get_parent())
	_held_items.append(item)	
	clang_audio_player.play()

func _on_navigation_finished() -> void:
	print("finished navigating")
	if performing_action:
		return
	walk_sfx_timer.stop()
	performing_action = true
	# when we reach the plate after clicking it, we take the top item
	if (target_node is PlateOnBelt) or target_node is WashingMachine:
		if action == "take":
			var item = target_node.take_item()
			if item:
				await _animate_take_item(item)
				_hold_item(item)
		if action == "drop":
			if len(_held_items) > 0:
				if target_node is WashingMachine:
					await target_node.deposit_stack(_held_items)
					_held_items.clear()
				else:
					await target_node.add_item(_held_items.pop_back())
		if action == "clean":
			if ($wash_timer.time_left == 0):
				target_node.clean_top_down()
				$wash_timer.start()
				#TODO animation..
			else:
				pass #TODO inform user wash is on cooldown
			
	target_node = null
	performing_action = false

@onready var walk_audio_player: AudioStreamPlayer3D = $WalkAudioPlayer
@onready var walk_sfx_timer: Timer = $WalkSFXTimer
@onready var clang_audio_player: AudioStreamPlayer3D = $ClangAudioPlayer

func _on_walk_sfx_timer_timeout() -> void:
	walk_audio_player.play()
