extends CharacterBody2D

@export var speed := 100.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var interact_area: Area2D = $InteractArea

# Seus sprites têm 6 direções: Down, Up, Left_Down, Left_Up, Right_Down, Right_Up
var vertical := "Down"
var horizontal := ""   # "", "Left" ou "Right"


func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("left", "right", "up", "down")
	velocity = dir * speed
	move_and_slide()

	if dir != Vector2.ZERO:
		if dir.y != 0.0:
			vertical = "Up" if dir.y < 0.0 else "Down"
		if dir.x != 0.0:
			horizontal = "Left" if dir.x < 0.0 else "Right"
		else:
			horizontal = ""
		_play("walk_")
	else:
		_play("Idle_")


func _play(prefix: String) -> void:
	# Ex.: "walk_Down", "walk_Left_Up", "Idle_Right_Down"
	var anim := prefix + (horizontal + "_" if horizontal != "" else "") + vertical
	if sprite.animation != anim:
		sprite.play(anim)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for area in interact_area.get_overlapping_areas():
			if area.has_method("interact"):
				area.interact()
				break
