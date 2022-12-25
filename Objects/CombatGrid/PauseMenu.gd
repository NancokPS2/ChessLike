extends CanvasLayer

func _ready() -> void:
	Events.connect("PAUSE_enter",self,"game_paused",[true])
	Events.connect("PAUSE_exit",self,"game_paused",[false])
	game_paused(false)

func game_paused(yes:bool):
	if yes:
		pause_mode = PAUSE_MODE_PROCESS
	else:
		pause_mode = PAUSE_MODE_STOP
		
	visible = yes
