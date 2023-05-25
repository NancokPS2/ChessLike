extends Node

#Global
var saveFile:SaveFile = SaveFile.new()
var playerFaction="PLAYER"
var currentMap:Map = Map.new()

#Settings
var settingsFile:ConfigFile
var settingCameraSpeed:float = 3
var settingDebugMode:bool = true
var settingUsingController:bool = false

#Combat prep
var prepUnitToPlace:Node#Stores a node during preparation

func get_setting(settingName:String):
	if not settingsFile is ConfigFile: push_error("There is no settingsFile loaded"); return null
	settingsFile.get_value("MAIN", settingName)
func set_setting(settingName:String, value):
	if not settingsFile is ConfigFile: push_error("There is no settingsFile loaded"); return
	settingsFile.set_value("MAIN", settingName, value)
	pass

