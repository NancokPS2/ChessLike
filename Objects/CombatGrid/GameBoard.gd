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

#var cellDict:Dictionary:
#	set(val):
#		pass
#	get:
#		if gridMap: return gridMap.cellDict
#		else: push_error("No gridMap has been set."); return {}
	


@export_group("References")
@export var callQueue:CallQueue

@export var gridMap:MovementGrid
@export var unitHandler:UnitHandler
@export var abilityHandler:AbilityHandler

@export var unitList:UnitDisplayManager
@export var menuCombat:NestedMenu
@export var confirmationDialogue:ConfirmationPopup

@export var unitInfo:UnitDisplay

@export_group("Map")
@export var currentMap:Map:
	set(val):
		currentMap = val
#		assert(currentMap is Map and gridMap is MovementGrid) 
			
			
var state:int
var combatState:int


		
var allUnits:Array[Unit]
		
var abilityInUse:Ability:
	set(val):
		abilityInUse = val
		if abilityInUse is Ability:
#			$Debug.text = abilityInUse.displayedName
			change_combat_state(CombatStates.C_ABILITY_TARGETING)



var targetedCells:Array[Vector3i]
var actionStack:Array[Tween]

func _init() -> void:
	Ref.board = self
	
	
func _enter_tree() -> void:
	pass
	
	
	
func _ready() -> void:
	#Setup
	gridMap = Ref.grid
	change_state(States.SETUP)
	
	
#	testing()


	
func run_stack():
	change_combat_state(CombatStates.C_ANIMATING)
	callQueue.run_queue()

func queue_ability():
	pass

	
func testing():
	change_state(States.COMBAT)
#	unitHandler.actingUnit = get_tree().get_nodes_in_group(Const.ObjectGroups.UNIT)[0]
	unitHandler.actingUnit.position = gridMap.map_to_local(Vector3i.ZERO)
	


func change_state(newState:States):
	var currentStateName:String = States.find_key(state)
	var newStateName:String = States.find_key(newState)
	if newState != state:#Handle exiting the current state
		Events.BOARD_STATE_EXITED.emit(state)
		Events.BOARD_STATE_ENTERED.emit(newState)
	
	match newState:
		States.COMBAT:
			if not unitHandler.actingUnit is Unit: unitHandler.actingUnit = unitHandler.turn_get_next_unit()
	
	state = newState#Change the recorded state
	
	#Enabling/Disabling nodes
#	for group in States.keys():
#		for node in get_tree().get_nodes_in_group(group):
#			node.process_mode = Node.PROCESS_MODE_DISABLED
#			node.visible = false
#
#	for node in get_tree().get_nodes_in_group(newStateName):
#		node.process_mode = Node.PROCESS_MODE_INHERIT
#		node.visible = true
			

func change_combat_state(newState:CombatStates):
	if combatState != newState:#State has been changed
		Events.BOARD_COMBAT_STATE_EXITED.emit(combatState)
		Events.BOARD_COMBAT_STATE_ENTERED.emit(newState)
		
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
	$Debug.text = gridMap.get_cell_debug_text(cell)

	if unitHandler.selectedUnit is Unit and unitHandler.selectedUnit.get_parent() == self:
		var origin:Vector3i = unitHandler.selectedUnit.get_current_cell()
		gridMap.pathing.get_unit_path(unitHandler.selectedUnit, origin, cell)
		
	match state:
		States.SETUP:
			Events.UPDATE_UNIT_INFO.emit()
#			var unit:Unit = gridMap.search_in_cell(cell, gridMap.Searches.UNIT)
#			if unit is Unit: unitList.unitSelected = unit
			
			#Unit spawn logic.
			
			#If there is a unit selected.
			if unitHandler.selectedUnit is Unit:
				var unitToSpawn:Unit = unitHandler.selectedUnit
				#The selected cell has the correct tag.
				if gridMap.get_cell_tags(cell,true).has(SPAWN_TAG + unitToSpawn.attributes.get_faction().internalName):
					#The unit was not removed and may be added
					if unitHandler.get_unit_state(unitToSpawn) != UnitHandler.UnitStates.REMOVED:
						#Add it if not added already.
						unitHandler.spawn_unit(unitToSpawn, cell)
						#Position it
						gridMap.position_object_3D(cell, unitList.unitSelected)
#						unitList.unitSelected.position = gridMap.map_to_local(cell)
				
				
			pass
	
		States.COMBAT:
			
			match combatState:
				#An ability has been selected
				CombatStates.C_ABILITY_TARGETING:
					assert(abilityInUse is Ability)
					if gridMap.is_cell_marked(cell):
						
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
#	Events.emit_signal("UPDATE_UNIT_INFO")
	
#func get_units(combatOnly:bool=true, factionFilter:String = "")->Array[Unit]:
#	var unitArr:Array[Unit]
#	unitArr = allUnits
##	var units:Array[Unit]
##	units.assign( get_tree().get_nodes_in_group(Const.ObjectGroups.UNIT) )
#	if combatOnly:
#		unitArr = unitArr.filter(func(unit): return unit.get_parent()==self)
#	if factionFilter != "":
#		unitArr = unitArr.filter(func(unit): return unit.attributes.get_faction().internalName == factionFilter)
#
#	return unitArr
	
#func get_present_factions(inCombatOnly:bool)->Array[Faction]:
#	var units:Array[Unit] = get_units(inCombatOnly)
#	var factionList:Array[Faction]
#	for unit in units:
#		if not factionList.has(unit.attributes.get_faction()):
#			factionList.append(unit.attributes.get_faction())
#	return factionList



func load_map(mapUsed:Map = currentMap)->void:
	assert(mapUsed is Map and gridMap is MovementGrid) 
	
	currentMap = mapUsed
	mapUsed.auto_generation()
	if not mapUsed.is_valid(): push_error("Could not validate map!")
	
	# Load cells
	gridMap.clear()
	gridMap.mesh_library = mapUsed.meshLibrary
	gridMap.initialize_cells_from_map(mapUsed)
	
	for cell in mapUsed.cellArray:
		
		#Add any unit that should spawn in the cell
		if cell.preplacedUnit is CharAttributes:
			var newUnit:Unit = Unit.Generator.build_from_attributes(cell.preplacedUnit)
			#Add
			unitHandler.add_unit(newUnit, unitHandler.UnitStates.BENCHED)
			unitHandler.spawn_unit(newUnit, cell.position)
			
	gridMap.update_pathing(mapUsed)
	gridMap.update_object_positions()
			
	#Place spawn positions
	var index:int=0
	for faction in mapUsed.factionsPresent:
		#Mark the cells
		var spawnCells:Array[Vector3i] = mapUsed.get_faction_spawns(faction) 
		gridMap.mark_cells(spawnCells, index+1, false)
		
		if not faction is Faction: push_error("Faction is null!"); continue
		
		#Add the tags
		gridMap.tag_cells(spawnCells, SPAWN_TAG + faction.internalName)
		print_debug("Prepared cells " + str(spawnCells) + " for faction: " + faction.internalName)
			
		index+=1
	
		

#	Events.UPDATE_UNIT_INFO.emit()
	
#	for spawnArray in mapUsed.spawnLocations:
#		if mapUsed.spawnLocations.size() > 8: push_error("Too many Arrays! Can only support up to 8.")
#
	
class SetupController extends Control:
	var board:GameBoard
	
	func _init(_board:GameBoard) -> void:
		board = _board
		
	
		
	
	pass
