class_name Dish
extends Node3D

enum DISH_TYPES
{
	PLATE,
	CUTLERY,
	BOWL,
	CUP
}
@onready var clean_sprite: Sprite3D = %CleanSprite
@onready var dirty_sprite: Sprite3D = %DirtySprite
@onready var sprites: Node3D = %Sprites

@export var clean_textures : Array[Texture]
@export var dirty_textures : Array[Texture]

@export var dish_type  : DISH_TYPES
@export var is_dirty   : bool
var         is_landing : bool
var index: int

func _init() -> void:
	pass
	#position.y = 100
	#is_landing = true

func clean() -> void:
	is_dirty = false
	dirty_sprite.visible = false
	
func dirty() -> void:
	is_dirty = true
	dirty_sprite.visible = true

func _ready() -> void:
	clean_sprite.texture  = clean_textures[dish_type]
	dirty_sprite.texture = dirty_textures[dish_type]
	
func _process(delta: float) -> void:
	var time_in_sec: float = Time.get_ticks_msec() / 1000.0
	sprites.scale.x = 1.0+((1.0+cos(index*200.0 + time_in_sec*5.0)/2.0) * 0.5)
	sprites.scale.y = 1.0+((1.0+sin(index*200.0 + time_in_sec*5.0)/2.0) * 0.5)
