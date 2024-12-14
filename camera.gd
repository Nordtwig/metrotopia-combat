extends Marker3D


@export var pan_speed: float = 1.5


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("pan_left", "pan_right", "pan_forward", "pan_backward")
	
	var direction: Vector3 = (%Camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var pan_velocity:= Vector3.ZERO
	pan_velocity.z = direction.z * pan_speed
	pan_velocity.x = direction.x * pan_speed

	global_position += pan_velocity