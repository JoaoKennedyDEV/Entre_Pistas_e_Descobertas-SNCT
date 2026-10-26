extends Node2D
## Pinta de preto tudo que está fora da sala atual.
## Necessário porque os limites da câmera não escondem nada quando a sala
## é menor que a tela (a câmera é centralizada e mostra o que está em volta).

var room := Rect2()


func _init() -> void:
	z_as_relative = false
	z_index = 100


func set_room(r: Rect2) -> void:
	room = r
	queue_redraw()


func _draw() -> void:
	if room.size == Vector2.ZERO:
		return
	var big := 100000.0
	var r := room
	draw_rect(Rect2(-big, -big, big * 2.0, r.position.y + big), Color.BLACK) # cima
	draw_rect(Rect2(-big, r.end.y, big * 2.0, big), Color.BLACK)             # baixo
	draw_rect(Rect2(-big, r.position.y, r.position.x + big, r.size.y), Color.BLACK) # esquerda
	draw_rect(Rect2(r.end.x, r.position.y, big, r.size.y), Color.BLACK)      # direita
