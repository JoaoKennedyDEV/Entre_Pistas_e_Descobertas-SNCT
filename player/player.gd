extends CharacterBody2D
class_name BaseCharacter

@export var speed := 110.0
@onready var interact_area: Area2D = $InteractArea

@export_category("objects")
@export var _spritr2d: Sprite2D
@export var _animation: AnimationPlayer

func _physics_process(_delta: float) -> void:
	_move()
	_pular()
	_animate()
	
func _move() -> void:
	var dir := Input.get_vector("left", "right", "up", "down")
	velocity = dir * speed
	move_and_slide()
	
func _pular() -> void:
	if Input.is_action_just_pressed("jump"):
		if velocity.x < 0:
			_animation.play("jump left down")
			return
	

func _animate() -> void:
	if velocity.x > 0:
		_animation.play("right down")
		return
	if velocity.x < 0:
		_animation.play("left down")
		return
	if velocity.y > 0:
		_animation.play("idle")
		return
	if velocity.y < 0:
		_animation.play("up")
		return
	if velocity:
		_animation.play("idle")
		return
		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for area in interact_area.get_overlapping_areas():
			if area.has_method("interact"):
				area.interact()
				break
