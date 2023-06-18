extends Node

#Global
var saveFile:SaveFile = load("res://Resources/SaveFile/DefaultSave.tres")
var currentMap:Map = Map.new()

#Settings
var settingsFile:ConfigFile
var settingCameraSpeed:float = 3
var settingDebugMode:bool = true
var settingUsingController:bool = false
