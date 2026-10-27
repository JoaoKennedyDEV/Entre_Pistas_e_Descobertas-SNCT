extends Area2D

@export var dialog_scene: PackedScene

var player_in_range: bool = false
var dialog_open: bool = false
var _layer: CanvasLayer
var _dialog: Node

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if player_in_range and not dialog_open:
		if Input.is_action_just_pressed("interact"):
			iniciar_dialogo()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		_fechar_dialogo()


func iniciar_dialogo() -> void:
	dialog_open = true

	var dialog = dialog_scene.instantiate()

	dialog.data = {
		0: {
			"dialog": "Você vê algumas anotação sobre programação",
		},
		1: {
			"dialog": "\"A computação é a área que estuda como processar e armazenar informações usando máquinas.\"",
		},
		2: {
			"dialog": "\"Para conseguir se comunicar com a maquina o ser humano utiliza as linguagens de programação, que é transformada em linguagem binaria.\"",
		},
		3: {
			"dialog": "\"A linguagem binaria consiste em somente dois valores 0 e 1\"",
		},
		4: {
			"dialog": "\"Ou seja quando a energia está desligada o valor é 0, e quando estiver ligada é 1.\"",
		}
	}

	# o diálogo vive numa CanvasLayer: fica fixo na tela, não no mundo (chão)
	_layer = CanvasLayer.new()
	_layer.layer = 40
	_layer.add_child(dialog)
	get_tree().current_scene.add_child(_layer)
	_dialog = dialog
	dialog.tree_exited.connect(_on_dialogo_fechado)


func _on_dialogo_fechado() -> void:
	dialog_open = false
	if is_instance_valid(_layer):
		_layer.queue_free()
	_layer = null
	_dialog = null


## Fecha o diálogo (ex.: quando a jogadora se afasta do objeto).
func _fechar_dialogo() -> void:
	if not is_instance_valid(_dialog):
		return
	if _dialog.has_method("close"):
		_dialog.close()
	else:
		_dialog.queue_free()
