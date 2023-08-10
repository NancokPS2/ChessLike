extends Panel
class_name UnitDisplay

signal clicked_unit(unit:Unit)
signal refreshed

const NORMAL_COLOR:=Color(1,1,1,1)
const NEGATIVE_COLOR:=Color(1,0.5,0.5,1)
const POSITIVE_COLOR:=Color(0.5,1,0.5,1)

var unitRef:Unit:
	set(val):
		if unitRef is Unit: push_error("This display already had a unitRef, swapping them is not supported yet???")
		unitRef = val

@onready var tween = get_tree().create_tween().set_loops()

@export_group("Input")
## For selecting the unit
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

var stats:Dictionary
var info:Dictionary

func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
#	Events.UPDATE_UNIT_INFO.connect(refresh_ui)

func _ready() -> void:	
	tween.tween_property(self,"modulate",Color.WHITE * 1.25, 1)
	tween.tween_property(self,"modulate",modulate, 0.5)
#	refresh_ui()
	
func clear_unit():
	unitRef = Node.new()
	for child in get_children():
		child.set("text","")

#func _gui_input(event: InputEvent) -> void:
#	if event.is_action_released("primary_click"):
#		emit_signal("clicked_unit",self)
#		animated_glow(true)
#		accept_event()
	
	
func refresh_ui(useBaseStats:bool=false):
#	assert(unitRef is Unit)
	# THESE MAY DIFFER FROM ACTUAL VALUES!
	
	if unitRef is Unit:
		stats = unitRef.get("attributes").baseStats.duplicate()
		info = unitRef.get("attributes").info.duplicate()
		
		if nameLabel: 
			nameLabel.text = unitRef.attributes.info["nickName"]
		
		if classLabel: 
			classLabel.text = unitRef.attributes.info["className"]
		
		if healthLabel: 
			healthLabel.text = str(unitRef.attributes.get_stat(AttributesBase.StatNames.HEALTH, useBaseStats)) + " / " + str(unitRef.attributes.get_stat(AttributesBase.StatNames.HEALTH_MAX, useBaseStats))
			
		if healthMeter: 
			healthMeter.value = unitRef.attributes.get_stat(AttributesBase.StatNames.HEALTH, useBaseStats) 
			healthMeter.max_value = unitRef.attributes.get_stat(AttributesBase.StatNames.HEALTH_MAX, useBaseStats)
		
		if energyLabel: 
			energyLabel.text = str(unitRef.attributes.get_stat(AttributesBase.StatNames.ENERGY, useBaseStats)) + " / " + str(unitRef.attributes.get_stat(AttributesBase.StatNames.ENERGY_MAX, useBaseStats))
		if energyMeter: 
			energyMeter.value = unitRef.attributes.get_stat(AttributesBase.StatNames.ENERGY, useBaseStats)
			energyMeter.max_value = unitRef.attributes.get_stat(AttributesBase.StatNames.ENERGY_MAX, useBaseStats)
		
		if delayLabel: 
			delayLabel.text = "Delay: " + str(unitRef.attributes.get_stat(AttributesBase.StatNames.TURN_DELAY, useBaseStats))
		
		if strengthLabel: 
			set_colored_value_on_label(strengthLabel, 
			unitRef.attributes.get_stat(AttributesBase.StatNames.STRENGTH, useBaseStats),
			unitRef.attributes.get_stat(AttributesBase.StatNames.STRENGTH, true)
			)
			
		if agilityLabel: 
			set_colored_value_on_label(agilityLabel, 
			unitRef.attributes.get_stat(AttributesBase.StatNames.AGILITY, useBaseStats),
			unitRef.attributes.get_stat(AttributesBase.StatNames.AGILITY, true)
			)
			
			
		if mindLabel: 
			set_colored_value_on_label(mindLabel, 
			unitRef.attributes.get_stat(AttributesBase.StatNames.MIND, useBaseStats),
			unitRef.attributes.get_stat(AttributesBase.StatNames.MIND, true)
			)
			
		refreshed.emit()

func set_colored_value_on_label(label:Label, value:float, normalValue:float):
	var color:Color
	if value < normalValue: 
		color = NEGATIVE_COLOR
	elif value > normalValue: 
		color = POSITIVE_COLOR
	else: 
		color = NORMAL_COLOR
	label.text = str(value)
	label.add_theme_color_override("font_color", color)

func animated_glow(enabled:bool):
	if enabled:
		tween.play()
	else:
		tween.stop()
		
func emit_unit():
	clicked_unit.emit(unitRef)
