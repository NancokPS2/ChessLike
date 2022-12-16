extends Control

	
func create_save(saveName:String):
	var save = SaveLoad.SaveFile.new()
	save.set_value("main","saveName",saveName)
	SaveLoad.Manager.save_game(save)
	$Saves/SaveList.load_saves()

