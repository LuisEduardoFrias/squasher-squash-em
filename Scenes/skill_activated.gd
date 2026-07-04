class_name SkillActivated
extends TextureRect

## Se emite cuando la habilidad se activa y comienza su tiempo de recarga.
signal activate

## La textura completa del Atlas (la hoja de sprites).
@export var atlas_completo: Texture2D
## La región específica (X, Y, Ancho, Alto) que ocupa este icono en el atlas.
@export var img: Rect2
## El tiempo total en segundos que durará la recarga de la habilidad.
@export var time_cooldown: float = 3.0

## Referencia al nodo del botón que activa la habilidad.
@onready var btn: BaseButton = $btn

var remaining_time: float = 0.0
var _en_cooldown: bool = false


func _ready() -> void:
	_inicializar_textura_recortada()
	_inicializar_shader()
	_conectar_boton()
	material = material.duplicate()


func _process(delta: float) -> void:
	if not _en_cooldown:
		return

	remaining_time -= delta

	if remaining_time <= 0.0:
		_finalizar_cooldown()
	else:
		_actualizar_progreso_shader()


func _inicializar_textura_recortada() -> void:
	if not atlas_completo:
		return

	var imagen_completa: Image = atlas_completo.get_image()
	var imagen_recortada: Image = imagen_completa.get_region(img)
	texture = ImageTexture.create_from_image(imagen_recortada)


func _inicializar_shader() -> void:
	if material:
		material.set_shader_parameter("progreso", 1.0)


func _conectar_boton() -> void:
	if btn:
		btn.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	if _en_cooldown:
		return

	_en_cooldown = true
	remaining_time = time_cooldown
	if btn:
		btn.disabled = true

	material.set_shader_parameter("progreso", 0.0)
	activate.emit()


func _actualizar_progreso_shader() -> void:
	var porcentaje_transcurrido: float = 1.0 - (remaining_time / time_cooldown)
	material.set_shader_parameter("progreso", porcentaje_transcurrido)


func _finalizar_cooldown() -> void:
	_en_cooldown = false
	remaining_time = 0.0
	if btn:
		btn.disabled = false
	material.set_shader_parameter("progreso", 1.0)
