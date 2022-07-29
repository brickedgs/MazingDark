extends Spatial

onready var start_button = $CanvasLayer/Fader/Control/VBoxContainer/CenterContainer/VBoxContainer/StartButton
onready var quit_button = $CanvasLayer/Fader/Control/VBoxContainer/CenterContainer/VBoxContainer/QuitButton
onready var fader = $CanvasLayer/Fader
onready var jump_scare_timer = $JumpScareTimer
onready var jump_scare_sprite = $CanvasLayer/Fader/JumpScareSprite
onready var jump_scare_audio = $JumpScareAudio

export (PackedScene) var game_scene = null

func _ready():
	start_button.connect("pressed", self, "start_button_pressed")
	quit_button.connect("pressed", self, "quit_button_pressed")
	fader.connect("fade_finished", self, "on_fade_finished")
	
	jump_scare_timer.connect("timeout", self, "on_jump_scare_timer_timeout")
	jump_scare_timer.start()
	jump_scare_sprite.visible = true

func start_button_pressed():
	fader.fade_out()

func quit_button_pressed():
	get_tree().quit()
	
func on_fade_finished():
	get_tree().change_scene_to(game_scene)

func on_jump_scare_timer_timeout():
	jump_scare_sprite.visible = false
	jump_scare_audio.stop()
