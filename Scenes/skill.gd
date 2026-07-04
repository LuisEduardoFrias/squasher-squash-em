class_name SkillItem extends Panel

signal update

@onready var btn: TextureButton = $update
@onready var img: TextureRect = $img

@export var skill_img: Rect2 = Rect2(168.0, 261.0, 36.0, 38.0):
	set(val):
		skill_img = val
		$img.texture.region = skill_img
@export var skill_name: String = "Name":
	set(val):
		skill_name = val
		$name.text = skill_name
@export var skill_ph_required: int = 0:
	set(val):
		skill_ph_required = val
		$ph_required.text = "Ph: %s" % str(skill_ph_required)
@export var skill_lv_required: int = 0:
	set(val):
		skill_lv_required = val
		$lv_required.text = "Lv: %s" % str(skill_lv_required)
@export var skill_coin_required: int = 0:
	set(val):
		skill_coin_required = val
		$coin.text = str(skill_coin_required)
@export var skill_resource_required: int = 0:
	set(val):
		skill_resource_required = val
		$resource.text = str(skill_resource_required)
@export var skill_lv: int = 0:
	set(val):
		skill_lv = val
		$lv.text = "Lv: %s" % str(skill_lv)


func _ready() -> void:
	img.texture = img.texture.duplicate()
	'''skill_img =Rect2(132.0, 261.0, 36.0, 38.0)
	skill_name = "Push"
	skill_ph_required = 5
	skill_lv_required = 3
	skill_coin_required = 150
	skill_resource_required = 30
	skill_lv = 2'''


func _on_update_pressed() -> void:
	Global.coins -= skill_coin_required
	Global.resource -= skill_resource_required
	Global.player_ph -= skill_ph_required
	skill_lv += 1
	update.emit()


func _process(_delta: float) -> void:
	if Global.player_level >= skill_lv_required and \
	Global.coins >= skill_coin_required and \
	Global.resource >= skill_resource_required and \
	Global.player_ph >= skill_ph_required :
		btn.disabled = false
	else:
		btn.disabled = true
