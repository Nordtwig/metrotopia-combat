extends Area3D
class_name HitboxComponent


@export var health_component: HealthComponent

var is_disabled: bool = false


func take_damage(attack) -> void:
	if !health_component:
		return
	
	health_component.take_damage(attack)
