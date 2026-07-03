extends Item

@export var deceleration: float = 5.0
@export var reduced_life: float = 15


func attack() -> void:
	is_attacking = true

	for enem in enemics:
		if enem and enem.has_method("hurt"):
			if not enem.is_destroyed:
				live -= reduced_life
				enem.speed -= deceleration
				enemics.remove_at(enemics.find(enem))

	await get_tree().create_timer(1.5).timeout
	is_attacking = false
