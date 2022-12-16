extends Resource
class_name GridData#Allows storing information on each tile of a TileMap

var mapData:Dictionary

#static func tr_Vector2(vector2:Vector2):#Turns a Vector2 into a String usable by GridData
#	var returnValue:String
#	returnValue += str(int(vector2.x))
#	returnValue += ","
#	returnValue += str(int(vector2.y))
#	return returnValue

func get_cellv_data(vector2:Vector2,entry:String = ""):
	if not mapData.has(vector2):
		set_cellv_data(vector2,"dummy",null)
	if not mapData[vector2].has(entry):
		set_cellv_data(vector2,entry,null)
		
	if entry == "":
		return mapData[vector2]
	else:
		return mapData[vector2][entry]

func generate_map_data(cells:PoolVector2Array,overwrite:bool = false):#fills mapData with several dictionaries, if unsafe, overwrites all data
	for x in cells:
		if overwrite or !mapData.has(x):#If unsafe or lacking the key
			print_debug("UNFINISHED METHOD")
		pass	

func set_cellv_data(cellVector:Vector2,entry:String,value):
	if not mapData.has(cellVector):
		mapData[cellVector] = {}
	mapData[cellVector][entry] = value
	
func mark_cell_as_occupied_by(cellVector:Vector2,object:Object):
	set_cellv_data(cellVector,"occupant",object)

