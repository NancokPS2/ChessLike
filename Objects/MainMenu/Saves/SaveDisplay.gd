extends Panel

var save

func _on_save_selected(saveFile:ConfigFile) -> void:
	save = saveFile
	$SaveName.text = save.get_value("main","saveName","ERR_NOT_SET")#Set the name
	
	var icon = load( save.get_value("main","icon") )#Load the icon
	if icon == null:#In case it does not exist
		icon = load( "res://Assets/WIPs/ClassIcons/template.png" )
		
	$SaveIcon.texture = icon#Add it
	


func _on_Load_button_up() -> void:
	CVars.saveFile = save
	get_tree().change_scene("res://DummyScene.tscn")
	pass # Replace with function body.


func _on_SaveList_save_selected() -> void:
	pass # Replace with function body.
