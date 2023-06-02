extends Node3D
class_name GameBoard

signal units_changed

enum States {SETUP,COMBAT,PAUSE,END}


enum CombatStates {
	C_IDLE,#Nothing is happening, actions are displayed
	C_ANIMATING,#Awaiting for a cell to be chosen in order to move to it
	C_ABILITY_TARGETING,
	C_FACING_SELECT,
	C_OFF_TURN
	}

#var cellDict:Dictionary:
#	set(val):
#		pass
#	get:
#		if gridMap: return gridMap.cellDict
#		else: push_error("No gridMap has been set."); return {}
	


@export_group("References")
@export var gridMap:MovementGrid
@export var unitList:UnitDisplayManager
@export var menuCombat:NestedMenu

@export var endTurnButton:Button

@export_group("Map")
@export var currentMap:Map:
	set(val):
		currentMap = val
		if currentMap is Map and gridMap is MovementGrid:
			gridMap.mesh_library = currentMap.meshLibrary
			
			gridMap.clear()
			for cellData in currentMap.terrainCells:
				gridMap.set_cell_item(cellData[1],cellData[0])
			gridMap.update_grid(currentMap)
			
			
var state:int
var combatState:int

var actingUnit:Unit:
	set(val):
		actingUnit = val
		if actingUnit is Unit:
			update_menus_to_unit(actingUnit)
			assert(actingUnit.is_in_group(Const.Groups.UNIT))
			
var unitsInCombat:Array[Unit]
		
var abilityInUse:Ability:
	set(val):
		abilityInUse = val
		$Debug.text = abilityInUse.displayedName

var targetedCells:Array[Vector3i]
var actionStack:Array[Tween]

var picker:Picker3D = Picker3D.new()


func _init() -> void:
	Ref.board = self
	
	
func _enter_tree() -> void:
	#Add unit when it enters the tree
	var registerUnit:Callable = func(node): 
		if node is Unit and node.get_parent() == self: 
			unitsInCombat.append(node); emit_signal("units_changed")
			
	get_tree().node_added.connect(registerUnit)
	
	
	
func _ready() -> void:
	#Setup
	gridMap = Ref.grid
	currentMap = currentMap
	gridMap.cell_clicked.connect(on_cell_clicked)
	picker.user = self
	Signal(Events,"C_ABILITY_TARGETING_exit").connect(set.bind("abilityInUse", null))
	endTurnButton.pressed.connect(turn_cycle)
#	Ref.mainNode = self
	change_state(States.SETUP)
	
	
	testing()


	
func run_stack():
	change_combat_state(CombatStates.C_ANIMATING)
	for tween in actionStack:
		tween.play()
		await tween.finished

	actionStack.clear()
		
	
func testing():
	actingUnit = $Unit
	unitList.refresh_units([actingUnit])
#	abilityInUse = $Unit.attributes.abilities[0]
#	change_combat_state(CombatStates.C_ABILITY_TARGETING)
#	gridMap.mark_cells([Vector3.ZERO])
#	menuCombat = $UI/CombatMenu
#	update_menus_to_unit($Unit)
	#State change buttons
#	$UI/ActingMenu/Move.button_up.connect( change_combat_state.bind(CombatStates.MOVING) )
#	$UI/ActingMenu/Act.button_up.connect( change_combat_state.bind(CombatStates.ACTING) )
#	$UI/ActingMenu/EndTurn.button_up.connect( change_combat_state.bind(CombatStates.FACING) )


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
			get_tree().paused = true
		States.END:
			Events.emit_signal("END_enter")
			pass

	state = newState#Change the recorded state

func change_combat_state(newState:CombatStates):
	if combatState != newState:#Exiting current state
		match combatState:
			CombatStates.C_IDLE:
				Events.emit_signal("C_IDLE_exit")

			CombatStates.C_ANIMATING:
				Events.emit_signal("C_ANIMATING_exit")


			CombatStates.C_ABILITY_TARGETING:
				Events.emit_signal("C_ABILITY_TARGETING_exit")
				gridMap.mark_cells([])
				abilityInUse = null
				targetedCells.clear()

			CombatStates.C_FACING_SELECT:
				Events.emit_signal("C_FACING_SELECT_exit")

				
	match newState:#New state initialization
		CombatStates.C_IDLE:
			Events.emit_signal("C_IDLE_enter")

			
		CombatStates.C_ANIMATING:
			Events.emit_signal("C_ANIMATING_enter")
			
		CombatStates.C_ABILITY_TARGETING:#Called by ActionsMenu.gd: press_button()
			if not abilityInUse is Ability: push_error("Entered targeting without an ability set.")
			Events.emit_signal("C_ABILITY_TARGETING_enter")
			var allCells:Array[Vector3i] = []; allCells.assign(gridMap.cellDict.keys()) 
			var cellsToMark:Array[Vector3i] = abilityInUse.filter_targetable_cells(allCells)
			gridMap.mark_cells(cellsToMark)

		CombatStates.C_FACING_SELECT:
			Events.emit_signal("C_FACING_SELECT_enter")

	combatState = newState
	
				
	
#func _unhandled_input(event: InputEvent) -> void:
#	match combatState:
#		CombatStates.ABILITY_TARGETING:
#			if event.is_action_pressed("primary_click")

#	gridMap.update_hovered_cell()
#	match state:
#		States.SETUP:
#			if event.is_action_released("primary_click"):#Unit placement
#				if Ref.unitSelected != null:#If a unit has been selected
#					gridMap.place_object(Ref.unitSelected,gridMap.hoveredCell,MovementGrid.objectTypes.UNITS)#Add unit to map in the highlighted cell in the UNITs section
#					if Ref.unitsInBattle.find(Ref.unitSelected ) == -1 : #If the unit is not in battle...
#						Ref.unitsInBattle.append(Ref.unitSelected )#Add it to the list
#
#				else:#If not, select any clicked units
#					Ref.unitSelected = gridMap.get_cell_occupant(gridMap.hoveredCell)
#
#			elif event.is_action_released("secondary_click"):
#				var thingHovered = gridMap.get_cell_occupant(gridMap.hoveredCell)
#				if thingHovered and thingHovered.get("isUnit"):#If a unit was clicked
#					gridMap.remove_object(thingHovered, gridMap.objectTypes.UNITS)#Remove it from the field
#					Ref.unitsInBattle.erase( thingHovered )#Remove it from the unit list
#
#				Ref.unitSelected = null#Deselect the current unit
#				$UI/InfoDisplay.clear_unit()
#
#			elif event is InputEventMouseMotion and Ref.unitSelected == null:#If no unit has been selected and one was moused over
#				var target = gridMap.get_cell_occupant(gridMap.hoveredCell)
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
#					Ref.unitSelected = gridMap.get_cell_occupant(gridMap.hoveredCell)
#
#			elif event.is_action_released("secondary_click"):
#				Ref.unitSelected = null#Deselect the current unit
#				$UI/InfoDisplay.clear_unit()
#
#			elif event is InputEventMouseMotion and Ref.unitSelected == null:#If no unit has been selected and one was moused over
#				var target = gridMap.get_cell_occupant(gridMap.hoveredCell)#Get the unit in the cell hovered
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
#						elif gridMap.get_cell_occupant(gridMap.hoveredCell) == null:#Check if the cell is empty
#							gridMap.place_object(Ref.unitInAction,gridMap.hoveredCell)#Move the unit there
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
#					gridMap.mark_cells_for_aoe(gridMap.hoveredCell,stateVariants["abilityChosen"])
#
#					if event.is_action_released("primary_click"): 
#						var parameters:Dictionary
#						var target
#
#
#						if stateVariants.targetedCells.has(gridMap.hoveredCell):#Check if it is valid	
#							target = gridMap.get_cell_occupant(gridMap.hoveredCell,gridMap.objectTypes.UNITS)#Get who is in that cell
#
#							if target == null:#Get an object if there's no unit
#								target = gridMap.get_cell_occupant(gridMap.hoveredCell,gridMap.objectTypes.OBJECTS)#Get who is in that cell
#
#							if target:#If the target is valid, add it
#								parameters["target"] = target
#								stateVariants["abilityChosen"].use(parameters)
#
#
#						else:
#							push_warning( "Tried to target non-highlighted cell " + str(gridMap.hoveredCell) )
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

## IMPORTANT for usage!!!
func on_cell_clicked(cell:Vector3i):
	match combatState:
		CombatStates.C_ABILITY_TARGETING:
			if gridMap.is_cell_marked(cell):
				if targetedCells.size() < abilityInUse.amountOfTargets:
					targetedCells.append(cell)
				else:
					actionStack.append(abilityInUse.get_tween(targetedCells))
	

func update_menus_to_unit(unit:Unit):
	for menu in menuCombat.get_menus():
		if menu != "MENU": 
			menuCombat.clear_menu(menu)
	
	for ability in unit.attributes.abilities:
		var button:=Button.new()
		var menuName:String
		match ability.type:
			Ability.AbilityTypes.MOVEMENT: menuName = "MOVEMENT"
			Ability.AbilityTypes.OBJECT: menuName = "OBJECT"
			Ability.AbilityTypes.SKILL: menuName = "SKILL"
			Ability.AbilityTypes.SPECIAL: menuName = "SPECIAL"
			Ability.AbilityTypes.PASSIVE: return
			_: push_error("Invalid ability type."); return
		
		button.text = ability.displayedName
#		button.add_user_signal("abil",[ability])
#		button.pressed.connect( Callable(button,"emit_signal").bind("abil",ability) )
		button.pressed.connect(set.bind("abilityInUse",ability))
		menuCombat.add_to_menu(button,menuName)
		
	menuCombat.change_current_menu("MENU")
	
func get_units(combatOnly:bool=true)->Array[Unit]:
	var units:Array[Unit]
	units.assign( get_tree().get_nodes_in_group(Const.Groups.UNIT) )
	if combatOnly:
		units = units.filter(func(unit): return unit.get_parent()==self)
	return units

class Cell extends Area3D:
	var mesh:Mesh
	
	
#class UnitManager extends Node:
#	var board:GameBoard
#
#	func _init(_board:GameBoard):
#		board = _board
#TURN
func turn_sort_units_by_delay():
	unitsInCombat.sort_custom( func(a:Unit,b:Unit): return a.attributes.stats["turnDelay"] < b.attributes.stats["turnDelay"] )

func turn_get_next_unit()->Unit:
	turn_sort_units_by_delay()
	return unitsInCombat[0]
	
func turn_apply_delays():
	var currDelay:int = actingUnit.attributes.stats["turnDelay"]
	assert(currDelay == actingUnit.attributes.stats["turnDelay"])
	for unit in unitsInCombat: 
		unit.attributes.apply_turn_delay(currDelay)
	
func turn_cycle():
	actingUnit.end_turn()
	turn_apply_delays()
	actingUnit = turn_get_next_unit()
	actingUnit.start_turn()
