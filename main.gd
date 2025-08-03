extends Node3D
class_name Main

@onready var player: Player = $Player
@onready var conveyor_belt: Node3D = $NavigationRegion3D/ConveyorBelt
@onready var start_menu: MenuSign = $MenuSign
@onready var help_screen = $HelpScreen
@onready var camera      = $Camera3D

var score: int
var game_over: bool
var game_paused = true
var title_screen = true
var show_help = false

func _ready():
	show_start_screen()
	
func start_game():
	await start_menu.raise_signs()
	# ADJUST CAMERA
	var t = get_tree().create_tween()
	t.set_parallel(true)
	t.tween_property(camera, "rotation", Vector3(deg_to_rad(-39), 0, 0), 2)
	t.tween_property(camera, "position", Vector3(0, 12.964, 16.896), 2)
	await t.finished
	
	# SHOW PLAYER
	$Player.show_player()
	
	game_paused = false
	title_screen = false
	
	# START CONVEYOR
	await get_tree().create_timer(1)
	await conveyor_belt.start_up()
	
	

func show_title_screen():
	pass

func show_start_screen():
	start_menu.lower_signs()
	pass

func _process(delta: float) -> void:
	var obj = get_object_over_mouse()
	if obj:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	if (not game_over && not game_paused):
		if Input.is_action_just_pressed("move"):
			var plate = get_object_over_mouse()
			if plate is PlateOnBelt:
				player.move_to_plate(plate)
			else:
				var floor = get_mouse_on_floor_plane()
				player.move_to_position(floor)
		if Input.is_action_just_pressed("drop"):
			var object = get_object_over_mouse()
			if object is WashingMachine:
				player.drop_on_washing_machine(object)
			elif object is PlateOnBelt:
				player.drop_on_plate(object)
	elif obj: # MENU
		if Input.is_action_just_pressed("move"):
			if obj.name == "start":
				start_game()
			elif obj.name == "help":
				show_help_screen()
		#if Input.is_action_just_pressed("clean"):
			#var plate = get_object_over_mouse()
			#if plate is PlateOnBelt:
				#player.move_to_clean_plate(plate)
	# pass data to HUD
	var hud = $Hud/wash_icon as Hud
	hud.update_timer_display($Player/wash_timer)

func get_mouse_on_floor_plane() -> Vector3:
	var mp: Vector2 = get_viewport().get_mouse_position()
	if mp.x > 0 and mp.y > 0:
		var camera: Camera3D = get_viewport().get_camera_3d()
		var floor_plane  = Plane(Vector3(0, 1, 0), 0.0)
			
		return floor_plane.intersects_ray(
			 camera.project_ray_origin(mp),
			 camera.project_ray_normal(mp))
	return Vector3.ZERO

func get_object_over_mouse() -> Node3D:
	var mp: Vector2 = get_viewport().get_mouse_position()
	if mp.x > 0 and mp.y > 0:
		var camera: Camera3D = get_viewport().get_camera_3d()
		var space_state = get_world_3d().direct_space_state

		var origin = camera.project_ray_origin(mp)
		var end = origin + camera.project_ray_normal(mp) * 100
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		query.collision_mask = 1 << 2

		var result = space_state.intersect_ray(query)
		if result.is_empty():
			return null
		return result.collider
	
	return null

func _on_difficulity_timer_timeout() -> void:
	conveyor_belt.belt_speed += 0.125
	pass # Replace with function body.
	
const NICE = preload("res://assets/audio/nice.tres")
const OK = preload("res://assets/audio/ok.tres")
const MEH = preload("res://assets/audio/meh.tres")

@onready var score_reaction: AudioStreamPlayer2D = $ScoreReaction

func _on_washer_machine_score(gained: int) -> void:
	if gained < 10:
		score_reaction.stream = MEH
	elif gained < 25:
		score_reaction.stream = OK
	else:
		score_reaction.stream = NICE
	score_reaction.play()

	score += gained
	conveyor_belt.score = score

@onready var difficulity_timer: Timer = $DifficulityTimer
const EXPLOSION = preload("res://assets/audio/explosion.wav")
func _on_conveyor_belt_broken() -> void:
	difficulity_timer.stop()
	score_reaction.stream = EXPLOSION
	score_reaction.play()
	game_over = true
	$EndScreen.visible = true
	# TODO: game end


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()

func show_help_screen() -> void:
	help_screen.show()

func _on_close_button_pressed() -> void:
	help_screen.hide()
