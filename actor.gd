extends CharacterBody3D


@export var _movement_speed: float = 4.0

@onready var nav_agent: NavigationAgent3D = get_node("NavigationAgent3D")


func _ready() -> void:
	print("Actor spawned")
	nav_agent.velocity_computed.connect(_on_velocity_computed)


func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * _movement_speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)


func set_movement_target(_target_position: Vector3) -> void:
	nav_agent.target_position = _target_position


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()