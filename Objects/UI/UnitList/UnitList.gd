extends Panel

var displayScene = preload("res://Objects/UI/TurnDisplay/PerUnitDisplay.tscn")#Returns the unit inside when clicked
var active:bool

func _ready() -> void:
	Events.SETUP_exit.connect(on_setup_exit)

func populate_list(units:Array[Unit]):
	for unit in units:
		var display = displayScene.instantiate()
		$ScrollContainer/List.add_child(display)
		display.load_unit(unit)
		display.clicked_unit.connect(set_selected_unit)

func set_selected_unit(display:Node):
	Ref.unitSelected = display.unitRef

func on_setup_exit():
	queue_free()


