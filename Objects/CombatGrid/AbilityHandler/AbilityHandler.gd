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

var selectedAbility:Ability:
	set(ability):
		selectedAbility = ability
		if not selectedAbility is Ability: return
		
		selected_ability.emit(ability)
		selected_ability_with_name.emit(ability.displayedName)
		#Update the targetable cells
		targetableCells = get_targetable_cells(selectedAbility)
		update_markers(targetableCells, MarkerTypes.TARGETABLE)

var chosenTargets:Array[Vector3i]:
	set(val):
		chosenTargets = val
		if not chosenTargets.is_empty():
			update_chosen_targets()
			
var targetableCells:Array[Vector3i]

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
	#Unset related variables
	selectedAbility = null
	chosenTargets = []
	
	for marker in MarkerTypes.values():
		update_markers([], marker)
	ability_targeting_ended.emit(selectedAbility)	
	
	
func preview_ability_effects(ability:Ability=selectedAbility, targets:Array[Vector3i]=chosenTargets):
	print("{0} ability will do something!".format([ability.displayedName]))
	pass
	
func get_targeting_from_cells(ability:Ability, cells:Array[Vector3i])->AbilityTargetingInfo:
	var targetInfo:=AbilityTargetingInfo.new()
	var units:Array[Unit]
	units.assign(gridMap.multi_search_in_cell(cells, MovementGrid.Searches.UNIT))
#	var cells:Array[Vector3i] = targets
	targetInfo.gridRef = gridMap
	targetInfo.ability = ability
	targetInfo.unitsTargeted = units
	targetInfo.cellsTargeted = cells
	targetInfo.user = ability.user
	return targetInfo
	
func queue_ability_call(ability:Ability, targeting:AbilityTargetingInfo, reactionTo:Ability = null, preClear:bool = true):
	if preClear: callQueue.clear_queue()
	
	#Depending if it is a reaction or not
	if reactionTo is Ability:
		callQueue.add_queued(ability.use, callQueue.queue.find(reactionTo))
	else:
		callQueue.add_queued(ability.use)
		
	callQueue.set_queued_arguments([targeting])#Keep it an Array with an Array[Vector3i] inside
	callQueue.set_queued_post_wait(ability.animationDuration)
	
	var userCell:Vector3i = ability.user.get_current_cell()
	
	#Warn every unit
	for unit in targeting.unitsTargeted:
		unit.was_targeted.emit(ability)

	
	ability_queued.emit(ability)
	pass

	
func on_hover_ability_button(button:AbilityButton):
	ability_button_hovered.emit(button)

	## Cells that the user can target
func get_targetable_cells(ability:Ability)->Array[Vector3i]:
#	var cells:Array[Vector3i] = gridMap.get_typed_cellDict_array()
	
	var shape:Array[Vector3i] = ability.targetingShape.duplicate()
	var userCell:Vector3i = ability.user.get_current_cell()
	
	
	#Select cells based on the shape
	var filteredCells:Array[Vector3i]
	for cellPos in shape:
		var cellWantedAt:Vector3i = userCell + cellPos
		
		#Use the 2D map of the gridMap to find the cell on this x,z coordinate.
		var cellAcquired:Cell = gridMap.get_cell_by_vec_2d( Vector2i(cellWantedAt.x, cellWantedAt.z) )
		
		#Use it's position.
		if cellAcquired is Cell: filteredCells.append(cellAcquired.position)
		else: breakpoint

#	assert(filteredCells.size()>2)
	#Then, remove non-existent cells
	filteredCells.filter(func(cell:Vector3i): return gridMap.has_cell(cell))
	
	assert(filteredCells.size()>2)
	#Filter by ability filters
	for filter in ability.filters:
		filteredCells.filter(filter.bind(ability.user))
	
	#Apply custom ability filter
	filteredCells.filter(ability._custom_filter)
	
	assert(filteredCells.size()>2)
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

#func update_targeting_visuals(newOrigin:Vector3i, AOEMode:bool)->Array[Vector3i]:
#	if currentState == States.TARGETING:
#		var targetedCells:Array[Vector3i]
#
#		if AOEMode: 
#			targetedCells = get_targeted_cells(newOrigin, selectedAbility)
#			update_markers(targetedCells, MarkerTypes.AOE)
#
#		else: 
#			targetedCells = get_targetable_cells(selectedAbility)
#			update_markers(targetedCells, MarkerTypes.TARGETABLE)
#
#		print(targetedCells)
#		return targetedCells
#	else:
#		return [] as Array[Vector3i]
	

		

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
	if not unit is Unit: push_error("No actingUnit set."); return
	for abilityBtn in list.get_children():
		if abilityBtn is AbilityButton: abilityBtn.queue_free()
		
	for ability in unit.attributes.abilities:
		var button:=AbilityButton.new()
		var buttonName:String
		
		button.text = ability.displayedName
		button.disabled = not ability.is_usable()
		button.ability = ability
		#Selection
		button.pressed.connect(start_ability_targeting.bind(ability))
		#Hovering
		button.mouse_entered.connect(on_hover_ability_button.bind(button))
		button.focus_mode = Control.FOCUS_NONE
		
		list.add_child(button)

func on_new_cell_hovered(cellPos:Vector3i):
	match currentState:
		States.TARGETING:
			update_markers( get_targeted_cells(cellPos, selectedAbility), MarkerTypes.AOE )

	
func on_cell_clicked(cell:Vector3i):
	match currentState:
		States.TARGETING:
			if cell in targetableCells:
				chosenTargets = get_targeted_cells(cell, selectedAbility)
				update_markers(chosenTargets, MarkerTypes.CHOSEN_TARGET)
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
				queue_ability_call(selectedAbility, get_targeting_from_cells(selectedAbility, chosenTargets))
				currentState = States.CONFIRMING
				
				update_markers([], MarkerTypes.TARGETABLE)
				update_markers([], MarkerTypes.AOE)

			else:
				push_warning("Cannot confirm targeting without targets.")
		
		States.CONFIRMING:
			callQueue.run_queue()
			update_ability_list(selectedAbility.user)
			end_ability_targeting()
			currentState = States.INACTIVE
	pass

class AbilityButton extends Button:
	
	var ability:Ability
	
class AbilityQueue extends CallQueue:
	
	pass
	
