extends Node2D

@onready var live: ProgressBar = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer/Panel/live
@onready var l_live: Label = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer/Panel/l_live
@onready var expe: ProgressBar = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer2/Panel/exp
@onready var l_exp: Label = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer2/Panel/l_exp
@onready var coins: Label = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer3/coins
@onready var resource: Label = $CanvasLayer2/Panel/MarginContainer/Panel/HBoxContainer/HBoxContainer4/resours

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

	$CanvasLayer/SubViewportContainer/SubViewport2.gui_disable_input = false
	$CanvasLayer/SubViewportContainer/SubViewport2.handle_input_locally = true


func _process(_delta: float) -> void:
	live.value = Global.player_live
	l_live.text = "LIVE: %s %%" % round(Global.player_live / 5.0)
	expe.value = Global.player_exp
	l_exp.text = "EXP: %s %%" % round(Global.player_exp / 5.0)
	coins.text = str(Global.coins)
	resource.text = str(Global.resource)
