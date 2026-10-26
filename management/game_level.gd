extends Node2D
## Fase principal. Trava a câmera e esconde tudo que está fora da sala em que a jogadora está.

## Retângulos das salas (bordas EXTERNAS das paredes, em pixels do mundo).
@export var rooms: Array[Rect2] = [
	Rect2(-480, -384, 992, 608), # sala grande
	Rect2(-480, 224, 448, 320),  # escritório
]
## (não usado mais; mantido para não quebrar a cena)
@export var start_door: NodePath

@export_group("Terminal binário")
## Onde fica o ponto de interação (ao lado da cadeira do computador, no escritório).
@export var terminal_position := Vector2(-212, 485)
## Número (0 a 255) mostrado em binário pelas luzes. É a senha que destrava a porta.
@export var terminal_code := 42
## Onde fica o ponto de interação do teclado da porta (painel na parede, à esquerda da porta).
@export var keypad_position := Vector2(200, -172)
## Porta destravada ao acertar a senha.
@export var keypad_door: NodePath = ^"PortaFuturo"

var _mask: Node2D


func _ready() -> void:
	# fora das salas fica preto (em vez do cinza padrão)
	RenderingServer.set_default_clear_color(Color.BLACK)
	_mask = load("res://objects/room_mask.gd").new()
	_mask.name = "RoomMask"
	add_child(_mask)
	enter_room_at($Player.global_position)
	_spawn_terminal()


## Retângulo da sala que contém a posição (vazio se nenhuma).
func room_at(pos: Vector2) -> Rect2:
	for r in rooms:
		if r.has_point(pos):
			return r
	return Rect2()


## Chamada no início e pelas portas depois de teletransportar a jogadora.
func enter_room_at(pos: Vector2) -> void:
	var room := room_at(pos)
	if room.size == Vector2.ZERO:
		push_warning("Posição %s não está em nenhuma sala (veja 'rooms' no game_level)." % pos)
		return
	_mask.set_room(room)
	_apply_camera(room)


func _apply_camera(room: Rect2) -> void:
	var cam := $Player.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		return
	var view := cam.get_viewport_rect().size / cam.zoom
	var r := room
	# sala menor que a tela: centraliza a sala para a câmera não ficar andando à toa
	if r.size.x < view.x:
		r.position.x -= (view.x - r.size.x) / 2.0
		r.size.x = view.x
	if r.size.y < view.y:
		r.position.y -= (view.y - r.size.y) / 2.0
		r.size.y = view.y
	cam.limit_left = floori(r.position.x)
	cam.limit_top = floori(r.position.y)
	cam.limit_right = ceili(r.end.x)
	cam.limit_bottom = ceili(r.end.y)
	cam.reset_smoothing()


func _spawn_terminal() -> void:
	# computador: só mostra as luzes (número em binário)
	var pc = load("res://objects/binary_terminal_spot.gd").new()
	pc.name = "TerminalBinario"
	pc.position = terminal_position
	pc.code = terminal_code
	add_child(pc)

	# porta: digitar a senha em binário
	var keypad = load("res://objects/binary_terminal_spot.gd").new()
	keypad.name = "TecladoPorta"
	keypad.position = keypad_position
	keypad.ui_script = "res://ui/door_keypad.gd"
	keypad.code = terminal_code
	keypad.door = get_node_or_null(keypad_door)
	add_child(keypad)
