extends Resource
class_name Inventory

signal inventory_altered

@export var inventorySize:int

@export var canStoreItems:bool #If false, any non equipped items will be sent to the stockPile

@export var items:Array[Resource]

@export var equipped:Dictionary = {
	Const.equipmentSlots.R_HAND:null,
	Const.equipmentSlots.L_HAND:null,
	Const.equipmentSlots.ARMOR:null,
	Const.equipmentSlots.ACC1:null,
	Const.equipmentSlots.ACC2:null,
	Const.equipmentSlots.ACC3:null
}
#[null,load("res://Resources/Items/Weapons/BasicGun.tres"),null,null,null,null]

@export var stockPile:Resource #Meant to be an inventory to be shared by others

var owner:Object

	#Basic
func send_to_stockpile(item:Item):#If no stockpile is present, the items are discarded
	if stockPile == null:
		item.queue_free()#If there is no stockPile, delete the item
	else:
		transfer_to_other(item,stockPile)

func transfer_to_self(item:Item):#Take from another inventory
	var tempHolder = item
	item.free()
	add_item(tempHolder)
	pass
	
func transfer_to_other(item:Item,destination:Inventory):#Remove from inventory and add it to another
	var tempHolder:Item = item
	destination.add_item(tempHolder)
	item.free()
	pass

func remove_item(item:Item):#Should only remove items from this inventory!
	if equipped.values().has(item) or items.has(item):
		item.free()
	else:
		push_error("Cannot remove an item that's not in this inventory!")
	
		pass

func add_item(item):#Create an item in this inventory
	items.append(item.duplicate())
	if not canStoreItems or items.size() > inventorySize:
		send_to_stockpile(items.pop_back())
	emit_signal("inventory_altered")
	
func connect_to_stockPile(stockpile:Inventory):
	stockPile = stockpile



#Equipment
func equip_item(item,slot:String, replace:bool=false):#If replace is true, any item already in the slot will be deleted, otherwise it's sent to the inventory
	var slotName:String
	if !item.compatibleSlots.has(slot):#Ensure it can be equipped there
		push_error("This equipment cannot be inserted in that slot")
		return
	
	if not replace and equipped[slot] != null:
		add_item( equipped[slot] )
	equipped[slot] = item
		
		
func unequip_item(slot:String):#WIP (Should use enum)
	add_item(equipped[slot])
	equipped[slot] = null
		
func get_bonus_attributes_from_equipment()->Dictionary:
	var dictWithTotal:Dictionary
	for equipment in equipped:#Loop trough equipment
		if equipment is Equipment:#And ensure it is equipment
			for equipmentBonus in equipment.statBonuses.keys():
				dictWithTotal[equipmentBonus] += equipment.statBonuses[equipmentBonus]
	return dictWithTotal
