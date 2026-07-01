extends Control

signal is_ready(is_mobile_platform: bool)

func _ready() -> void:
	var is_mobile_platform: bool = OS.get_name() in [&"Android", &"iOS"]
	visible = is_mobile_platform
	is_ready.emit(is_mobile_platform)
