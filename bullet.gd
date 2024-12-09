extends RigidBody3D


func _ready():
	apply_impulse(-global_transform.basis.y * 25, global_position)

