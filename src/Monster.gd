extends KinematicBody

const WALK_SPEED = 3
const RUN_SPEED = 6

var speed = WALK_SPEED
var target = null
var vel = Vector3()
var path_finder = null
var path = []
var find_path_timer: Timer = null
var spawn_locations = [
	[15, 10],
	[-15, 14],
	[-15, -15],
	[-7, 5]
]

var difficulty = 1

onready var hitbox = $HitboxArea
onready var chaseArea = $ChaseArea
onready var chaseAreaShape = $ChaseArea/CollisionShape
onready var animation = $Mesh/AnimationPlayer

func _ready():
	randomize()
	var index = int(rand_range(0, 4))
	self.global_transform.origin.x = spawn_locations[index][0]
	self.global_transform.origin.z = spawn_locations[index][1]
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
	animation.play("walk")
	updateChaseAreaChape()

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
	
	vel = (path[0] - global_transform.origin).normalized() * speed
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
	path = path_finder.find_path(self.global_transform.origin, target.global_transform.origin)
	
	if (path.size() > 0):
		path.remove(0)

func on_body_entered(body):
	animation.play("run")
	speed = RUN_SPEED

func on_body_exited(body):
	animation.play("walk")
	speed = WALK_SPEED

func increase_difficulty():
	difficulty += 1
	updateChaseAreaChape()
	
func updateChaseAreaChape():
	chaseAreaShape.shape.extents = Vector3(difficulty * 1.2, 1, difficulty * 2)
