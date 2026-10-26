extends Area2D

# Exporta uma variável para você definir o texto direto no Inspector do Godot
@export_multiline var texto_dialogo : String = "Olá, viajante!"

func _ready() -> void:
	# Conecta o sinal de entrada de corpo à função correspondente
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que entrou é o jogador
	# (Substitua "Player" pelo nome da classe ou grupo do seu jogador)
	if body.is_in_group("player"):
		disparar_dialogo()

func disparar_dialogo() -> void:
	print("Diálogo ativado: ", texto_dialogo)
	
	# AQUI você chama o seu sistema de diálogo global ou interface de UI
	# Exemplo: DialogManager.mostrar_mensagem(texto_dialogo)
	
	# (Opcional) Desativa o trigger para não repetir o diálogo se o jogador pisar de novo
	queue_free() 
