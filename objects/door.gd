extends Node2D
## Porta de vidro de correr. Abre sozinha quando a jogadora chega perto e,
## ao atravessar, leva para a porta de destino (outra sala) com um fade.
##
## Como usar: instancie door.tscn na posição do CENTRO DA BASE da porta,
## aponte `destination_path` para a outra porta e defina `room_rect`
## (retângulo da sala em que esta porta está, usado nos limites da câmera).

## Porta para onde esta leva (outra instância de door.tscn na mesma cena).
## Deixe vazio se a porta só liga duas salas coladas (a jogadora atravessa andando).
@export var destination_path: NodePath
## Retângulo da sala em que ESTA porta está (pixels do mundo). Limita a câmera.
@export var room_rect := Rect2()
## Retângulo da sala para onde esta porta leva. Usado na câmera depois da troca de sala.
@export var destination_room_rect := Rect2()
## Se true a porta não abre (use para ligar com o puzzle de senha depois).
@export var locked := false
## Segundos para abrir/fechar por completo.
@export var open_time := 0.3
## Segundos de cada fade (escurecer e clarear) na troca de sala.
@export var fade_time := 0.25
## Mostra uma seta quicando no lado norte da porta (sala grande) para indicar o caminho de volta.
@export var show_return_marker := true
## Posição da ponta da seta, relativa à base da porta. Ajuste para ficar na frente da parede.
@export var marker_offset := Vector2(0, -134)

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var blocker: CollisionShape2D = $Blocker/CollisionShape2D
@onready var proximity: Area2D = $Proximity
@onready var trigger: Area2D = $Trigger
@onready var exit_point: Marker2D = $ExitPoint

## 0.0 = fechada, 1.0 = totalmente aberta (controla o frame e a colisão).
var openness := 0.0: set = _set_openness

var _tween: Tween
var _near := 0
var _busy := false
var _fader: ColorRect
var _marker: Node2D
var _marker_t := 0.0


func _ready() -> void:
	proximity.body_entered.connect(_on_proximity_entered)
	proximity.body_exited.connect(_on_proximity_exited)
	trigger.body_entered.connect(_on_trigger_entered)
	_set_openness(0.0)
	if show_return_marker and not destination_path.is_empty():
		_create_marker()


func _create_marker() -> void:
	_marker = Node2D.new()
	_marker.position = marker_offset
	_marker.z_index = 10
	var pts := PackedVector2Array([
		Vector2(0, 0), Vector2(-10, -14), Vector2(-4, -14), Vector2(-4, -26),
		Vector2(4, -26), Vector2(4, -14), Vector2(10, -14),
	])
	var fill := Polygon2D.new()
	fill.polygon = pts
	fill.color = Color(1.0, 0.85, 0.2)
	var outline := Line2D.new()
	outline.points = pts
	outline.closed = true
	outline.width = 2.0
	outline.default_color = Color.BLACK
	_marker.add_child(fill)
	_marker.add_child(outline)
	add_child(_marker)


func _process(delta: float) -> void:
	if _marker == null:
		return
	_marker_t += delta
	_marker.position = marker_offset + Vector2(0, sin(_marker_t * 5.0) * 4.0)
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		_marker.visible = false
		return
	# só aparece com a jogadora no lado norte (sala grande) e já longe da seta
	var north := player.global_position.y < global_position.y - 100.0
	var far := player.global_position.distance_to(global_position + marker_offset) > 20.0
	_marker.visible = north and far and not _busy


func unlock() -> void:
	locked = false
	_refresh()


## Chamada pela porta de origem: deixa esta porta aberta e ajusta a câmera.
func arrive(player: CharacterBody2D) -> void:
	if "facing" in player:
		player.set("facing", "Down")
	if _tween:
		_tween.kill()
	openness = 1.0
	apply_camera(player)


## Prende a câmera da jogadora aos limites da sala desta porta.
func apply_camera(player: Node, rect: Rect2 = room_rect) -> void:
	var cam := player.get_node_or_null("Camera2D") as Camera2D
	if cam == null or rect.size == Vector2.ZERO:
		return
	var view := cam.get_viewport_rect().size / cam.zoom
	var r := rect
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


func _set_openness(value: float) -> void:
	openness = clampf(value, 0.0, 1.0)
	if sprite == null:
		return
	var last := sprite.sprite_frames.get_frame_count("open") - 1
	sprite.frame = roundi(openness * last)
	# só libera a passagem quando a porta está (quase) toda aberta
	blocker.set_deferred("disabled", openness >= 0.9)


func _is_player(body: Node) -> bool:
	return body is CharacterBody2D


func _on_proximity_entered(body: Node2D) -> void:
	if _is_player(body):
		_near += 1
		_refresh()


func _on_proximity_exited(body: Node2D) -> void:
	if _is_player(body):
		_near = maxi(_near - 1, 0)
		_refresh()


func _on_trigger_entered(body: Node2D) -> void:
	_try_travel(body)


## Tenta atravessar. Só funciona com a porta aberta. Se a jogadora já estava
## encostada no gatilho enquanto a porta ainda abria, _check_trigger chama de novo.
func _try_travel(body: Node2D) -> void:
	# sem destino = porta de passagem direta (salas coladas) ou porta futura
	if destination_path.is_empty() or _busy or openness < 0.9 or not _is_player(body):
		return
	_travel(body as CharacterBody2D)


func _check_trigger() -> void:
	for body in trigger.get_overlapping_bodies():
		_try_travel(body)


## true = jogadora está no lado norte (sala grande); false = lado sul (escritório).
## 48 = metade da altura da porta (96px).
func _is_north_side(player: Node2D) -> bool:
	return player.global_position.y < global_position.y - 48.0


func _refresh() -> void:
	if _busy:
		return
	var target := 1.0 if (_near > 0 and not locked) else 0.0
	if is_equal_approx(openness, target):
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "openness", target, open_time * absf(target - openness))
	_tween.finished.connect(_check_trigger)


func _travel(player: CharacterBody2D) -> void:
	var from_north := _is_north_side(player)
	var target: Vector2
	if from_north:
		# VOLTA: sai pelo ExitPoint (lado sul da porta, dentro do escritório)
		target = exit_point.global_position
	else:
		# IDA: vai para o destino configurado
		var dest = get_node_or_null(destination_path)
		if dest == null:
			push_warning("Porta '%s' está sem destino (destination_path)." % name)
			return
		target = dest.global_position
	_busy = true
	_freeze(player, true)
	await _fade(1.0)
	player.global_position = target
	# trava a câmera/máscara na sala onde a jogadora acabou de chegar
	var level := get_parent()
	if level.has_method("enter_room_at"):
		level.enter_room_at(target)
	if "facing" in player:
		player.set("facing", "Down" if from_north else "Up")
	await _fade(0.0)
	_freeze(player, false)
	_busy = false
	_refresh()


func _freeze(player: CharacterBody2D, on: bool) -> void:
	player.set_physics_process(not on)
	player.set_process_unhandled_input(not on)
	if on:
		player.velocity = Vector2.ZERO
		var spr := player.get_node_or_null("Sprite") as AnimatedSprite2D
		if spr and String(spr.animation).begins_with("walk_"):
			spr.play(String(spr.animation).replace("walk_", "Idle_"))


func _fade(target_alpha: float) -> void:
	var fader := _get_fader()
	var t := create_tween()
	t.tween_property(fader, "modulate:a", target_alpha, fade_time)
	await t.finished


func _get_fader() -> ColorRect:
	if _fader == null:
		var layer := CanvasLayer.new()
		layer.layer = 100
		_fader = ColorRect.new()
		_fader.color = Color.BLACK
		_fader.modulate.a = 0.0
		_fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(_fader)
		add_child(layer)
		_fader.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return _fader
