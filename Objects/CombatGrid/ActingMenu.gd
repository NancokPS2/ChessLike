extends VBoxContainerCollapsable

func _ready() -> void:
	._ready()#Run the signal connections
	$Move.connect("button_up",self,"move_button")
	$Act.connect("button_up",self,"act_button")
	$EndTurn.connect("button_up",self,"end_turn_button")
	pass # Replace with function body.

func move_button():
	Ref.mainNode.change_combat_state(GameBoard.combatStates.MOVING)

func act_button():
	assert(Ref.unitInAction is Unit)
	Ref.mainNode.change_combat_state(GameBoard.combatStates.ACTING)
	Events.emit_signal("COMBAT_ACTING_listabilities")
	expand(false)#Hide
	
	
func end_turn_button():
	Ref.mainNode.change_combat_state(GameBoard.combatStates.FACING)
