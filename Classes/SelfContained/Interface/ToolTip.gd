extends Label
class_name Tooltip

const DEFAULT_STYLEBOX_COLOR:Color = Color.WEB_GRAY

const TextureAnchors:Dictionary = {
	LEFT = Rect2(-1,0,0,1),
	TOP = Rect2(0,-1,1,0),
	RIGHT = Rect2(1,0,2,1),
	BOTTOM = Rect2(0,1,1,2),
	COVERING = Rect2(0,0,1,1)
}
@export var texture:Texture
@export var textureAnchors:Rect2 = TextureAnchors.TOP

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

var textureRectRef:=TextureRect.new()

func _ready() -> void:
	activate(false)
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	top_level = true
	reset_size()
	place_texture()
	
	if not focusSource is Control and get_parent() is Control:
		focusSource = get_parent()
	else:
		focusSource = focusSource
	

func activate(value):
	visible = value
#	set_process(value)

func place_texture(anchors:Rect2 = textureAnchors):
	if textureRectRef.get_parent() != self: add_child(textureRectRef)
	textureRectRef.texture = texture
	textureRectRef.anchor_left = anchors.position.x
	textureRectRef.anchor_top = anchors.position.y
	textureRectRef.anchor_right = anchors.size.x
	textureRectRef.anchor_bottom = anchors.size.y
	
	pass
	

func _process(delta: float) -> void:
	global_position = get_global_mouse_position() + Vector2.ONE*16

class TooltipStyleBoxPreset extends StyleBoxFlat:
	func _init() -> void:
		bg_color = DEFAULT_STYLEBOX_COLOR
