extends Panel
class_name UnitDisplay

signal clicked_unit(unit:Unit)

var unitRef:Unit:
	set(val):
		if unitRef is Unit: push_error("This display already had a unitRef, swapping them is not supported yet.")
		unitRef = val
		if unitRef is Unit:
			stats = unitRef.attributes.stats
			info = unitRef.attributes.info
			refresh_ui()

var stats
var info
@onready var tween = get_tree().create_tween().set_loops()

@export_group("Input")
@export var buttonRef:Button:
	set(val):
		buttonRef = val
		if buttonRef is Button:
			buttonRef.pressed.connect(emit_unit)

@export_group("Resources & Info Refs")
@export var nameLabel:Label
@export var classLabel:Label

@export var healthMeter:Range
@export var healthLabel:Label

@export var energyMeter:Range
@export var energyLabel:Label

@export_group("Primary Stats Refs")
@export var strengthLabel:Label
@export var agilityLabel:Label
@export var mindLabel:Label

@export_group("Secondary stats")
@export var delayLabel:Label

func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)

func _ready() -> void:
	Events.UPDATE_UNIT_INFO.connect(refresh_ui)
	
	tween.tween_property(self,"modulate",Color.WHITE * 1.25, 1)
	tween.tween_property(self,"modulate",modulate, 0.5)

func load_unit(unit):#Used to load and display a unit simultaneously
	if unit and unit != unitRef and not ( unit.get("stats") == {} or unit.get("stats") == null ):
		unitRef = unit
	else:
		push_error(str(unit) + " could not be loaded.")
		return
		
	assert(unit is Unit)
		
	refresh_ui()
	
func clear_unit():
	unitRef = Node.new()
	for child in get_children():
		child.set("text","")

#func _gui_input(event: InputEvent) -> void:
#	if event.is_action_released("primary_click"):
#		emit_signal("clicked_unit",self)
#		animated_glow(true)
#		accept_event()
	
	
func refresh_ui():
	if unitRef is Unit:
		var testStats = unitRef.attributes.stats
		if nameLabel: nameLabel.text = unitRef.attributes.info["nickName"]
		
		if classLabel: classLabel.text = unitRef.attributes.info["className"]
		
		if healthLabel: healthLabel.text = str(unitRef.attributes.stats["health"]) + " / " + str(unitRef.attributes.stats["healthMax"])
		if healthMeter: healthMeter.value = unitRef.attributes.stats["health"]; healthMeter.max_value = unitRef.attributes.stats["healthMax"]
		
		if energyLabel: energyLabel.text = str(unitRef.attributes.stats["energy"]) + " / " + str(unitRef.attributes.stats["energyMax"])
		if energyMeter: energyMeter.value = unitRef.attributes.stats["energy"]; energyMeter.max_value = unitRef.attributes.stats["energyMax"]
		
		if delayLabel: delayLabel.text = "Delay: " + str(unitRef.attributes.stats["turnDelay"])
		
		if strengthLabel: strengthLabel.text = unitRef.attributes.stats["strength"]
		if agilityLabel: agilityLabel.text = unitRef.attributes.stats["agility"]
		if mindLabel: mindLabel.text = unitRef.attributes.stats["mind"]

func animated_glow(enabled:bool):
	if enabled:
		tween.play()
	else:
		tween.stop()
		
func emit_unit():
	emit_signal("clicked_unit", unitRef)
