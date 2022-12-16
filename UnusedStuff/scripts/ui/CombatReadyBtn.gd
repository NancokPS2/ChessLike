extends Button



func _on_ReadyBtn_button_up(): #Button that ends the preparation phase
	FieldVars.combatStage = 1
	queue_free()
