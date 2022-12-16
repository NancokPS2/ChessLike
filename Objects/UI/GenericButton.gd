extends Button

export

func _ready() -> void:
	connect("button_up",self,"released")
	
func released():
	Ref.mainNode.change_state(GameBoard.states.COMBAT)


