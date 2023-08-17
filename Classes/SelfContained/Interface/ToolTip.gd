extends Label
class_name Tooltip

const DEFAULT_STYLEBOX_COLOR:Color = Color.WEB_GRAY

@export var defaultStyleBox:bool = true:
	set(val):
		defaultStyleBox = val
		if defaultStyleBox:
			add_theme_stylebox_override("normal", TooltipStyleBoxPreset.new())


@export var focusSource:Control:
	set(val):
		if focusSource is Control:
			if focusSource.focus_entered.is_connected(activate):
				focusSource.focus_entered.disconnect(activate)
				focusSource.focus_exited.disconnect(activate)
				
			if focusSource.mouse_entered.is_connected(activate):
				focusSource.mouse_entered.disconnect(activate)
				focusSource.mouse_exited.disconnect(activate)
			
		focusSource = val
		
		if focusSource is Control:
			if activateOnFocus:
				focusSource.focus_entered.connect(activate.bind(true))
				focusSource.focus_exited.connect(activate.bind(false))
			if activateOnHover:
				focusSource.mouse_entered.connect(activate.bind(true))
				focusSource.mouse_exited.connect(activate.bind(false))

@export var activateOnFocus:bool = false
@export var activateOnHover:bool = true

func _ready() -> void:
	activate(false)
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	top_level = true
	reset_size()
	
	if not focusSource is Control and get_parent() is Control:
		focusSource = get_parent()
	else:
		focusSource = focusSource
	

func activate(value):
	visible = value
#	set_process(value)

func _process(delta: float) -> void:
	global_position = get_global_mouse_position() + Vector2.ONE*16

class TooltipStyleBoxPreset extends StyleBoxFlat:
	func _init() -> void:
		bg_color = DEFAULT_STYLEBOX_COLOR
