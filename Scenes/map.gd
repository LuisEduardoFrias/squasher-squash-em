extends Node2D

@onready var col: CollisionShape2D = $area_click/CollisionShape2D
@onready var light: Sprite2D = $light
@onready var tab: TabContainer = %TabContainer
@onready var enemic_generator = $enemi_generator
@onready var btn_menu: TextureButton = $PanelContainer/MarginContainer/menu_btn
@export var store_item: PackedScene
@export var skills_item: PackedScene

var shape: Shape2D


func _ready() -> void:
	hidden_menu(0)
	_show_store_item()


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		var rect_size = col.shape.size
		var zona_interactiva = Rect2(col.global_position - rect_size / 2, rect_size)
		var mouse_pos = event.position

		if zona_interactiva.has_point(mouse_pos):
			hidden_menu()
			set_process_input(false)

		if event is InputEventScreenTouch:
			get_viewport().set_input_as_handled()


func _show_store_item() -> void:
	for i in Global.store:
		var sti: StoreItem = store_item.instantiate()
		sti.item_img = i.img
		sti.item_name = i.name
		sti.item_lv = i.lv

		sti.item_coin_buy = i.coins_pay
		sti.item_resource_buy = i.resource_pay

		sti.item_lv_required = i.lv_required
		sti.item_ph_required = i.ph_required
		sti.item_coin_update = i.coins_required
		sti.item_resource_update = i.resource_required

		sti.buy.connect(func () -> void:
			var item:PackedScene = load(i.item)
			var instanciate: Item = item.instantiate()
			$items.add_child(instanciate)
		)

		%store_item_container.add_child(sti)


func _on_texture_button_pressed() -> void:
	Mouse.chance(Mouse.Mousers.PURGE)

	var tw: Tween = create_tween()
	tw.tween_property(light, ^"modulate:a", 0.0, 1.0)
	tw.parallel().tween_property(btn_menu, ^"modulate:a", 0.0, 0.5)
	tw.parallel().tween_property(tab, ^"position:x", 0, 0.8)
	tw.tween_callback(func () -> void: enemic_generator.paused(true))
	set_process_input(true)


func _on_texture_button_button_up() -> void:
	Mouse.chance(Mouse.Mousers.RESET)


func hidden_menu(time: float = 0.8) -> void:
	var tw: Tween = create_tween()
	tw.tween_property(light, ^"modulate:a", 1.0, 1.0)
	tw.parallel().tween_property(tab, ^"position:x", -260, time)
	tw.chain().tween_property(btn_menu, ^"modulate:a", 1.0, 0.5)
	tw.tween_callback(func () -> void: enemic_generator.paused(false))
