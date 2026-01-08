extends CharacterBody3D

const SPEED : float = 250.0
const J_SPEED : float = 200.0
const R_SPEED : float = 10.0
const CAST_MAX_RANGE : float = 20
var move_input : Vector3 = Vector3.ZERO
var direction = "up"

@export var cam_crane : SpringArm3D
@export var hook : RigidBody3D

# This will be changed when the actual art comes in but is used in line 20
@onready var mesh := $MeshInstance3D
@onready var cast_reticle = $SpringArm3D/cast_reticle
@onready var cast_bar = $CastingBar
@onready var cast_distance = $SpringArm3D

func input_listen():
	if(Input.is_action_just_pressed("cast_state")):
		if(Globals.state == Globals.STATE.CAST):
			Globals.state = Globals.STATE.WALK #consider defining a "last state" variable to return to instead of returning to walk always
			cast_reticle.visible = false
		else:
			Globals.state = Globals.STATE.CAST

func update_movement(delta):
	# Getting the movement inputs and converting them to a direction to move the player in
	move_input.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	move_input.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	var move_dir = move_input.rotated(Vector3.UP, cam_crane.rotation.y).normalized()
	
	# Model rotation logic
	# Checks to see if there is an input, or else it would snap back to Vector3.ZERO
	if abs(move_input) > Vector3.ZERO:
		var last_move_dir : Vector3 = move_dir
		var new_mesh_angle : float = Vector3.BACK.signed_angle_to(last_move_dir, Vector3.UP)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, new_mesh_angle, R_SPEED * delta)
	
	# Velocity is part of the CharacterBody3D class and is necessary for move_and_slide() to move the character
	velocity = move_dir * SPEED * delta
	
	# Jumping and gravity logic
	if !is_on_floor():
		velocity.y += get_gravity().y * 10 * delta
	
	move_and_slide()

func aim_cast(delta):
	move_input.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	#move_input.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	
	var move_dir = move_input.normalized()
	
	mesh.rotate(Vector3.UP, move_dir.x * R_SPEED * delta)  
	#cast_reticle.velocity.z = move_dir.z * SPEED * delta
	
	cast_distance.spring_length = 5 + CAST_MAX_RANGE * (cast_bar.value / 100)

func cast_rod():
	if(Input.is_action_just_pressed("cast_rod")):
		cast_bar.visible = true
	
	if(Input.is_action_pressed("cast_rod")):
		if(cast_bar.value == 100): direction = "down"
		if(cast_bar.value == 0): direction = "up"
		if(direction == "up"): cast_bar.value += cast_bar.step
		if(direction == "down"): cast_bar.value -= cast_bar.step
	
	if(Input.is_action_just_released("cast_rod")):
		hook.global_position = cast_reticle.global_position
		hook.visible = 1 #TODO: put this in the hook controller/state transition function
		cast_bar.visible = 0
		cast_bar.value = 0
		cast_reticle.visible = false
		Globals.state = Globals.STATE.FISH
		

func _physics_process(delta):
	
	input_listen()
	match Globals.state:
		Globals.STATE.WALK:
			hook.visible = 0 #TODO: put this in the hook controller/state transition function
			update_movement(delta)
		Globals.STATE.CAST:
			hook.visible = 0 #TODO: put this in the hook controller/state transition function
			cast_reticle.visible = true
			aim_cast(delta)
			cast_rod()
		Globals.STATE.FISH:
			pass
		Globals.STATE.BOAT:
			pass
