extends Node
 
const COMBAT_SCENE:PackedScene = preload("res://Objects/CombatGrid/CombatField.tscn")

func _ready() -> void:
#	start_combat(load("res://Resources/Maps/UniqueMaps/Default.tres") as Map)
	pass

var board:GameBoard
var grid:MovementGrid #Combat field




#var unitInAction:Unit #Unit currently taking a turn
#var unitSelected:Node #Unit currently trying to interact with
#var unitHovered:Node

var mainNode:Node #Main node of the combat scene

var mainCamera:Node#Camera of the battlefield



#var unitsInBattle:Array #Units in battle

#var unitsBenched:Array #Units that are not participating



#var UITree:CanvasLayer #The UI


var debugRef

func start_combat(map:Map):
	get_tree().change_scene_to_packed(COMBAT_SCENE)
	await get_tree().process_frame
	var mainNode:GameBoard = get_tree().current_scene
	assert(mainNode is GameBoard)
	mainNode.load_map(map)
	
	pass
