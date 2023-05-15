extends Node3D
class_name GameBoard

enum States {SETUP,COMBAT,PAUSE,END}


enum CombatStates {
	IDLE,#Nothing is happening, actions are displayed
	ANIMATING,#Awaiting for a cell to be chosen in order to move to it
	ABILITY_TARGETING,
	FACING_SELECT,
	OFF_TURN
	}

var cellDict:Dictionary:
	set(val):
		pass
	get:
		if gridMap: return gridMap.cellDict
		else: push_error("No gridMap has been set."); return {}
	
var state:int
var combatState:int

@export_group("References")
@export var gridMap:MovementGrid
@export var unitList:UnitDisplay

var actingUnit:Unit
var abilityInUse:Ability

var cellFilters:Dictionary = {
	#True if it has a unit
	"HAS_UNIT":func(cell:Vector3i): return true if Ref.grid.search_in_tile(cell,MovementGrid.Searches.UNIT) is Unit else false,
	#True if there's not a unit
	"NOT_HAS_UNIT":func(cell:Vector3i): return false if Ref.grid.search_in_tile(cell,MovementGrid.Searches.UNIT) is Unit else true,
	#True if the tile has nothing in it
	"EMPTY_TILE":func(cell:Vector3i): return true if Ref.grid.search_in_tile(cell,MovementGrid.Searches.ANYTHING) == null else false
	
}

func _init() -> void:
	Ref.board = self
		
		



func _ready() -> void:

	#Setup
	Ref.mainNode = self
	change_state(States.SETUP)
	
	
	#State change buttons
#	$UI/ActingMenu/Move.button_up.connect( change_combat_state.bind(CombatStates.MOVING) )
#	$UI/ActingMenu/Act.button_up.connect( change_combat_state.bind(CombatStates.ACTING) )
#	$UI/ActingMenu/EndTurn.button_up.connect( change_combat_state.bind(CombatStates.FACING) )
	
	#State variant intake

enum typesOfInfo {POSITION,OBJECT}
func get_hovered(infoType:int = typesOfInfo.POSITION):#Returns the position or node hovered by the mouse
	var mousePos = get_viewport().get_mouse_position()
	var rayFrom = $Grid/CameraOrigin/Camera.project_ray_origin(mousePos)
	var rayTo = rayFrom + $Grid/CameraOrigin/Camera.project_ray_normal(mousePos) * 6000
	var spaceState = get_world_3d().direct_space_state
	var physicsRay:=PhysicsRayQueryParameters3D.create(rayFrom, rayTo)
	var selection = spaceState.intersect_ray(physicsRay)
	
	match infoType:
		typesOfInfo.OBJECT:
			return selection.get("collider",null)
		
		typesOfInfo.POSITION:
			return selection.get("position",Vector3.ZERO)-Vector3(0,0.1,0)


#State handling
var stateVariants:Dictionary = {
	"abilityChosen":null,
	"targetedCells":[]
}#Stores variables that can be externally modified which are handled by the States below
func state_variant_update(variantName:String,value):
	stateVariants[variantName] = value


func change_state(newState:int):
	
	if newState != state:#Handle exiting the current state
		match state:
			States.SETUP:
				Events.emit_signal("SETUP_exit")
			States.COMBAT:
				Events.emit_signal("COMBAT_exit")
			States.PAUSE:
				Events.emit_signal("PAUSE_exit")
				get_tree().paused = false
			States.END:
				Events.emit_signal("END_exit")
	
	match newState:#Entering the new state
		States.SETUP:
			Events.emit_signal("SETUP_enter")
			pass
		States.COMBAT:
			Events.emit_signal("COMBAT_enter")
			pass
		States.PAUSE:
			Events.emit_signal("PAUSE_enter")
			get_tree().paused = false
		States.END:
			Events.emit_signal("END_enter")
			pass

	state = newState#Change the recorded state

func change_combat_state(newState:CombatStates):
	if combatState != newState:#Exiting current state
		match combatState:
			CombatStates.IDLE:
				Events.emit_signal("COMBAT_IDLE_exit")

#			CombatStates.MOVING:
#				Events.emit_signal("COMBAT_MOVING_exit")
#				$Grid.clear_targeting_grids()
#				stateVariants["targetedCells"] = []
#
#
#			CombatStates.ACTING:
#				Events.emit_signal("COMBAT_ACTING_exit")
#				$Grid.clear_targeting_grids()
			CombatStates.ANIMATING:
				Events.emit_signal("ANIMATING_exit")
				pass

			CombatStates.ABILITY_TARGETING:
				Events.emit_signal("ABILITY_TARGETING_exit")
				$Grid.clear_targeting_grids()
				stateVariants["abilityChosen"] = null

			CombatStates.FACING_SELECT:
				Events.emit_signal("FACING_SELECT_exit")
				stateVariants["abilityChosen"] = null

				
	match newState:#New state initialization
		CombatStates.IDLE:
			Events.emit_signal("COMBAT_IDLE_enter")
			stateVariants["abilityChosen"] = null

			
#		CombatStates.MOVING:
#			Events.emit_signal("COMBAT_MOVING_enter")
#			$Grid.mark_cells_for_movement()
#			stateVariants["targetedCells"] = $Grid.ABILITY_TARGETING.get_used_cells()#Store valid cells for movement or ABILITY_TARGETING
#
#		CombatStates.ACTING:
#			Events.emit_signal("COMBAT_ACTING_enter")
#			#ActionsMenu.gd:_ready() takes care of filling the abilities
		CombatStates.ANIMATING:
			Events.emit_signal("ANIMATING_enter")
			pass
			
		CombatStates.ABILITY_TARGETING:#Called by ActionsMenu.gd: press_button()
			Events.emit_signal("ABILITY_TARGETING_enter")
			$Grid.mark_cells_for_targeting(stateVariants["abilityChosen"])
			stateVariants["targetedCells"] = $Grid.ABILITY_TARGETING.get_used_cells()#Store valid cells for movement or ABILITY_TARGETING
			print(stateVariants["targetedCells"])#TEMP
			
		CombatStates.FACING_SELECT:
			Events.emit_signal("FACING_SELECT_enter")
			pass
	
	combatState = newState
	
#func _unhandled_input(event: InputEvent) -> void:
#	$Grid.update_hovered_cell()
#	match state:
#		States.SETUP:
#			if event.is_action_released("primary_click"):#Unit placement
#				if Ref.unitSelected != null:#If a unit has been selected
#					$Grid.place_object(Ref.unitSelected,$Grid.hoveredCell,MovementGrid.objectTypes.UNITS)#Add unit to map in the highlighted cell in the UNITs section
#					if Ref.unitsInBattle.find(Ref.unitSelected ) == -1 : #If the unit is not in battle...
#						Ref.unitsInBattle.append(Ref.unitSelected )#Add it to the list
#
#				else:#If not, select any clicked units
#					Ref.unitSelected = $Grid.get_cell_occupant($Grid.hoveredCell)
#
#			elif event.is_action_released("secondary_click"):
#				var thingHovered = $Grid.get_cell_occupant($Grid.hoveredCell)
#				if thingHovered and thingHovered.get("isUnit"):#If a unit was clicked
#					$Grid.remove_object(thingHovered, $Grid.objectTypes.UNITS)#Remove it from the field
#					Ref.unitsInBattle.erase( thingHovered )#Remove it from the unit list
#
#				Ref.unitSelected = null#Deselect the current unit
#				$UI/InfoDisplay.clear_unit()
#
#			elif event is InputEventMouseMotion and Ref.unitSelected == null:#If no unit has been selected and one was moused over
#				var target = $Grid.get_cell_occupant($Grid.hoveredCell)
#				if target and target.get("isUnit"):
#					$UI/InfoDisplay.load_unit(target)
#				else:
#					$UI/InfoDisplay.clear_unit()
#
#		States.COMBAT:
#			if event.is_action_released("primary_click"):#Unit selection
#				if Ref.unitSelected and Ref.unitSelected.get("isUnit"):#If a unit has been selected
#					pass#Nothing ATM
#				else:#If not, select any clicked units
#					Ref.unitSelected = $Grid.get_cell_occupant($Grid.hoveredCell)
#
#			elif event.is_action_released("secondary_click"):
#				Ref.unitSelected = null#Deselect the current unit
#				$UI/InfoDisplay.clear_unit()
#
#			elif event is InputEventMouseMotion and Ref.unitSelected == null:#If no unit has been selected and one was moused over
#				var target = $Grid.get_cell_occupant($Grid.hoveredCell)#Get the unit in the cell hovered
#				if target and target.get("isUnit"):#If it is a unit, show their info
#					$UI/InfoDisplay.load_unit(target)
#				else:#Otherwise clear it
#					$UI/InfoDisplay.clear_unit()
#
#			match combatState:
#				CombatStates.MOVING:
#					if event.is_action_released("primary_click"):
#
#						if Ref.unitInAction.stats.moves <= 0:#Not enough moves
#							Events.emit_signal("HINT_UPDATE","UI_NOT_ENOUGH_MOVES") #Anounce it
#
#						elif $Grid.get_cell_occupant($Grid.hoveredCell) == null:#Check if the cell is empty
#							$Grid.place_object(Ref.unitInAction,$Grid.hoveredCell)#Move the unit there
#							Ref.unitInAction.stats["moves"] -= 1#Reduce the amount of moves remaining
#							change_combat_state(CombatStates.IDLE)#Change to IDLE state
#
#					if event.is_action_released("go_back"):#Exit ABILITY_TARGETING mode
#						change_combat_state(CombatStates.IDLE)
#
#
#				CombatStates.ACTING:
#					if event.is_action_released("NOMAP_ability_chosen"):
#						assert(event.get_meta("ability",null) != null)
#						stateVariants["abilityChosen"] = event.get_meta("ability",null)
#						change_combat_state(CombatStates.ABILITY_TARGETING)
#
#				CombatStates.ABILITY_TARGETING:
#					assert(stateVariants["abilityChosen"] != null, "abilityChosen is null!")  
#					$Grid.mark_cells_for_aoe($Grid.hoveredCell,stateVariants["abilityChosen"])
#
#					if event.is_action_released("primary_click"): 
#						var parameters:Dictionary
#						var target
#
#
#						if stateVariants.targetedCells.has($Grid.hoveredCell):#Check if it is valid	
#							target = $Grid.get_cell_occupant($Grid.hoveredCell,$Grid.objectTypes.UNITS)#Get who is in that cell
#
#							if target == null:#Get an object if there's no unit
#								target = $Grid.get_cell_occupant($Grid.hoveredCell,$Grid.objectTypes.OBJECTS)#Get who is in that cell
#
#							if target:#If the target is valid, add it
#								parameters["target"] = target
#								stateVariants["abilityChosen"].use(parameters)
#
#
#						else:
#							push_warning( "Tried to target non-highlighted cell " + str($Grid.hoveredCell) )
#						pass
#					if event.is_action_released("go_back"):#Exit ABILITY_TARGETING mode
#						change_combat_state(CombatStates.ACTING)
#
#				CombatStates.FACING:
#					if event.is_action_released("primary_click"):
#						Events.emit_signal("COMBAT_FACING_exit")
#						change_combat_state(CombatStates.IDLE)
#						pass
#
#		States.PAUSE:
#			pass
#		States.END:
#			pass
	
func _process(delta: float) -> void:
	match state:
		States.SETUP:
			pass
			
		States.COMBAT:
			pass
				
		States.PAUSE:
			pass
			
		States.END:
			pass

	

class Cell extends Area3D:
	var mesh:Mesh
	
