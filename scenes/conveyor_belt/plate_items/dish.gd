class_name Dish
extends Node3D

enum DISH_TYPES
{
	PLATE,
	CUTLERY,
	BOWL,
	CUP
}

@export var clean_textures : Array[Texture]
@export var dirty_textures : Array[Texture]

@export var dish_type  : DISH_TYPES
@export var is_dirty   : bool
var         is_landing : bool

func _init() -> void:
	pass
	#position.y = 100
	#is_landing = true

func clean() -> void:
	is_dirty = false
	$Sprite3D2.visible = false
	
func dirty() -> void:
	is_dirty = true
	$Sprite3D2.visible = true

func _ready() -> void:
	$Sprite3D.texture  = clean_textures[dish_type]
	$Sprite3D2.texture = dirty_textures[dish_type]
	
func _process(delta: float) -> void:
	var time_in_sec: float = Time.get_ticks_msec() / 1000.0
	scale.x = 1.0+((1.0+cos(position.y*200.0 + time_in_sec*5.0)/2.0) * 0.5)
	scale.y = 1.0+((1.0+sin(position.y*200.0 + time_in_sec*5.0)/2.0) * 0.5)
