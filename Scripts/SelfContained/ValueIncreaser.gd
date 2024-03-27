extends VSeparator
class_name ValueButtons

@onready var buttonPlus:=Button.new() #Buttons to handle the changes
@onready var buttonMinus:=Button.new()
@export var nodeWithVars:Node #The owner of the variables that this button will affect, as a reference (can be set from the editor)
@export var variableName:String #The name of the variable to affect
@export var changeAmount:int = 1

func _ready():
  add_child(buttonPlus)
  add_child(buttonMinus)

  buttonMinus.anchor_right = 0.5#Spread the buttons equally
  buttonPlus.anchor_left = 0.5
  buttonPlus.anchor_right = 1
  
  buttonMinus.pressed.connect(minus_button_pressed)
  buttonPlus.pressed.connect(plus_button_pressed)


func minus_button_pressed():
  nodeWithVars.set(variableName, nodeWithVars.get(variableName) - changeAmount) 

func plus_button_pressed():
  nodeWithVars.set(variableName, nodeWithVars.get(variableName) + changeAmount) 
