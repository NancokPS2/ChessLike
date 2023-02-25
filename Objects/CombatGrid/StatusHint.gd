extends Label

var tempTextTimer:SceneTreeTimer


func _ready() -> void:
	Events.HINT_UPDATE.connect(set_text)
	
	Events.SETUP_enter.connect(set_text.bind("UI_HINT_SETUP"))
	
	Events.COMBAT_enter.connect(set_text.bind(""))
	Events.COMBAT_IDLE_enter.connect(set_text.bind(""))
	Events.COMBAT_MOVING_enter.connect(set_text.bind("UI_HINT_COMBAT_MOVING"))
	Events.COMBAT_ACTING_enter.connect(set_text.bind("UI_HINT_COMBAT_ACTING"))
	Events.COMBAT_FACING_enter.connect(set_text.bind("UI_HINT_COMBAT_FACING"))
	Events.COMBAT_TARGETING_enter.connect(set_text.bind("UI_HINT_COMBAT_TARGETING"))
	


func temp_text(tempText:String,duration:float):
	var oldText = text#Save the old text
	text = tempText#Change the text
	tempTextTimer = get_tree().create_timer(duration)#Prepare the timer
	tempTextTimer.timeout.connect(return_to_old_text.bind(tempText,oldText))#Make it return to it when it finishes
	
func return_to_old_text(textExpected:String, oldText:String):
	if textExpected == text:#The text is just as it was left when changed temporarily
		text = oldText#Return it to it's original state
	#If the text is different from expected, it means it was changed and it's time to revert has passed
		
	pass
