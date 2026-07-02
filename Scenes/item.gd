class_name Item extends StaticBody2D

@onready var progres: ProgressBar = $ProgressBar
@onready var col: CollisionShape2D = $CollisionShape2D


@export var is_attacable: bool = true
@export var damage: float = 12.5
@export var attacks: bool = true
@export var max_live: float = 100.0:
	set(val):
		max_live = val
		if not is_node_ready(): await ready
		progres.max_value = val
@export var live: float = 100.0:
	set(val):
		live = val
		if not is_node_ready(): await ready
		progres.value = val
		if val <= 0:
			destroyed()

var move: bool = true
var is_destroyed: bool = false
var time: float = 0.0
var enemics: Array[Enemic] = []
var is_attacking: bool = false

func _ready() -> void:
	progres.modulate.a = 0.0
	if not attacks: $hit.queue_free()


func _process(delta: float) -> void:
	if move:
		Mouse.chance(Mouse.Mousers.GRAB)
		global_position = (Mouse.area_point_cursor.global_position/2) - Vector2(19.0, 5.0)
	if not is_destroyed and progres.modulate.a == 1.0:
		time += delta

		if time == 1.0:
			var tw: Tween = create_tween()
			tw.tween_property(progres, "modulate:a", 0.0, 1.0)
			time = 0.0

	if enemics.size() > 0:
		if not is_attacking:
			attack()


func attack() -> void:
	$AnimatedSprite2D.play(&"attack")

	is_attacking = true

	for enem in enemics:
		if enem and enem.has_method("hurt"):
			if not enem.is_destroyed:
				enem.hurt(damage)

	await get_tree().create_timer(1.0).timeout
	is_attacking = false


func _on_texture_button_pressed() -> void:
	move = false
	Mouse.chance(Mouse.Mousers.RESET)
	global_position = global_position + Vector2(12.0, 12.0)
	$item_control.queue_free()


func destroyed() -> void:
	is_destroyed = true
	col.queue_free()
	progres.queue_free()
	enemics = []
	if $hit:
		$hit.queue_free()
	$AnimatedSprite2D.play(&"destroyed")


func hurt(damage_:float) -> void:
	live -= damage_
	time = 0.0
	if progres.modulate.a == 0.0:
		var tw: Tween = create_tween()
		tw.tween_property(progres, "modulate:a", 1.0, 1.0)


func _on_hit_body_entered(body: Node2D) -> void:
	if body is Enemic:
		enemics.append(body)


func _on_hit_body_exited(body: Node2D) -> void:
	if body is Enemic:
		var index = enemics.find(body)
		if index >= 0: enemics.remove_at(index)
