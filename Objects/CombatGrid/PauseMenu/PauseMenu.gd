extends CanvasLayer

func _ready() -> void:
	Events.PAUSE_enter.connect(game_paused.bind(true))
	Events.PAUSE_exit.connect(game_paused.bind(false))
	game_paused(false)
	
	$Buttons/Resume.button_up.connect(Callable(Events,"emit_signal").bind("STATE_CHANGE",GameBoard.states.COMBAT))

func game_paused(yes:bool):
	if yes:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		
	visible = yes

