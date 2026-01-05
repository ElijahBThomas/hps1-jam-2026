extends CharacterBody3D

const SPEED : float = 250.0
const J_SPEED : float = 200.0
const R_SPEED : float = 10.0
var move_input : Vector3 = Vector3.ZERO

@export var cam_crane : SpringArm3D

# This will be changed when the actual art comes in but is used in line 20
@onready var mesh := $MeshInstance3D

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

func cast_rod():
	pass

func _physics_process(delta):
	update_movement(delta)
