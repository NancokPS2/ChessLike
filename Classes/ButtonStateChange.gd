extends Button
class_name ButtonStateChange
#Affects the desired state when pressed

enum stateTypes {MAIN,COMBAT}

@export var activateOnRelease:bool = true #Otherwise, it is when pressed
@export var stateToAffect:stateTypes #Which ofthe 2 states should be affected
@export var mainState:GameBoard.states
@export var combatState:GameBoard.combatStates
@export var freeOnSignal:String = ""

func _ready() -> void:
	if activateOnRelease:
		button_up.connect(button_released)
	else:
		button_down.connect(button_released)
		
	if freeOnSignal != "":
		Signal(Events,freeOnSignal).connect(queue_free)
	
	
func button_released():
	if stateToAffect == stateTypes.MAIN:
		Ref.mainNode.change_state(mainState)
	elif stateToAffect == stateTypes.COMBAT:
		Ref.mainNode.change_combat_state(combatState)

