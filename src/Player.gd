extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 7
const JUMP_SPEED = 8
const ACCEL = 3

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.1

onready var collider = $Collider
onready var fear_collider = $FearCollider
signal orb_collected

onready var animation = $Head/AnimationPlayer
onready var flashlight = $Head/flashlight/SpotLight
onready var sfx_footsteps = $SFX/Footsteps
onready var sfx_breathing = $SFX/Breathing
onready var sfx_orb_collected = $SFX/OrbCollected

func _ready():
	camera = $Head/Camera
	rotation_helper = $Head
	collider.connect("area_entered", self, "on_area_entered")
	fear_collider.connect("body_entered", self, "on_fear_area_entered")
	fear_collider.connect("body_exited", self, "on_fear_area_exited")

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------
	
	if Input.is_action_just_pressed("toggle_flashlight"):
		flashlight.visible = !flashlight.visible

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
	if vel.x == 0 and vel.z == 0:
		if animation.is_playing():
			animation.stop()
		if sfx_footsteps.playing:
			sfx_footsteps.stop()
	elif (vel.x != 0 or vel.z != 0):
		if !animation.is_playing():
			animation.play("movement")
		if !sfx_footsteps.playing:
			sfx_footsteps.play()
	
	# ----------------------------------
	# Joystick Right Stick
	var stickUp = Input.get_action_strength("right_stick_up")
	var stickLeft = Input.get_action_strength("right_stick_left")
	var stickDown = Input.get_action_strength("right_stick_down")
	var stickRight = Input.get_action_strength("right_stick_right")
	
	if stickLeft:
		self.rotate_y(deg2rad(stickLeft * 25 * MOUSE_SENSITIVITY))
	if stickRight:
		self.rotate_y(deg2rad(-stickRight * 25 * MOUSE_SENSITIVITY))
	
	if stickUp or stickDown:
		if stickUp:
			rotation_helper.rotate_x(deg2rad(stickUp * 25 * MOUSE_SENSITIVITY))
		
		if stickDown:
			rotation_helper.rotate_x(deg2rad(-stickDown * 25 * MOUSE_SENSITIVITY))
		
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
	# Joystick Right Stick
	# ----------------------------------

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

func on_area_entered(area):
	if area.is_in_group("orbs"):
		area.queue_free()
		emit_signal("orb_collected")
		sfx_orb_collected.play()

func on_fear_area_entered(body):
	if body.name == "Monster":
		sfx_breathing.volume_db = -5

func on_fear_area_exited(body):
	if body.name == "Monster":
		sfx_breathing.volume_db = -10

func die():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene("res://scenes/GameOver.tscn")
