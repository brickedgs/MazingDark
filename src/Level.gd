extends Spatial

onready var monster = $GridMap/Monster
onready var player = $GridMap/Player
onready var orbs = $GridMap/Orbs

onready var pause_menu = $CanvasLayer/PauseMenu
onready var main_menu_button = $CanvasLayer/PauseMenu/VBoxContainer/CenterContainer/VBoxContainer/MainMenuButton
onready var quit_game_button = $CanvasLayer/PauseMenu/VBoxContainer/CenterContainer/VBoxContainer/QuitGameButton
onready var hud = $CanvasLayer/HUD
onready var hud_timer = $CanvasLayer/HUD/Timer
onready var orbs_label = $CanvasLayer/HUD/VBoxContainer/OrbsLabel

var collected_orbs = 0
var total_orbs = 0

func _ready():
	monster.set_target(player)
	total_orbs = orbs.get_child_count()
	player.connect("orb_collected", self, "on_orb_collected")
	pause_menu.visible = false
	main_menu_button.connect("pressed", self, "on_main_menu_button_pressed")
	quit_game_button.connect("pressed", self, "on_quit_game_button_pressed")
	hud_timer.connect("timeout", self, "on_hud_timer_timeout")
	hud.visible = false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.visible = !pause_menu.visible

func on_orb_collected():
	collected_orbs += 1
	monster.increase_difficulty()
	orbs_label.text = String(collected_orbs) + "/" + String(total_orbs)
	hud.visible = true
	hud_timer.start()
	
	if collected_orbs >= total_orbs:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://scenes/YouWon.tscn")

func on_main_menu_button_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")

func on_quit_game_button_pressed():
	get_tree().quit()

func on_hud_timer_timeout():
	hud.visible = false
