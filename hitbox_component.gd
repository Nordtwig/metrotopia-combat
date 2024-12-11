extends Area3D
class_name HitboxComponent


@export var health_component: HealthComponent


func take_damage(attack) -> void:
	if !health_component:
		return
	
	health_component.take_damage(attack)
