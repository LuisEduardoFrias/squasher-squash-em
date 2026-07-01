class_name Wall extends StaticBody2D


func _ready() -> void:
	pass # Replace with function body.


func _on_get_coin_body_entered(body: Node2D) -> void:
	if body is Coin:
		Global.coins += body.value
		body.queue_free()


func hurt(damage: float) -> void:
	Global.player_live -= damage
