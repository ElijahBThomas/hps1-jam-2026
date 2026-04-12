extends RigidBody3D

@onready var player = $"../Player"

const JERK_COOLDOWN = 1
const JERK_SPEED = 50
const REEL_SPEED = 100
var last_action : float

enum HOOK_STATE{no_fish, fish_on}
var state = HOOK_STATE.no_fish

var line_strength : float
var bouyancy : float
var bobber : bool

func update_movement(delta):
	if(Globals.state == Globals.STATE.FISH):
		var vector_to_player = global_position.direction_to(player.global_position)
		if(Time.get_unix_time_from_system() > last_action + JERK_COOLDOWN):
			if(Input.is_action_just_pressed("move_left")):
				#sets velocity vector to the vector halfway between the vector to player and it's horizontal perpendicular vector
				var velocity = (vector_to_player - (vector_to_player).cross(Vector3.UP)) * JERK_SPEED * delta
				apply_impulse(velocity)
				last_action = Time.get_unix_time_from_system()
			if(Input.is_action_just_pressed("move_right")):
				#sets velocity vector to the vector halfway between the vector to player and it's horizontal perpendicular vector
				var velocity = (vector_to_player - (vector_to_player).cross(Vector3.UP)) * JERK_SPEED * delta
				apply_impulse(velocity)
				last_action = Time.get_unix_time_from_system()
		if(Input.is_action_pressed("cast_rod")):
			var velocity = vector_to_player * Input.get_action_strength("cast_rod") * REEL_SPEED * delta
			apply_force(velocity)

func _physics_process(delta):
	match (state):
		HOOK_STATE.no_fish:
			update_movement(delta)
		HOOK_STATE.fish_on:
			pass
