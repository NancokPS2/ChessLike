extends Spatial
class_name GameBoard

enum states {SETUP,COMBAT,PAUSE,END}
var state:int

enum combatStates {IDLE,MOVING,ACTING,TARGETING,FACING}
var combatState:int

func _ready() -> void:
	Events.connect("COMBAT_ACTING_abilitychosen",self,"change_combat_state",[combatStates.TARGETING])
	
	Ref.mainNode = self
	change_state(states.SETUP)

	CVars.saveFile.setup()
	$UI/UnitList.populate_list(CVars.saveFile.playerUnits)#Put player units in the list
	
	
	


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
var mainVariants:Dictionary = {}#Stores variables that can be externally modified which are handled by the states below
var combatVariants:Dictionary = {
	"ABILITY_CHOSEN":null}
#Both unused

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
				pass
			combatStates.MOVING:
				Events.emit_signal("COMBAT_MOVING_exit")
				pass
			combatStates.ACTING:
				Events.emit_signal("COMBAT_ACTING_exit")
				pass
			combatStates.TARGETING:
				Events.emit_signal("COMBAT_TARGETING_exit")
				pass
			combatStates.FACING:
				Events.emit_signal("COMBAT_FACING_exit")
				pass
				
	match newState:#New state initialization
		combatStates.IDLE:
			Events.emit_signal("COMBAT_IDLE_enter")
			pass
		combatStates.MOVING:
			Events.emit_signal("COMBAT_MOVING_enter")
			pass
		combatStates.ACTING:
			Events.emit_signal("COMBAT_ACTING_enter")
			pass
		combatStates.TARGETING:
			Events.emit_signal("COMBAT_TARGETING_enter")
			pass
		combatStates.FACING:
			Events.emit_signal("COMBAT_FACING_enter")
			pass
	
	combatState = newState
				
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
		
func _unhandled_input(event: InputEvent) -> void:
	match state:
		states.SETUP:
			if event.is_action_released("primary_click"):#Unit placement
				if Ref.unitSelected is Unit:#If a unit has been selected
					$Grid.place_object(Ref.unitSelected,$Grid.hoveredCell,MovementGrid.objectTypes.UNITS)#Add unit to map in the highlighted cell in the UNITs section
					if Ref.unitsInBattle.find(Ref.unitSelected ) == -1 : #If the unit is not in battle...
						Ref.unitsInBattle.append(Ref.unitSelected )#Add it to the list
						
				else:#If not, select any clicked units
					Ref.unitSelected = $Grid.get_cell_occupant($Grid.hoveredCell)
			
			elif event.is_action_released("secondary_click"):
				var thingHovered = $Grid.get_cell_occupant($Grid.hoveredCell)
				if thingHovered is Unit:#If a unit was clicked
					$Grid.remove_object(thingHovered, $Grid.objectTypes.UNITS)#Remove it from the field
					Ref.unitsInBattle.remove( Ref.unitsInBattle.find(thingHovered) )#Remove it from the unit list
					
				Ref.unitSelected = null#Deselect the current unit
				$UI/InfoDisplay.clear_unit()
					
			elif event is InputEventMouseMotion and not Ref.unitSelected is Unit:#If no unit has been selected and one was moused over
				var target = $Grid.get_cell_occupant($Grid.hoveredCell)
				if target is Unit:
					$UI/InfoDisplay.load_unit(target)
				else:
					$UI/InfoDisplay.clear_unit()
					
		states.COMBAT:
			if event.is_action_released("primary_click"):#Unit selection
				if Ref.unitSelected is Unit:#If a unit has been selected
					pass#Nothing ATM
				else:#If not, select any clicked units
					Ref.unitSelected = $Grid.get_cell_occupant($Grid.hoveredCell)
			
			elif event.is_action_released("secondary_click"):
				Ref.unitSelected = null#Deselect the current unit
				$UI/InfoDisplay.clear_unit()
					
			elif event is InputEventMouseMotion and not Ref.unitSelected is Unit:#If no unit has been selected and one was moused over
				var target = $Grid.get_cell_occupant($Grid.hoveredCell)#Get the unit in the cell hovered
				if target is Unit:#If it is a unit, show their info
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
					
							
			
				combatStates.TARGETING:
					if event.is_action_released("primary_click"): #TODO
						pass
						
				combatStates.FACING:
					if event.is_action_released("primary_click"):
						Events.emit_signal("COMBAT_FACING_turnend")
						change_combat_state(combatStates.IDLE)
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
