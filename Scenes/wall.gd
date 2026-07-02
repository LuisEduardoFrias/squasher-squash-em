class_name Wall extends StaticBody2D

var is_destroyed: bool = false

# puede funcional para una habilidad, dónde no recibe daño por x cantidad de tiempo
@export var is_attacable: bool = true


func _ready() -> void:
	pass # Replace with function body.


func _on_get_coin_body_entered(body: Node2D) -> void:
	if body is ItemDrop:
		if body is Coin:
			Global.coins += body.value
		elif body is Resources:
			Global.resource += body.value
		body.queue_free()


func hurt(damage: float) -> void:
	if Global.player_live > 0:
		Global.player_live -= damage

		if Global.player_live <= 0 and is_destroyed == false:
			is_destroyed = true
			$CollisionShape2D.queue_free()
