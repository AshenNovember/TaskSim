extends Control

func _ready():
	%ModalLogo.hide()
	%TelaPrincipal.hide()
	%ModalErro.hide()
	
	if has_node("%BotaoOk"):
		%BotaoOk.pressed.connect(func(): %ModalErro.hide())
	
	%BotaoLogo.pressed.connect(abrir_modal)
	%BotaoCancelar.pressed.connect(fechar_modal)
	
	for botao_imagem in %GridContainer.get_children():
		if botao_imagem is TextureButton:
			botao_imagem.pressed.connect(func(): escolher_imagem(botao_imagem.texture_normal))
			
	%BotaoIniciar.pressed.connect(iniciar_expediente)

func abrir_modal():
	%ModalLogo.show()

func fechar_modal():
	%ModalLogo.hide()

func escolher_imagem(imagem_selecionada):
	%LogoEscolhido.texture = imagem_selecionada
	%LogoEscolhido.show()
	%BotaoLogo.text = "Edit"
	fechar_modal()

func limpar_campos_tarefas_vazios():
	var tarefas_vazias = []
	var total_tarefas = 0
	
	for tarefa_no in %ListaTarefas.get_children():
		if tarefa_no is HBoxContainer:
			total_tarefas += 1
			var campo = tarefa_no.get_node("CampoTexto")
			if campo and campo.text.strip_edges() == "":
				tarefas_vazias.append(tarefa_no)
				
	for tarefa_no in tarefas_vazias:
		if total_tarefas > 1:
			tarefa_no.queue_free()
			total_tarefas -= 1
		else:
			break
func iniciar_expediente():
	limpar_campos_tarefas_vazios()
	await get_tree().process_frame 
	
	var profissao_texto = %InputProfissao.text.strip_edges()
	
	if %LogoEscolhido.texture == null or not %LogoEscolhido.visible:
		mostrar_erro("Please, choose a image for the profile.")
		return

	if profissao_texto == "":
		mostrar_erro("The career field can't be empty.")
		return

	var tarefas_preenchidas = []
	for tarefa_no in %ListaTarefas.get_children():
		if tarefa_no is HBoxContainer:
			var campo = tarefa_no.get_node("CampoTexto")
			if campo:
				var texto_limpo = campo.text.strip_edges()
				if texto_limpo != "":
					tarefas_preenchidas.append(texto_limpo)
					
	if tarefas_preenchidas.size() == 0:
		mostrar_erro("It's required to add at least 1 valid task.")
		return
		
	%LabelErro.text = ""
	
	Global.profissao_nome = profissao_texto
	Global.avatar_textura = %LogoEscolhido.texture
	
	var texto_tempo = %SeletorTempo.get_item_text(%SeletorTempo.selected)
	Global.tempo_foco_minutos = texto_tempo.to_int()
	
	Global.dias_ativos.clear()
	for botao_dia in %GradeDias.get_children():
		if botao_dia is Button:
			Global.dias_ativos.append(botao_dia.button_pressed)
			
	Global.lista_tarefas = tarefas_preenchidas
	
	salvar_dados_no_disco()
	
	self.hide()
	%TelaPrincipal.show()
	%TelaPrincipal.atualizar_dados()

func mostrar_erro(mensagem: String):
	%LabelErro.text = mensagem
	%ModalErro.show()

func salvar_dados_no_disco():
	var config = ConfigFile.new()
	
	config.set_value("MeuApp", "profissao", Global.profissao_nome)
	config.set_value("MeuApp", "tempo", Global.tempo_foco_minutos)
	config.set_value("MeuApp", "tarefas", Global.lista_tarefas)
	config.set_value("MeuApp", "dias", Global.dias_ativos)
	
	if Global.avatar_textura != null:
		config.set_value("MeuApp", "avatar", Global.avatar_textura.resource_path)
		
	config.save("user://save_app.cfg")

func carregar_dados_do_disco():
	var config = ConfigFile.new()
	var erro = config.load("user://save_app.cfg")
	
	if erro == OK:
		Global.profissao_nome = config.get_value("MeuApp", "profissao", "")
		Global.tempo_foco_minutos = config.get_value("MeuApp", "tempo", 25)
		Global.lista_tarefas = config.get_value("MeuApp", "tarefas", [])
		Global.dias_ativos = config.get_value("MeuApp", "dias", [])
		
		var caminho_avatar = config.get_value("MeuApp", "avatar", "")
		if caminho_avatar != "":
			Global.avatar_textura = load(caminho_avatar)
			
		self.hide()
		%TelaPrincipal.show()
		%TelaPrincipal.atualizar_dados()
