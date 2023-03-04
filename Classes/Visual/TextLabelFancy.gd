extends Label
class_name FancyLabel

## The text moves and fades away
@export_category("Float")
var floatTween:Tween
@export var floatActiveOnReady:= false
@export var floatAutoFree:= true
@export var floatTargetPosition:= Vector2.UP * 20
@export var floatRandomVariation:= 1.5
@export var floatSpeed:= 1.0
@export var floatFadeDuration:= 1.0
@export var floatDeleteOnCompletion:= true
@export var floatTweenTransition:Tween.TransitionType
@export_enum("LINEAR") var floatAnimation:String = "LINEAR"


#The text flashes a specific color
@export_category("Flashing")
@onready var flashingTween:Tween
@export var flashingEnabled:= false:
	set(value):
		flashingEnabled = value
		if flashingTween and flashingTween.is_running():
			return
		var originalColor:Color = modulate
		flashingTween = create_tween()
		if flashingTween != null:
			flashingTween.set_loops()
			flashingTween.tween_property(self,"modulate",flashingColor,flashingDuration/2)
			flashingTween.tween_property(self,"modulate",originalColor,flashingDuration/2)

			if flashingEnabled:
				flashingTween.play()
			else:
				flashingTween.stop()
		
@export var flashingColor:= Color.WHITE * 0.8
@export var flashingDuration:= 1.0


func _ready() -> void:
	if floatActiveOnReady:
		floatAnimation
	flashingEnabled = flashingEnabled

func float_animation(freeWhenFinishing:bool=floatAutoFree):
	if floatTween and floatTween.is_running():
		return
		
	visible = true
	floatTween = create_tween()
	var originalColor:= modulate
	var originalPosition:= position
	
	var variatedPosition:Vector2 = Vector2(randfn(floatTargetPosition.x, floatRandomVariation), randfn(floatTargetPosition.y, floatRandomVariation))
	
	match floatAnimation:
		"LINEAR":
			floatTween.set_parallel(true)
			floatTween.tween_property(self,"position",position + variatedPosition,floatSpeed)
	
	
	floatTween.tween_property(self,"modulate",Color(originalColor.r, originalColor.g, originalColor.b, 0.0), floatFadeDuration)
	if freeWhenFinishing:
		floatTween.tween_callback(queue_free)
	
	floatTween.play()
	
	await floatTween.finished
	modulate = originalColor
	position = originalPosition
	

