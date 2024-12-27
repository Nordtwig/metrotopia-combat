extends RigidBody3D


@export var hitscan_component: Area3D


func _ready():
	hitscan_component.area_entered.connect(_on_hitscan_component_area_entered)
	apply_impulse(global_transform.basis.z * 30, global_position)
	await  get_tree().create_timer(5.0).timeout
	queue_free()
	

func _on_hitscan_component_area_entered(area)  -> void:
	if area is HitboxComponent and !area.is_disabled:
		
		var hitbox: HitboxComponent = area
		var attack = Attack.new()
		attack.attack_damage = 5.0
		attack.attack_position = hitscan_component.global_position

		hitbox.take_damage(attack)

		queue_free()
