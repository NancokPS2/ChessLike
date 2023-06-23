extends Resource
class_name MapTileSet

@export var meshLibrary:MeshLibrary

var itemIDs:PackedInt32Array:
	get: return meshLibrary.get_item_list()

@export var terrainCosts:Dictionary = {0:1,1:1,2:1,3:1,4:1,5:1,6:1,7:1,8:1,9:1,10:1,11:1}

func get_item_cost(itemID:int)->int:
	if not itemIDs.has(itemID): push_error("itemIDs does not include " + str(itemID)); return 1
	if not terrainCosts.has(itemID): push_error("terrainCosts does not include " + str(itemID)); return 1
	return terrainCosts[itemID]
