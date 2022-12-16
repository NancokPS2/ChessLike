extends ItemList



func _ready():
	add_item("Back", null, true)
	add_item("Dummy ability", null, true)
	visible = false
	pass
	
func _process(delta):
	if is_selected(0) == true:
		$"../CommandList".visible = true
		visible = false
		unselect(0)
	elif is_selected(1) == true:
		unselect(1)


