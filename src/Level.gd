extends Spatial

onready var monster = $GridMap/Monster
onready var player = $GridMap/Player
onready var orbs = $GridMap/Orbs

var collected_orbs = 0
var total_orbs = 0

func _ready():
	monster.set_target(player)
	total_orbs = orbs.get_child_count()
	player.connect("orb_collected", self, "on_orb_collected")

func on_orb_collected():
	collected_orbs += 1
	
	if collected_orbs >= total_orbs:
		print('You won')
