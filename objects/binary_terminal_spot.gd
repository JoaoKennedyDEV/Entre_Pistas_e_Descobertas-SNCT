extends Area2D
## Ponto de interação genérico: ao apertar "interact" perto dele abre a interface `ui_script`.
## - computador: ui/binary_terminal.gd (só mostra as luzes)
## - porta:      ui/door_keypad.gd (digitar a senha em binário; acertando, destrava `door`)

var ui_script := "res://ui/binary_terminal.gd"
var code := 42
var bits := 8
var door: Node
var unlocked := false

var _player_in_range := false
var _open := false
var _prompt: Label


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 32.0
	shape.shape = circle
	add_child(shape)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# brilho no chão, igual ao dos outros pontos de interação
	var glow = load("res://glow_ground.gd").new()
	glow.radius = 24.0
	add_child(glow)

	_prompt = Label.new()
	_prompt.text = "E"
	_prompt.position = Vector2(-5, -36)
	_prompt.z_index = 20
	_prompt.add_theme_font_size_override("font_size", 12)
	_prompt.add_theme_color_override("font_outline_color", Color.BLACK)
	_prompt.add_theme_constant_override("outline_size", 4)
	_prompt.visible = false
	add_child(_prompt)


func _process(_delta: float) -> void:
	if _player_in_range and not _open and Input.is_action_just_pressed("interact"):
		_open_terminal()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_prompt.visible = not _open


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_prompt.visible = false


func _open_terminal() -> void:
	_open = true
	_prompt.visible = false
	var ui = load(ui_script).new()
	ui.code = code
	ui.bits = bits
	if "already_solved" in ui:
		ui.already_solved = unlocked
	if ui.has_signal("solved"):
		ui.solved.connect(_on_solved)
	ui.closed.connect(_on_closed)
	get_parent().add_child(ui)
	_set_player_frozen(true)


func _on_solved() -> void:
	unlocked = true
	if door != null and door.has_method("unlock"):
		door.unlock()


func _on_closed() -> void:
	_set_player_frozen(false)
	# pequena espera: Enter/Espaço também são "interact" e reabririam o terminal
	await get_tree().create_timer(0.25).timeout
	_open = false
	_prompt.visible = _player_in_range


func _set_player_frozen(on: bool) -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null:
		return
	player.set_physics_process(not on)
	player.set_process_unhandled_input(not on)
	if on:
		player.velocity = Vector2.ZERO
		var spr := player.get_node_or_null("Sprite") as AnimatedSprite2D
		if spr and String(spr.animation).begins_with("walk_"):
			spr.play(String(spr.animation).replace("walk_", "Idle_"))
