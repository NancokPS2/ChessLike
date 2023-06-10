extends Node
 
const COMBAT_SCENE:PackedScene = preload("res://Objects/Scenes/CombatField.tscn")


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
	
	pass
