extends CanvasLayer

enum Mousers { RESET, GRAB, PURGE, POINT_OUT, OKEY, FIST }

@onready var area_point_cursor: Area2D = $Area2D
@onready var anim = $Area2D/icon/AnimationPlayer


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	var screen_center = get_viewport().size / 2.0
	area_point_cursor.global_position = screen_center


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventScreenDrag or event is InputEventScreenTouch:
		area_point_cursor.global_position = event.position

	# Si es un toque (pulsación), lo consumimos para que no se duplique abajo
	#if event is InputEventScreenTouch:
		#get_viewport().set_input_as_handled()


func chance(index: Mousers = Mousers.RESET) -> void:
	match index:
		0: anim.play(&"RESET")
		1: anim.play(&"aga")
		2: anim.play(&"pull")
		3: anim.play(&"señ")
		4: anim.play(&"ok")
		5: anim.play(&"puñ")
