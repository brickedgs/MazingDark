extends ColorRect

onready var animationPlayer = $AnimationPlayer

signal fade_finished

func _ready():
	animationPlayer.connect("animation_finished", self, "on_animation_finished")

func fade_in():
	pass

func fade_out():
	pass

func on_animation_finished():
	emit_signal("fade_sinished")
