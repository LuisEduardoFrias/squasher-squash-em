class_name Enemic extends CharacterBody2D

@export var wall: Wall
@export var live: float = 25.0
@export var category: int = 1
@export var type_enemic: Type_enemic = Type_enemic.ENEMIC_1
@export var damage: float = 15.0
@export var exp_: float = 10
@export var speed: float = 15.0
@export var item_provability: float = 0.4
@export var item_bettwen_provability: float = 0.6


enum State { WALL, ATTACK }
enum Type_enemic { ENEMIC_1, ENEMIC_2, ENEMIC_3, ENEMIC_4 }

var state: State = State.WALL

var is_destroyed: bool = false
var enemic = null
var is_attacking: bool = false
var is_hurt: bool = false

@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var coli: CollisionShape2D = $CollisionShape2D
@onready var mouse_coli: CollisionShape2D = $mouse_hurt/CollisionShape2D


func _ready() -> void:
	anim.play(enemic_str(type_enemic) + "_move")


func _physics_process(_delta: float) -> void:
	if state == State.WALL:
		velocity = Vector2(-1.0, 0.0) * speed
		move_and_slide()
	elif state == State.ATTACK:
		if not is_attacking:
			execute_attack_cycle()


func execute_attack_cycle() -> void:
	is_attacking = true
	anim.play(enemic_str(type_enemic) + "_attack")

	if enemic and enemic.has_method("hurt"):
		if not enemic.is_destroyed:

			enemic.hurt(damage)

	await get_tree().create_timer(1.0).timeout
	is_attacking = false



## Método que hace que el Player sea intermitente por un periodo de tiempo
func intermittency(duration: float = 1.0, callback: Callable = Callable()) -> void:
	var tw: Tween = create_tween().set_loops()

	tw.tween_property(self, "modulate:a", 0.0, 0.1)
	tw.tween_property(self, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(duration).timeout

	tw.kill()
	modulate.a = 1.0
	if callback.is_valid(): callback.call_deferred()


func enemic_str(type_: Type_enemic) -> String:
	return Type_enemic.keys()[type_].to_lower()


'''
func _input(event: InputEvent) -> void:
		var mouse_pos = get_global_mouse_position()

		var rect_size = coli.shape.size
		var zona_interactiva = Rect2(coli.global_position - rect_size / 2, rect_size)

		if zona_interactiva.has_point(mouse_pos):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					var size: Vector2 = coli.shape.size
					var vect1: Vector2 = Vector2(global_position.x - (size.x / 2), global_position.y - (size.y / 2))
					var vect2: Vector2 = Vector2(global_position.x + (size.x / 2), global_position.y + (size.y / 2))

					if (event.position.x > vect1.x and event.position.x < vect2.x) and (event.position.y > vect1.y and event.position.y < vect2.y) and not is_hurt:
						is_hurt = true
						Mouse.chance(Mouse.Mousers.PURGE)
						intermittency()

						live -= 1

						if live <= 0:
							set_physics_process(false)
							anim.play(enemic_str(type_enemic) + "_dead")
							await anim.animation_finished

							if item_provability <= randf():
								var coin: Coin = (load("res://Scenes/coint.tscn") as PackedScene).instantiate()
								var index = 1 if randf() >= 0.6 else 0
								coin.index_to_type(index)
								coin.wall = wall
								coin.global_position = global_position
								get_parent().add_child(coin)

							Global.player_exp += exp_
							Mouse.chance(Mouse.Mousers.RESET)

							queue_free()
						else:
							is_hurt = false'''

func arrow_hurt() -> void:
	var rect_size = mouse_coli.shape.size
	var zona_interactiva = Rect2(mouse_coli.global_position - rect_size / 2, rect_size)
	var mouse_pos = Vector2()

	if zona_interactiva.has_point(mouse_pos):
		pass


func hurt_(damage_:float) -> void:
	is_hurt = true
	intermittency()
	live -= damage_

	if live <= 0:
		is_destroyed = true
		set_physics_process(false)
		anim.play(enemic_str(type_enemic) + "_dead")
		await anim.animation_finished

		if item_provability <= randf():
			get_parent().add_child(get_drop_item())

		Global.player_exp += exp_

	await get_tree().create_timer(0.2).timeout
	is_hurt = false


func hurt(damage_:float) -> void:
	hurt_(damage_)

	if live <= 0:
		queue_free()


func _input(event: InputEvent) -> void:
	if is_hurt:
		return

	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		var radio = mouse_coli.shape.radius
		var centro_circulo = mouse_coli.global_position
		var mouse_pos = get_global_mouse_position()

		if centro_circulo.distance_to(mouse_pos) <= radio:

			print(event)
			Mouse.chance(Mouse.Mousers.PURGE)
			await get_tree().create_timer(0.2).timeout
			hurt_(25.0)
			Mouse.chance(Mouse.Mousers.RESET)

			if live <= 0:
				queue_free()


func get_drop_item() -> Node2D:
	var ps: PackedScene
	var range_index: int = 0

	if item_bettwen_provability <= randf():
		ps = load("res://Scenes/coint.tscn")
		range_index = randi_range(0, 4)
	else:
		ps = load("res://Scenes/resource.tscn")
		range_index = randi_range(0, 8)

	#range_index = 1 if randf() >= 0.6 else 0
	var drop_item: ItemDrop = ps.instantiate()
	drop_item.index_to_type(range_index)
	drop_item.wall = wall
	drop_item.global_position = global_position
	return drop_item


func _on_hit_body_entered(body: Node2D) -> void:
	if body is Wall or body is Item:
		if body.is_attacable:
			enemic = body
			state = State.ATTACK


func _on_hit_body_exited(body: Node2D) -> void:
	if body is Wall or body is Item:
		enemic = null
		state = State.WALL


func initial(props: Dictionary) -> void:
	live = props.live
	category = props.category
	type_enemic = props.type_enemic
	scale = Vector2(props.scale, props.scale)
	damage = props.damage
	exp_ = props.exp_
	speed = props.speed



static func type_to_level() -> Array[Dictionary]:
	return [
		{
		"level": 1,
		"category": 1,
		"live": 25.0,
		"type_enemic": Type_enemic.ENEMIC_1,
		"scale": 1.0,
		"item_provability": 0.4,
		"damage": 15.0,
		"exp_": 10,
		"speed": 15.0,
		},{
		"level": 1,
		"category": 1,
		"live": 25.0,
		"type_enemic": Type_enemic.ENEMIC_2,
		"scale": 1.0,
		"item_provability": 0.4,
		"damage": 18.0,
		"exp_": 13,
		"speed": 20.0,
		},{
		"level": 1,
		"category": 2,
		"live": 50.0,
		"type_enemic": Type_enemic.ENEMIC_4,
		"scale": 1.2,
		"item_provability": 0.4,
		"damage": 18.0,
		"exp_": 13,
		"speed": 20.0,
		},{
		"level": 1,
		"category": 8,
		"live": 50.0,
		"type_enemic": Type_enemic.ENEMIC_3,
		"scale": 1.0,
		"item_provability": 0.4,
		"damage": 25.0,
		"exp_": 20,
		"speed": 30.0,
		}
	]
