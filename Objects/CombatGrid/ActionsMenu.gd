extends VBoxContainerCollapsable
class_name YieldMenu

signal button_pressed

func add_misc_option(buttonName:String="UnassignedName",returnValue=null):#Adds a button
	var newButton = ActionMenuButton.new(buttonName,returnValue)
	pass

func clear_menu():
	for child in get_children():
		child.queue_free()


func button_press(btn:ActionMenuButton):#Called when a button is pressed
	emit_signal("button_pressed",btn.returnValue)#Important when someone yields to this


class ActionMenuButton extends Button:
	
	var returnValue
	
	func _init(btnText:String,returnVal) -> void:
		margin_right = 1
		rect_min_size = Vector2(64,32)
		text = btnText
		returnValue = returnVal
		
	func _ready() -> void:
		if get_parent().get_class() == "YieldMenu":
			connect("button_up",get_parent(),"button_press",[self])#Causes the parent to send a signal
