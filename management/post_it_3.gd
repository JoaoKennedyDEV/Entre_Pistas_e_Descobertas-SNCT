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
			"dialog": "Você olha no computador e vê algumas anotações.",
		},
		1: {
			"dialog": "\"20/03/20XX\nMinha pesquisa está demorando mais tempo do que eu pensava, preciso de um programa que me ajude a monitorar os meus ambientes de teste. Terei que procurar",
		},
		2: {
			"dialog": "alguém da área para me ajudar nisso.\"",
		},
		3: {
			"dialog": "\"27/03/20XX\nCandidato 1\n\"Boa entrevista, mas o currículo não é dos melhores. Preciso de alguém mais experiente.\"",
		},
		4: {
			"dialog": "\"Candidato 2\nAlguém muito experiente, e com boa entrevista, mas não tem nenhum conhecimento da área da minha pesquisa.\"",
		},
		5: {
			"dialog": "\"24/04/20XX\nCandidato 27\nFinalmente achei alguém perfeito!!! A entrevista foi impecável, um currículo impressionante e ele consegue\"",
		},
		6: {
			"dialog": "entender o que eu quero. Agora eu só dar uma olhada no background dele e posso voltar a focar na pesquisa!!\"",
		},
		7: {
			"dialog": "\"25/04/20XX\nAAAAAHHHH DESISTO!! Quando fui investigar o histórico do candidato 27, eu vi que ele trabalha para a empresa X. CANALHAS!! Quer saber, se você quer algo bem feito faça",
		},
		8: {
			"dialog": "você mesmo, nem que eu tenha que usar todo meu horário de descanso para estudar programação eu vou fazer sozinha mesmo.\"",
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
