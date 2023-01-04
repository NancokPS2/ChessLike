extends Panel
class_name UnitDisplay

signal clicked_unit

var unitRef:Node
var stats
var info

func load_unit(unit:Unit):#Used to load and display a unit simultaneously
	if unit != unitRef and not ( unit.get("stats") == {} or unit.get("info") == {} ):
		unitRef = unit
	else:
		return
		
	assert(unit is Unit)
		
	get_unit_data()
	refresh_ui()
	
func clear_unit():
	unitRef = Node.new()
	for child in get_children():
		child.set("text","")

func _gui_input(event: InputEvent) -> void:
	if event.is_action_released("primary_click"):
		emit_signal("clicked_unit",self)
		accept_event()
	
func get_unit_data():
	stats = unitRef.stats
	info = unitRef.info
	
	
func refresh_ui():
	if unitRef != null:
		$Name.text = info["nickName"]
		$Class.text = info["className"]
		$Health.text = str(stats["health"]) + " / " + str(stats["healthMax"])
		$Delay.text = "UNIT_DELAY" + ": " + str(stats["delay"])

func animated_glow(enabled:bool):
	if enabled:
		$Tween.interpolate_property(self,"modulate",Color.white,Color.white+Color(1.5,1.5,1.5,1),0.7)
		$Tween.start()
	else:
		$Tween.stop_all()
		
