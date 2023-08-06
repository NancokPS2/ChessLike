extends Node
class_name AbilityHandler

signal ability_button_hovered(button:Button)
signal ability_selected(ability:Ability)
signal ability_started(ability:Ability)
signal ability_targeting(ability:Ability)
signal ability_finished(ability:Ability)

enum States {
	INACTIVE, ## Non-functional
	TARGETING, ## Update targeting visuals when a cell is hovered
	CONFIRMING, ## Target chosen, stop updating targeting
	USING ## Usage in progress
	}
enum MarkerTypes {
	TARGETABLE,
	AOE
}

@export var targetableMarker:PackedScene
#@export var targetingMarker:PackedScene
@export var AOEMarker:PackedScene

@export_category("References")
@export var abilityButtonList:Control
@export var gridMap:MovementGrid
var abilityConfirmButton:Button

var currentState:States = States.INACTIVE

var selectedAbility:Ability

var chosenTargets:Array[Vector3i]

func _ready() -> void:
	Events.CANCEL_UNIVERSAL
	Ability.new().callQueue = Ref.board.callQueue
	



func start_ability_targeting(ability:Ability):
	selectedAbility = ability
	currentState = States.TARGETING
	ability_started.emit(ability)
	
func end_ability_targeting():
	#Update the list of abilities from the user.
	update_ability_list(selectedAbility.user)
	
	#Unset related variables
	selectedAbility = null
	chosenTargets.clear()

	#Change to inactive state
	currentState = States.INACTIVE
	ability_finished.emit(selectedAbility)	
	
	
	##Marks the cells that the user can target
func select_ability(ability:Ability):
	selectedAbility = ability
	ability_selected.emit(ability)
	
	start_ability_targeting(ability)
	
	update_targeting_visuals(ability.user.get_current_cell(), MarkerTypes.TARGETABLE)
	
func select_cell(cell:Vector3i):
	if currentState == States.TARGETING:
		currentState = States.CONFIRMING
		
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
			currentState = States.INACTIVE
			end_ability_targeting()
	
func on_confirm():
	match currentState:
		States.TARGETING:
			if not chosenTargets.is_empty():
				currentState = States.CONFIRMING
				selectedAbility.queue_call(chosenTargets)
				
			else:
				push_warning("Cannot confirm targeting without targets.")
				
	pass

class AbilityButton extends Button:
	
	var ability:Ability
	
