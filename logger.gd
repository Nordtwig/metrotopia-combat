extends Node

var mute_logs: bool = false


func log(message: String) -> void:
	if mute_logs:
		return
	print(message)