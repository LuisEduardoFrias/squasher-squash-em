extends Item

var arrow: PackedScene = load("res://Scenes/arrow.tscn")

func _ready() -> void:
	super()


func attack() -> void:
	$AnimatedSprite2D.play(&"attack")

	is_attacking = true

	for enem in enemics:
		if enem and enem.has_method("hurt"):
			if not enem.is_destroyed:
				var instanciate = arrow.instantiate()
				instanciate.enemic_position = enem.global_position
				instanciate.damage = 9.0
				instanciate.position = (global_position + Vector2(0.0, -36.0))
				get_parent().get_parent().add_child(instanciate)
				break

	await get_tree().create_timer(1.5).timeout
	is_attacking = false
