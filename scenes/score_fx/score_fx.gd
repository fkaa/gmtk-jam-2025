extends Node3D

var score: int
var description: String
@onready var score_label: Label3D = $ScoreLabel
@onready var score_description: Label3D = $ScoreLabel/ScoreDescription
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D

func _ready() -> void:
	cpu_particles_3d.emitting = true
	score_label.text = "%d" % score
	score_description.text = description
	animation_player.play("score_animation")
	await animation_player.animation_finished
	queue_free()
