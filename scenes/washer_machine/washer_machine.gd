extends Area3D
class_name WashingMachine

const BASE_WASH_TIME    = 3
const COMBO_TIME_SCALAR = 0.75

var is_cleaning        : bool
var active_combo_count : int
var current_wash_time  : float

@onready var cleaning_timer = $CleaningTimer
@onready var item_holder: Node3D = %ItemHolder
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

var items: Array[Node3D] = []

func _process(delta_time) -> void:
	pass

func _ready()-> void:
	# it dont work..
	pass

func deposit_stack(items: Array[Node3D]):
	var tweens = []
	var wait_between = 0.1
	for i in range(0, len(items)):
		var item = items[len(items) - 1 - i]
		item.reparent(item_holder)
		
		var a = get_tree().create_tween()
		a.tween_property(self, "scale", self.scale, 1.25 + i * wait_between * 1.2)
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
	
	for t in tweens:
		await t.finished
	await get_tree().create_timer(0.2).timeout
	print("not eating!")
	animation_tree.set("parameters/conditions/eat", false)
	animation_tree.set("parameters/conditions/idle", true)
	pass

func animate_eat():
	print("eat!!")
	#animation_player.stop()
	#animation_player.play("wash_eat")
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/eat", true)
	
func clean_bottom_dish() -> Dish:
	var clean_dish : Dish
	clean_dish = items[0]
	items.remove_at(0)
	clean_dish.clean()
	return clean_dish
