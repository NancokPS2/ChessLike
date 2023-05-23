extends Resource
class_name Map

enum DefaultCellTags {
	WALKABLE, ## All units (dirt, path)
	EMPTY, ## Flying only (chasms)
	LIQUID, ## All except non-swimming walkers (water)
	UNSTABLE, ## All except heavy walkers (mud)
	PUSHER, ## Only heavy walkers (water current, brambles)
	HARD, ## Fall damage is increased on this kind of tile (rock)
	SOFT, ## Fall damage is negated on this kind of tile (slime, water, hay)
	NO_AIR, ## All but flying and hovering (strong wind)
	ELEVATOR, ## Walkers ignore terrain differences (ladder)
	UNTARGETABLE, ## Units may not willingly move into these (lava)
	NO_ENTRY, ## Impossible to enter
	}

@export var displayName:String
@export var internalName:String
@export var description:String

@export var heightMap:Array = []

@export var meshLibrary:MeshLibrary = preload("res://Assets/CellMesh/Base/DefaultTiles.tres")

@export var background:Texture

enum TerrainCellData {TILE_ID,TILE_POS,TAGS}
@export var terrainCells:Array[Array] = [
	[0,Vector3i.ZERO,["WALKABLE"]],
	[0,Vector3i.RIGHT,["WALKABLE"]],
	[0,Vector3i.FORWARD,["WALKABLE"]],
	[0,Vector3i.BACK,["WALKABLE"]],
	[0,Vector3i.LEFT,["WALKABLE"]],
	[0,Vector3i.LEFT*2,["WALKABLE"]],
	[0,Vector3i(1,0,1),["WALKABLE"]],
	[0,Vector3i(2,0,1),["WALKABLE"]]
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
@export var unitsToLoad:Array[CharAttributes]



