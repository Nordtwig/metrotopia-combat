extends CharacterBody3D
class_name Actor


enum FACTION  {
	PLAYER,
	MERC,
	CORP,
	GOV,
}

enum STATE {
	ALIVE,
	DEAD
}

@export var _movement_speed: float = 4.0
@export var _bullet_scene: PackedScene
@export var actor_faction: FACTION
@export var actor_state: STATE = STATE.ALIVE
@export var uniform_material: Material

var _target: Node3D = null
var _is_ready_to_shoot: bool = true

@onready var nav_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var muzzle_marker: Marker3D = get_node("Rifle/MuzzleMarker")
@onready var muzzle_raycast: RayCast3D = get_node("Rifle/RayCast3D")
@onready var gun_cycle_timer: Timer = get_node("Rifle/GunCycleTimer")
@onready var anim_tree: AnimationTree = get_node("AnimationTree")
@onready var hitbox_component: HitboxComponent = get_node("HitboxComponent")
@onready var model_mesh: MeshInstance3D = get_node("Model2/Armature/Skeleton3D/Cube")


func _ready() -> void:
	Logger.log("Actor spawned")
	# TODO Implement Faction Data Object and Materials Object
	# %Model/MeshInstance3D.mesh.material = 

	
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	gun_cycle_timer.timeout.connect(_on_gun_cycle_timer_timeout)
	nav_agent.navigation_finished.connect(_on_navigation_finished)
	Events.actor_died.connect(_on_actor_died)
	Events.clickable_clicked.connect(_on_clickable_clicked)

	model_mesh.material_override = uniform_material

	match actor_state:
		STATE.ALIVE:
			gun_cycle_timer.start()
		STATE.DEAD:
			_target = null
			_is_ready_to_shoot = false
			gun_cycle_timer.stop()
		

func _process(_delta):
	if actor_state == STATE.DEAD:
		return

	if _is_ready_to_shoot and _check_if_facing_target():
		_shoot()


func _physics_process(delta: float) -> void:
	if actor_state == STATE.DEAD:
		return

	if _target:
		_face_target(delta)
	else:
		var position_2d: Vector2 = Vector2(global_position.x, global_position.z)
		var target_position_2d: Vector2 = Vector2(nav_agent.get_next_path_position().x, nav_agent.get_next_path_position().z)
		var direction_to_face = -(position_2d - target_position_2d)
		rotation.y = lerp_angle(rotation.y, atan2(direction_to_face.x, direction_to_face.y), delta / 0.15)
	
	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / _movement_speed)

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


func get_rotation_to_target() -> Vector2:
	var position_2d: Vector2 = Vector2(global_position.x, global_position.z)
	var target_position_2d: Vector2 = Vector2(_target.global_position.x, _target.global_position.z)
	return -(position_2d - target_position_2d)


func _check_if_facing_target() -> bool:
	if _target == null:
		return false

	if muzzle_raycast.is_colliding() and muzzle_raycast.get_collider() == _target:
		Logger.log("Aiming at target")
		return true
	
	return false


func _shoot() -> void:
	var bullet_instance = _bullet_scene.instantiate()
	bullet_instance.rotation = muzzle_marker.global_rotation
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle_marker.global_position
	_is_ready_to_shoot = false
	gun_cycle_timer.start()


func _die() -> void:
	if actor_state != STATE.DEAD:
		actor_state = STATE.DEAD
		Events.actor_died.emit(self)
		velocity = Vector3.ZERO
		$Rifle.visible = false
		hitbox_component.is_disabled = true
		for child in hitbox_component.get_children():
			if child is CollisionShape3D:
				child.disabled = true


func _set_selected_indicator(setting: bool)  -> void:
	$SelectedIndicator.visible = setting


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_gun_cycle_timer_timeout() -> void:
	_is_ready_to_shoot = true


func _on_actor_died(actor: Actor)  -> void:
	if _target == actor:
		_target = null


func _on_clickable_clicked(node: Node3D) -> void:
	if !node.is_in_group("actors"):
		_set_selected_indicator(false)
		return
	
	if node != self:
		return

	if actor_faction != FACTION.PLAYER:
		return

	_set_selected_indicator(true)
	Events.playable_actor_selected.emit(self)


func _on_navigation_finished() -> void:
	velocity = Vector3.ZERO