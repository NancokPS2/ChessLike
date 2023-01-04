extends VBoxContainerCollapsable

func _ready() -> void:
	._ready()#Run the signal connections
	Events.connect("COMBAT_IDLE_enter",self,"expand",[true])
	Events.connect("COMBAT_IDLE_exit",self,"expand",[false])

func move_button():
	Events.emit_signal("STATE_CHANGE_COMBAT",GameBoard.combatStates.MOVING)
	expand(false)#Hide

func act_button():
	assert(Ref.unitInAction is Unit)
	Events.emit_signal("STATE_CHANGE_COMBAT",GameBoard.combatStates.ACTING)
	expand(false)#Hide
	
	
func end_turn_button():
	Events.emit_signal("STATE_CHANGE_COMBAT",GameBoard.combatStates.FACING)
