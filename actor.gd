extends CharacterBody3D
class_name Actor


enum FACTION  {
	PLAYER,
	MERC,
	CORP,
	GOV,
}

@export var _movement_speed: float = 4.0
@export var _bullet_scene: PackedScene
@export var actor_faction: FACTION

var _target: Node3D = null
var _is_aiming_at_target: bool = false
var _is_ready_to_shoot: bool = true

@onready var nav_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var muzzle_marker: Marker3D = get_node("Rifle/MuzzleMarker")
@onready var muzzle_raycast: RayCast3D = get_node("Rifle/RayCast3D")
@onready var gun_cycle_timer: Timer = get_node("Rifle/GunCycleTimer")


func _ready() -> void:
	Logger.log("Actor spawned")
	# TODO Implement Faction Data Object and Materials Object
	# %Model/MeshInstance3D.mesh.material = 
	
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	gun_cycle_timer.timeout.connect(_on_gun_cycle_timer_timeout)


func _process(_delta):
	if _is_ready_to_shoot and _is_aiming_at_target:
		_shoot()


func _physics_process(delta: float) -> void:
	if _target:
		_face_target(delta)
	
	if !_is_aiming_at_target and _check_if_facing_target():
		_is_aiming_at_target = true

	if nav_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * _movement_speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)


func _face_target(delta: float) -> void:
	var direction_to_face = get_rotation_to_target()
	rotation.y = lerp_angle(rotation.y, atan2(direction_to_face.x, direction_to_face.y), delta / 0.15)


func set_movement_target(_target_position: Vector3) -> void:
	nav_agent.target_position = _target_position


func set_target(_target_node: Node3D) -> void:
	if _target != _target_node:
		_target = _target_node
		_is_aiming_at_target = false


func get_rotation_to_target() -> Vector2:
	var position_2d: Vector2 = Vector2(global_position.x, global_position.z)
	var target_position_2d: Vector2 = Vector2(_target.global_position.x, _target.global_position.z)
	return -(position_2d - target_position_2d)


func _check_if_facing_target() -> bool:
	if _target == null:
		return false

	if muzzle_raycast.is_colliding() and muzzle_raycast.get_collider() == _target:
		print("Aiming at target")
		return true
	
	return false


func _shoot() -> void:
	var bullet_instance = _bullet_scene.instantiate()
	bullet_instance.rotation = muzzle_marker.global_rotation
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle_marker.global_position
	_is_ready_to_shoot = false
	gun_cycle_timer.start()


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_gun_cycle_timer_timeout() -> void:
	_is_ready_to_shoot = true
