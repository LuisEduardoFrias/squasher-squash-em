class_name StoreItem extends Panel

signal buy(coint: float, resource: float, lv: int)
signal update(coint: float, resource: float, item_id: int)

@onready var btn_buy: TextureButton = $btn_buy
@onready var btn_update: TextureButton = $btn_update
@onready var lab_buy: Label = $btn_buy/Label
@onready var lab_update: Label = $btn_update/Label

@export var item_id: int
@export var item_img: Rect2 = Rect2(132.0, 223.0, 36.0, 38.0):
	set(val):
		item_img = val
		(($image as TextureRect).texture as AtlasTexture).region = val
@export var item_name: String = "Ítem Name":
	set(val):
		item_name = val
		$name.text = val
@export var item_coin_buy: int = 0:
	set(val):
		item_coin_buy = get_calculate_value(val)
		$coint_buy.text = str(item_coin_buy)
@export var item_resource_buy: int = 5:
	set(val):
		item_resource_buy = get_calculate_value(val)
		$resource_buy.text = str(item_resource_buy)
@export var item_lv: int = 0:
	set(val):
		item_lv = val
		$lv.text = "LV: %d" % val
@export var item_lv_required: int = 3:
	set(val):
		if item_lv == 0:
			item_lv_required = val * (item_lv + 1)
		else:
			item_lv_required = ceil(val * ((item_lv + 1) * 0.75))

@export var item_ph_required: int = 1:
	set(val):
		item_ph_required = val

@export var item_coin_update: int = 20:
	set(val):
		item_coin_update =  get_calculate_value(val)
		$coint_update.text = str(item_coin_update)
@export var item_resource_update: int = 15:
	set(val):
		item_resource_update =  get_calculate_value(val)
		$resource_update.text = str(item_resource_update)
@export var item: String:
	set(val):
		item = val


func _ready() -> void:
	$image.texture = $image.texture.duplicate()


func get_calculate_value(val: int) -> int:
	return roundi(item_lv * (val * 0.23)) + val


func level_up() -> void:
	item_lv += 1
	item_coin_buy = item_coin_buy
	item_resource_buy = item_resource_buy
	item_lv_required = item_lv_required
	item_coin_update = item_coin_update
	item_resource_update = item_resource_update


func _process(_delta: float) -> void:
	pass
	if Global.coins >= item_coin_buy and Global.resource >= item_resource_buy:
		btn_buy.disabled = false
	else:
		btn_buy.disabled = true

	if Global.coins >= item_coin_update and Global.resource >= item_resource_update and Global.player_level >= item_lv_required:
		btn_update.disabled = false
	else:
		btn_update.disabled = true


func _on_btn_buy_pressed() -> void: buy.emit(item_coin_buy, item_resource_buy, item_lv)

func _on_btn_updaye_pressed() -> void: update.emit(item_coin_update, item_resource_update, item_id)


func _on_btn_buy_mouse_entered() -> void:
	Mouse.chance(Mouse.Mousers.POINT_OUT)


func _on_btn_buy_mouse_exited() -> void:
	Mouse.chance(Mouse.Mousers.RESET)


func _on_btn_buy_draw() -> void:
	if not btn_buy.disabled:
		lab_buy.modulate.a = 1.0
	elif btn_buy.disabled:
		lab_buy.modulate.a = 0.5


func _on_btn_update_draw() -> void:
	if not btn_update.disabled:
		lab_update.modulate.a = 1.0
	elif btn_buy.disabled:
		lab_update.modulate.a = 0.5
