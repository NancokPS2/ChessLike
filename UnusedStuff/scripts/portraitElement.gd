extends Control

var ID
var chosen
var whiteColor = Color(128,128,128,1)
var blackColor = Color(1,1,1,1)
func _ready():
	$CoolFX.set_visible(false)
		
func _input(event):
	if event is InputEventMouseButton && Globalvars.clickReady == true && event.button_mask == 1 && $Sprite.get_rect().has_point(get_local_mouse_position()):
		UniversalFunc.click_cooldown()
		chosen = true
		FieldVars.selectedUnitID = ID
		FieldVars.selectedUnitReference = UniversalFunc.get_unit_by_ID(ID)
		#FieldVars.selectedUnitReference
	elif event is InputEventMouseButton && (event.button_mask == 1 || event.button_mask == 2 ) && !$Sprite.get_rect().has_point(get_local_mouse_position()):
		chosen = false
	
	if $Sprite.get_rect().has_point(get_local_mouse_position()): #When hovered show
		$CoolFX.set_visible(true)
	else:
		$CoolFX.set_visible(false)
	
	if chosen == true: #It is active so it's white and permanently visible, overriding the hover
		$CoolFX.set_modulate(whiteColor)
		$CoolFX.set_visible(true)
	elif chosen == false: #It is false so it is black
		$CoolFX.set_modulate(blackColor)

