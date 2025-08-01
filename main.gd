extends Node3D

@onready var player: Player = $Player
@onready var conveyor_belt: Node3D = $NavigationRegion3D/ConveyorBelt

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move"):
		var plate = get_object_over_mouse()
		if plate is PlateOnBelt:
			player.move_to_plate(plate)
		else:
			var floor = get_mouse_on_floor_plane()
			player.move_to_position(floor)
	if Input.is_action_just_pressed("drop"):
		var object = get_object_over_mouse()
		if object is PlateOnBelt:
			player.drop_on_plate(object)
		elif object is WashingMachine:
			player.drop_on_washing_machine(object)
	if Input.is_action_just_pressed("clean"):
		var plate = get_object_over_mouse()
		if plate is PlateOnBelt:
			player.move_to_clean_plate(plate)
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
