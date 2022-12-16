extends Popup
signal finished
	

func button_pressed(button:Button):#Start button pressed
	if button.internalName == "Accept":
		emit_signal("finished",true)
	elif button.internalName == "Cancel":
		emit_signal("finished",false)
	hide()
