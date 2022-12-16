extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_OpenClassPanel_button_down():
	$EquipmentPanel.visible = false
	if $ClassPanel.visible == false:
		$ClassPanel.visible = true
	else:
		$ClassPanel.visible = false
	pass # Replace with function body.


func _on_OpenEquipMenu_button_down():
	$ClassPanel.visible = false
	if $EquipmentPanel.visible == false:
		$EquipmentPanel.visible = true
	else:
		$EquipmentPanel.visible = false
	pass # Replace with function body.
