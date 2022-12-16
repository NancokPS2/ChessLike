extends TileMap
export(PackedScene) var movementMarker_scene
export(PackedScene) var targetingMarker_scene
var moveExpansionRemaining
var movementCounter
var movementMarks = PoolVector2Array()
var prevMarks = PoolVector2Array()
var newMarks = PoolVector2Array()
var markedTiles = PoolVector2Array()

func copy_parent_shape():
	var tempShape = get_parent().get_custom_transform()
	set_custom_transform(tempShape)
		
func movement_marking(coordinates,moveDistance):
	clear()
	movementMarks = PoolVector2Array()
	var movementMarker = movementMarker_scene.instance()
	if moveDistance <= 0:  
		return
		
	if moveDistance >= 1:
		moveExpansionRemaining = moveDistance
		movementMarks.append(Vector2(coordinates))
		prevMarks.append(Vector2(coordinates))
		
	if moveDistance >= 2:
		for _i in range(2,moveDistance):
			for x in prevMarks:
				if !Maps.solidTiles.has(get_parent().get_cellv(x+Vector2.LEFT)):
					newMarks.append(x + Vector2.LEFT)
				if !Maps.solidTiles.has(get_parent().get_cellv(x+Vector2.RIGHT)):
					newMarks.append(x + Vector2.RIGHT)
				if !Maps.solidTiles.has(get_parent().get_cellv(x+Vector2.UP)):
					newMarks.append(x + Vector2.UP)
				if !Maps.solidTiles.has(get_parent().get_cellv(x+Vector2.DOWN)):
					newMarks.append(x + Vector2.DOWN)
				movementMarks.append_array(newMarks)#save the tiles
				prevMarks.resize(0)#clear the old marks
				prevMarks.append_array(newMarks)#make the new ones old
				newMarks.resize(0)#clear the new ones
		for e in movementMarks:
			set_cellv(e,0)

func _on_CommandList_item_activated(index):
	if index == 0:
		FieldVars.combatState = 1
		var vectorPos = Vector2(FieldVars.turnOwnerReference.gridCoords[0],FieldVars.turnOwnerReference.gridCoords[1])
		movement_marking(vectorPos, FieldVars.turnOwnerReference.stats["move"])
