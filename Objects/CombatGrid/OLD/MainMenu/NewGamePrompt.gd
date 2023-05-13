extends Panel

signal create_save

func _ready() -> void:
	$Confirm.connect("button_up",self,"confirm")

func confirm():
	if $NameEntry.text.is_valid_filename():
		emit_signal("create_save",$NameEntry.text)
	else:
		$Warning.text = "Invalid name!"
		
	$Back.emit_signal("button_up")
	
