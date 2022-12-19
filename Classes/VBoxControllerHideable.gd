extends VBoxContainer
class_name VBoxContainerCollapsable

#const button:PackedScene = preload("res://Objects/UI/Controller/ControllerButton.tscn")
#var linkedUnit:Unit

signal button_with_variant_pressed
export (String) var expandSignal = ""
export (String) var collapseSignal = ""

func _ready() -> void:
	if expandSignal != "":
		Events.connect(expandSignal,self,"expand",[true])
	if collapseSignal != "":
		Events.connect(collapseSignal,self,"expand",[false])
		

func expand(enable:bool, menu:Node = self):
	if enable:
		mouse_filter = MOUSE_FILTER_STOP
	else:
		mouse_filter = MOUSE_FILTER_IGNORE
	
	visible = enable#Show/hide
	

#func add_button(buttonName,buttonText,variant = null,enabled:bool = true):#variant can be returned as a value
#	var addedButton = button.instance()
#	addedButton.set_name(buttonName)
#	addedButton.internalName = buttonName
#	addedButton.text = buttonText
#	addedButton.variant = variant
#	add_child(addedButton)
#	return addedButton
#
#var persistentButtons:Array = ["Move","Act","EndTurn"]
#func unit_base_menu(unit:Unit):
#	clear_controller()
#
#	add_button("Move","UI_UNIT_MOVE").add_to_group("MAIN BUTTON")
#	add_button("Act","UI_UNIT_ACT").add_to_group("MAIN BUTTON")
#	add_button("EndTurn","UI_UNIT_ENDTURN").add_to_group("MAIN BUTTON")
#
#func update_ability_list(unit:Unit):
#	clear_controller()
#	if unit.attributes.activeAbilities != null:
#		for x in unit.attributes.activeAbilities:
#			add_button("Ability",tr(x.displayedName),x)
#	add_button("Cancel","UI_MISC_CANCEL")
#
#func misc_update(items:Array):
#	clear_controller()
#	for x in items:
#		add_button(x["name"],x["text"],x["variant"])
#
#func button_pressed(button:Button):
#	if button.internalName == "Move":
#		linkedUnit.move_attempt(linkedUnit.attributes.statMove,linkedUnit.attributes.movementType)
#	elif button.internalName == "Act":
#		update_ability_list(linkedUnit)
#	elif button.internalName == "EndTurn":
#		CVars.refUnitInAction.end_turn()
#		#CVars.refUITree.get_node("TurnManager").end_turn(linkedUnit, CVars.unitsInPlay)
#	elif button.internalName == "Cancel":
#		unit_base_menu(linkedUnit)
#	elif button.internalName == "Ability":
#		linkedUnit.use_ability(button.variant.identifier)
#	elif CVars.controlState == CVars.controlStates.MENU_CHOICE and button.get("variant") != null:#If a choice is being expected and the button has a variant...
#		emit_signal("button_with_variant_pressed",button.variant)#An
#		CVars.controlState = CVars.controlStates.FREE
##	check_option_availability(CVars.refUnitInAction)
#
#func check_option_availability(unit:Unit):
#	for x in get_children():
#		if x.internalName == "Move" and unit.attributes.movesRemaining <= 0:
#			x.disabled = true
#		else:
#			x.disabled = false
#
#		if x.internalName == "Act" and unit.attributes.actionsRemaining <= 0:
#			x.disabled = true
#		else:
#			x.disabled = false
#
#
##		if unit.attributes.actionsRemaining <= 0:
##			actionButton.disabled = true
##		else:
##			actionButton.disabled = false
#
#func _input(event):#Temp
##	if not event is InputEventMouseMotion:
##		call_deferred("check_option_availability")
#	pass
#
#
#

