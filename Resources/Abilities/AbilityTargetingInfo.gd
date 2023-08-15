extends Resource
class_name AbilityTargetingInfo

var boardRef:GameBoard
var gridRef:MovementGrid

var ability:Ability
var user:Unit
var unitsTargeted:Array[Unit]
var cellsTargeted:Array[Vector3i]
