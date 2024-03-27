extends Label
class_name FancyLabel

	
@export_category("Float")# The text moves and fades away, set floatingTargetPosition to 0,0 to disable movement
var floatTween:Tween
@export var floatActiveOnReady:= false ##Activates the floating when added to the scene
@export var floatAutoFree:= true ##Automatically deletes this label once the fading ends
@export var floatTargetPosition:= Vector2.UP * 20 ##Where it should move towards (relative to original position)
@export var floatRandomVariation:= 1.5 ##How much it should deviate from the target position, set to 0 to disable
@export var floatFadeDuration:= 1.0 ##How long it takes for the whole animation to play out
@export var floatTweenTransition:Tween.TransitionType ##Type of Tween transition to use
@export_enum("LINEAR") var floatAnimation:String = "LINEAR" ##Type of animation to use, only LINEAR is available atm


#The text flashes a specific color
@export_category("Flashing")
@onready var flashingTween:Tween
@export var flashingEnabled:= false:#Wether to be flashing or not
	set(value):
		flashingEnabled = value
		if flashingTween and flashingTween.is_running():
			push_warning("Prevented activation of flashing animation due to invalid Tween (This node may not be in the tree yet)")
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
		
@export var flashingColor:= Color.WHITE * 0.8 #Color to flash (this is a 20% gray by default)
@export var flashingDuration:= 1.0 #How long it takes to flash to and from the flashingColor

@export_category("Icon")
var icon:Sprite2D
@export var iconTexture:Texture2D
@export var iconEnabled:=false
@export_enum("LEFT", "ABOVE", "BELOW", "RIGHT", "ON_TOP") var iconAlignment
@export var iconOffset:=Vector2.ZERO

func _ready() -> void:
	if floatActiveOnReady:#Auto start the floating animation when ready
		floatAnimation
	flashingEnabled = flashingEnabled#Update flashing status when ready

func float_animation(freeWhenFinishing:bool=floatAutoFree):#This can be called manually
	if floatTween and floatTween.is_running():
		push_warning("Prevented activation of float animation due to invalid Tween (This node may not be in the tree yet)")
		return
		
	visible = true
	floatTween = create_tween()
	floatTween.set_trans(floatTweenTransition)
	var originalColor:= modulate
	var originalPosition:= position
	
	
	var variatedPosition:Vector2 = Vector2(randfn(floatTargetPosition.x, floatRandomVariation), randfn(floatTargetPosition.y, floatRandomVariation))
	
	match floatAnimation:
		"LINEAR":
			floatTween.set_parallel(true)
			floatTween.tween_property(self,"position",position + variatedPosition,floatFadeDuration)
	
	
	floatTween.tween_property(self,"modulate",Color(originalColor.r, originalColor.g, originalColor.b, 0.0), floatFadeDuration)
	if freeWhenFinishing:
		floatTween.tween_callback(queue_free)
	
	floatTween.play()
	
	await floatTween.finished
	modulate = originalColor
	position = originalPosition
	
func place_icon(alignment:int=iconAlignment):
	icon=Sprite2D.new()
	icon.centered = true
	icon.texture = iconTexture
	
	var iconSize = Vector2(iconTexture.get_width(), iconTexture.get_height())
	var rect:Rect2 = get_rect()
	
	match iconAlignment:
		"LEFT":
			icon.position.x = rect.position - ( iconSize.x / 2 ) 
			icon.position.y = rect.size.y / 2
			
		"ABOVE":
			icon.position.x = rect.size.x / 2
			icon.position.y = rect.size.y - iconSize.y
			
			
