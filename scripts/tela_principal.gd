extends Control 

var arrastando = false
var offset_mouse = Vector2.ZERO
var som_alarme = preload("res://media/alarm.mp3")

func _ready():
	get_viewport().transparent_bg = true
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	
	var config = ConfigFile.new()
	var err = config.load("user://save_app.cfg")
	
	if err != OK:
		%TelaConfigura.show()
		self.hide()
	else:
		carregar_dados_do_disco(config)
		self.show()
		atualizar_dados()
		
	if has_node("%BotaoEditar"):
		%BotaoEditar.pressed.connect(func():
			self.hide() 
			%TelaConfigura.show()
		)
	%TimerFoco.one_shot = true 

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if %AreaArrastar.get_global_rect().has_point(event.position):
				arrastando = event.pressed
				offset_mouse = get_global_mouse_position()
			else:
				arrastando = false
				
	if event is InputEventMouseMotion and arrastando:
		DisplayServer.window_set_position(DisplayServer.window_get_position() + Vector2i(get_global_mouse_position() - offset_mouse))

func carregar_dados_do_disco(config):
	Global.profissao_nome = config.get_value("MeuApp", "profissao", "")
	Global.tempo_foco_minutos = config.get_value("MeuApp", "tempo", 25)
	Global.lista_tarefas = config.get_value("MeuApp", "tarefas", [])
	Global.dias_ativos = config.get_value("MeuApp", "dias", [])
	
	var caminho_avatar = config.get_value("MeuApp", "avatar", "")
	if caminho_avatar != "" and FileAccess.file_exists(caminho_avatar):
		Global.avatar_textura = load(caminho_avatar)

func atualizar_dados():
	if Global.profissao_nome != "":
		%LabelProfissao.text = Global.profissao_nome.to_upper()
		
	if Global.avatar_textura != null:
		%AvatarPerfil.texture = Global.avatar_textura
		
	%LabelTempoFoco.text = "Focus Time: " + str(Global.tempo_foco_minutos) + " min"
	
	var nomes_dias = ["S", "M", "T", "W", "T", "F", "S"]
	var texto_formatado = "[right]" 
	for i in range(nomes_dias.size()):
		if i < Global.dias_ativos.size() and Global.dias_ativos[i] == true:
			texto_formatado += "[color=#55932a][b]" + nomes_dias[i] + "[/b][/color] "
		else:
			texto_formatado += "[color=#2e626d]" + nomes_dias[i] + "[/color] "
	%LabelDiasSemana.text = texto_formatado
	
	for filho in %ListaChecklist.get_children():
		filho.queue_free()
		
	%BarraProgresso.max_value = Global.lista_tarefas.size()
	%BarraProgresso.value = 0 
		
	for tarefa in Global.lista_tarefas:
		var caixa_selecao = CheckBox.new()
		caixa_selecao.text = tarefa
		var fonte_itc = preload("res://fonts/KabelITCBQ-Medium.ttf")
		caixa_selecao.add_theme_font_override("font", fonte_itc)
		var cor_texto1 = Color("#2e626d") 
		caixa_selecao.add_theme_color_override("font_color", cor_texto1)
		var cor_texto2 = Color("#55932a") 
		caixa_selecao.add_theme_color_override("font_pressed_color", cor_texto2)
		caixa_selecao.add_theme_color_override("font_hover_color", cor_texto2)
		caixa_selecao.add_theme_color_override("font_hover_pressed_color", cor_texto2)
		caixa_selecao.add_theme_color_override("font_focus_color", cor_texto2)
		
		caixa_selecao.pressed.connect(func():
			if caixa_selecao.button_pressed:
				%BarraProgresso.value += 1
			else:
				%BarraProgresso.value -= 1
		)
		%ListaChecklist.add_child(caixa_selecao)
	
	iniciar_cronometro()

func iniciar_cronometro():
	%TimerFoco.stop()
	if %TimerFoco.timeout.is_connected(tocar_alerta):
		%TimerFoco.timeout.disconnect(tocar_alerta)
	%TimerFoco.timeout.connect(tocar_alerta)
	%TimerFoco.wait_time = Global.tempo_foco_minutos * 60.0
	%TimerFoco.start()
	
func tocar_alerta():
	if has_node("%BotaoSom") and %BotaoSom.button_pressed:
		%SomAlerta.stream = som_alarme 
		%SomAlerta.play()
		
	DisplayServer.window_request_attention()
	iniciar_cronometro()
