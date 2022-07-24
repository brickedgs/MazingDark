extends Spatial

onready var monster = $GridMap/Monster
onready var monster = $GridMap/Monster
onready var player = $GridMap/Player
# Called when the node enters the scene tree for the first time.
func _ready():
	monster.set_target(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
