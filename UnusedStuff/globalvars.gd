extends Node


#Basic config
var mapSpacing = 128
var saveSlot = 1
var savePaths = {
	"playerUnits": "res://saves/slot"  + str(saveSlot) + "/playerUnits.json"
	}

#Misc variables
var chosenMap = 0
	
#Used to point to a unit's index on the SavedUnits.unitList/enemyList array
var selectedUnit = 0
var chosenEnemy = -1

# Used in the Combat Field scene similarly to the previous example
var fieldPanelChosenUnit = 0
var fieldPanelChosenEnemy = -1
var fieldChosenUnitStats = -1
var targetingIndex = 0
var UnitForPlacement = -1


# Used to know if the target is an ally
var friendlyTarget = 0

# Self explanatory
var partySize = 0

# Mouse input related variables
var clickReady = true

var mousePositionVector = Vector2(0,0)

var normGridPos = Vector2(0,0)


