extends CanvasLayer

func _ready() -> void:
	Ref.UITree = self
	
func combat_starts():

		get_node("TurnManager").populate_list(CVars.unitsInPlay)
		#update_ability_list(CVars.refUnitInAction)
		$Controller.linkedUnit = CVars.refUnitInAction
		$Controller.linkedUnit.inventory.equip_item(load("res://Resources/Items/Weapons/BasicGun.tres"),Const.equipmentSlots.L_HAND)
		$Controller.unit_base_menu($Controller.linkedUnit)

func button_pressed(button:Button):#Start button pressed
	if button.internalName == "StartCombat":
		$Popup/Message.text = tr("MESSAGE_QUERY_STARTCOMBAT")
		$Popup.popup()
		var accepted:bool = yield($Popup,"finished")
		
		if accepted:
			get_parent().change_combat_stage(CVars.combatStages.COMBAT)
