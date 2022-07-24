extends KinematicBody

const SPEED = 4

var target = null
var vel = Vector3()
var path_finder = null
var path = []
var find_path_timer: Timer = null
var chase = false
var spawn_locations = [
	[15, 10],
	[-15, 14],
	[-15, -15],
	[-7, 5]
]

onready var hitbox = $HitboxArea
onready var mesh = $MeshInstance
onready var chaseArea = $ChaseArea

func _ready():
	randomize()
	var index = int(rand_range(0, 4))
	self.global_transform.origin.x = spawn_locations[index][0]
	self.global_transform.origin.z = spawn_locations[index][1]
	mesh.visible = false
	self.set_physics_process(false)
	hitbox.connect("body_entered", self, "on_hit_player")
	path_finder = PathFinder.new(get_parent(), 1)
	add_child(path_finder)
	find_path_timer = Timer.new()
	find_path_timer.wait_time = 1
	add_child(find_path_timer)
	find_path_timer.connect("timeout", self, "find_path")
	chaseArea.connect("body_entered", self, "on_body_entered")
	chaseArea.connect("body_exited", self, "on_body_exited")
	

func _physics_process(delta):
	var dir = Vector3(target.global_transform.origin.x, 1.5, target.global_transform.origin.z)
	self.look_at(dir, Vector3.UP)
	
	if path.size() > 0:
		move_along_path(path)

func move_along_path(path):
	if global_transform.origin.distance_to(path[0]) < 0.1:
		path.remove(0)
		if path.size() == 0:
			return
	
	vel = (path[0] - global_transform.origin).normalized() * SPEED
	vel = move_and_slide(vel, Vector3.UP)

func set_target(target):
	self.target = target
	
	if target != null:
		find_path()
		find_path_timer.start()
		self.set_physics_process(true)
	else:
		self.set_physics_process(false)
		path = []
		find_path_timer.stop()

func on_hit_player(body):
	body.die()
	

func find_path():
	if !chase:
		return

	path = path_finder.find_path(self.global_transform.origin, target.global_transform.origin)
	
	if (path.size() > 0):
		path.remove(0)

func on_body_entered(body):
	chase = true
	mesh.visible = true

func on_body_exited(body):
	chase = false
	mesh.visible = false
