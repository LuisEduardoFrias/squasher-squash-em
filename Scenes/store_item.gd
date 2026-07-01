class_name StoreItem extends Panel

signal buy
signal update

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
		item_coin_buy = val
		$coint_buy.text = str(val)
@export var item_resource_buy: int = 5:
	set(val):
		item_resource_buy = val
		$resource_buy.text = str(val)
@export var item_lv: int = 1:
	set(val):
		item_lv = val
		$lv.text = "LV: %d" % val
@export var item_lv_required: int = 3:
	set(val):
		item_lv_required = val

@export var item_ph_required: int = 1:
	set(val):
		item_ph_required = val

@export var item_coin_update: int = 20:
	set(val):
		item_coin_update = val
		$coint_update.text = str(val)
@export var item_resource_update: int = 15:
	set(val):
		item_resource_update = val
		$resource_update.text = str(val)
@export var item: String:
	set(val):
		item = val


func _ready() -> void:
	$image.texture = $image.texture.duplicate()


func _on_btn_buy_pressed() -> void: buy.emit()

func _on_btn_updaye_pressed() -> void: update.emit()


func _on_btn_buy_mouse_entered() -> void:
	Mouse.chance(Mouse.Mousers.POINT_OUT)


func _on_btn_buy_mouse_exited() -> void:
	Mouse.chance(Mouse.Mousers.RESET)
