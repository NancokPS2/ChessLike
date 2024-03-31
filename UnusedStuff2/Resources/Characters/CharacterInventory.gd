extends Resource
class_name CharInventory

signal inventory_altered

@export var contents:Array[Item]

@export var inventorySize:int = 999

@export var canStorecontents:bool #If false, any non equipped contents will be sent to the stockPile

@export var stockPile:Inventory #Meant to be an inventory to be shared by others


func take_from_inventory(item:Item)->Item:
	if not item in contents: push_error("This item is not from this inventory."); return null
	
	var takenItem:Item = item.duplicate()
	contents.erase(item)
	return takenItem
		
func get_all_contents():
	return contents

	#Basic
func send_to_stockpile(item:Item):#If no stockpile is present, the contents are discarded
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


func add_item(item:Item):#Create an item in this inventory
	contents.append(item.duplicate())
	if not canStorecontents or contents.size() > inventorySize:
		send_to_stockpile(contents.pop_back())
	emit_signal("inventory_altered")
	
func connect_to_stockPile(stockpile:Inventory):
	stockPile = stockpile
