extends KinematicBody2D
var ID:int
var stats
var friendly: bool
var pathfindType: String = "default" #Temporary value
var pathfindNodesList: Array #Locations that the unit will travel trough
var pathfindStage: int = 0 #The unit will move towards the node with this stage



func _ready():
	$Sprite.texture = load(Stats.unitStats[ID].texture)#Get texture
	
	for x in get_tree().get_nodes_in_group("PATHFIND NODES"):#Read all path nodes
		pathfindNodesList.append(x.get_global_position())
		
	stats = Stats.unitStats[ID].duplicate()#Gets all stats

	update_health_circle()#Set the right color to the circle
	
	
func _physics_process(delta):
	advance()
	
	
var canMove: bool = true #Temporary value
func advance():
	if canMove == true and !pathfindNodesList.empty(): #Checks if it is allowed to move and if it has pathfinding targets
		look_at(pathfindNodesList[pathfindStage])
		move_and_slide(Vector2.RIGHT.rotated(rotation) * stats.speed)
	
func get_current_health():
	return stats.health - stats.damage
	
func reduce_health(amount):
	stats.damage += amount
	update_health_circle()
	if stats.damage > stats.health:
		queue_free()
	
func update_health_circle():
	var healthPercent = get_current_health()/stats.health
	var greenColor = clamp(255 * healthPercent, 0, 255)
	var redColor = clamp(255 - greenColor, 0, 255)
	$HealthCircle.set_modulate(Color(redColor,greenColor,0,255))
	#$ProgressBar.value = stats.health

var hasTriggeredSURVIVOR: bool = false
func take_damage(incomingDamage,damageType): #Calculates damage to take based on the units properties
	var armorValue = stats.defense
	var finalDamage = incomingDamage
	#Start with armorType
	if stats.armorType == Globals.armorType.FLAT:#Light Armor
		finalDamage = finalDamage - armorValue
	elif stats.armorType == Globals.armorType.LIGHT:#Light Armor
		if damageType == Globals.damageType.BLAST:#1/2 effectiveness against BLAST
			armorValue = armorValue * 0.5
		finalDamage = finalDamage * (1 - (armorValue / 100) ) 
	elif stats.armorType == Globals.armorType.HEAVY:#Heavy Armor
		if damageType == Globals.damageType.PIERCE:#3/4 effectiveness against PIERCE
			armorValue = armorValue * 0.75
		finalDamage = (finalDamage * (1 - (armorValue / 100) ) ) - (armorValue)
			
	#Then, secondaryArmorType
	if hasTriggeredSURVIVOR == false and stats.armorProperties.has(Globals.secondaryArmorEffect.SURVIVOR):#Upon death, stay alive for up to 1 second
		if incomingDamage > get_current_health(): #If the damage is going to kill the unit...
			finalDamage = 0 #Cancel the damage
			yield(get_tree().create_timer(1.0), "timeout") #Wait 1 second
			hasTriggeredSURVIVOR = true #Disable the property

	if stats.armorProperties.has(Globals.secondaryArmorEffect.ADAPTIVE):
		var tenPercentOfMax = stats.health * 0.1
		if finalDamage > tenPercentOfMax: #If damage goes above 10% of their max health...
			var modifiedDamage = finalDamage - tenPercentOfMax #Amount of damage that will be altered
			finalDamage = tenPercentOfMax + (modifiedDamage * 0.35)#All damage going above 10% is set to 35% of it's value

	reduce_health(finalDamage)
	
