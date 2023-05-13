extends Node

func _init() -> void:
	for state in GameBoard.States.keys():
		add_user_signal(state+"_enter")
		add_user_signal(state+"_exit")
	
	for state in GameBoard.CombatStates.keys():
		add_user_signal(state+"_enter")
		add_user_signal(state+"_exit")
		
		
##States
#signal SETUP_enter
#signal SETUP_exit
#
#signal COMBAT_enter
#signal COMBAT_exit
#
#signal PAUSE_enter
#signal PAUSE_exit
#
#signal END_enter
#signal END_exit
#
##Combat sub states
#signal STATE_CHANGE
#signal STATE_CHANGE_COMBAT
#
#signal COMBAT_MOVING_enter
#signal COMBAT_MOVING_exit
#
#signal COMBAT_ACTING_enter  
#signal COMBAT_ACTING_listabilities
#signal COMBAT_ACTING_miscoptions #used to select arbitrary options
#signal COMBAT_ACTING_abilitychosen
#signal COMBAT_ACTING_targetingmode
#signal COMBAT_ACTING_exit
#
#signal COMBAT_TARGETING_enter
#signal COMBAT_TARGETING_exit
#
#signal COMBAT_FACING_enter
#signal COMBAT_FACING_turnend
#signal COMBAT_FACING_exit
#
#
#
#signal COMBAT_IDLE_enter
#signal COMBAT_IDLE_exit

#GridMap signals
signal GRID_UNIT_HOVERED
signal GRID_UNIT_CLICKED

#UI Updates
signal UPDATE_UNIT_INFO

#Misc
signal GRID_TILE_CLICKED
signal UNIT_IN_TILE
signal OBJECT_IN_TILE
signal HINT_UPDATE
