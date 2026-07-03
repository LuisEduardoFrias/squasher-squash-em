extends CharacterBody2D

@export var speed: float = 200.0
var enemic_position: Vector2 = Vector2.INF
var direction: Vector2 = Vector2.INF

@export var damage: float = 1.0

func _ready() -> void:
	if enemic_position != Vector2.INF:
		direction = position.direction_to(enemic_position)


func _physics_process(_delta: float) -> void:
		velocity = direction * speed
		move_and_slide()


func _on_hit_body_entered(body: Node2D) -> void:
	if body is Enemic:
		body.hurt(damage)
		queue_free()
