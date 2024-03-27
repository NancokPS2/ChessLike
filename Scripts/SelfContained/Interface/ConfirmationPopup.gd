extends Control
class_name ConfirmationPopup

signal decided(confirmed:bool)

@export var acceptBtn:Button:
	set(val):
		acceptBtn = val
		acceptBtn.pressed.connect(decide, true)
		
@export var declineBtn:Button:
	set(val):
		declineBtn = val
		declineBtn.pressed.connect(decide, false)
		
@export var textLabel:Label


func _ready() -> void:
	visible = false
	if not (acceptBtn and declineBtn and textLabel):
		generate_UI()
		
func popup(show:bool = !visible):
	visible = show
	mouse_filter = Control.MOUSE_FILTER_PASS if show else Control.MOUSE_FILTER_IGNORE
	acceptBtn.mouse_filter = Control.MOUSE_FILTER_PASS if show else Control.MOUSE_FILTER_IGNORE
	declineBtn.mouse_filter = Control.MOUSE_FILTER_PASS if show else Control.MOUSE_FILTER_IGNORE
	textLabel.mouse_filter = Control.MOUSE_FILTER_PASS if show else Control.MOUSE_FILTER_IGNORE

func set_msg(text:String=""):
	if textLabel is Label: textLabel.text = text 
	else: push_error("No Label has been set.")

func generate_UI():
	acceptBtn = Button.new(); add_child(acceptBtn)
	declineBtn = Button.new(); add_child(declineBtn)
	textLabel = Label.new(); add_child(textLabel)
	
	acceptBtn.set_anchor_and_offset(SIDE_TOP,0.75,0)
	acceptBtn.set_anchor_and_offset(SIDE_RIGHT,0.5,0)
	
	declineBtn.set_anchor_and_offset(SIDE_TOP,0.75,0)
	declineBtn.set_anchor_and_offset(SIDE_LEFT,0.5,0)
	declineBtn.set_anchor_and_offset(SIDE_RIGHT,1.0,0)
	
	textLabel.set_anchor_and_offset(SIDE_RIGHT,1.0,0)
	textLabel.set_anchor_and_offset(SIDE_BOTTOM,0.75,0)

func decide(decision:bool):
	decided.emit(decision)
	popup(false)

