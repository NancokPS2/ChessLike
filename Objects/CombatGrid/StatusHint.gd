extends Label

var tempTextTimer:SceneTreeTimer


func _ready() -> void:
	Events.connect("HINT_UPDATE",self,"set_text")
	
	Events.connect("SETUP_enter",self,"set_text",["UI_HINT_SETUP"])
	
	Events.connect("COMBAT_enter",self,"set_text",[""])
	Events.connect("COMBAT_IDLE_enter",self,"set_text",[""])
	Events.connect("COMBAT_MOVING_enter",self,"set_text",["UI_HINT_COMBAT_MOVING"])
	Events.connect("COMBAT_ACTING_enter",self,"set_text",["UI_HINT_COMBAT_ACTING"])
	Events.connect("COMBAT_FACING_enter",self,"set_text",["UI_HINT_COMBAT_FACING"])
	Events.connect("COMBAT_TARGETING_enter",self,"set_text",["UI_HINT_COMBAT_TARGETING"])
	


func temp_text(tempText:String,duration:float):
	var oldText = text#Save the old text
	text = tempText#Change the text
	tempTextTimer = get_tree().create_timer(duration)#Prepare the timer
	tempTextTimer.connect("timeout",self,"return_to_old_text",[tempText,oldText])#Make it return to it when it finishes
	
func return_to_old_text(textExpected:String, oldText:String):
	if textExpected == text:#The text is just as it was left when changed temporarily
		text = oldText#Return it to it's original state
	#If the text is different from expected, it means it was changed and it's time to revert has passed
		
	pass
