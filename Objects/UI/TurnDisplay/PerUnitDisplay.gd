extends Panel
class_name UnitDisplay

signal clicked_unit

var unitRef
var stats
var info
@onready var tween = get_tree().create_tween().set_loops()

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
	assert(unit.info is Dictionary)
	assert(unit.stats is Dictionary)
		
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
	
func get_unit_data():
	stats = unitRef.stats
	info = unitRef.info
	
	
func refresh_ui():
	if unitRef != null:
		get_unit_data()
		$Name.text = info["nickName"]
		$Class.text = info["className"]
		$Health.text = str(stats["health"]) + " / " + str(stats["healthMax"])
		$Delay.text = "UNIT_DELAY" + ": " + str(stats["delay"])

func animated_glow(enabled:bool):
	if enabled:
		tween.play()
	else:
		tween.stop()
		
