extends Control

@export_file("*.tscn")
var gameplay_scene_path: String = "res://management/game_level.tscn"

@export var frames: Array[Texture2D] = []

@onready var background: TextureRect = $Background
@onready var dialogue_panel: Panel = $DialoguePanel
@onready var fade: ColorRect = $Fade
@onready var dialogue: Label = $Dialogue
@onready var next_button: Button = $NextButton
@onready var skip_button: Button = $SkipButton

var current_frame: int = 0
var is_transitioning: bool = false
var game_starting: bool = false

var story: Array[String] = [
	#"Depois de anos de pesquisa, minha maior descoberta estava finalmente pronta...",
	#"Eu estava convencida de que alguém queria roubar minhas pesquisas.",
	#"Por isso, criei um complexo sistema de segurança para proteger meu laboratório.",
	#"Mas, durante um experimento, algo deu errado. Os sistemas começaram a falhar...",
	#"Quando acordei, estava sozinha. As portas estavam trancadas e minha memória estava confusa.",
	#"Os computadores estão bloqueados. Eu sei que criei tudo isso, mas não lembro como desativar o sistema.",
	#"Encontrei meu diário de pesquisa. Talvez eu tenha deixado alguma pista por aqui.",
	#"Há registros de mulheres que transformaram a história da ciência.",
	#"Se registrei tantas descobertas, talvez também tenha deixado uma maneira de escapar...",
	#"Preciso explorar cada sala, resolver os enigmas e recuperar o acesso aos sistemas.",
	#"Ada Lovelace... seus estudos sobre computação podem me ajudar a desbloquear o primeiro sistema!",
	#"Cada pista pode me aproximar da saída. Está na hora de escapar do meu próprio laboratório!"
]


func _ready() -> void:
	# Mantém a interface legível e posicionada em diferentes tamanhos de janela.
	_configure_visual_style()
	next_button.pressed.connect(_next_frame)
	skip_button.pressed.connect(_start_game)

	fade.color = Color(0, 0, 0, 1)
	_show_frame()
	await _fade_to(0.0, 0.75)


func _configure_visual_style() -> void:
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Caixa de diálogo escura com borda azul-violeta.
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.025, 0.12, 0.94)
	panel_style.border_color = Color(0.34, 0.24, 0.95, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 14
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	dialogue_panel.add_theme_stylebox_override("panel", panel_style)

	dialogue.add_theme_color_override("font_color", Color(0.94, 0.93, 1.0))
	dialogue.add_theme_font_size_override("font_size", 15)
	dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	_style_button(next_button, true)
	_style_button(skip_button, false)

	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.z_index = 100


func _style_button(button: Button, primary: bool) -> void:
	var normal := StyleBoxFlat.new()
	var hover := StyleBoxFlat.new()
	var pressed := StyleBoxFlat.new()

	normal.bg_color = Color(0.16, 0.10, 0.48, 0.98) if primary else Color(0.07, 0.06, 0.20, 0.96)
	normal.border_color = Color(0.43, 0.32, 1.0, 1.0)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 5
	normal.content_margin_bottom = 5

	hover = normal.duplicate()
	hover.bg_color = Color(0.30, 0.20, 0.75, 1.0)
	pressed = normal.duplicate()
	pressed.bg_color = Color(0.10, 0.08, 0.34, 1.0)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color(0.85, 0.83, 1.0))
	button.add_theme_font_size_override("font_size", 13)
	button.focus_mode = Control.FOCUS_NONE


func _show_frame() -> void:
	dialogue.text = story[current_frame]
	if current_frame < frames.size() and frames[current_frame] != null:
		background.texture = frames[current_frame]

	if current_frame == story.size() - 1:
		next_button.text = "COMEÇAR  →"
	else:
		next_button.text = "CONTINUAR  →"


func _next_frame() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	await _fade_to(1.0, 0.18)

	if current_frame < story.size() - 1:
		current_frame += 1
		_show_frame()
		await _fade_to(0.0, 0.28)
		is_transitioning = false
	else:
		is_transitioning = false
		await _start_game()


func _start_game() -> void:
	if game_starting:
		return
	game_starting = true
	is_transitioning = true
	next_button.disabled = true
	skip_button.disabled = true
	await _fade_to(1.0, 0.5)
	get_tree().change_scene_to_file(gameplay_scene_path)


func _fade_to(alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "color:a", alpha, duration)
	await tween.finished
