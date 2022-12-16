extends Button
class_name ButtonStateChange
#Affects the desired state when pressed

enum stateTypes {MAIN,COMBAT}

export (bool) var activateOnRelease = true #Otherwise, it is when pressed
export (stateTypes) var stateToAffect #Which ofthe 2 states should be affected
export (GameBoard.states) var mainState
export (GameBoard.combatStates) var combatState
export (String) var freeOnSignal = ""

func _ready() -> void:
	if activateOnRelease:
		connect("button_up",self,"button_released")
	else:
		connect("button_down",self,"button_released")
		
	if freeOnSignal != "":
		Events.connect(freeOnSignal,self,"queue_free")
	
	
func button_released():
	if stateToAffect == stateTypes.MAIN:
		Ref.mainNode.change_state(mainState)
	elif stateToAffect == stateTypes.COMBAT:
		Ref.mainNode.change_combat_state(combatState)

