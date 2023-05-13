extends Control



func _ready() -> void: #Setup
	$MainButtons/Play.connect("button_up",self,"activate_group",["START_LOAD"])
	$MainButtons/Exit.connect("button_up",self,"quit_game")
	
	$Back.connect("button_up",self,"activate_group",["MAIN"])
	$PlayMenu/NewGame.connect("button_up",self,"activate_group",["NEW_GAME"])
	
	$NewGamePrompt/Back.connect("button_up",self,"activate_group",["START_LOAD"])
	$NewGamePrompt.connect("create_save",$PlayMenu,"create_save")
	
	activate_group("MAIN")
	
	
func quit_game():
	get_tree().quit()

func activate_group(group:String):
	for child in get_children():#Deactivate all children
		child.hide()
		child.pause_mode = PAUSE_MODE_STOP
		
	for node in get_tree().get_nodes_in_group(group):#Activate the ones that should be active
		node.show()
		node.pause_mode = PAUSE_MODE_INHERIT

