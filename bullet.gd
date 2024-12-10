extends RigidBody3D


func _ready():
	apply_impulse(global_transform.basis.z * 30, global_position)
	
