extends Resource
class_name Map

@export (String) var displayName
@export (String) var internalName
@export (String) var description

@export (Array) var heightMap = []

@export (MeshLibrary) var meshLibrary = preload("res://Assets/CellMesh/Base/DefaultTiles.tres")

@export (Texture) var background

enum TerrainTileData {TILE_ID,TILE_POS,FLAGS}
@export (Array,Array) var terrainTiles = [
	[0,Vector3.ZERO,0],
	[0,Vector3.RIGHT,0],
	[0,Vector3.FORWARD,0],
	[0,Vector3.BACK,0],
	[0,Vector3.LEFT,0]
]

@export (Array,Dictionary) var unitsToGenerate = [
	{
		"unitName":"Human",
		"raceName":"HUMAN",
		"className":"CIVILIAN",
		"factionName":"DEFAULT",
		"positionInGrid":(Vector2(0,0))
	}
]
@export (Array,String) var unitsToLoad



