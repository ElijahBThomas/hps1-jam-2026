extends SpringArm3D

@onready var character = get_parent().find_child("MeshInstance3D")

func _physics_process(delta):
	rotation = character.rotation
