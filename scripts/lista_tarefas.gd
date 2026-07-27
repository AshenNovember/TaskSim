extends VBoxContainer

const MAX_TAREFAS = 3

func _ready():
	$BotaoAdicionar.pressed.connect(adicionar_nova_tarefa)
	_configurar_conexoes_da_tarefa($TarefaBase)
	_atualizar_limite_de_tarefas()

func adicionar_nova_tarefa():
	var total_atual = _contar_tarefas()
	
	if total_atual >= MAX_TAREFAS:
		return

	var ultima_tarefa = get_child(get_child_count() - 2) 
	if ultima_tarefa is HBoxContainer:
		var texto_digitado = ultima_tarefa.get_node("CampoTexto").text.strip_edges()
		
		if texto_digitado == "":
			ultima_tarefa.get_node("CampoTexto").grab_focus()
			return

	var molde_para_copiar = null
	for filho in get_children():
		if filho is HBoxContainer:
			molde_para_copiar = filho
			break
			
	var novo_grupo = molde_para_copiar.duplicate()
	novo_grupo.get_node("CampoTexto").text = ""
	
	add_child(novo_grupo)
	move_child(novo_grupo, get_child_count() - 2)
	
	_configurar_conexoes_da_tarefa(novo_grupo)
	_atualizar_limite_de_tarefas()
	novo_grupo.get_node("CampoTexto").grab_focus()

func _configurar_conexoes_da_tarefa(no_da_tarefa):
	var campo_texto = no_da_tarefa.get_node("CampoTexto")
	var botao_apagar = no_da_tarefa.get_node("BotaoApagar")
	
	campo_texto.text_submitted.connect(func(_texto): adicionar_nova_tarefa())
	botao_apagar.pressed.connect(func(): apagar_tarefa(no_da_tarefa))

func apagar_tarefa(no_da_tarefa):
	if _contar_tarefas() == 1:
		no_da_tarefa.get_node("CampoTexto").text = ""
	else:
		no_da_tarefa.queue_free() 
		await get_tree().process_frame
		_atualizar_limite_de_tarefas()

func _contar_tarefas() -> int:
	var contador = 0
	for filho in get_children():
		if filho is HBoxContainer:
			contador += 1
	return contador

func _atualizar_limite_de_tarefas():
	var total = _contar_tarefas()
	
	if total >= MAX_TAREFAS:
		$BotaoAdicionar.hide()
	else:
		$BotaoAdicionar.show()
		
	for filho in get_children():
		if filho is HBoxContainer:
			var botao_x = filho.get_node("BotaoApagar")
			if total == 1:
				botao_x.hide()
			else:
				botao_x.show()
