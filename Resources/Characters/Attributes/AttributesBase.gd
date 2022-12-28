extends Resource
class_name AttributesBase

export (String) var internalName
export (String) var displayName = "ERR_NONAME"

export (PackedScene) var model = load("res://Assets/CellMesh/Characters/Dummy/Dummy.tscn")


export (Dictionary) var stats ={
	#Combat only
	"health":100,
	"energy":30,
	"turnDelay":0,
	"actions":1,
	"moves":1,
	#Primary
	"healthMax":100,
	"energyMax":30,
	"strength":0,
	"agility":0,
	"mind":0,
	"special":0,
	"moveDistance":0,
	"defense":0,
	"dodge":0,
	"accuracy":0,
	#Secondary
	"turnDelayMax":100,
	"delay":0,
	"actionsMax":1,
	"movesMax":1,
	"movementType":0
}
export (Dictionary) var statModifiers ={
	"maxHealth":1.0,
	"maxEnergy":1.0,
	"strength":1.0,
	"agility":1.0,
	"mind":1.0,
	"special":1.0,
	"moveDistance":1.0,
	"defense":1.0,
	"dodge":1.0,
	"accuracy":1.0,
}
