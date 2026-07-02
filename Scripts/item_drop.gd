class_name ItemDrop extends CharacterBody2D

var value: float = 0.0
const MAX_SPEED = 800.0
var current_speed = 0.0
var acceleration = 400.0

@export var wall: Wall
@export var time: float = 0.5
@export var value_cost: float = 3.0


func _ready() -> void:
	set_physics_process(false)
	await get_tree().create_timer(time).timeout
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if is_instance_valid(wall):
		var direction = global_position.direction_to(wall.global_position)
		current_speed = move_toward(current_speed, MAX_SPEED, acceleration * delta)
		velocity = direction * current_speed
		move_and_slide()
