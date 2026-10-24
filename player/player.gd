extends CharacterBody2D

@export var speed := 160.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var interact_area: Area2D = $InteractArea


var facing := "Down"


func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("left", "right", "up", "down")
	velocity = dir * speed
	move_and_slide()
	
	if dir != Vector2.ZERO:
		if abs(dir.x) > abs(dir.y):
			facing = "Right" if dir.x > 0.0 else "Left"
		else:
			facing = "Down" if dir.y > 0.0 else "Up"
		_play("walk_")
	else:
		_play("Idle_")


func _play(prefix: String) -> void:
	# Ex.: "walk_Down", "walk_Left_Up", "Idle_Right_Down"
	var anim_dir := "Right" if facing == "Left" else facing
	sprite.flip_h = (facing == "Left")
	
	var anim := prefix + facing
	if sprite.animation != anim:
		sprite.play(anim)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		# interage com o objeto interagivel mais proximo
		var best: Area2D = null
		var best_d := INF
		for area in interact_area.get_overlapping_areas():
			if area.has_method("interact"):
				var d := area.global_position.distance_to(global_position)
				if d < best_d:
					best_d = d
					best = area
		if best:
			best.interact()
