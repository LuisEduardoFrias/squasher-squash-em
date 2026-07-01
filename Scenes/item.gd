class_name Item extends Node2D

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	Mouse.chance(Mouse.Mousers.GRAB)
	global_position = (Mouse.area_point_cursor.global_position/2) - Vector2(19.0, 5.0)
