extends ColorRect

onready var animationPlayer = $AnimationPlayer

signal fade_finished

func _ready():
	animationPlayer.connect("animation_finished", self, "on_animation_finished")

func fade_in():
	animationPlayer.play("fade_in")

func fade_out():
	animationPlayer.play("fade_out")

func on_animation_finished(name):
	emit_signal("fade_finished")
