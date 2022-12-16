extends Node
#Global
var saveFile:SaveLoad.SaveFile = SaveLoad.SaveFile.new()
var playerFaction="PLAYER"
var currentMap:Map = Map.new()

#Settings
var settingCameraSpeed:int = 20
var settingDebugMode:bool = true
var settingUsingController:bool = false

#Combat prep
var prepUnitToPlace:Node#Stores a node during preparation




#States
enum controlStates{SETUP,COMBAT,PAUSE,END}
var controlState
