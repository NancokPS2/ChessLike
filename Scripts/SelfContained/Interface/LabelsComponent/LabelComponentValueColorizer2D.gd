extends Node
class_name LabelComponentValueColorizer2D

var labelRef:Label
@export var intMode:bool=false

@export var baseValue:float
#@export var positiveValue:float
#@export var negativeValue:float

@export var baseColor:=Color.WHITE
@export var positiveColor:=Color.GREEN
@export var negativeColor:=Color.RED

func _enter_tree() -> void:
	labelRef = get_parent() if get_parent() is Label else null
	
	
func update_color():
	var value:float = labelRef.text.to_float()
	
	if intMode: value = int(value)
	
	var offset:float = value / baseValue
	
	var color:Color
	if offset > 1: 
		color = positiveColor
	elif offset < 1: 
		color = negativeColor
	else: 
		color = baseColor
		
	labelRef.add_theme_color_override("font_color", color)
