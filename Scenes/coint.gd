class_name Coin extends CharacterBody2D

enum Type_coin { COIN_5, COIN_10, COIN_15, COIN_20, COIN_25 }

var type_coin: Type_coin = Type_coin.COIN_5
var value: int = 0
const MAX_SPEED = 800.0
var current_speed = 0.0
var acceleration = 400.0

@export var wall: Wall
@export var time: float = 0.5


func _ready() -> void:
	set_physics_process(false)
	$AnimatedSprite2D.play(Type_coin.keys()[type_coin].to_lower())
	value = 3 * type_coin
	await get_tree().create_timer(time).timeout
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if is_instance_valid(wall):
		var direction = global_position.direction_to(wall.global_position)
		current_speed = move_toward(current_speed, MAX_SPEED, acceleration * delta)
		velocity = direction * current_speed
		move_and_slide()


func index_to_type(index: int) -> void:
	type_coin = Coin.Type_coin[Coin.Type_coin.keys()[index]]
