extends Node

var profissao_nome: String = ""
var avatar_textura: Texture2D = null
var tempo_foco_minutos: int = 0 
var dias_ativos: Array = []
var lista_tarefas: Array = []

func tem_perfil_configurado() -> bool:
	return profissao_nome != "" and lista_tarefas.size() > 0
