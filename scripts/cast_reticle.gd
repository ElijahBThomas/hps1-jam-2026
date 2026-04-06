extends Node3D

@onready var raycast = find_child("floor_raycast")
@onready var mesh = find_child("MeshInstance3D")

func follow_floor():
	var floor = raycast.get_collision_point()
	if(floor):
		position.y = floor.y + .5 * mesh.mesh.height

func _physics_process(delta):
	follow_floor()
