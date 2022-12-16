extends ItemList



func _ready():
	add_item("Back", null, true)
	add_item("Dummy ability", null, true)
	pass
	
func _process(delta):
	if is_selected(0) == true:
		$"../CommandList".visible = true
		visible = false
	elif is_selected(1) == true:
		Globalvars.battleText = "This ability does nothing!"
		unselect(1)


