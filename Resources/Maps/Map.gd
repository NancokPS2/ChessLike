extends Resource
class_name Map

@export var displayName:String
@export var internalName:String
@export var description:String

@export var heightMap:Array = []

@export var meshLibrary:MeshLibrary = preload("res://Assets/CellMesh/Base/DefaultTiles.tres")

@export var background:Texture

enum TerrainTileData {TILE_ID,TILE_POS,FLAGS}
@export var terrainTiles:Array[Array] = [
	[0,Vector3.ZERO,0],
	[0,Vector3.RIGHT,0],
	[0,Vector3.FORWARD,0],
	[0,Vector3.BACK,0],
	[0,Vector3.LEFT,0]
]

@export var unitsToGenerate:Array[Dictionary] = [
	{
		"unitName":"Human",
		"raceName":"HUMAN",
		"className":"CIVILIAN",
		"factionName":"DEFAULT",
		"positionInGrid":(Vector2(0,0))
	}
]
@export var unitsToLoad:Array[String]



