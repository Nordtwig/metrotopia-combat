extends Node3D
class_name GameManager


@export var _camera: Camera3D
@export var _actors: Array[CharacterBody3D]
@export var _enemies: Array[CharacterBody3D]
@export var _indicator: MeshInstance3D
@export var _aim_indicator: MeshInstance3D


func _ready():
	Global.game_manager = self
	Events.playable_actor_selected.connect(_on_playable_actor_selected)
	for actor in _actors:
		actor._set_selected_indicator(true)
	# for enemy in _enemies:
	# 	enemy.set_target(_actor)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var origin: Vector3 = _camera.project_ray_origin(event.position)
		var direction: Vector3  = _camera.project_ray_normal(event.position)
		var end: Vector3 = origin + direction * 1000
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = origin
		ray_query.to = end
		ray_query.collide_with_areas = true

		var state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

		var intersection: Dictionary = state.intersect_ray(ray_query)
		if intersection.size() <= 0:
			return

		var target_position: Vector3 = intersection["position"] as Vector3
		
		if event.is_action_pressed("right_click"):
			if intersection.collider.is_in_group("ground"):
				for actor in _actors:
					actor.set_movement_target(target_position)
				_indicator.global_position = target_position
			elif intersection.collider.is_in_group("actors"):
				for actor in _actors:
					actor.set_target(intersection.collider)
				_aim_indicator.global_position = intersection.collider.global_position

		if event.is_action_pressed("left_click"):
			if intersection.collider.is_in_group("ground"):
				for actor in _actors:
					actor._set_selected_indicator(false)
					_actors.erase(actor)
			elif intersection.collider.is_in_group("actors"):
				if Input.is_action_pressed("shift_modifier"):
					Events.clickable_clicked.emit(intersection.collider)
				else:
					for actor in _actors:
						actor._set_selected_indicator(false)
				Events.clickable_clicked.emit(intersection.collider)
	if event.is_action_pressed("ui_accept"):
		print("toggling mute log")
		Logger.mute_logs = !Logger.mute_logs


func _on_playable_actor_selected(actor: Actor) -> void:
	_actors.append(actor)