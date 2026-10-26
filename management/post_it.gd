extends Area2D

@export var dialog_scene: PackedScene

var player_in_range: bool = false
var dialog_open: bool = false

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


func iniciar_dialogo() -> void:
	dialog_open = true

	var dialog = dialog_scene.instantiate()

	dialog.data = {
		0: {
			"dialog": "Você repara em alguns Post-Its",
		},
		1: {
			"dialog": "\"Ada Lovelace foi uma matemática inglesa que viveu no século XIX.\"",
		},
		2: {
			"dialog": "\"Ela ficou conhecida por suas ideias pioneiras sobre a computação\"",
		},
		3: {
			"dialog": "\"Ada estudou a Máquina Analítica, um projeto de computador mecânico criado por Charles Babbage.\"",
		},
		4: {
			"dialog": "\"Por isso, ela é frequentemente considerada a primeira programadora da história.\"",
		}
	}

	get_tree().current_scene.add_child(dialog)
	dialog.tree_exited.connect(_on_dialogo_fechado)


func _on_dialogo_fechado() -> void:
	dialog_open = false
