extends Node

signal clickable_clicked(node: Node3D)
signal actor_died(actor: Actor)


func _ready() -> void:
	clickable_clicked.connect(_on_clickable_clicked)


func _on_clickable_clicked(node: Node3D) -> void:
	Logger.log(node.name + " clicked")