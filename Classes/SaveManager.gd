extends Node
class_name SaveManager

func create_empty_save_file(fileName:String):
	var dir = Directory.new()
	dir.open(Const.dirSaves)
	var saveFile = SaveLoad.SaveFile.new()
	saveFile.set_name(fileName)
	ResourceSaver.save(Const.dirSaves + fileName+".tres", saveFile)

func prepare_basic_save_file(fileName:String):
	create_empty_save_file(fileName)
	var saveFile = load(Const.dirSaves + fileName + ".tres")
	saveFile.playerUnits.append(load("res://Resources/Characters/UniqueCharacters/Misha.tres"))
	save_game(saveFile)
	
func get_save_file(fileName:String)->Resource:
	var dir = Directory.new()
	dir.open(Const.dirSaves)
	return load(Const.dirSaves + fileName+ ".tres")

func save_game(file:SaveLoad.SaveFile):
	var dir = Directory.new()
	dir.open(Const.dirSaves)
	ResourceSaver.save(Const.dirSaves + file.get_name() + ".tres", file)

