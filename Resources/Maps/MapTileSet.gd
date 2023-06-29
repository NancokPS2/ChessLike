extends Resource
class_name MapTileSet

@export var meshLibrary:MeshLibrary

@export var tags:Dictionary = {0:["WALKABLE"],1:[""],2:[""],3:[""],4:[""],5:[""],6:[""],7:[""],8:[""],9:[""],10:[""],11:[""]} #cellID(int):CellTags(Array[String])
#	set(val): 
#		if val.size() > itemIDs.size():
#			push_error("There's more arrays than cellIDs!")
#			tags = []
#		else:
#			tags = val
			

var itemIDs:PackedInt32Array:
	get: return meshLibrary.get_item_list()

#func get_item_move_cost(itemID:int)->int:
#	var terrainCosts = moveCostWalk
#	if not itemIDs.has(itemID): push_error("itemIDs does not include " + str(itemID)); return 1
#	if not terrainCosts.has(itemID): push_error("terrainCosts does not include " + str(itemID)); return 1
#	return terrainCosts[itemID]
