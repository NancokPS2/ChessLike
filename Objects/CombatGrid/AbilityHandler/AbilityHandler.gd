extends Node
class_name AbilityHandler

signal ability_button_hovered(button:Button)
signal ability_selected(ability:Ability)
signal ability_started(ability:Ability)
signal ability_targeting(ability:Ability)
signal ability_finished(ability:Ability)

enum States {
	INACTIVE, ## Non-functional
	CHOOSING, ## DEPRECATED
	TARGETING, ## Update targeting visuals
	CONFIRMING, ## Target chosen, stop updating targeting
	USING ## Usage in progress
	}
enum MarkerTypes {
	TARGETABLE,
	TARGETING,
	AOE
}

@export var targetableMarker:PackedScene
@export var targetingMarker:PackedScene
@export var AOEMarker:PackedScene

@export_category("References")
@export var abilityButtonList:Control
@export var gridMap:MovementGrid
var abilityConfirmButton:Button

var currentState:States = States.INACTIVE

var selectedAbility:Ability

var validTargets:Array[Vector3i]

func start_ability_targeting(ability:Ability):
	selectedAbility = ability
	currentState = States.TARGETING
	ability_started.emit(ability)
	
func select_ability(ability:Ability):
	selectedAbility = ability
	ability_selected.emit(ability)
	update_targeting_visuals(ability.user.get_current_cell(), MarkerTypes.TARGETABLE)
	
func hover_ability_button(button:AbilityButton):
	ability_button_hovered.emit(button)

	## Cells that the user can target, if AOEMode is true it will be based on 
	## The AOE Area of the ability instead of the ability's targeting range.
func get_cells_targeted(targetedCell:Vector3i, ability:Ability, AOEMode:bool)->Array[Vector3i]:
	var cells:Array[Vector3i] = gridMap.get_typed_cellDict_array()
	
	var shape:Ability.TargetingShapes
	var range:int
	
	if AOEMode: 
		shape = ability.targetingAOEShape
		range = ability.targetingAOESize
	else: 
		shape = ability.targetingShape
		range = ability.targetingRange

	#Cell filter by cell shape
	var filteredCells:Array[Vector3i]
	match shape:
		Ability.TargetingShapes.STAR:
			for cell in cells:
				var manhattanDistance:int = abs(targetedCell.x - cell.x) + abs(targetedCell.y - cell.y) + abs(targetedCell.z - cell.z)
				if manhattanDistance <= range: filteredCells.append(cell)
	
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
			targetedCells = get_cells_targeted(newOrigin, selectedAbility, true)
			update_markers(targetedCells, MarkerTypes.TARGETING)
			
		else: 
			targetedCells = get_cells_targeted(newOrigin, selectedAbility, false)
			update_markers(targetedCells, MarkerTypes.TARGETABLE)
		
		return targetedCells
	else:
		return [] as Array[Vector3i]
	
func select_cell(cell:Vector3i):
	if currentState == States.TARGETING:
		currentState = States.CONFIRMING
		
		#Set the valid targets and update visuals for a final time
		validTargets = update_targeting_visuals(cell, true)
		
		
		if abilityConfirmButton is Button:
			abilityConfirmButton.pressed.connect(confirm_ability, CONNECT_ONE_SHOT)
		else:
			push_error("Cannot find a button for confirming!")
		
func confirm_ability():
	currentState = States.CONFIRMING
	selectedAbility.warn_units([])
	
		

	
	
func update_markers(cells:Array[Vector3i], type:MarkerTypes):
	#Clear other refs of this kind
	clear_markers(type)
	
	#Select the marker
	var cellMarkerUsed:PackedScene
	match type:
		MarkerTypes.TARGETABLE: cellMarkerUsed = targetableMarker
		MarkerTypes.TARGETING: cellMarkerUsed = targetingMarker
		MarkerTypes.AOE: cellMarkerUsed = AOEMarker
			
	#Place it down in the cells
	var newRefs:Array[Node3D]
	for cell in cells:
		var marker:Node3D = cellMarkerUsed.instantiate()
		marker.position = gridMap.map_to_local(cell)
		#Save a reference
		newRefs.append(marker)
	
	#Update the reference
	set_meta("REFS_"+str(type), newRefs)
	
func clear_markers(type:MarkerTypes):
	var refs:Array[Node3D] = get_meta("REFS_"+str(type), [] as Array[Node3D])
	for marker in refs: marker.queue_free()
	
	
func update_ability_list(unit:Unit, list:Control):
	for ability in unit.attributes.abilities:
		var button:=AbilityButton.new()
		var buttonName:String
		
		button.text = ability.displayedName
		button.disabled = not ability.is_usable()
		button.ability = ability
		#Selection
		button.pressed.connect(select_ability.bind(ability))
		#Hovering
		button.mouse_entered.connect(hover_ability_button.bind(button))
		
		list.add_child(button)

class AbilityButton extends Button:
	var ability:Ability
	
