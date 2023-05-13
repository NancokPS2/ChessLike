extends Panel
class_name UnitDisplay

signal clicked_unit

var unitRef:Unit:
	set(val):
		unitRef = val
		if unitRef is Unit:
			stats = unitRef.attributes.stats
			info = unitRef.attributes.info
			refresh_ui()

var stats
var info
@onready var tween = get_tree().create_tween().set_loops()

@export_group("Input")
@export var actAsButton:bool=true

## If set, actAsButton will be automatically disabled to avoid double inputs, it will be restored if the reference is lost for any reason
@export var buttonRef:Button#:
#	set(val):
#		buttonRef = val
#		if buttonRef is Button and actAsButton:
#			set_meta("actAsButtonWasON",true)
#			actAsButton = false
#		elif get_meta("actAsButtonWasON"): 
#			actAsButton = true

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

func _gui_input(event: InputEvent) -> void:
	if event.is_action_released("primary_click"):
		emit_signal("clicked_unit",self)
		animated_glow(true)
		accept_event()
	
	
func refresh_ui():
	if unitRef is Unit:
		if nameLabel: nameLabel.text = info["nickName"]
		
		if classLabel: classLabel.text = info["className"]
		
		if healthLabel: healthLabel.text = str(stats["health"]) + " / " + str(stats["healthMax"])
		if healthMeter: healthMeter.value = stats["health"]; healthMeter.max_value = stats["healthMax"]
		
		if energyLabel: energyLabel.text = str(stats["energy"]) + " / " + str(stats["energyMax"])
		if energyMeter: energyMeter.value = stats["energy"]; energyMeter.max_value = stats["energyMax"]
		
		if delayLabel: delayLabel.text = "Delay: " + str(stats["delay"])
		
		if strengthLabel: strengthLabel.text = stats["strength"]
		if agilityLabel: agilityLabel.text = stats["agility"]
		if mindLabel: mindLabel.text = stats["mind"]

func animated_glow(enabled:bool):
	if enabled:
		tween.play()
	else:
		tween.stop()
		
