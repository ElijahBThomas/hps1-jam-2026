extends CharacterBody3D

const SPEED: float = 600.0
const J_SPEED: float = 20.0
var jump_reset: int = 0
var dbl_jump_reset: bool = false
const R_SPEED: float = 10.0
var move_input: Vector3 = Vector3.ZERO

@export var cam_crane : SpringArm3D

# This will be changed when the actual art comes in but is used in line 20
@onready var mesh := $Mesh
@onready var cast_reticle = $SpringArm3D/cast_reticle
@onready var anim_tree = $AnimationTree

func update_anims():
	anim_tree.set("parameters/conditions/idle", velocity == Vector3.ZERO && is_on_floor())
	anim_tree.set("parameters/Idle/Rand_Scratch/blend_position", randi_range(0, 1))
	anim_tree.set("parameters/conditions/running", velocity != Vector3.ZERO && is_on_floor())
	anim_tree.set("parameters/Movement/blend_position", abs(move_input.x) + abs(move_input.z))
	anim_tree.set("parameters/conditions/jump", !is_on_floor())
	anim_tree.set("parameters/Jump_Fall/blend_position", jump_reset)

func input_listen():
	if(Input.is_action_just_pressed("cast_state") && is_on_floor()):
		if(Globals.state == Globals.STATE.CAST):
			Globals.state = Globals.STATE.WALK #consider defining a "last state" variable to return to instead of returning to walk always
			cast_reticle.visible = false
		else:
			velocity = Vector3.ZERO
			Globals.state = Globals.STATE.CAST

func update_jump():
	if jump_reset >= 30:
		jump_reset = 30 # Stops the player from jumping mid air after falling of ledges
		velocity.y = get_gravity().y * 1.5 if! Input.is_action_pressed("jump") else get_gravity().y * 0.5
	if jump_reset < 30: # Checks if the player has a jump and allows for a longer jump
		velocity.y = J_SPEED - jump_reset
		jump_reset += 1 if Input.is_action_pressed("jump") else 2
		# print(jump_reset)
	if is_on_floor() && Input.is_action_just_pressed("jump"):
		dbl_jump_reset = true
		jump_reset = 1 # Resets the jump
	if !is_on_floor() && Input.is_action_just_pressed("jump") && dbl_jump_reset:
		dbl_jump_reset = false
		jump_reset = 1

func update_movement(delta):
	# Getting the movement inputs and converting them to a direction to move the player in
	move_input.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	move_input.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	var move_dir = move_input.rotated(Vector3.UP, cam_crane.rotation.y)
	
	# Model rotation logic
	# Checks to see if there is an input, or else it would snap back to Vector3.ZERO
	if abs(move_input) > Vector3.ZERO:
		var last_move_dir: Vector3 = move_dir
		var new_mesh_angle: float = Vector3.BACK.signed_angle_to(last_move_dir, Vector3.UP)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, new_mesh_angle, R_SPEED * delta)
	
	# Velocity is part of the CharacterBody3D class and is necessary for move_and_slide() to move the character
	velocity = move_dir * SPEED * delta
	update_jump()
	move_and_slide()

func aim_cast(delta):
	move_input.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	move_input.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	
	var move_dir = move_input.normalized()
	
	mesh.rotate(Vector3.UP, move_dir.x * R_SPEED * delta)  
	#cast_reticle.velocity.z = move_dir.z * SPEED * delta
	
	$SpringArm3D.spring_length += move_dir.z * SPEED * delta

func cast_rod():
	pass

func _physics_process(delta):
	update_anims()
	input_listen()
	match Globals.state:
		Globals.STATE.WALK:
			update_movement(delta)
		Globals.STATE.CAST:
			cast_reticle.visible = true
			aim_cast(delta)
			pass
		Globals.STATE.FISH:
			pass
		Globals.STATE.BOAT:
			pass
