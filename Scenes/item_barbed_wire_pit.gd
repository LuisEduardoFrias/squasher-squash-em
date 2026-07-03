extends Item

@export var reduced_life: float = 15


func attack() -> void:
	is_attacking = true

	for enem in enemics:
		if enem and enem.has_method("hurt"):
			if not enem.is_destroyed:
				live -= reduced_life
				enem.hurt(damage)

	await get_tree().create_timer(1.5).timeout
	is_attacking = false
