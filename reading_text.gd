extends Control
class_name  ReadingText

var _step: float = 0.01
var _id: int = 0
var data: Dictionary = {}

@onready var _dialog: RichTextLabel = $Background/HContainer/VContainer/Dialog
@onready var _letter_sound: AudioStreamPlayer2D = $LetterSound

@export_category("Objects")
#@export var _name: Label = null
#@export var _dialog: RichTextLabel = null
#@export var _faceset: TextureRect = null

func _ready() -> void:
	_initialize_dialog()

func _process(delta: float) -> void:
	if Input.is_action_pressed("interact") and _dialog.visible_ratio < 1:
		_step = 0.001
		return
	
	_step = 0.01
	if Input.is_action_just_pressed("interact"):
		_id += 1
		if _id == data.size():
			queue_free()
			return
		
		_initialize_dialog()

func _initialize_dialog() -> void:
	_dialog.text = data[_id]["dialog"]
	_dialog.visible_characters = 0
	
	while _dialog.visible_ratio < 1:
		await get_tree().create_timer(_step).timeout

		if not is_inside_tree():
			return

		_dialog.visible_characters += 1

		var index := _dialog.visible_characters - 1
		var character := _dialog.text.substr(index, 1)

		# Não reproduz o som para espaços ou quebras de linha.
		if not character in [" ", "\n", "\t", "\r"]:
			if not _letter_sound.playing:
				_letter_sound.play()
	
	#while _dialog.visible_ratio < 1:
	#	await get_tree().create_timer(_step).timeout
	#	_dialog.visible_characters += 1
