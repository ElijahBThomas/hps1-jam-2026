class_name Fish3D
extends CharacterBody3D

# Fish properties
@export var swim_speed: float = 80
@export var drift_speed: float = 20
var speed_check: float
@onready var last_position: Vector3 = global_position
@onready var last_move_dir: Vector3
@export var rot_speed: float = 4
@export var strength: float = 100
@export var fatigue: float = 100
@export var roam_range : float = 5
@export var bait_check_area : Area3D
var smooth_rot_node: Node3D
@export var mesh: MeshInstance3D
@export var idle_time: float = 15
@export var bait_range: float = 2.0
@export var hook: Node3D # Will check exactly what kind of node it is later
var timer: Timer
var new_swim_target: Vector3
@export var pool: Area3D
var pool_aabb: AABB
var is_swimming: bool = true
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var ray_cast: RayCast3D
@onready var collider: CollisionShape3D
var swim_limiter = 0
@onready var skel = $Fish_Bass/Armature/Skeleton3D
@onready var id = skel.find_bone("Head")

# Inventory properties
@onready var size: float = randf_range(0.8, 1.6)
@export var name_tag: String = "Fish"
@export var length: float = randf_range(1.0, 1.5)
@export var weight: float = 10 * size
@export var price: int = 10
@export var icon: Image # Not sure if inventory is 2D or 3D yet

enum STATE {IDLE, INVESTIGATE, HOOKED}
var state = STATE.IDLE

# Will probably make a constructor here for when we need to spawn fish in pools

func _ready():
	# Randomized sizing
	scale = Vector3(size, size, size)
	skel.set_bone_pose_scale(id, Vector3(size, length, size))
	
	# Adds a new timer for each fish for state transitions and stuff
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timout)
	timer.one_shot = true
	timer.start(4)
	
	# Creates collision shape properties
	collider = CollisionShape3D.new()
	add_child(collider)
	collider.shape = CapsuleShape3D.new()
	collider.shape.radius = 0.2
	collider.shape.height = 1.0
	collider.rotation_degrees.x = 90
	collider.position.z = 0.4
	
	# Creates a new raycast node
	ray_cast = RayCast3D.new()
	add_child(ray_cast)
	
	# Adds the smooth_rot_node to smoothly look at things like the hook
	smooth_rot_node = Node3D.new()
	add_child(smooth_rot_node)
	smooth_rot_node.top_level = true
	
	# Adds the bait_check_area and it's collision
	bait_check_area = Area3D.new()
	add_child(bait_check_area)
	bait_check_area.position = Vector3.ZERO
	var area_col = CollisionShape3D.new()
	bait_check_area.add_child(area_col)
	area_col.shape = SphereShape3D.new()
	area_col.get_shape().set_radius(bait_range)
	
	# TO DO: Find a different way of checking whether the fish movement point is in water
	# Finding what body of water it is in
	for area in bait_check_area.get_overlapping_areas():
		if area.is_in_group("Water"):
			pool = area
		
	#pool_aabb = AABB(pool_col.global_position, pool_col.get_shape().size)
	
	# Setting initial swim position
	new_swim_target = get_rand_point(roam_range) + global_position

func get_rand_point(range_max : float):
	# Should point to the ground and collide
	var point := Vector3(0, -9999, 0) 
	
	#Using a raycast to check if the fish is going to collide with a wall
	ray_cast.target_position = point
	print(ray_cast.get_collider())
	print(ray_cast.is_colliding())
	
	# Keep it in the loop until it finds a point in the water
	var loop_limiter: int = 0
	while ray_cast.is_colliding():
		point.x = randf_range(-range_max, range_max)
		point.y = randf_range(-range_max, range_max)
		point.z = randf_range(-range_max, range_max)
		point = point + global_position
		ray_cast.target_position = point
		loop_limiter += 1
		
		if loop_limiter == 100:
			# print("Too many loops!")
			break
	
	return point

func swim_to_target(swim_target : Vector3, delta : float):
	var swimming = true
	# If the distance to swim_target is larger than the path_segment_range, create a path to the swim_target
	
	# Follow the path one point at a time wile removing previous points from the path
	
	# For now it just simply goes in a straight line
	var move_dir = global_position.direction_to(swim_target)
	last_move_dir = move_dir
	velocity = move_dir * swim_speed * delta
	smooth_look_at(swim_target, delta)
	move_and_slide()
	
	if global_position.distance_to(swim_target) <= 0.5 || swim_limiter == 100: 
		# print("Timer Started")
		timer.start(randf_range(4, idle_time))
		swim_limiter = 0
		swimming = false
	
	swim_limiter += 1
	return swimming

func drift(delta):
	velocity = last_move_dir * drift_speed * delta
	reset_rotation(delta)
	move_and_slide()

func _on_timer_timout():
	new_swim_target = get_rand_point(roam_range)
	print("Timer Ended!")

func smooth_look_at(target : Vector3, delta : float):
	smooth_rot_node.global_position = global_position
	smooth_rot_node.look_at(target, Vector3.UP)
	rotation.x = lerp_angle(rotation.x, smooth_rot_node.rotation.x, (rot_speed - size) * delta)
	rotation.y = lerp_angle(rotation.y, smooth_rot_node.rotation.y, (rot_speed - size) * delta)
	rotation.z = lerp_angle(rotation.z, smooth_rot_node.rotation.z, (rot_speed - size) * delta)

func reset_rotation(delta):
	rotation.x = lerp_angle(rotation.x, 0, delta / size)
	rotation.z = lerp_angle(rotation.z, 0, delta / size)

func bite(_hook : Node3D, delta : float):
	swim_to_target(_hook.global_position, delta)
	# Will need to run a biting animation here
	# Will need to attach the hook to the fish's mouth
	# The player controls should now influence the fish's position
	print("I'm bitin it!!")
	state = STATE.HOOKED

func update_anims():
	anim_tree.set("parameters/conditions/idle", speed_check < 0.01)
	anim_tree.set("parameters/conditions/swimming", speed_check > 0.01)
	anim_tree.set("parameters/Swim/blend_position", speed_check)

func _physics_process(delta):
	ray_cast.force_raycast_update()
	update_anims()
	speed_check = (last_position - global_position).length()
	last_position = global_position
	#print(speed_check)
	
	match state:
		STATE.IDLE:
			if is_swimming == false:
				drift(delta)
			if timer.is_stopped():
				# |Swim to a random spot within an area|
				is_swimming = swim_to_target(new_swim_target, delta)
				
				# |If bait is near by, move to INVESTIGATE|
				for body in bait_check_area.get_overlapping_bodies():
					if body.is_in_group("Hook"):
						state = STATE.INVESTIGATE

		STATE.INVESTIGATE:
			# |Swim near the bait and wait a random amount of time until nibbling|
			smooth_look_at(hook.global_position, delta)
			if global_position.distance_to(hook.global_position) > 1.0:
				swim_to_target(hook.global_position, delta)
			
			# |Nibble a random amount of times|
			else:
				pass 
			# |If the bait is still near by, is in biting range and another fish is not biting it, bite down and transition to HOOKED|
			if global_position.distance_to(hook.global_position) <= 1.0:
				bite(hook, delta)
			# |If the bait is still near by but isn't in biting range, repeat INVESTIGATE|
			elif global_position.distance_to(hook.global_position) <= 2.0 && global_position.distance_to(hook.global_position) > 1.0:
				state = STATE.INVESTIGATE
			# |If the bait is not near by, resume IDLE|
			elif global_position.distance_to(hook.global_position) > 2.0:
				state = STATE.IDLE
		
		STATE.HOOKED:
			# |Swim away until fatigue reaches zero|
			
			# |Stop swimming and recover fatigue for a while|
			
			# |Repeat until caught or line snaps|
			
			# |If line is snapped maybe swim to a safe area?|
			
			# |If caught go into caught animation|
			pass
