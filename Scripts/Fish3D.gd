class_name Fish3D
extends CharacterBody3D

# Fishing properties
@export var speed: float = 40
@export var strength: float = 100
@export var fatigue: float = 100
@export var roam_range : float = 5
@export var bait_check_area : Area3D
@export var mesh: MeshInstance3D
@export var idle_time: float = 15
var timer: Timer
var new_swim_target: Vector3
@export var pool: Area3D
var aabb = AABB()

# Inventory properties
@export var name_tag: String = "Fish"
@export var length: int = 10
@export var weight: float = 10
@export var price: int = 10
@export var icon: Image # Not sure if inventory is 2D or 3D yet

enum STATE {IDLE, INVESTIGATE, HOOKED}
var state = STATE.IDLE

func _ready():
	
	# Adds a new timer for each fish for state transitions and stuff
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timout)
	timer.one_shot = true
	timer.start(4)
	
	# Adds the bait_check_area and it's collision
	bait_check_area = Area3D.new()
	add_child(bait_check_area)
	var area_col = CollisionShape3D.new()
	area_col.shape = SphereShape3D
	#area_col.shape.radius = 2.0
	bait_check_area.add_child(area_col)
	
	# TO DO: Find a different way of checking whether the fish movement point is in water
	# Finding what body of whater it is in for its AABB
	for area in bait_check_area.get_overlapping_areas():
		if area.is_in_group("Water"):
			pool = area
	var shape = pool.get_child(0).shape as ConcavePolygonShape3D
	for face in shape.get_faces(): # Get faces doesn't exist or shape is NIL
		aabb = aabb.expand(face)
	
	# Setting initial swim position
	new_swim_target = get_rand_point(roam_range) + global_position

func get_rand_point(range_max : float):
	var point := Vector3.ZERO
	point.x = randf_range(-range_max, range_max)
	point.y = randf_range(-range_max, range_max)
	point.z = randf_range(-range_max, range_max)
	
	point = point + global_position
	
	if aabb.has_point(point):
		return point
	else:
		get_rand_point(range_max)

func swim_to_target(swim_target : Vector3, delta : float):
	var swimming = true
	# If the distance to swim_target is larget than the path_segment_range, create a path to the swim_target
	
	# Follow the path one point at a time wile removing previous points from the path
	
	# For now it just simply goes in a straight line
	var move_dir = global_position.direction_to(swim_target)
	velocity = move_dir * speed * delta
	look_at(swim_target, Vector3.UP)
	move_and_slide()
	
	if global_position.distance_to(swim_target) <= 0.5: swimming = false
	return swimming

func _on_timer_timout():
	print("Timer Ended!")

func _physics_process(delta):
	match state:
		STATE.IDLE:
			var is_swimming: bool = true
			
			if timer.is_stopped():
				# |Swim to a random spot within an area|
				is_swimming = swim_to_target(new_swim_target, delta)
				
				# |If bait is near by, move to INVESTIGATE|
				for body in bait_check_area.get_overlapping_bodies():
					if body.is_in_group("Hook"):
						state = STATE.INVESTIGATE
			
			if is_swimming == false:
				# |Wait a random amount of time|
				timer.start(randf_range(4, idle_time))
				new_swim_target = get_rand_point(roam_range) + global_position
				print("New Position = ", new_swim_target)

		STATE.INVESTIGATE:
			# |Swim near the bait and wait a random amount of time until nibbling|
			
			# |Nibble a random amount of times|
			
			# |If the bait is still near by, is in biting range and another fish is not biting it, bite down and transition to HOOKED|
			
			# |If the bait is still near by but isn't in biting range, repeat INVESTIGATE|
			
			# |If the bait is not near by, resume IDLE|
			pass
		STATE.HOOKED:
			# |Swim away until fatigue reaches zero|
			
			# |Stop swimming and recover fatigue for a while|
			
			# |Repeat until caught or line snaps|
			
			# |If line is snapped maybe swim to a safe area?|
			
			# |If caught go into caught animation|
			pass
