extends CanvasLayer
## Painel da porta: a jogadora digita a senha em BINÁRIO (só 0 e 1).
## Se acertar, emite `solved` (a porta é destravada por quem abriu o painel).

signal solved
signal closed

var code := 42
var bits := 8
var already_solved := false

const COLOR_ON := Color("#46f2a0")
const COLOR_ERR := Color("#ff5a5a")
const COLOR_TEXT := Color("#7fe9e2")
const COLOR_DIM := Color("#9fb4b6")

var _code_input: LineEdit
var _confirm: Button
var _status: Label
var _panel: PanelContainer


func _ready() -> void:
	layer = 50
	_build_ui()
	if already_solved:
		_mark_solved()
	else:
		_code_input.grab_focus.call_deferred()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(340, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#0a1214")
	sb.border_color = Color("#3fd0c9")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(14)
	_panel.add_theme_stylebox_override("panel", sb)
	center.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_panel.add_child(vbox)

	vbox.add_child(_make_label("PORTA TRANCADA", COLOR_TEXT, 14))
	vbox.add_child(_make_label("Digite o código de acesso em binário:", COLOR_DIM, 10))

	_code_input = LineEdit.new()
	_code_input.custom_minimum_size = Vector2(160, 0)
	_code_input.max_length = bits
	_code_input.placeholder_text = "0".repeat(bits)
	_code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_code_input.add_theme_color_override("font_color", COLOR_ON)
	_code_input.text_changed.connect(_on_text_changed)
	_code_input.text_submitted.connect(_submit)
	var input_row := HBoxContainer.new()
	input_row.alignment = BoxContainer.ALIGNMENT_CENTER
	input_row.add_child(_code_input)
	vbox.add_child(input_row)

	_status = _make_label("Use apenas 0 e 1.", COLOR_DIM, 10)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(_status)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 10)
	vbox.add_child(buttons)
	_confirm = Button.new()
	_confirm.text = "Confirmar"
	_confirm.pressed.connect(_submit)
	buttons.add_child(_confirm)
	var exit := Button.new()
	exit.text = "Sair (Esc)"
	exit.pressed.connect(close)
	buttons.add_child(exit)


func _make_label(text: String, color: Color, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", size)
	return l


## Só aceita os caracteres 0 e 1.
func _on_text_changed(t: String) -> void:
	var clean := ""
	for ch in t:
		if ch == "0" or ch == "1":
			clean += ch
	if clean != t:
		var pos := _code_input.caret_column
		_code_input.text = clean
		_code_input.caret_column = mini(pos, clean.length())


func _submit(_text: String = "") -> void:
	if already_solved:
		return
	var t := _code_input.text.strip_edges()
	if t.is_empty():
		return
	# "101010" e "00101010" valem o mesmo número
	if t.bin_to_int() == code:
		_success()
	else:
		_fail()


func _fail() -> void:
	_status.text = "CÓDIGO INCORRETO."
	_status.add_theme_color_override("font_color", COLOR_ERR)
	_code_input.clear()
	_panel.pivot_offset = _panel.size / 2.0
	var tw := create_tween()
	for r in [-0.02, 0.02, -0.012, 0.012, 0.0]:
		tw.tween_property(_panel, "rotation", r, 0.05)


func _success() -> void:
	already_solved = true
	_mark_solved()
	solved.emit()
	# fecha sozinho para a jogadora ver a porta abrindo
	await get_tree().create_timer(1.2).timeout
	if is_inside_tree():
		close()


func _mark_solved() -> void:
	_status.text = "ACESSO LIBERADO."
	_status.add_theme_color_override("font_color", COLOR_ON)
	_code_input.editable = false
	_confirm.disabled = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func close() -> void:
	closed.emit()
	queue_free()
