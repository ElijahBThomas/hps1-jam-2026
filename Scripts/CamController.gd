extends SpringArm3D

@export var player : CharacterBody3D

const SPEED : float = 500.0
const EASE : float = 50.0
const Y_OFFSET : float = 2.0

var move_input : Vector2 = Vector2.ZERO
var controller_sensitivity : float = 2.0

# Will probably change this to stop the player from moving the character
var menu_visible : bool = false

func follow_target(delta):
	var target: Vector3 = Vector3(player.global_position.x, player.global_position.y + Y_OFFSET, player.global_position.z)
	global_position = lerp(global_position, target, 5 * delta)

func controller_rotation(delta):
	move_input.x = Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right")
	#move_input.y = Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	
	var move_dir = move_input.normalized()
	rotate(Vector3.UP, move_dir.x * controller_sensitivity * delta)

# Handles camera rotation with the mouse
func _input(event):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate(Vector3.UP, event.relative.x * -0.001)
		transform = transform.orthonormalized()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	follow_target(delta)
	controller_rotation(delta)

func _process(_delta):
	# Regaining mouse control when pressing escape and set up for later menu work
	if Input.is_action_just_pressed("menu"):
		if !menu_visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			menu_visible = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			menu_visible = false
