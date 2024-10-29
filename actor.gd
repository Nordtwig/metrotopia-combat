extends CharacterBody3D


@export var _movement_speed: float = 4.0
@export var _bullet_scene: PackedScene

var _target: Node3D = null

@onready var nav_agent: NavigationAgent3D = get_node("NavigationAgent3D")


func _ready() -> void:
	print("Actor spawned")
	nav_agent.velocity_computed.connect(_on_velocity_computed)


func _physics_process(delta: float) -> void:
	if _target:
		print(_target.position)
		_face_target(delta)
		
	if nav_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * _movement_speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

	


func _face_target(delta: float) -> void:
	var position_2d: Vector2 = Vector2(global_position.x, global_position.z)
	var target_position_2d: Vector2 = Vector2(_target.global_position.x, _target.global_position.z)
	var direction_to_face = -(position_2d - target_position_2d)
	rotation.y = lerp_angle(rotation.y, atan2(direction_to_face.x, direction_to_face.y), delta / 0.5)


func set_movement_target(_target_position: Vector3) -> void:
	nav_agent.target_position = _target_position


func set_target(_target_node: Node3D) -> void:
	_target = _target_node


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()
