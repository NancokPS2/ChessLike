extends VBoxContainerCollapsable

func _ready() -> void:
	._ready()#Run the signal connections
	$Move.connect("button_up",self,"move_button")
	$Act.connect("button_up",self,"act_button")
	$EndTurn.connect("button_up",self,"end_turn_button")
	pass # Replace with function body.

func move_button():
	pass

func act_button():
	expand(false)#Hide
	Ref.UITree.get_node("ActionsMenu").expand(true)#Show the ActionsMenu
	
	
	pass
	
func end_turn_button():
	pass
