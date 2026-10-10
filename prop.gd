extends StaticBody2D
## Móvel/objeto com sprite e colisão nos "pés".
## "position" = centro da base do sprite (por isso o y-sort funciona).

@export var texture: Texture2D
@export var collider_size := Vector2(16, 8)
@export var solid := true


func _ready() -> void:
	var s := Sprite2D.new()
	s.texture = texture
	s.centered = false
	s.offset = Vector2(-floor(texture.get_width() / 2.0), -texture.get_height())
	add_child(s)
	if solid:
		var cs := CollisionShape2D.new()
		var rs := RectangleShape2D.new()
		rs.size = collider_size
		cs.shape = rs
		cs.position = Vector2(0, -collider_size.y / 2.0)
		add_child(cs)
