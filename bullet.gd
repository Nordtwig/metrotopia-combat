extends RigidBody3D


func _ready():
	apply_impulse(global_transform.basis.z * 30, global_position)
	await  get_tree().create_timer(5.0).timeout
	queue_free()
	
