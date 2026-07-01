extends Node2D

@onready var live: ProgressBar = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer/Panel/live
@onready var l_live: Label = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer/Panel/l_live
@onready var expe: ProgressBar = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer2/Panel/exp
@onready var l_exp: Label = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer2/Panel/l_exp
@onready var coins: Label = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer3/coins
@onready var resource: Label = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer4/resours
@onready var l_level: Label = %label_level
@onready var l_level2: Label = %label_level2
@onready var l_ph: Label = %label_ph
@onready var l_ph2: Label = %label_ph2
@onready var store_item_contained: VBoxContainer = %store_item_container
@export var store_item: PackedScene
@export var skills_item: PackedScene


func _ready() -> void:
	live.max_value = Global.player_max_live
	l_live.text = "LIVE: %s %%" % Global.player_max_live
	expe.max_value = Global.player_max_exp
	l_exp.text = "EXP: %s %%" % Global.player_max_exp

	live.value = Global.player_live
	expe.value = Global.player_exp
	coins.text = str(Global.coins)
	resource.text = str(Global.resource)
	#l_level.text = str(Global.player_level)
	#l_level2.text = str(Global.player_level)
	#l_ph.text = str(Global.player_ph)
	#l_ph2.text = str(Global.player_ph)

	#_show_store_item()

	$CanvasLayer/SubViewportContainer/SubViewport.gui_disable_input = false
	$CanvasLayer/SubViewportContainer/SubViewport.handle_input_locally = true


func _process(_delta: float) -> void:
	live.value = Global.player_live
	l_live.text = "LIVE: %s %%" % round(Global.player_live / 5.0)
	expe.value = Global.player_exp
	l_exp.text = "EXP: %s %%" % round(Global.player_exp / 5.0)
	coins.text = str(Global.coins)
	resource.text = str(Global.resource)

	#l_level.text = str(Global.player_level)
	#l_level2.text = str(Global.player_level)
	#l_ph.text = str(Global.player_ph)
	#l_ph2.text = str(Global.player_ph)


func _input(event: InputEvent) -> void:
	%SubViewport.push_input(event)


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

		store_item_contained.add_child(sti)
