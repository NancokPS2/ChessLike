extends VBoxContainerCollapsable

func _ready() -> void:
	._ready()#Run the signal connections

func move_button():
	Events.emit_signal("STATE_CHANGE_COMBAT",GameBoard.combatStates.MOVING)

func act_button():
	assert(Ref.unitInAction is Unit)
	Events.emit_signal("STATE_CHANGE_COMBAT",GameBoard.combatStates.ACTING)
	Events.emit_signal("COMBAT_ACTING_listabilities")
	expand(false)#Hide
	
	
func end_turn_button():
	Events.emit_signal("STATE_CHANGE_COMBAT",GameBoard.combatStates.FACING)
