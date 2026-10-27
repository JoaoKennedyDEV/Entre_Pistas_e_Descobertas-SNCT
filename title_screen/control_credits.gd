
extends Control

@export var textura_normal: Texture2D
@export var textura_hover: Texture2D

@onready var botao: TextureRect = get_parent() as TextureRect

var mouse_estava_sobre: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	if textura_normal != null:
		botao.texture = textura_normal

func _process(_delta: float) -> void:
	var mouse_sobre = get_global_rect().has_point(
		get_global_mouse_position()
	)

	# Detecta quando o mouse entra ou sai da área.
	if mouse_sobre and not mouse_estava_sobre:
		if textura_hover != null:
			botao.texture = textura_hover
		print("Mouse entrou!")

	elif not mouse_sobre and mouse_estava_sobre:
		if textura_normal != null:
			botao.texture = textura_normal
		print("Mouse saiu!")

	mouse_estava_sobre = mouse_sobre

	# Detecta apenas o instante em que o botão é pressionado.
	if mouse_sobre and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not Input.is_action_just_pressed("ui_accept"):
		print("Botão clicado!")
		efeito_clique()
		iniciar_jogo()

	if mouse_sobre and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pass

func efeito_clique() -> void:
	var tween := create_tween()
	tween.tween_property(botao, "modulate", Color(1.5, 1.5, 1.5), 0.1)
	tween.tween_property(botao, "modulate", Color.WHITE, 0.1)

func iniciar_jogo() -> void:
	#get_tree().change_scene_to_file("res://management/game_level.tscn")
	pass
