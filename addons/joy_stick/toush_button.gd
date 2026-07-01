'''
@tool
class_name TouchButton
extends TextureButton

# --- CONFIGURACIÓN DE ATLAS (Spritesheet) ---
@export_group("Spritesheet Texture")
## La textura principal que contiene todos los botones (spritesheet).
@export var spritesheet: Texture2D:
	set(value):
		spritesheet = value
		_update_textures()

@export_subgroup("Normal Region")
## Región (X, Y, Ancho, Alto) para el estado normal del botón.
@export var normal_rect: Rect2i = Rect2i(0, 0, 64, 64):
	set(value):
		normal_rect = value
		_update_textures()

@export_subgroup("Pressed Region")
## Región (X, Y, Ancho, Alto) para el estado presionado del botón.
@export var pressed_rect: Rect2i = Rect2i(0, 0, 64, 64):
	set(value):
		pressed_rect = value
		_update_textures()


# --- CONFIGURACIÓN DE ACCIÓN (Estilo TouchScreenButton) ---
# Variable manejada dinámicamente en el inspector por _get_property_list()
var action: StringName = &""


# --- MECÁNICA: AUTO-REPEAT (Presión Constante) ---
@export_group("Auto Repeat")
## Si está activo, el botón enviará la acción constantemente mientras se mantenga presionado.
@export var auto_repeat: bool = false
## Tiempo en segundos entre cada pulso cuando 'auto_repeat' está activo. Evitar usar 0 o menos.
@export var repeat_delay: float = 0.05


# --- MECÁNICA: VIBRACIÓN HÁPTICA (Feedback de Consola) ---
@export_group("Haptic Feedback")
## Duración de la vibración en milisegundos al tocar el botón. (15 ms es un click físico ideal).
## Si se establece en 0, la vibración estará desactivada.
@export var vibration_duration_ms: int = 15


# --- SEÑALES PERSONALIZADAS ---
## Se emite en cada pulso de presión. Pasa la intensidad del toque (0.0 a 1.0).
signal touch_pressed(pressure: float)
## Se emite cuando se suelta el botón.
signal touch_released


# --- VARIABLES INTERNAS ---
var _is_pressing: bool = false
var _current_touch_index: int = -1
var _repeat_timer: float = 0.0
var _current_pressure: float = 1.0


func _ready() -> void:
	_update_textures()
	if not Engine.is_editor_hint():
		set_process(false)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not _is_pressing:
		set_process(false)
		return

	if auto_repeat:
		_repeat_timer += delta
		if _repeat_timer >= repeat_delay:
			_repeat_timer = 0.0
			_trigger_action_press()


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventScreenTouch:
		if event.pressed and _current_touch_index == -1:
			if get_local_mouse_position().x >= 0 and get_local_mouse_position().x <= size.x \
			and get_local_mouse_position().y >= 0 and get_local_mouse_position().y <= size.y:
				_press_button(event.index)

		elif not event.pressed and event.index == _current_touch_index:
			_release_button()

	elif event is InputEventScreenDrag:
		if event.index == _current_touch_index:
			_current_pressure = event.pressure

			if not Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position()):
				_release_button()


func _press_button(touch_index: int) -> void:
	_is_pressing = true
	_current_touch_index = touch_index
	_repeat_timer = 0.0
	_current_pressure = 1.0

	button_pressed = true

	if vibration_duration_ms > 0 and not Engine.is_editor_hint():
		Input.vibrate_handheld(vibration_duration_ms)

	_trigger_action_press()

	if auto_repeat:
		set_process(true)


func _release_button() -> void:
	if not _is_pressing:
		return

	_is_pressing = false
	_current_touch_index = -1
	button_pressed = false
	set_process(false)

	_trigger_action_release()
	touch_released.emit()


func _trigger_action_press() -> void:
	if not action.is_empty():
		var ev:= InputEventAction.new()
		ev.action = action
		ev.pressed = true
		ev.strength = _current_pressure
		Input.parse_input_event(ev)

	touch_pressed.emit(_current_pressure)


func _trigger_action_release() -> void:
	if not action.is_empty():
		var ev:= InputEventAction.new()
		ev.action = action
		ev.pressed = false
		Input.parse_input_event(ev)


func _exit_tree() -> void:
	if not Engine.is_editor_hint() and _is_pressing:
		_trigger_action_release()


# --- LÓGICA DE RECORTE AUTOMÁTICO (AtlasTexture) ---
func _update_textures() -> void:
	if not spritesheet:
		texture_normal = null
		texture_pressed = null
		return

	if not texture_normal is AtlasTexture:
		texture_normal = AtlasTexture.new()
	texture_normal.atlas = spritesheet
	texture_normal.region = normal_rect

	if not texture_pressed is AtlasTexture:
		texture_pressed = AtlasTexture.new()
	texture_pressed.atlas = spritesheet
	texture_pressed.region = pressed_rect


# --- LÓGICA DE INSPECTOR DINÁMICO (Filtro por caracteres) ---

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	var hint_string: String = ""

	# CRÍTICO: Obliga al InputMap en el editor a recargar
	# las acciones personalizadas desde los Ajustes del Proyecto.
	InputMap.load_from_project_settings()

	# Ahora sí, obtenemos todas las acciones en memoria
	var all_actions:= InputMap.get_actions()

	for act in all_actions:
		var act_string: String = str(act)

		# Filtro inteligente: Eliminamos la basura del editor que usa '/'
		if not act_string.contains("/"):
			hint_string += act_string + ","

	# Quitamos la última coma
	hint_string = hint_string.rstrip(",")

	# Creamos el encabezado de grupo
	properties.append({
		"name": "Input Action",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP
	})

	# Dibujamos la propiedad 'action' como un menú desplegable
	properties.append({
		"name": "action",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": hint_string,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	return properties
'''

@tool
class_name TouchButton
extends TextureButton

# --- CONFIGURACIÓN DE ATLAS (Spritesheet) ---
@export_group("Spritesheet Texture")
## La textura principal que contiene todos los botones (spritesheet).
@export var spritesheet: Texture2D:
	set(value):
		spritesheet = value
		_update_textures()

@export_subgroup("Normal Region")
## Región (X, Y, Ancho, Alto) para el estado normal del botón.
@export var normal_rect: Rect2i = Rect2i(0, 0, 64, 64):
	set(value):
		normal_rect = value
		_update_textures()

@export_subgroup("Pressed Region")
## Región (X, Y, Ancho, Alto) para el estado presionado del botón.
@export var pressed_rect: Rect2i = Rect2i(0, 0, 64, 64):
	set(value):
		pressed_rect = value
		_update_textures()


# --- CONFIGURACIÓN DE ACCIÓN (Estilo TouchScreenButton) ---
# Variable manejada dinámicamente en el inspector por _get_property_list()
var action: StringName = &""


# --- MECÁNICA: AUTO-REPEAT (Presión Constante) ---
@export_group("Auto Repeat")
## Si está activo, el botón enviará la acción constantemente mientras se mantenga presionado.
@export var auto_repeat: bool = false
## Tiempo en segundos entre cada pulso cuando 'auto_repeat' está activo. Evitar usar 0 o menos.
@export var repeat_delay: float = 0.05


# --- MECÁNICA: VIBRACIÓN HÁPTICA (Feedback de Consola) ---
@export_group("Haptic Feedback")
## Duración de la vibración en milisegundos al tocar el botón. (15 ms es un click físico ideal).
## Si se establece en 0, la vibración estará desactivada.
@export var vibration_duration_ms: int = 15


# --- SEÑALES PERSONALIZADAS ---
## Se emite en cada pulso de presión. Pasa la intensidad del toque (0.0 a 1.0).
signal touch_pressed(pressure: float)
## Se emite cuando se suelta el botón.
signal touch_released


# --- VARIABLES INTERNAS ---
var _is_pressing: bool = false
var _current_touch_index: int = -1
var _repeat_timer: float = 0.0
var _current_pressure: float = 1.0


func _ready() -> void:
	_update_textures()
	if not Engine.is_editor_hint():
		set_process(false)
		# Apagamos por completo el comportamiento de interfaz de escritorio
		focus_mode = FOCUS_NONE
		mouse_filter = MOUSE_FILTER_IGNORE


# =========================================================================
# CONTROL DE INTERCEPCIÓN ABSOLUTO (Usa _input y rectángulos globales)
# =========================================================================
func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventScreenTouch:
		# Si se detecta un nuevo dedo y este botón no está ocupado trackeando otro
		if event.pressed and _current_touch_index == -1:
			# Comprobamos si las coordenadas de la pantalla (globales) están dentro del botón
			if get_global_rect().has_point(event.position):
				_press_button(event.index)
				get_viewport().set_input_as_handled()

		# Si el dedo que se levanta es el que tenía asignado este botón
		elif not event.pressed and event.index == _current_touch_index:
			_release_button()
			get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag:
		if event.index == _current_touch_index:
			_current_pressure = event.pressure

			# Si arrastran el dedo fuera del botón global, lo soltamos automáticamente
			if not get_global_rect().has_point(event.position):
				_release_button()
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not _is_pressing:
		set_process(false)
		return

	if auto_repeat:
		_repeat_timer += delta
		if _repeat_timer >= repeat_delay:
			_repeat_timer = 0.0
			_trigger_action_press()


func _press_button(touch_index: int) -> void:
	_is_pressing = true
	_current_touch_index = touch_index
	_repeat_timer = 0.0
	_current_pressure = 1.0

	button_pressed = true

	# -----------------------------------------------------------------
	# CAMBIO VISUAL INMEDIATO: Forzamos al Atlas a recortar la zona presionada
	# -----------------------------------------------------------------
	if texture_normal is AtlasTexture:
		texture_normal.region = pressed_rect
	# -----------------------------------------------------------------

	if vibration_duration_ms > 0 and not Engine.is_editor_hint():
		Input.vibrate_handheld(vibration_duration_ms)

	_trigger_action_press()

	if auto_repeat:
		set_process(true)


func _release_button() -> void:
	if not _is_pressing:
		return

	_is_pressing = false
	_current_touch_index = -1
	button_pressed = false
	set_process(false)

	# -----------------------------------------------------------------
	# RESTAURACIÓN VISUAL INMEDIATA: Volvemos al recorte de la región normal
	# -----------------------------------------------------------------
	if texture_normal is AtlasTexture:
		texture_normal.region = normal_rect
	# -----------------------------------------------------------------

	_trigger_action_release()
	touch_released.emit()


# --- LÓGICA DE RECORTE AUTOMÁTICO (Modificada para consistencia) ---
func _update_textures() -> void:
	if not spritesheet:
		texture_normal = null
		texture_pressed = null
		return

	if not texture_normal is AtlasTexture:
		texture_normal = AtlasTexture.new()
		texture_normal.atlas = spritesheet

	# Si estás presionando dejamos la pressed, si no, la normal
	texture_normal.region = pressed_rect if _is_pressing else normal_rect

	# Mantenemos esto por si acaso usas texture_pressed en otra parte del editor
	if not texture_pressed is AtlasTexture:
		texture_pressed = AtlasTexture.new()
		texture_pressed.atlas = spritesheet
	texture_pressed.region = pressed_rect



func _trigger_action_press() -> void:
	if not action.is_empty():
		var ev:= InputEventAction.new()
		ev.action = action
		ev.pressed = true
		ev.strength = _current_pressure
		Input.parse_input_event(ev)

	touch_pressed.emit(_current_pressure)


func _trigger_action_release() -> void:
	if not action.is_empty():
		var ev:= InputEventAction.new()
		ev.action = action
		ev.pressed = false
		Input.parse_input_event(ev)


func _exit_tree() -> void:
	if not Engine.is_editor_hint() and _is_pressing:
		_trigger_action_release()


# --- LÓGICA DE INSPECTOR DINÁMICO (Filtro por caracteres) ---
func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	var hint_string: String = ""

	InputMap.load_from_project_settings()
	var all_actions:= InputMap.get_actions()

	for act in all_actions:
		var act_string: String = str(act)
		if not act_string.contains("/"):
			hint_string += act_string + ","

	hint_string = hint_string.rstrip(",")

	properties.append({
		"name": "Input Action",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP
	})

	properties.append({
		"name": "action",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": hint_string,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	return properties
