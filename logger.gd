extends Node


var mute_logs: bool = true


func log(message: String) -> void:
	if mute_logs:
		return
	print(message)