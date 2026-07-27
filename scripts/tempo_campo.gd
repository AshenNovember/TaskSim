extends OptionButton

func _ready():
	var menu_suspenso = get_popup()
	
	for i in range(menu_suspenso.item_count):
		menu_suspenso.set_item_as_radio_checkable(i, false)
		
	menu_suspenso.about_to_popup.connect(_arrumar_visual_do_menu)

func _arrumar_visual_do_menu():
	var menu_suspenso = get_popup()
	
	menu_suspenso.min_size.x = 0
