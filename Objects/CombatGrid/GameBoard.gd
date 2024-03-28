extends Node3D
class_name GameBoard

## Started from Ref.start_combat(map)

signal time_advanced(amount:float)

const SPAWN_TAG:StringName = "FACTION_SPAWN_"

enum States {SETUP,COMBAT,PAUSE,END}

enum CombatStates {
	C_IDLE, ##Nothing is happening, actions are displayed
	C_ANIMATING, ##An animation is playing, disable most controls.
	C_ABILITY_TARGETING,
	C_FACING_SELECT,
	C_OFF_TURN
	}

	


@export_group("References")
@export var callQueue:CallQueue

@export var unitHandler:UnitHandler
@export var abilityHandler:AbilityHandler

@export var unitList:UnitDisplayManager
@export var menuCombat:NestedMenu
@export var confirmationDialogue:ConfirmationPopup

@export var unitInfo:UnitDisplay

@export_group("Reference", "ref")
@export var refTurnSystem:TurnSystem

@export_group("Map")
@export var currentMap:Map:
	set(val):
		Board.currentMap = val
	get:
		return Board.currentMap
#		assert(currentMap is Map and Board is MovementGrid) 
			
			
var state:int
var combatState:int


		
var allUnits:Array[Unit]
		
var abilityInUse:Ability



var targetedCells:Array[Vector3i]
var actionStack:Array[Tween]


func run_stack():
	change_combat_state(CombatStates.C_ANIMATING)
	callQueue.run_queue()

func change_state(newState:States):
	var currentStateName:String = States.find_key(state)
	var newStateName:String = States.find_key(newState)
	if newState != state:#Handle exiting the current state
		Event.BOARD_STATE_EXITED.emit(state)
		Event.BOARD_STATE_ENTERED.emit(newState)
	
	match newState:
		States.COMBAT:
			pass
	
	state = newState#Change the recorded state

func change_combat_state(newState:CombatStates):
	if combatState != newState:#State has been changed
		Event.BOARD_COMBAT_STATE_EXITED.emit(combatState)
		Event.BOARD_COMBAT_STATE_ENTERED.emit(newState)
		
	match newState:
		_: pass
		
	combatState = newState
	
				
	
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
	$Debug.text = Board.get_cell_debug_text(cell)

	if unitHandler.selectedUnit is Unit and unitHandler.selectedUnit.get_parent() == self:
		var origin:Vector3i = unitHandler.selectedUnit.get_current_cell()
		Board.pathing.get_unit_path(unitHandler.selectedUnit, origin, cell)
		
	match state:
		States.SETUP:
			Event.UPDATE_UNIT_INFO.emit()
#			var unit:Unit = Board.search_in_cell(cell, Board.Searches.UNIT)
#			if unit is Unit: unitList.unitSelected = unit
			
			#Unit spawn logic.
			
			#If there is a unit selected.
			if unitHandler.selectedUnit is Unit:
				var unitToSpawn:Unit = unitHandler.selectedUnit
				#The selected cell has the correct tag.
				if Board.get_cell_by_vec(cell).tags.has(SPAWN_TAG + unitToSpawn.attributes.get_faction().internalName):
					#The unit was not removed and may be added
					if unitHandler.get_unit_state(unitToSpawn) != UnitHandler.UnitStates.REMOVED:
						#Add it if not added already.
						unitHandler.spawn_unit(unitToSpawn, cell)
						#Position it
						Board.position_object_3D(cell, unitList.unitSelected)
#						unitList.unitSelected.position = Board.map_to_local(cell)
				
				
			pass
	
		States.COMBAT:
			
			match combatState:
				#An ability has been selected
				CombatStates.C_ABILITY_TARGETING:
					assert(abilityInUse is Ability)
					if Board.is_cell_marked(cell):
						
						#Mark cells ready for targeting
						if targetedCells.size() < abilityInUse.amountOfTargets:
							targetedCells.append(cell)
							
						#Confirmed usage
						else:
							callQueue.add_queued(abilityInUse.get_tween(targetedCells).play)
#							actionStack.append(abilityInUse.get_tween(targetedCells))
							var attrib:AttributesBase = abilityInUse.user.attributes
							if abilityInUse.moveCost > attrib.stats[attrib.StatNames.MOVES]: push_error("Insufficient moves left."); return
							if abilityInUse.actionCost > attrib.stats[attrib.StatNames.ACTIONS]: push_error("Insufficient actions left."); return
#							abilityInUse.user.attributes.change_stat(AttributesBase.StatNames.ACTIONS) -= abilityInUse.actionCost
#							abilityInUse.user.attributes.change_stat(AttributesBase.StatNames.MOVES) -= abilityInUse.moveCost
							update_menus_to_unit()
							run_stack()
							
					
	

func update_menus_to_unit(unit:Unit=unitHandler.unitHandler.selectedUnit):
	if not unit is Unit: push_warning("A unit has not been selected yet."); return
	for menu in menuCombat.get_menus():
		if menu != "MENU": 
			menuCombat.clear_menu(menu)
	
#	assert(not unit.attributes.abilities.is_empty())
	
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
		button.disabled = not ability.is_usable()
#		button.add_user_signal("abil",[ability])
#		button.pressed.connect( Callable(button,"emit_signal").bind("abil",ability) )
		button.pressed.connect(set.bind("abilityInUse",ability))
		menuCombat.add_to_menu(button,menuName)
		
	menuCombat.change_current_menu("MENU")
	unitInfo.unitRef = unit
	unitInfo.refresh_ui()
#	Event.emit_signal("UPDATE_UNIT_INFO")
	
	
class SetupController extends Control:
	var board:GameBoard
	
	func _init(_board:GameBoard) -> void:
		board = _board
		
	
		
	
	pass
