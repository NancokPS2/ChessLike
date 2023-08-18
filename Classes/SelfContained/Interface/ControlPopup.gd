extends Control
class_name ControlPopup

signal popped(value)


@export var universalCancelAction:String = "ui_cancel"
@export var exclusive:bool = false #If true, everything else is paused when this appears
var isPopped:bool

func _ready() -> void:
	pop_up(visible)
	top_level

func pop_up(active:bool=true, popPos:Vector2 = position):
	process_mode = Node.PROCESS_MODE_ALWAYS if active else Node.PROCESS_MODE_DISABLED
	mouse_filter = Control.MOUSE_FILTER_PASS if active else Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_ALL if active else Control.FOCUS_NONE
	
	if exclusive and get_tree(): get_tree().paused = active
	
	position = popPos
	visible = active
	isPopped = active
	popped.emit(active)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(universalCancelAction):
		pop_up(false)
