extends MovementGrid

var terrainTemplate:PackedScene = preload("res://Objects/CombatGrid/TerrainTemplate.tscn")

func _ready() -> void:
	pass



func construct(mapResource:Map):
	set_tileset(mapResource.tileSet)
		
	for x in mapResource.heightMap:#Layer creation
		var elevationLayer = terrainTemplate.instance()
		elevationLayer.set_name( "Layer" + str(x) )
		add_child(elevationLayer)
		
	for e in mapResource.terrainTiles:#Place tiles
		get_parent().gridData.set_cellv_data(e["tilePos"],"elevation",e["elevation"])#Update gridData stuff
		get_parent().gridData.set_cellv_data(e["tilePos"],"moveRequirement",e["moveRequirement"])
		get_parent().gridData.set_cellv_data(e["tilePos"],"tileID",e["tileID"])
		
		
		
		if e["elevation"] == 0:
			set_cellv(e["tilePos"],e["tileID"])
		else:
			get_node( "Layer" + str(e["elevation"]) ).set_cellv(e["tilePos"],e["tileID"])
			
		print_debug( "Added cell " + str(e["tileID"]) + " at position " + str(e["tilePos"]) + " in layer " + str(e["elevation"]) )

		
