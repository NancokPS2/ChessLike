extends Node
#Global
var saveFile:SaveFile = SaveFile.new()
var playerFaction="PLAYER"
var currentMap:Map = Map.new()

#Settings
var settingCameraSpeed:float = 3
var settingDebugMode:bool = true
var settingUsingController:bool = false

#Combat prep
var prepUnitToPlace:Node#Stores a node during preparation




#States
enum controlStates{SETUP,COMBAT,PAUSE,END}
var controlState
