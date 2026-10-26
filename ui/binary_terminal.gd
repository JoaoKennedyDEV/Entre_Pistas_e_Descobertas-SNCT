extends CanvasLayer
## Tela do computador: só mostra as luzes acesas/apagadas (um número em binário).
## A senha é digitada na porta (ui/door_keypad.gd).

signal closed

var code := 42
var bits := 8

const COLOR_ON := Color("#46f2a0")
const COLOR_OFF := Color("#16262a")
const COLOR_TEXT := Color("#7fe9e2")

var _lights: Array[Panel] = []
var _exit_button: Button


func _ready() -> void:
	layer = 50
	_build_ui()
	_refresh_lights()
	_exit_button.grab_focus.call_deferred()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(340, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#0a1214")
	sb.border_color = Color("#3fd0c9")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "TERMINAL // ACESSO RESTRITO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", COLOR_TEXT)
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	vbox.add_child(row)
	for i in bits:
		var light := Panel.new()
		light.custom_minimum_size = Vector2(28, 28)
		row.add_child(light)
		_lights.append(light)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(buttons)
	_exit_button = Button.new()
	_exit_button.text = "Sair (Esc)"
	_exit_button.pressed.connect(close)
	buttons.add_child(_exit_button)


## Acende/apaga as luzes conforme os bits do código (bit mais significativo à esquerda).
func _refresh_lights() -> void:
	for i in _lights.size():
		var on := ((code >> (bits - 1 - i)) & 1) == 1
		var s := StyleBoxFlat.new()
		s.set_corner_radius_all(14)
		s.set_border_width_all(2)
		s.border_color = Color("#2d4448")
		s.bg_color = COLOR_ON if on else COLOR_OFF
		if on:
			s.shadow_color = Color(COLOR_ON.r, COLOR_ON.g, COLOR_ON.b, 0.55)
			s.shadow_size = 6
		_lights[i].add_theme_stylebox_override("panel", s)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func close() -> void:
	closed.emit()
	queue_free()
