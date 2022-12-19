extends VBoxContainerCollapsable
class_name YieldMenu
#This class can create buttons that store values and emit them trough this node

signal button_pressed

enum State {EMPTY,ABILITIES,OPTIONS}
var currentState = State.EMPTY



func _ready() -> void:
	._ready()
	expand(false)

func add_option(buttonName:String="UnassignedName",returnValue=null):#Adds a button that can return any value trough button_press()
	currentState = State.OPTIONS
	var newButton = ActionMenuButton.new(buttonName,returnValue)
	add_child(newButton)
	return newButton

func clear_menu():
	currentState = State.EMPTY
	for child in get_children():
		child.queue_free()
		
func fill_abilities(unit:Node):#Fills it with abilities from a unit, they return the ability in question
	currentState = State.ABILITIES
	for abil in unit.abilities:
		if not abil.get_class() != "Ability":
			push_error("Tried to add non-Ability to " + get_class())
			
		else:
			var button:ActionMenuButton = add_option(abil.displayedName,abil)#Create the button and keep a reference to it
			
			if not abil.check_availability() == Ability.AvailabilityStatus.OK:#Disable it if it should not be selectable
				button.disabled = true

func button_press(btn:ActionMenuButton):#Called when a button is pressed
	emit_signal("button_pressed",btn.returnValue)#Important when someone yields to this


class ActionMenuButton extends Button:
	
	var returnValue
	
	func _init(btnText:String,returnVal) -> void:
		margin_right = 1
		rect_min_size = Vector2(64,32)
		
		action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		text = btnText
		returnValue = returnVal
			
	func _ready() -> void:
		if get_parent().get_class() == "YieldMenu":
			connect("button_up",get_parent(),"button_press",[self])#Causes the parent to send a signal
		else:
			push_error("Placed " + get_class() + " under NON YieldMenu parent, freeing self...")
			queue_free()

	func _pressed():
		return returnValue
