extends Node2D
## Fase principal. Define os limites iniciais da câmera pela sala onde a jogadora começa.

## Porta cuja sala é a sala inicial (usa o room_rect dela para a câmera).
@export var start_door: NodePath


func _ready() -> void:
	# fora das salas fica preto (em vez do cinza padrão)
	RenderingServer.set_default_clear_color(Color.BLACK)
	##_abrir_vao_da_porta()
	var door = get_node_or_null(start_door)
	if door:
		door.apply_camera($Player)


## Os tiles da faixa de parede entre a sala grande e o escritório têm colisão.
## Troca os 3 tiles em cima da porta do escritório pelo piso da sala (sem colisão).
##func _abrir_vao_da_porta() -> void:
	##var terreno := get_node_or_null("Node2D/terreno") as TileMapLayer
	##if terreno == null:
	##	push_warning("TileMapLayer 'terreno' não encontrado; o vão da porta não foi aberto.")
	##	return
	##for x in [-9, -8, -7]:
	##	var acima := Vector2i(x, 5)
	##	terreno.set_cell(Vector2i(x, 6), terreno.get_cell_source_id(acima), terreno.get_cell_atlas_coords(acima))
