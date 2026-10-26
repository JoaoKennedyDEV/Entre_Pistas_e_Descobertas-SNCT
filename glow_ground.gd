
extends Node2D
class_name GlowGround

@export_category("Aparência")
@export_range(4.0, 100.0, 1.0) var radius: float = 20.0
@export_range(8, 64, 1) var segments: int = 32
@export var glow_color: Color = Color("#FFC857")

@export_category("Animação")
@export_range(0.2, 5.0, 0.1) var pulse_duration: float = 1.5

var rings: Array[Line2D] = []


func _ready() -> void:
	_create_rings()
	_animate_glow()


func _create_rings() -> void:
	# Três anéis sobrepostos para simular luminosidade.
	var widths: Array[float] = [5.0, 2.5, 1.0]
	var alphas: Array[float] = [0.18, 0.55, 1.0]
	var radii: Array[float] = [1.12, 1.0, 0.94]

	for i in range(3):
		var ring := Line2D.new()
		ring.name = "Ring" + str(i)
		ring.width = widths[i]
		ring.default_color = Color(
			glow_color.r,
			glow_color.g,
			glow_color.b,
			alphas[i]
		)
		ring.closed = true
		ring.antialiased = false
		ring.z_index = -1

		# Desenha uma elipse achatada, como um círculo no chão.
		for point_index in range(segments):
			var angle := TAU * float(point_index) / float(segments)
			var x := cos(angle) * radius * radii[i]
			var y := sin(angle) * radius * 0.4 * radii[i]
			ring.add_point(Vector2(x, y))

		add_child(ring)
		rings.append(ring)


func _animate_glow() -> void:
	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(
		self, "modulate:a", 0.55, pulse_duration
	).from(1.0)

	tween.tween_property(
		self, "modulate:a", 1.0, pulse_duration
	)
