extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Basic_button_down():
	var selUnit = Globalvars.selectedUnit
	var classList = Globalrole.classList
	SavedUnits.unitList[selUnit][3] = 0
	for index in range(3, UnitStats.unitStatNames.size() -1):
		print(index)
		SavedUnits.unitList[selUnit][index] = classList[0][index] * UnitStats.playerBaseStats[index]
	pass # Replace with function body.



func _on_Knight_button_down():
	var selUnit = Globalvars.selectedUnit
	var classList = Globalrole.classList
	SavedUnits.unitList[selUnit][3] = 1
	for index in range(3, UnitStats.unitStatNames.size() -1):
		print(index)
		SavedUnits.unitList[selUnit][index] = classList[1][index] * UnitStats.playerBaseStats[index]
	pass


func _on_Thief_button_down():
	var selUnit = Globalvars.selectedUnit
	var classList = Globalrole.classList
	SavedUnits.unitList[selUnit][3] = 2
	for index in range(3, UnitStats.unitStatNames.size() -1):
		print(index)
		SavedUnits.unitList[selUnit][index] = classList[2][index] * UnitStats.playerBaseStats[index]
	pass # Replace with function body.


func _on_Wizard_button_down():
	var selUnit = Globalvars.selectedUnit
	var classList = Globalrole.classList
	SavedUnits.unitList[selUnit][3] = 3
	for index in range(3, UnitStats.unitStatNames.size() -1):
		SavedUnits.unitList[selUnit][index] = classList[3][index] * UnitStats.playerBaseStats[index]
	pass # Replace with function body.
