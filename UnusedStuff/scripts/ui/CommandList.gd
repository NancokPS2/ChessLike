extends ItemList

signal movement

func _ready():
	pass
	
func _process(delta):
	if FieldVars.combatState == 0:
		one_off_click(0)
		enabled_actions()
			
			
#	elif is_selected(1) == true:
#		$"../SkillList".visible = true
#		visible = false
#		unselect(1)

func one_off_click(item_index): #Makes sure to unselect items and to issue a click cooldown after an item is used 
	if is_selected(item_index) == true:
		unselect(item_index)
		UniversalFunc.click_cooldown()

func enabled_actions():
	if not FieldVars.turnOwnerReference == null:
		if FieldVars.turnOwnerReference.remainingActs["moves"] <= 0:
			set_item_disabled(0, true)
		else:
			set_item_disabled(0, false)
			
		if FieldVars.turnOwnerReference.remainingActs["actions"] <= 0:
			set_item_disabled(1, true)
			set_item_disabled(2, true)
		else:
			set_item_disabled(1, false)
			set_item_disabled(2, false)
		pass
