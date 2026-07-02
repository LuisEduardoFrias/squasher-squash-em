extends Node2D

var enemic: PackedScene = load("res://Scenes/Enemies/enemic_base.tscn")

@export var area: Area2D
@export var wall: Wall

var is_creating_enemies: bool = false
var create_enemic_time: float = 0.9
var point: Dictionary = {}


func _ready() -> void:
	randomize()
	var collision: CollisionShape2D = area.get_child(0)
	point.set("point1", global_position.y - (collision.shape.size.y / 2))
	point.set("point2", global_position.y + collision.shape.size.y/2)


func _process(_delta: float) -> void:
	if not is_creating_enemies:
		create_enemic()


func create_enemic() -> void:
	is_creating_enemies = true

	var enem: Enemic = enemic.instantiate()
	var enemics = Enemic.type_to_level()

	enem.wall = wall

	enem.initial(enemics[enemic_index()])
	enem.global_position.y = randi_range(point.point1, point.point2)
	enem.global_position.x = global_position.x
	get_parent().add_child(enem)

	await get_tree().create_timer(create_enemic_time).timeout
	create_enemic_time = randf_range(0.3, 0.8)
	is_creating_enemies = false


func enemic_index() -> int:
	return randi() % 3


func paused(on: bool ) -> void:
	set_process(!on)
