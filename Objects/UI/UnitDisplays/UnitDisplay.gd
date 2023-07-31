extends Panel
class_name UnitDisplay

signal clicked_unit(unit:Unit)

const NORMAL_COLOR:=Color(1,1,1,1)
const NEGATIVE_COLOR:=Color(1,0.5,0.5,1)
const POSITIVE_COLOR:=Color(0.5,1,0.5,1)

var unitRef:Unit:
	set(val):
		if unitRef is Unit: push_error("This display already had a unitRef, swapping them is not supported yet.")
		unitRef = val
		if unitRef is Unit:
#			stats = unitRef.attributes.stats
#			info = unitRef.attributes.info
#			refresh_ui()
			pass

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
		var keyUsed:String = "baseStats" if useBaseStats else "stats"
		
		if nameLabel: nameLabel.text = unitRef.attributes.info["nickName"]
		
		if classLabel: classLabel.text = unitRef.attributes.info["className"]
		
		if healthLabel: healthLabel.text = str(unitRef.attributes[keyUsed]["health"]) + " / " + str(unitRef.attributes[keyUsed]["healthMax"])
		if healthMeter: healthMeter.value = unitRef.attributes[keyUsed]["health"]; healthMeter.max_value = unitRef.attributes[keyUsed]["healthMax"]
		
		if energyLabel: energyLabel.text = str(unitRef.attributes[keyUsed]["energy"]) + " / " + str(unitRef.attributes[keyUsed]["energyMax"])
		if energyMeter: energyMeter.value = unitRef.attributes[keyUsed]["energy"]; energyMeter.max_value = unitRef.attributes[keyUsed]["energyMax"]
		
		if delayLabel: delayLabel.text = "Delay: " + str(unitRef.attributes[keyUsed]["turnDelay"])
		
		if strengthLabel: 
			strengthLabel.text = unitRef.attributes.stats["strength"]
			var color:Color
			if unitRef.attributes.stats.strength < unitRef.attributes[keyUsed].strength: color = NEGATIVE_COLOR
			elif unitRef.attributes.stats.strength > unitRef.attributes[keyUsed].strength: color = POSITIVE_COLOR
			else: color = NORMAL_COLOR
			strengthLabel.add_theme_color_override("font_color", color)
			
		if agilityLabel: 
			agilityLabel.text = unitRef.attributes.stats["agility"]
			var color:Color
			if unitRef.attributes.stats.agility < unitRef.attributes[keyUsed].agility: color = NEGATIVE_COLOR
			elif unitRef.attributes.stats.agility > unitRef.attributes[keyUsed].agility: color = POSITIVE_COLOR
			else: color = NORMAL_COLOR
			agilityLabel.add_theme_color_override("font_color", color)
			
		if mindLabel: 
			mindLabel.text = unitRef.attributes.stats["mind"]
			var color:Color
			if unitRef.attributes.stats.mind < unitRef.attributes[keyUsed].mind: color = NEGATIVE_COLOR
			elif unitRef.attributes.stats.mind > unitRef.attributes[keyUsed].mind: color = POSITIVE_COLOR
			else: color = NORMAL_COLOR
			mindLabel.add_theme_color_override("font_color", color)

func animated_glow(enabled:bool):
	if enabled:
		tween.play()
	else:
		tween.stop()
		
func emit_unit():
	emit_signal("clicked_unit", unitRef)
