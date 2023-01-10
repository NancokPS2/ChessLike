extends Panel

var displayScene = preload("res://Objects/UI/TurnDisplay/PerUnitDisplay.tscn")#Returns the unit inside when clicked
var active:bool

func _ready() -> void:
	Events.connect("SETUP_exit",self,"on_setup_exit")

func populate_list(units:Array):
	for unit in units:
		var display = displayScene.instance()
		$ScrollContainer/List.add_child(display)
		display.load_unit(unit)
		display.connect("clicked_unit",self,"set_selected_unit")

func set_selected_unit(display:Node):
	Ref.unitSelected = display.unitRef

func on_setup_exit():
	queue_free()


