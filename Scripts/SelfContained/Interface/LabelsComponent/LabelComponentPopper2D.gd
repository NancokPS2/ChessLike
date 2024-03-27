extends Node
class_name LabelComponentPopper2D

var labelRef:Label
#var movementTween:Tween
#var modulationTween:Tween

@export var movementFinal:Vector2 = Vector2.UP * 2
@export var movementDuration:float = 1

@export var modulationFinal:=Color.WHITE
@export var modulationDuration:float = 1

func _enter_tree() -> void:
	labelRef = get_parent() if get_parent() is Label else null

func pop():
	var newLabel:Label = labelRef.duplicate(DUPLICATE_SCRIPTS + DUPLICATE_SIGNALS)
	newLabel.top_level = true
	newLabel.visible = true
	
	var tween:Tween = create_tween()
	tween.tween_property(newLabel, "position", movementFinal, movementDuration).parallel().tween_property(newLabel, "modulate", Color.WHITE, modulationDuration)
	
	tween.play()
#	var moveTween = create_tween()
#	moveTween.tween_property(newLabel, "position", movementFinal, movementDuration)
#
#	var moduTween = create_tween()
#	moduTween.tween_property(newLabel, "modulate", Color.WHITE, modulationDuration)
	
#	movementTween.play()
#	modulationTween.play()
	pass
