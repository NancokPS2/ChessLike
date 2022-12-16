extends Timer

func _on_ClickCooldown_timeout(): #click Cooldown ends
	Globalvars.clickReady = true
