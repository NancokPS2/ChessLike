extends VBoxContainer

const saveButton = preload("res://Objects/MainMenu/Saves/SaveFileButton.tscn")

signal save_selected

var saveFiles:Array

onready var saveBtnGroup = ButtonGroup.new() 

func _ready() -> void:
	load_saves()

func load_saves():#Loads all saves and creates a button for each
	for button in saveBtnGroup.get_buttons():
		button.queue_free()
		
	var savePaths = Utility.FileManipulation.get_folders_in_folder(Const.dirSaves)#Get all save file paths
	for path in savePaths:
		var configFile:ConfigFile = ConfigFile.new()
		configFile.load(path+"/save.tactsav")
		var saveData = configFile
		add_save_button(saveData)#Add it to the list
		


func add_save_button(saveFile:ConfigFile):
	var file = saveFile
	if not file is ConfigFile:#Ensure it is a config file
		file = SaveLoad.Manager.save_to_config(file)
		
	var button:Button = saveButton.instance()
	print( str(file.get_section_keys("main")) )
	button.text = file.get_value("main","saveName")
	button.saveFileStored = file
	add_child(button)
	button.group = saveBtnGroup
	button.connect("button_up",self,"emit_signal",["save_selected",button.saveFileStored])
	

	

	
