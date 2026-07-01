'''@tool class_name JoyStick extends Control

#region Enumerators
## Enumerador que define las 8 direcciones posibles más el estado neutral.
enum DirectionState {
	NONE,
	UP,
	UP_RIGHT,
	RIGHT,
	DOWN_RIGHT,
	DOWN,
	DOWN_LEFT,
	LEFT,
	UP_LEFT
}
#endregion

#region Inspector Properties: Base Configuration
@export_category("Base Configuration")
## Define si el vector de dirección de salida tendrá siempre una magnitud máxima de 1.0.
## Si es falso, el valor escalará progresivamente de 0.0 a 1.0 según la posición de la palanca.
@export var is_normalized: bool = true

## Activa la restricción del movimiento del joystick a direcciones fijas basadas en el umbral.
@export var use_threshold: bool = false

## Si está activo, el umbral bloqueará el movimiento a 8 direcciones (incluyendo diagonales).
## Si es falso, se limitará estrictamente a las 4 direcciones cardinales básicas.
@export var allow_diagonals: bool = false

## Porcentaje de distancia máxima a partir del cual el umbral comenzará a forzar las direcciones.
@export_range(0.0, 1.0) var threshold: float = 0.4

## Distancia mínima requerida desde el centro del joystick para empezar a registrar movimiento.
@export_range(0.0, 0.5) var deadzone: float = 0.08
#endregion

#region Inspector Properties: Dynamic & Opacity
@export_category("Dynamic & Opacity Behavior")
## Determina si el joystick es flotante y se posiciona dinámicamente en el lugar del toque inicial.
@export var is_dynamic: bool = false

## Activa el retorno interpolado y suave de la palanca hacia el centro cuando se deja de tocar.
@export var smooth_return: bool = true

## Grado de opacidad transparente que tendrá el componente cuando no se encuentre activo.
@export_range(0.0, 1.0) var idle_opacity: float = 0.4:
	set(val):
		idle_opacity = val
		if not is_inside_tree(): await self.ready
		if index == -1: modulate.a = idle_opacity
#endregion

#region Inspector Properties: Mode & Textures
@export_category("Mode Selection")
## Si es verdadero, el componente funcionará como una cruceta dinámica cambiando texturas.
## Si es falso, funcionará como un joystick analógico tradicional con palanca móvil.
@export var is_dpad_mode: bool = false:
	set(val):
		is_dpad_mode = val
		if not is_node_ready(): await ready
		_setup_mode_visuals()

@export_category("Joystick Textures")
## Imagen única para el joystick (rango/palanca) y las direcciones del dpad en formato atlas grid.
@export var joystick_dpad_texture: Texture2D:
	set(val):
		joystick_dpad_texture = val
		if not is_node_ready(): await ready
		_initialize_base_atlas()
#endregion

#region Visual Node References
@export_category("Visual References")
@onready var range_bg: TextureRect = $panel/range
@onready var handle: TextureRect = $panel/handle
@onready var cover: TextureRect = $analog_stick_cover
#endregion

#region Private Variables
var frame_size: Vector2i = Vector2i(256, 256)

# Texturas estáticas cacheadas para el comportamiento del Joystick analógico
var range_texture: AtlasTexture
var handle_texture: AtlasTexture
var cover_texture: AtlasTexture

# Textura Atlas dinámica que mutará su región de recorte única y exclusivamente en Modo D-Pad
var dpad_dynamic_atlas: AtlasTexture

var direction: Vector2 = Vector2.ZERO
var index: int = -1
var radius: float = 0.0
var local_center: Vector2 = Vector2.ZERO
var static_initial_position: Vector2
var current_direction_state: DirectionState = DirectionState.NONE
#endregion

#region Lifecycle Methods
## Configura las dimensiones iniciales, la opacidad base y los recursos visuales del modo seleccionado.
func _ready() -> void:
	await get_tree().process_frame

	if range_bg and range_bg.texture:
		radius = range_bg.size.x / 2.5
	else:
		radius = 50.0

	local_center = size / 2.0
	static_initial_position = global_position

	modulate.a = idle_opacity
	_initialize_base_atlas()
	_setup_mode_visuals()
	_reset_handle()
#endregion

#region Media & Visual Setup Logic
## Instancia de forma única y persistente en memoria las estructuras Atlas de la hoja de sprites.
func _initialize_base_atlas() -> void:
	if not joystick_dpad_texture: return

	# Inicializa los recortes fijos del Joystick analógico para que nunca se corrompan
	range_texture = AtlasTexture.new()
	range_texture.atlas = joystick_dpad_texture
	range_texture.region = Rect2i(Vector2i(1, 2) * frame_size, frame_size)

	handle_texture = AtlasTexture.new()
	handle_texture.atlas = joystick_dpad_texture
	handle_texture.region = Rect2i(Vector2i(2, 2) * frame_size, frame_size)

	cover_texture = AtlasTexture.new()
	cover_texture.atlas = joystick_dpad_texture
	cover_texture.region = Rect2i(Vector2i(3, 2) * frame_size, frame_size)

	# Inicializa la instancia dinámica que usará la cruceta
	dpad_dynamic_atlas = AtlasTexture.new()
	dpad_dynamic_atlas.atlas = joystick_dpad_texture
	dpad_dynamic_atlas.region = Rect2i(Vector2i(0, 0) * frame_size, frame_size)


## Inicializa y alterna los estados visuales y texturas entre el modo Joystick y el modo Cruceta.
func _setup_mode_visuals() -> void:
	if not range_bg or not handle or not joystick_dpad_texture: return

	if not dpad_dynamic_atlas:
		_initialize_base_atlas()

	if is_dpad_mode:
		handle.visible = false
		handle.texture = null
		cover.visible = false
		cover.texture = null
		current_direction_state = DirectionState.NONE
		dpad_dynamic_atlas.region = Rect2i(Vector2i(0, 0) * frame_size, frame_size)
		range_bg.texture = dpad_dynamic_atlas
	else:
		handle.visible = true
		cover.visible = true
		range_bg.texture = range_texture
		handle.texture = handle_texture
		cover.texture = cover_texture
		_reset_handle()
#endregion

#region Input Handling
## Captura y procesa los eventos táctiles y de arrastre dentro del espacio del contenedor UI.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed() and index == -1:
			index = event.index
			modulate.a = 1.0

			if is_dynamic:
				global_position = static_initial_position + event.position - (size / 2.0)

			var distance: float = local_center.distance_to(event.position)
			_calculate_movement(event.position, distance)

		elif event.index == index:
			_end_touch()

	if event is InputEventScreenDrag:
		if event.index == index:
			var distance: float = local_center.distance_to(event.position)
			_calculate_movement(event.position, distance)
#endregion

#region Movement & Math Calculation
## Administra la restricción visual de la palanca y delega el cálculo matemático del vector de salida.
func _calculate_movement(touch_position_local: Vector2, distance: float) -> void:
	var half_handle: Vector2 = handle.size / 2.0
	var distance_percentage: float = distance / radius

	if distance_percentage < deadzone:
		handle.position = touch_position_local - half_handle
		cover.position = touch_position_local - half_handle
		direction = Vector2.ZERO
		if is_dpad_mode:
			_update_dpad_texture(DirectionState.NONE)
		return

	var raw_direction: Vector2 = local_center.direction_to(touch_position_local)
	if distance <= radius:
		handle.position = touch_position_local - half_handle
		cover.position = touch_position_local - half_handle
	else:
		handle.position = local_center + (raw_direction * radius) - half_handle
		cover.position = local_center + (raw_direction * radius) - half_handle

	if use_threshold:
		_apply_threshold(raw_direction, distance_percentage)
	else:
		if is_normalized:
			direction = raw_direction
		else:
			direction = raw_direction * clampf(distance_percentage, 0.0, 1.0)

		if is_dpad_mode:
			_update_dpad_directional_state(raw_direction)


## Procesa la dirección bajo los parámetros del umbral, evaluando si restringe a 4 o a 8 caminos.
func _apply_threshold(raw_direction: Vector2, distance_percentage: float) -> void:
	if distance_percentage > threshold:
		if allow_diagonals:
			var angle: float = raw_direction.angle()
			var octant: int = roundi(angle / (PI / 4.0))

			match octant:
				0:
					direction = Vector2.RIGHT
					if is_dpad_mode: _update_dpad_texture(DirectionState.RIGHT)
				1:
					direction = Vector2(1.0, 1.0).normalized() if is_normalized else Vector2(1.0, 1.0)
					if is_dpad_mode: _update_dpad_texture(DirectionState.DOWN_RIGHT)
				2:
					direction = Vector2.DOWN
					if is_dpad_mode: _update_dpad_texture(DirectionState.DOWN)
				3:
					direction = Vector2(-1.0, 1.0).normalized() if is_normalized else Vector2(-1.0, 1.0)
					if is_dpad_mode: _update_dpad_texture(DirectionState.DOWN_LEFT)
				4, -4:
					direction = Vector2.LEFT
					if is_dpad_mode: _update_dpad_texture(DirectionState.LEFT)
				-3:
					direction = Vector2(-1.0, -1.0).normalized() if is_normalized else Vector2(-1.0, -1.0)
					if is_dpad_mode: _update_dpad_texture(DirectionState.UP_LEFT)
				-2:
					direction = Vector2.UP
					if is_dpad_mode: _update_dpad_texture(DirectionState.UP)
				-1:
					direction = Vector2(1.0, -1.0).normalized() if is_normalized else Vector2(1.0, -1.0)
					if is_dpad_mode: _update_dpad_texture(DirectionState.UP_RIGHT)
		else:
			if abs(raw_direction.x) > abs(raw_direction.y):
				direction = Vector2(sign(raw_direction.x), 0.0)
				if is_dpad_mode: _update_dpad_texture(DirectionState.RIGHT if direction.x > 0 else DirectionState.LEFT)
			else:
				direction = Vector2(0.0, sign(raw_direction.y))
				if is_dpad_mode: _update_dpad_texture(DirectionState.DOWN if direction.y > 0 else DirectionState.UP)
	else:
		direction = Vector2.ZERO
		if is_dpad_mode: _update_dpad_texture(DirectionState.NONE)
#endregion

#region D-Pad System Logic
## Evalúa la dirección analógica pura para determinar cuál textura de cruceta corresponde en modos sin umbral fijo.
func _update_dpad_directional_state(raw_direction: Vector2) -> void:
	var angle: float = raw_direction.angle()
	var octant: int = roundi(angle / (PI / 4.0))

	match octant:
		0: _update_dpad_texture(DirectionState.RIGHT)
		1: _update_dpad_texture(DirectionState.DOWN_RIGHT)
		2: _update_dpad_texture(DirectionState.DOWN)
		3: _update_dpad_texture(DirectionState.DOWN_LEFT)
		4, -4: _update_dpad_texture(DirectionState.LEFT)
		-3: _update_dpad_texture(DirectionState.UP_LEFT)
		-2: _update_dpad_texture(DirectionState.UP)
		-1: _update_dpad_texture(DirectionState.UP_RIGHT)


## Cambia la región del contenedor Atlas únicamente si está el modo D-Pad activo sin reconstruir texturas.
func _update_dpad_texture(state: DirectionState) -> void:
	if not is_dpad_mode or current_direction_state == state or not dpad_dynamic_atlas: return
	current_direction_state = state

	var coords: Vector2i = Vector2i.ZERO

	match current_direction_state:
		DirectionState.NONE:       coords = Vector2i(0, 0)
		DirectionState.UP:         coords = Vector2i(1, 0)
		DirectionState.UP_RIGHT:   coords = Vector2i(2, 0)
		DirectionState.RIGHT:      coords = Vector2i(3, 0)
		DirectionState.DOWN_RIGHT: coords = Vector2i(0, 1)
		DirectionState.DOWN:       coords = Vector2i(1, 1)
		DirectionState.DOWN_LEFT:  coords = Vector2i(2, 1)
		DirectionState.LEFT:       coords = Vector2i(3, 1)
		DirectionState.UP_LEFT:    coords = Vector2i(0, 2)

	dpad_dynamic_atlas.region = Rect2i(coords * frame_size, frame_size)
#endregion

#region Touch Release & Cleanup
## Concluye el ciclo de entrada táctil, restablece los vectores y maneja la transición de retorno visual.
func _end_touch() -> void:
	index = -1
	direction = Vector2.ZERO
	modulate.a = idle_opacity

	if is_dpad_mode:
		_update_dpad_texture(DirectionState.NONE)

	if is_dynamic:
		global_position = static_initial_position

	if smooth_return and not is_dpad_mode:
		var tween: Tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).set_parallel()
		tween.tween_property(handle, "position", local_center - (handle.size / 2.0), 0.15)
		tween.tween_property(cover, "position", local_center - (cover.size / 2.0), 0.15)

	else:
		_reset_handle()


## Restablece de forma inmediata la posición de la palanca al centro geométrico exacto del control.
func _reset_handle() -> void:
	if handle:
		handle.position = local_center - (handle.size / 2.0)
		cover.position = local_center - (cover.size / 2.0)
#endregion
'''

@tool
class_name JoyStick
extends Control

#region Enumerators
## Enumerador que define las 8 direcciones posibles más el estado neutral.
enum DirectionState {
	NONE,
	UP,
	UP_RIGHT,
	RIGHT,
	DOWN_RIGHT,
	DOWN,
	DOWN_LEFT,
	LEFT,
	UP_LEFT
}
#endregion

#region Inspector Properties: Base Configuration
@export_category("Base Configuration")
## Define si el vector de dirección de salida tendrá siempre una magnitud máxima de 1.0.
## Si es falso, el valor escalará progresivamente de 0.0 a 1.0 según la posición de la palanca.
@export var is_normalized: bool = true

## Activa la restricción del movimiento del joystick a direcciones fijas basadas en el umbral.
@export var use_threshold: bool = false

## Si está activo, el umbral bloqueará el movimiento a 8 direcciones (incluyendo diagonales).
## Si es falso, se limitará estrictamente a las 4 direcciones cardinales básicas.
@export var allow_diagonals: bool = false

## Porcentaje de distancia máxima a partir del cual el umbral comenzará a forzar las direcciones.
@export_range(0.0, 1.0) var threshold: float = 0.4

## Distancia mínima requerida desde el centro del joystick para empezar a registrar movimiento.
@export_range(0.0, 0.5) var deadzone: float = 0.08
#endregion

#region Inspector Properties: Input Mapping (Agnóstico)
@export_category("Input Actions Mapping")
## Acción asociada al movimiento hacia la Izquierda.
@export var action_left: StringName = &"ui_left"
## Acción asociada al movimiento hacia la Derecha.
@export var action_right: StringName = &"ui_right"
## Acción asociada al movimiento hacia Arriba.
@export var action_up: StringName = &"ui_up"
## Acción asociada al movimiento hacia Abajo.
@export var action_down: StringName = &"ui_down"
#endregion

#region Inspector Properties: Haptic Feedback
@export_category("Haptic Feedback")
## Si está activo, el dispositivo vibrará al cambiar de dirección (Exclusivo de Modo D-Pad).
@export var dpad_vibration: bool = false
## Duración de la vibración en milisegundos cuando cambia de dirección en modo D-Pad.
@export var vibration_duration_ms: int = 15
#endregion

#region Inspector Properties: Dynamic & Opacity
@export_category("Dynamic & Opacity Behavior")
## Determina si el joystick es flotante y se posiciona dinámicamente en el lugar del toque inicial.
@export var is_dynamic: bool = false

## Activa el retorno interpolado y suave de la palanca hacia el centro cuando se deja de tocar.
@export var smooth_return: bool = true

## Grado de opacidad transparente que tendrá el componente cuando no se encuentre activo.
@export_range(0.0, 1.0) var idle_opacity: float = 0.4:
	set(val):
		idle_opacity = val
		if not is_inside_tree(): await self.ready
		if index == -1: modulate.a = idle_opacity
#endregion

#region Inspector Properties: Mode & Textures
@export_category("Mode Selection")
## Si es verdadero, el componente funcionará como una cruceta dinámica cambiando texturas.
## Si es falso, funcionará como un joystick analógico tradicional con palanca móvil.
@export var is_dpad_mode: bool = false:
	set(val):
		is_dpad_mode = val
		if not is_node_ready(): await ready
		_setup_mode_visuals()

@export_category("Joystick Textures")
## Imagen única para el joystick (rango/palanca) y las direcciones del dpad en formato atlas grid.
@export var joystick_dpad_texture: Texture2D:
	set(val):
		joystick_dpad_texture = val
		if not is_node_ready(): await ready
		_initialize_base_atlas()
#endregion

#region Visual Node References
@export_category("Visual References")
@onready var range_bg: TextureRect = $panel/range
@onready var handle: TextureRect = $panel/handle
@onready var cover: TextureRect = $analog_stick_cover
#endregion

#region Private Variables
var frame_size: Vector2i = Vector2i(256, 256)

# Texturas estáticas cacheadas para el comportamiento del Joystick analógico
var range_texture: AtlasTexture
var handle_texture: AtlasTexture
var cover_texture: AtlasTexture

# Textura Atlas dinámica que mutará su región de recorte única y exclusivamente en Modo D-Pad
var dpad_dynamic_atlas: AtlasTexture

var direction: Vector2 = Vector2.ZERO
var index: int = -1
var radius: float = 0.0
var local_center: Vector2 = Vector2.ZERO
var static_initial_position: Vector2
var current_direction_state: DirectionState = DirectionState.NONE

# Cache de los estados de presión de acciones para evitar parseos redundantes
var _current_press_states: Dictionary = {
	"left": 0.0,
	"right": 0.0,
	"up": 0.0,
	"down": 0.0
}
#endregion

#region Lifecycle Methods
func _ready() -> void:
	await get_tree().process_frame

	if range_bg and range_bg.texture:
		radius = range_bg.size.x / 2.5
	else:
		radius = 50.0

	local_center = size / 2.0
	static_initial_position = global_position

	modulate.a = idle_opacity
	_initialize_base_atlas()
	_setup_mode_visuals()
	_reset_handle()
#endregion

#region Media & Visual Setup Logic
func _initialize_base_atlas() -> void:
	if not joystick_dpad_texture: return

	range_texture = AtlasTexture.new()
	range_texture.atlas = joystick_dpad_texture
	range_texture.region = Rect2i(Vector2i(1, 2) * frame_size, frame_size)

	handle_texture = AtlasTexture.new()
	handle_texture.atlas = joystick_dpad_texture
	handle_texture.region = Rect2i(Vector2i(2, 2) * frame_size, frame_size)

	cover_texture = AtlasTexture.new()
	cover_texture.atlas = joystick_dpad_texture
	cover_texture.region = Rect2i(Vector2i(3, 2) * frame_size, frame_size)

	dpad_dynamic_atlas = AtlasTexture.new()
	dpad_dynamic_atlas.atlas = joystick_dpad_texture
	dpad_dynamic_atlas.region = Rect2i(Vector2i(0, 0) * frame_size, frame_size)


func _setup_mode_visuals() -> void:
	if not range_bg or not handle or not joystick_dpad_texture: return

	if not dpad_dynamic_atlas:
		_initialize_base_atlas()

	if is_dpad_mode:
		handle.visible = false
		handle.texture = null
		cover.visible = false
		cover.texture = null
		current_direction_state = DirectionState.NONE
		dpad_dynamic_atlas.region = Rect2i(Vector2i(0, 0) * frame_size, frame_size)
		range_bg.texture = dpad_dynamic_atlas
	else:
		handle.visible = true
		cover.visible = true
		range_bg.texture = range_texture
		handle.texture = handle_texture
		cover.texture = cover_texture
		_reset_handle()
#endregion

#region Input Handling
'''
func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return

	if event is InputEventScreenTouch:
		if event.is_pressed() and index == -1:
			index = event.index
			modulate.a = 1.0

			if is_dynamic:
				global_position = static_initial_position + event.position - (size / 2.0)

			var distance: float = local_center.distance_to(event.position)
			_calculate_movement(event.position, distance)

		elif event.index == index:
			_end_touch()

	if event is InputEventScreenDrag:
		if event.index == index:
			var distance: float = local_center.distance_to(event.position)
			_calculate_movement(event.position, distance)
'''

#region Input Handling

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return

	if event is InputEventScreenTouch:
		if event.is_pressed() and index == -1:
			# Usamos global_rect para verificar el toque sin importar los contenedores intermedios
			if get_global_rect().has_point(event.position):
				index = event.index
				modulate.a = 1.0

				# Convertimos la posición global del toque a local para el joystick
				var local_pos = event.position - global_position
				if is_dynamic:
					global_position = static_initial_position + event.position - (size / 2.0)
					local_pos = size / 2.0

				var distance: float = local_center.distance_to(local_pos)
				_calculate_movement(local_pos, distance)
				get_viewport().set_input_as_handled()

		elif event.index == index and not event.is_pressed():
			_end_touch()
			get_viewport().set_input_as_handled()

	if event is InputEventScreenDrag:
		if event.index == index:
			var local_pos = event.position - global_position
			var distance: float = local_center.distance_to(local_pos)
			_calculate_movement(local_pos, distance)
			get_viewport().set_input_as_handled()

#endregion



#endregion

#region Movement & Math Calculation
func _calculate_movement(touch_position_local: Vector2, distance: float) -> void:
	var half_handle: Vector2 = handle.size / 2.0
	var distance_percentage: float = distance / radius

	if distance_percentage < deadzone:
		handle.position = touch_position_local - half_handle
		cover.position = touch_position_local - half_handle
		direction = Vector2.ZERO
		_parse_virtual_input(direction)
		if is_dpad_mode:
			_update_dpad_texture(DirectionState.NONE)
		return

	var raw_direction: Vector2 = local_center.direction_to(touch_position_local)
	if distance <= radius:
		handle.position = touch_position_local - half_handle
		cover.position = touch_position_local - half_handle
	else:
		handle.position = local_center + (raw_direction * radius) - half_handle
		cover.position = local_center + (raw_direction * radius) - half_handle

	if use_threshold:
		_apply_threshold(raw_direction, distance_percentage)
	else:
		if is_normalized:
			direction = raw_direction
		else:
			direction = raw_direction * clampf(distance_percentage, 0.0, 1.0)

		_parse_virtual_input(direction)
		if is_dpad_mode:
			_update_dpad_directional_state(raw_direction)


func _apply_threshold(raw_direction: Vector2, distance_percentage: float) -> void:
	if distance_percentage > threshold:
		if allow_diagonals:
			var angle: float = raw_direction.angle()
			var octant: int = roundi(angle / (PI / 4.0))

			match octant:
				0:
					direction = Vector2.RIGHT
					if is_dpad_mode: _update_dpad_texture(DirectionState.RIGHT)
				1:
					direction = Vector2(1.0, 1.0).normalized() if is_normalized else Vector2(1.0, 1.0)
					if is_dpad_mode: _update_dpad_texture(DirectionState.DOWN_RIGHT)
				2:
					direction = Vector2.DOWN
					if is_dpad_mode: _update_dpad_texture(DirectionState.DOWN)
				3:
					direction = Vector2(-1.0, 1.0).normalized() if is_normalized else Vector2(-1.0, 1.0)
					if is_dpad_mode: _update_dpad_texture(DirectionState.DOWN_LEFT)
				4, -4:
					direction = Vector2.LEFT
					if is_dpad_mode: _update_dpad_texture(DirectionState.LEFT)
				-3:
					direction = Vector2(-1.0, -1.0).normalized() if is_normalized else Vector2(-1.0, -1.0)
					if is_dpad_mode: _update_dpad_texture(DirectionState.UP_LEFT)
				-2:
					direction = Vector2.UP
					if is_dpad_mode: _update_dpad_texture(DirectionState.UP)
				-1:
					direction = Vector2(1.0, -1.0).normalized() if is_normalized else Vector2(1.0, -1.0)
					if is_dpad_mode: _update_dpad_texture(DirectionState.UP_RIGHT)
		else:
			if abs(raw_direction.x) > abs(raw_direction.y):
				direction = Vector2(sign(raw_direction.x), 0.0)
				if is_dpad_mode: _update_dpad_texture(DirectionState.RIGHT if direction.x > 0 else DirectionState.LEFT)
			else:
				direction = Vector2(0.0, sign(raw_direction.y))
				if is_dpad_mode: _update_dpad_texture(DirectionState.DOWN if direction.y > 0 else DirectionState.UP)
	else:
		direction = Vector2.ZERO
		if is_dpad_mode: _update_dpad_texture(DirectionState.NONE)

	_parse_virtual_input(direction)
#endregion

#region D-Pad System Logic
func _update_dpad_directional_state(raw_direction: Vector2) -> void:
	var angle: float = raw_direction.angle()
	var octant: int = roundi(angle / (PI / 4.0))

	match octant:
		0: _update_dpad_texture(DirectionState.RIGHT)
		1: _update_dpad_texture(DirectionState.DOWN_RIGHT)
		2: _update_dpad_texture(DirectionState.DOWN)
		3: _update_dpad_texture(DirectionState.DOWN_LEFT)
		4, -4: _update_dpad_texture(DirectionState.LEFT)
		-3: _update_dpad_texture(DirectionState.UP_LEFT)
		-2: _update_dpad_texture(DirectionState.UP)
		-1: _update_dpad_texture(DirectionState.UP_RIGHT)


func _update_dpad_texture(state: DirectionState) -> void:
	if not is_dpad_mode or current_direction_state == state or not dpad_dynamic_atlas: return

	current_direction_state = state

	# --- GESTIÓN DE VIBRACIÓN EXCLUSIVA DE CRUCETA ---
	if dpad_vibration and vibration_duration_ms > 0 and state > 0 and not Engine.is_editor_hint():
		Input.vibrate_handheld(vibration_duration_ms)

	var coords: Vector2i = Vector2i.ZERO

	match current_direction_state:
		DirectionState.NONE:       coords = Vector2i(0, 0)
		DirectionState.UP:         coords = Vector2i(1, 0)
		DirectionState.UP_RIGHT:   coords = Vector2i(2, 0)
		DirectionState.RIGHT:      coords = Vector2i(3, 0)
		DirectionState.DOWN_RIGHT: coords = Vector2i(0, 1)
		DirectionState.DOWN:       coords = Vector2i(1, 1)
		DirectionState.DOWN_LEFT:  coords = Vector2i(2, 1)
		DirectionState.LEFT:       coords = Vector2i(3, 1)
		DirectionState.UP_LEFT:    coords = Vector2i(0, 2)

	dpad_dynamic_atlas.region = Rect2i(coords * frame_size, frame_size)
#endregion

#region Virtual Input Engine Mapping
## Traduce el vector de dirección en eventos nativos InputEventAction del InputMap de Godot.
func _parse_virtual_input(vector: Vector2) -> void:
	if Engine.is_editor_hint(): return

	# Calculamos la fuerza/intensidad para cada eje por separado
	var target_left: float = clampf(-vector.x, 0.0, 1.0)
	var target_right: float = clampf(vector.x, 0.0, 1.0)
	var target_up: float = clampf(-vector.y, 0.0, 1.0)
	var target_down: float = clampf(vector.y, 0.0, 1.0)

	_send_action_event(action_left, target_left, "left")
	_send_action_event(action_right, target_right, "right")
	_send_action_event(action_up, target_up, "up")
	_send_action_event(action_down, target_down, "down")


## Envía de forma optimizada el InputEventAction al motor de Godot solo si la fuerza cambió.
func _send_action_event(action_name: StringName, intensity: float, key_cache: String) -> void:
	if action_name.is_empty(): return

	# Si la intensidad actual es idéntica a la anterior, evitamos saturar el gestor de eventos
	if is_equal_approx(_current_press_states[key_cache], intensity): return

	_current_press_states[key_cache] = intensity

	var ev := InputEventAction.new()
	ev.action = action_name

	if intensity > 0.0:
		ev.pressed = true
		ev.strength = intensity
	else:
		ev.pressed = false
		ev.strength = 0.0

	Input.parse_input_event(ev)
#endregion

#region Touch Release & Cleanup
func _end_touch() -> void:
	index = -1
	direction = Vector2.ZERO
	modulate.a = idle_opacity

	_parse_virtual_input(direction)

	if is_dpad_mode:
		_update_dpad_texture(DirectionState.NONE)

	if is_dynamic:
		global_position = static_initial_position

	if smooth_return and not is_dpad_mode:
		var tween: Tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).set_parallel()
		tween.tween_property(handle, "position", local_center - (handle.size / 2.0), 0.15)
		tween.tween_property(cover, "position", local_center - (cover.size / 2.0), 0.15)
	else:
		_reset_handle()


func _reset_handle() -> void:
	if handle:
		handle.position = local_center - (handle.size / 2.0)
		cover.position = local_center - (cover.size / 2.0)


func _exit_tree() -> void:
	if not Engine.is_editor_hint() and index != -1:
		_parse_virtual_input(Vector2.ZERO)
#endregion
