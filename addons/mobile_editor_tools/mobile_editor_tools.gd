@tool
extends EditorPlugin

# RUTA: Ajusta si tu escena se llama diferente.
const PANEL_SCENE_PATH = "res://addons/mobile_editor_tools/MobileToolsPanel.tscn"

var panel_instance = null
var is_scroll_mode_active = false
var is_control_active: bool = false
var is_teclado_mode_active: bool = false

# --- Funciones de Ciclo de Vida del Plugin ---

# --- Funciones de Ciclo de Vida del Plugin ---

func _enter_tree():
	var panel_scene = load(PANEL_SCENE_PATH)
	if panel_scene:
		panel_instance = panel_scene.instantiate()
		
		# [ ... Tus conexiones de botones aquí ... ]
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer/Button_Tab").pressed.connect(_on_tab_pressed)
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer2/Button_Up").pressed.connect(_on_up_pressed)
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer3/Button_Down").pressed.connect(_on_down_pressed)
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer4/Button_Left").pressed.connect(_on_left_pressed)
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer5/Button_Right").pressed.connect(_on_right_pressed)
		'''
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer6/Button_teclado").pressed.connect(_on_teclado_pressed)
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer7/Button_control").pressed.connect(_on_control_pressed)'''
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer8/copy").pressed.connect(_on_copy_pressed)
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer9/paste").pressed.connect(_on_paste_pressed)
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer10/coment").pressed.connect(_on_coment_pressed)
		panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer11/move").pressed.connect(_on_move_pressed)                                            
		
		# --- CAMBIO CLAVE AQUÍ ---
		# Añade el panel a la barra de herramientas principal, junto a 2D/3D/Script
		# EditorPlugin.CONTAINER_TOOLBAR es la constante correcta.
		add_control_to_container(CONTAINER_TOOLBAR, panel_instance)

		# Ya NO necesitas el menú superior "Mobile Tools" ni la función _on_tool_menu_selected,
		# a menos que quieras que el usuario lo pueda ocultar desde ahí.
		# Lo comento por si acaso:
		# add_tool_menu_item("Mobile Tools", Callable(self, "_on_tool_menu_selected"))


func _exit_tree():
	if panel_instance:
		# Usa remove_control_from_container para limpiar
		remove_control_from_container(CONTAINER_TOOLBAR, panel_instance)
	# remove_tool_menu_item("Mobile Tools") # Si lo comentaste arriba, coméntalo aquí también

# --- Lógica de Inyección de Teclado ---

# En mobile_editor_tools.gd

# Función para obtener el Editor de Código activo
func _get_active_code_editor() -> ScriptEditor:
	# 1. Obtener la interfaz principal del editor
	var editor_interface = EditorInterface 
	
	# 2. Obtener el ScriptEditor, que es el panel completo del editor de código
	var script_editor = editor_interface.get_script_editor()
	if not script_editor:
		# No estamos en la pestaña de Script
		return null
		
	# 3. Obtener el CodeEdit activo
	# El ScriptEditor tiene un método para obtener la pestaña (tab) de código actual.
	var current_script_editor = script_editor.get_current_editor() #.get_current_script_editor()
	
	# La pestaña actual es un tipo de control que envuelve al CodeEdit.
# La propiedad 'code_editor' dentro de ese control es el nodo CodeEdit real.
	# Nota: Esto es una estructura interna de Godot. Puede cambiar entre versiones, 
	# pero es la forma común de acceder en Godot 4.
	
	if current_script_editor and current_script_editor.has_method("get_base_editor"):
		return current_script_editor.get_base_editor()
		
	return null

# Función CLAVE para simular la pulsación y liberación de una tecla
# Mover el cursor a la izquierda
func _on_left_pressed():
	var code_edit: ScriptEditor = _get_active_code_editor()
	if code_edit:
		var col = code_edit.get_caret_column()
		# El cursor no puede ir a una columna negativa.
		if col > 0:
			# Establecer la nueva columna (actual - 1)
			code_edit.set_caret_column(col - 1)
			# Asegurar que la pantalla sigue al cursor
			code_edit.grab_focus()

# Mover el cursor a la derecha
func _on_right_pressed():
	var code_edit : ScriptEditor = _get_active_code_editor()
	if code_edit:
		var col = code_edit.get_caret_column()
		var line = code_edit.get_caret_line()
		var line_text = code_edit.get_line(line)
		
		# El cursor solo se mueve si no está al final de la línea.
		if col < line_text.length():
			code_edit.set_caret_column(col + 1)
			code_edit.grab_focus()


# Mover el cursor hacia arriba
func _on_up_pressed():
	var code_edit: ScriptEditor  = _get_active_code_editor()
	if code_edit:
		var line = code_edit.get_caret_line()
		# El cursor no puede ir a una línea negativa.
		if line > 0:
			# Establecer la nueva línea (actual - 1), mantiene la columna actual
			code_edit.set_caret_line(line - 1)
			code_edit.grab_focus()


# Mover el cursor hacia abajo
func _on_down_pressed():
	var code_edit: ScriptEditor  = _get_active_code_editor()
	if code_edit:
		var line = code_edit.get_caret_line()
		var line_count = code_edit.get_line_count()
		
		# El cursor solo se mueve si no está en la última línea.
		if line < line_count - 1:
			code_edit.set_caret_line(line + 1)
			code_edit.grab_focus()

# Insertar un Tab (Indentación)
func _on_tab_pressed():
	var code_edit: ScriptEditor  = _get_active_code_editor()
	if code_edit:
		# El método do_indent() aplica una tabulación lógica a la línea actual.
		# Es más robusto que inyectar una tecla 'Tab'.
		code_edit.do_indent()
		code_edit.grab_focus()

'''func _on_teclado_pressed():
	var code_edit: ScriptEditor = _get_active_code_editor()
	if code_edit:
		code_edit.grab_focus()

	# Alternar el estado del modo teclado
	is_teclado_mode_active = !is_teclado_mode_active
	panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer6/Button_teclado").texture_normal = load("res://Addons/mobile_editor_tools/texture/teclado_true.png") if is_teclado_mode_active else load("res://Addons/mobile_editor_tools/texture/teclado.png")  
	# En este punto, deberías actualizar la apariencia del botón
	# para indicar si está activo o inactivo.

	if is_teclado_mode_active:
		print("Modo 'teclado' activado. El teclado virtual no debería salir.")
	else:
		print("Modo 'teclado' desactivado.")

func _on_control_pressed():
	var code_edit = _get_active_code_editor()
	if not code_edit:
		return

	# 1. Alternar el estado (se activa)
	is_control_active = true
	
	# 2. Devolver el foco
	code_edit.grab_focus()
	
	print("Modo CONTROL activado. Pulse la siguiente tecla de comando.") 
	# (Opcional: actualiza el color/texto del botón aquí para indicar que está activo)

	panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer7/Button_control").texture_normal = load("res://Addons/mobile_editor_tools/texture/control_true.png") if is_control_active else load("res://Addons/mobile_editor_tools/texture/control.png")            
	
# Función CLAVE para interceptar eventos de entrada del editor
func _input(event: InputEvent):
	# Solo actuamos si el modo CONTROL está activado
	if is_control_active:
		# 1. Verificar que sea una pulsación de tecla (DOWN)
		if event is InputEventKey and event.pressed:
			
			# 2. Opcional: Ignorar las teclas modificadoras solas (Ctrl, Shift, Alt)
			# Si Godot envía la pulsación de un modificador como un evento, lo ignoramos.
			if event.keycode == KEY_CTRL or event.keycode == KEY_SHIFT or event.keycode == KEY_ALT:
				return
			
			# 3. Crear el evento simulado con el modificador CONTROL
			var simulated_event = InputEventKey.new()
			simulated_event.pressed = true
			simulated_event.keycode = event.keycode
			simulated_event.ctrl_pressed = true # <-- ¡ACTIVA CTRL AQUÍ!
			
			# 4. Inyectar el comando (Ctrl + Tecla) en el CodeEdit
			var code_edit = _get_active_code_editor()
			if code_edit:
				code_edit.input(simulated_event) # Usamos 'input' directo, no 'call_deferred' para que sea instantáneo
				
				# Simular la liberación de la tecla y el modificador para completar el comando
				var release_event = InputEventKey.new()
				release_event.pressed = false
				release_event.keycode = event.keycode
				release_event.ctrl_pressed = true
				code_edit.input(release_event)
				
			# 5. DESACTIVAR el modo CONTROL (según tu requisito)
			is_control_active = false
			print("Comando ejecutado. Modo CONTROL desactivado.")
			# (Opcional: actualiza el color/texto del botón a inactivo)
			
			# 6. Marcar el evento como manejado
			get_tree().set_input_as_handled()
'''
												
func _on_copy_pressed():
	# La anotación ScriptEditor es incorrecta, CodeEdit hereda de TextEdit/Control
	# pero como _get_active_code_editor() devuelve CodeEdit, lo usamos así:
	var code_edit = _get_active_code_editor()
	if code_edit:
		# Llama al método nativo de TextEdit para copiar el texto seleccionado
		code_edit.copy()
		# Devuelve el foco
		code_edit.grab_focus()
		
func _on_paste_pressed():
	var code_edit = _get_active_code_editor()
	if code_edit:
		# Llama al método nativo de TextEdit para pegar el contenido del portapapeles
		code_edit.paste()
		# Devuelve el foco
		code_edit.grab_focus()

		
func _on_coment_pressed():
	var code_edit = _get_active_code_editor()
	if code_edit:
		
		# 1. Obtener los límites de la selección
		var start_line = code_edit.get_selection_from_line()
		var start_col = code_edit.get_selection_from_column()
		var end_line = code_edit.get_selection_to_line()
		var end_col = code_edit.get_selection_to_column()
		
		# 2. Extraer el texto seleccionado
		var selected_text = code_edit.get_selected_text()
		
		# Verificamos si el texto seleccionado tiene al menos 6 caracteres ('''texto''')
		if selected_text.length() >= 6 and \
		   selected_text.begins_with("'''") and \
		   selected_text.ends_with("'''"):
			
			# Lógica de DESCOMENTAR: Quitar ''' del inicio y del final
			var uncommented_text = selected_text.substr(3, selected_text.length() - 6)
			
			# Reemplazar el texto seleccionado con la versión sin comentar
			code_edit.insert_text_at_caret(uncommented_text)
			
			# Ajustar la selección (opcional, para seleccionar el texto descomentado)
			code_edit.select(start_line, start_col, end_line, end_col - 6)
		else:
			# Lógica de COMENTAR: Agregar ''' al inicio y al final
			var commented_text = "'''" + selected_text + "'''"
			
			# Reemplazar el texto seleccionado con la versión comentada
			code_edit.insert_text_at_caret(commented_text)
			
			# Ajustar la selección para incluir los nuevos delimitadores (''' ... ''')
			code_edit.select(start_line, start_col, end_line, end_col + 6)
		
		# Devuelve el foco
		code_edit.grab_focus()

		
		
func _on_move_pressed():
	var code_edit = _get_active_code_editor()
	if code_edit:
		
		# 1. Invertir el estado
		is_scroll_mode_active = not is_scroll_mode_active
		
		# 2. Aplicar el estado al CodeEdit (propiedad heredada de TextEdit)
		# Si is_scroll_mode_active es true, deshabilitamos la selección
		code_edit.selecting_enabled = not is_scroll_mode_active
		
		(panel_instance.get_node("HScrollBar/HBoxContainer/MarginContainer11/move") as TextureButton).texture_normal = load("res://Addons/mobile_editor_tools/texture/move_true.png") if is_scroll_mode_active else load("res://Addons/mobile_editor_tools/texture/move.png")            
		code_edit.grab_focus()

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
