extends Spatial
class_name GameBoard

enum states {SETUP,COMBAT,PAUSE,END}
var state:int

enum movementFlags {AGILE,GROUNDED,FLYING,FLOATING}
enum targetingFlags {NO_OBJECTS,NO_UNITS}

enum combatStates {
	IDLE,#Nothing is happening, actions are displayed
	MOVING,#Awaiting for a cell to be chosen in order to move to it
	ACTING,
	TARGETING,
	FACING}
var combatState:int

func _ready() -> void:

	#Setup
	Ref.mainNode = self
	change_state(states.SETUP)
	
	#Connect main signals
	Events.connect("STATE_CHANGE",self,"change_state")
	Events.connect("STATE_CHANGE_COMBAT",self,"change_combat_state")
	
	#State change buttons
	$UI/ActingMenu/Move.connect("button_up",self,"change_combat_state",[combatStates.MOVING])
	$UI/ActingMenu/Act.connect("button_up",self,"change_combat_state",[combatStates.ACTING])
	$UI/ActingMenu/EndTurn.connect("button_up",self,"change_combat_state",[combatStates.FACING])
	
	#State variant intake
	#UNUSED
	
	CVars.saveFile.setup()#Prepare save file
	Ref.unitsBenched = CVars.saveFile.playerUnits
	$UI/UnitList.populate_list(Ref.unitsBenched)#Put player units in the list

func _input(event: InputEvent) -> void:#Update hovered cell position	
	#$DebugLabel.text = str( get_hovered(typesOfInfo.POSITION) )#TEMP
	$DebugLabel.text = str(Ref.unitsInBattle)
	$DebugMesh.translation = get_hovered(typesOfInfo.POSITION)#TEMP

enum typesOfInfo {POSITION,OBJECT}
func get_hovered(infoType:int = typesOfInfo.POSITION):#Returns the position or node hovered by the mouse
	var mousePos = get_viewport().get_mouse_position()
	var rayFrom = $Grid/CameraOrigin/Camera.project_ray_origin(mousePos)
	var rayTo = rayFrom + $Grid/CameraOrigin/Camera.project_ray_normal(mousePos) * 6000
	var spaceState = get_world().direct_space_state
	var selection = spaceState.intersect_ray(rayFrom, rayTo)
	
	match infoType:
		typesOfInfo.OBJECT:
			return selection.get("collider",null)
		
		typesOfInfo.POSITION:
			return selection.get("position",Vector3.ZERO)-Vector3(0,0.1,0)


#State handling
var stateVariants:Dictionary = {
	"abilityChosen":null,
	"targetedCells":[]
}#Stores variables that can be externally modified which are handled by the states below
func state_variant_update(variantName:String,value):
	stateVariants[variantName] = value


func change_state(newState:int):
	
	if newState != state:#Handle exiting the current state
		match state:
			states.SETUP:
				Events.emit_signal("SETUP_exit")
			states.COMBAT:
				Events.emit_signal("COMBAT_exit")
			states.PAUSE:
				Events.emit_signal("PAUSE_exit")
				get_tree().paused = false
			states.END:
				Events.emit_signal("END_exit")
	
	match newState:#Entering the new state
		states.SETUP:
			Events.emit_signal("SETUP_enter")
			pass
		states.COMBAT:
			Events.emit_signal("COMBAT_enter")
			pass
		states.PAUSE:
			Events.emit_signal("PAUSE_enter")
			get_tree().paused = false
		states.END:
			Events.emit_signal("END_enter")
			pass

	state = newState#Change the recorded state

func change_combat_state(newState:int):
	if combatState != newState:#Exiting current state
		match combatState:
			combatStates.IDLE:
				Events.emit_signal("COMBAT_IDLE_exit")

			combatStates.MOVING:
				Events.emit_signal("COMBAT_MOVING_exit")
				$Grid.clear_targeting_grids()
				stateVariants["targetedCells"] = []
					

			combatStates.ACTING:
				Events.emit_signal("COMBAT_ACTING_exit")
				$Grid.clear_targeting_grids()

			combatStates.TARGETING:
				Events.emit_signal("COMBAT_TARGETING_exit")
				$Grid.clear_targeting_grids()
				stateVariants["abilityChosen"] = null

			combatStates.FACING:
				Events.emit_signal("COMBAT_FACING_exit")
				stateVariants["abilityChosen"] = null

				
	match newState:#New state initialization
		combatStates.IDLE:
			Events.emit_signal("COMBAT_IDLE_enter")
			stateVariants["abilityChosen"] = null


		combatStates.MOVING:
			Events.emit_signal("COMBAT_MOVING_enter")
			$Grid.mark_cells_for_movement()
			stateVariants["targetedCells"] = $Grid.targeting.get_used_cells()#Store valid cells for movement or targeting
			
		combatStates.ACTING:
			Events.emit_signal("COMBAT_ACTING_enter")
			#ActionsMenu.gd:_ready() takes care of filling the abilities

		combatStates.TARGETING:#Called by ActionsMenu.gd: press_button()
			Events.emit_signal("COMBAT_TARGETING_enter")
			$Grid.mark_cells_for_targeting(stateVariants["abilityChosen"])
			stateVariants["targetedCells"] = $Grid.targeting.get_used_cells()#Store valid cells for movement or targeting
			print(stateVariants["targetedCells"])#TEMP
			
		combatStates.FACING:
			Events.emit_signal("COMBAT_FACING_enter")
			pass
	
	combatState = newState
	
func _unhandled_input(event: InputEvent) -> void:
	$Grid.update_hovered_cell()
	match state:
		states.SETUP:
			if event.is_action_released("primary_click"):#Unit placement
				if Ref.unitSelected != null:#If a unit has been selected
					$Grid.place_object(Ref.unitSelected,$Grid.hoveredCell,MovementGrid.objectTypes.UNITS)#Add unit to map in the highlighted cell in the UNITs section
					if Ref.unitsInBattle.find(Ref.unitSelected ) == -1 : #If the unit is not in battle...
						Ref.unitsInBattle.append(Ref.unitSelected )#Add it to the list
						
				else:#If not, select any clicked units
					Ref.unitSelected = $Grid.get_cell_occupant($Grid.hoveredCell)
			
			elif event.is_action_released("secondary_click"):
				var thingHovered = $Grid.get_cell_occupant($Grid.hoveredCell)
				if thingHovered and thingHovered.get("isUnit"):#If a unit was clicked
					$Grid.remove_object(thingHovered, $Grid.objectTypes.UNITS)#Remove it from the field
					Ref.unitsInBattle.remove( Ref.unitsInBattle.find(thingHovered) )#Remove it from the unit list
					
				Ref.unitSelected = null#Deselect the current unit
				$UI/InfoDisplay.clear_unit()
					
			elif event is InputEventMouseMotion and Ref.unitSelected == null:#If no unit has been selected and one was moused over
				var target = $Grid.get_cell_occupant($Grid.hoveredCell)
				if target and target.get("isUnit"):
					$UI/InfoDisplay.load_unit(target)
				else:
					$UI/InfoDisplay.clear_unit()
					
		states.COMBAT:
			if event.is_action_released("primary_click"):#Unit selection
				if Ref.unitSelected and Ref.unitSelected.get("isUnit"):#If a unit has been selected
					pass#Nothing ATM
				else:#If not, select any clicked units
					Ref.unitSelected = $Grid.get_cell_occupant($Grid.hoveredCell)
			
			elif event.is_action_released("secondary_click"):
				Ref.unitSelected = null#Deselect the current unit
				$UI/InfoDisplay.clear_unit()
					
			elif event is InputEventMouseMotion and Ref.unitSelected == null:#If no unit has been selected and one was moused over
				var target = $Grid.get_cell_occupant($Grid.hoveredCell)#Get the unit in the cell hovered
				if target and target.get("isUnit"):#If it is a unit, show their info
					$UI/InfoDisplay.load_unit(target)
				else:#Otherwise clear it
					$UI/InfoDisplay.clear_unit()

			match combatState:
				combatStates.MOVING:
					if event.is_action_released("primary_click"):
		
						if Ref.unitInAction.stats.moves <= 0:#Not enough moves
							Events.emit_signal("HINT_UPDATE","UI_NOT_ENOUGH_MOVES") #Anounce it
						
						elif $Grid.get_cell_occupant($Grid.hoveredCell) == null:#Check if the cell is empty
							$Grid.place_object(Ref.unitInAction,$Grid.hoveredCell)#Move the unit there
							Ref.unitInAction.stats["moves"] -= 1#Reduce the amount of moves remaining
							change_combat_state(combatStates.IDLE)#Change to IDLE state
							
					if event.is_action_released("go_back"):#Exit targeting mode
						change_combat_state(combatStates.IDLE)
					
				
				combatStates.ACTING:
					if event.is_action_released("NOMAP_ability_chosen"):
						assert(event.get_meta("ability",null) != null)
						stateVariants["abilityChosen"] = event.get_meta("ability",null)
						change_combat_state(combatStates.TARGETING)
							
				combatStates.TARGETING:
					assert(stateVariants["abilityChosen"] != null, "abilityChosen is null!")  
					$Grid.mark_cells_for_aoe($Grid.hoveredCell,stateVariants["abilityChosen"])

					if event.is_action_released("primary_click"): 
						var parameters:Dictionary
						var target
						

						if stateVariants.targetedCells.has($Grid.hoveredCell):#Check if it is valid	
							target = $Grid.get_cell_occupant($Grid.hoveredCell,$Grid.objectTypes.UNITS)#Get who is in that cell
							
							if target == null:#Get an object if there's no unit
								target = $Grid.get_cell_occupant($Grid.hoveredCell,$Grid.objectTypes.OBJECTS)#Get who is in that cell
							
							if target:#If the target is valid, add it
								parameters["target"] = target
								stateVariants["abilityChosen"].use(parameters)
							
							
						else:
							push_warning( "Tried to target non-highlighted cell " + str($Grid.hoveredCell) )
						pass
					if event.is_action_released("go_back"):#Exit targeting mode
						change_combat_state(combatStates.ACTING)
						
				combatStates.FACING:
					if event.is_action_released("primary_click"):
						Events.emit_signal("COMBAT_FACING_exit")
						change_combat_state(combatStates.IDLE)
						pass

		states.PAUSE:
			pass
		states.END:
			pass
	
func _process(delta: float) -> void:
	match state:
		states.SETUP:
			pass
			
		states.COMBAT:
			pass
				
		states.PAUSE:
			pass
			
		states.END:
			pass

#func activate_nodes(group:String,controlVisibility:bool = false):#Only unpauses and shows the required nodes
#	for child in get_children():#Pause all children
#		child.pause_mode = Node.PAUSE_MODE_STOP
#		if controlVisibility:#Also hide if chosen
#			child.hide()
#
#	get_tree().set_group(group,"pause_mode",Node.PAUSE_MODE_PROCESS)#Unpause the required nodes
#	if controlVisibility:
#		get_tree().call_group(group,"show")#Show the nodes if controling that
