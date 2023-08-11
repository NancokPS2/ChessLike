extends Node
class_name AbilityHandler

signal ability_button_hovered(button:Button)
signal selected_ability(ability:Ability) ##The button for an ability was pressed
signal selected_ability_with_name(abilName:String)

signal ability_targeting_started(ability:Ability)
signal ability_targeting_ended(ability:Ability)



signal ability_queued(ability:Ability)

signal targeted_units(units:Array[Unit], ability:Ability)
signal targeted_cells(cells:Array[Vector3i], ability:Ability)



enum States {
	INACTIVE, ## Non-functional
	TARGETING, ## Update targeting visuals when a cell is hovered
	CONFIRMING, ## Target chosen, stop updating targeting
	USING ## Usage in progress
	}
enum MarkerTypes {
	TARGETABLE,
	AOE,
	CHOSEN_TARGET
}

@export var targetableMarker:PackedScene
#@export var targetingMarker:PackedScene
@export var AOEMarker:PackedScene
@export var chosenTargetMarker:PackedScene

@export_category("References")
@export var abilityButtonList:Control
@export var gridMap:MovementGrid
var abilityConfirmButton:Button

var currentState:States = States.INACTIVE:
	set(val):
		currentState = val
		print_debug("Changed to state: " + States.find_key(currentState))

var selectedAbility:Ability

var chosenTargets:Array[Vector3i]:
	set(val):
		chosenTargets = val
		if not chosenTargets.is_empty():
			update_chosen_targets()
			

var callQueue = CallQueue.new()

func _ready() -> void:
	Events.CANCEL_UNIVERSAL.connect(on_cancel)
	Events.CONFIRM_UNIVERSAL.connect(on_confirm)
	Ability.new().abilityHandler = self


func start_ability_targeting(ability:Ability):
	selectedAbility = ability
	currentState = States.TARGETING
	
	ability_targeting_started.emit(ability)
	
func end_ability_targeting():
	#Update the list of abilities from the user.
	update_ability_list(selectedAbility.user)
	
	#Unset related variables
	selectedAbility = null
	chosenTargets = []
	
	for marker in MarkerTypes.values():
		update_markers([], marker)
	ability_targeting_ended.emit(selectedAbility)	
	
	
	##Marks the cells that the user can target
func select_ability(ability:Ability):
	selectedAbility = ability
	selected_ability.emit(ability)
	selected_ability_with_name.emit(ability.displayedName)
	
	#Start targeting
	start_ability_targeting(ability)
	
	#Update the targetable cells
	update_targeting_visuals(ability.user.get_current_cell(), MarkerTypes.TARGETABLE)
	
func preview_ability_effects(ability:Ability=selectedAbility, targets:Array[Vector3i]=chosenTargets):
	print("{0} ability will do something!".format([ability.displayedName]))
	pass
	
func queue_ability_call(ability:Ability, targets:Array[Vector3i], reactionTo:Ability = null, preClear:bool = true):
	if preClear: callQueue.clear_queue()
	
	#Depending if it is a reaction or not
	if reactionTo is Ability:
		callQueue.add_queued(ability.use, callQueue.queue.find(reactionTo))
	else:
		callQueue.add_queued(ability.use)
		
	callQueue.set_queued_arguments([targets])#Keep it an Array with an Array[Vector3i] inside
	callQueue.set_queued_post_wait(ability.animationDuration)
	
	var userCell:Vector3i = ability.user.get_current_cell()
	
	#Signal what will be targeted.
#	signal_about_targets(ability, targets)
	
	#Warn every unit
	for unit in gridMap.multi_search_in_cell(targets, gridMap.Searches.UNIT):
#		ability.warn_unit(unit)
		unit.was_targeted.emit(ability)
		#Check all of their abilities
#		for unitAbility in unit.attributes.abilities:
#
#			if unitAbility is Ability: 
#				#If it can react, queue it before
#				if unitAbility.reacts_to_ability(ability):
#					callQueue.add_queued(unitAbility,0)
#					callQueue.set_queued_arguments([userCell],0)
#					callQueue.set_queued_post_wait(unitAbility.animationDuration)
#
#			else: push_error("NON ability detected in this array!")
			
	
	ability_queued.emit(ability)
	pass

func signal_about_targets(abilityUsed:Ability, targets:Array[Vector3i]):
	var cellsTargeted:Array[Vector3i]
	var unitsTargeted:Array[Unit]
	
	for cellTargeted in targets:
		cellsTargeted.append(cellTargeted)
		
		unitsTargeted.append_array( gridMap.search_in_cell(cellTargeted, MovementGrid.Searches.UNIT, true) )
	
	targeted_units.emit(unitsTargeted, abilityUsed)
	targeted_cells.emit(cellsTargeted, abilityUsed)
	
	
func select_cell(cell:Vector3i):
	if currentState == States.TARGETING:
#		currentState = States.CONFIRMING
		
		#Set the valid targets and update visuals for a final time, this also returns the cells that where valid
		chosenTargets = update_targeting_visuals(cell, true)
	
func on_hover_ability_button(button:AbilityButton):
	ability_button_hovered.emit(button)

	## Cells that the user can target
func get_targetable_cells(ability:Ability)->Array[Vector3i]:
#	var cells:Array[Vector3i] = gridMap.get_typed_cellDict_array()
	
	var shape = ability.targetingShape.duplicate()
	var userCell:Vector3i = ability.user.get_current_cell()
	
	#Select cells based on the shape
	var filteredCells:Array[Vector3i]
	for cellPos in shape:
		filteredCells.append(userCell + cellPos)
	
	#Filter by ability filters
	for filter in ability.filters:
		filteredCells.filter(filter.bind(ability.user))
	
	#Apply custom ability filter
	filteredCells.filter(ability._custom_filter)
	return filteredCells

	## Cells that the ability will affect based on the targeted Cell
func get_targeted_cells(targetedCell:Vector3i, ability:Ability)->Array[Vector3i]:
	
	var shape:Array[Vector3i] = ability.targetingAOEShape
	if ability.targetingRotates: shape = ability.targeting_get_rotated_to_cell(shape, targetedCell) 
	
	#Select cells based on the shape
	var filteredCells:Array[Vector3i]
	for cellPos in shape:
		filteredCells.append(targetedCell + cellPos)
	
	#Filter by ability filters
	for filter in ability.filters:
		filteredCells.filter(filter.bind(ability.user))
	
	#Apply custom ability filter
	filteredCells.filter(ability._custom_filter)
	return filteredCells
	
func update_chosen_targets():
	update_markers(chosenTargets, MarkerTypes.CHOSEN_TARGET)

func update_targeting_visuals(newOrigin:Vector3i, AOEMode:bool)->Array[Vector3i]:
	if currentState == States.TARGETING:
		var targetedCells:Array[Vector3i]
		
		if AOEMode: 
			targetedCells = get_targeted_cells(newOrigin, selectedAbility)
			update_markers(targetedCells, MarkerTypes.AOE)
			
		else: 
			targetedCells = get_targetable_cells(selectedAbility)
			update_markers(targetedCells, MarkerTypes.TARGETABLE)
		
		print(targetedCells)
		return targetedCells
	else:
		return [] as Array[Vector3i]
	

		

func update_markers(cells:Array[Vector3i], type:MarkerTypes):
	#Clear other refs of this kind
	clear_markers(type)
	
	#Select the marker
	var cellMarkerUsed:PackedScene
	match type:
		MarkerTypes.TARGETABLE: cellMarkerUsed = targetableMarker
		MarkerTypes.AOE: cellMarkerUsed = AOEMarker
		MarkerTypes.CHOSEN_TARGET: cellMarkerUsed = chosenTargetMarker
			
	#Place it down in the cells
	var newRefs:Array[Node3D]
	for cell in cells:
		#Add the cell
		var marker:Node3D = cellMarkerUsed.instantiate()
		marker.position = gridMap.map_to_local(cell)
		add_child(marker)
		
		#Save a reference
		newRefs.append(marker)
	
	#Update the reference
	set_meta("REFS_"+str(type), newRefs)
	
func clear_markers(type:MarkerTypes):
	var refs:Array[Node3D] = get_meta("REFS_"+str(type), [] as Array[Node3D])
	for marker in refs: marker.queue_free()
	
	
func update_ability_list(unit:Unit, list:Control=abilityButtonList):
	for ability in unit.attributes.abilities:
		var button:=AbilityButton.new()
		var buttonName:String
		
		button.text = ability.displayedName
		button.disabled = not ability.is_usable()
		button.ability = ability
		#Selection
		button.pressed.connect(select_ability.bind(ability))
		#Hovering
		button.mouse_entered.connect(on_hover_ability_button.bind(button))
		button.focus_mode = Control.FOCUS_NONE
		
		list.add_child(button)

func on_new_cell_hovered(cellPos:Vector3i):
#	print("hover")
	match currentState:
		States.TARGETING:
#			if cellPos != MovementGrid.INVALID_CELL_COORDS: breakpoint
			#Update the affeected area as the mouse moves.
			update_targeting_visuals(cellPos, true)
	pass
	
func on_cancel():
	match currentState:
		States.TARGETING: 
			end_ability_targeting()
			
		States.CONFIRMING:
			chosenTargets = []
	
func on_confirm():
	match currentState:
		States.TARGETING:
			if not chosenTargets.is_empty():
				queue_ability_call(selectedAbility, chosenTargets)
				currentState = States.CONFIRMING

			else:
				push_warning("Cannot confirm targeting without targets.")
		
		States.CONFIRMING:
			callQueue.run_queue()
			end_ability_targeting()
			currentState = States.INACTIVE
	pass

class AbilityButton extends Button:
	
	var ability:Ability
	
class AbilityQueue extends CallQueue:
	
	pass
	
