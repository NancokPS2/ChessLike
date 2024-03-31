extends Resource
class_name AbilityTargetingInfo

var boardRef:GameBoard:
	get:
		if not boardRef and user: push_warning("No boardRef was set, fetching from user."); return user.boardRef
		else: return boardRef
	

var ability:Ability
var user:Unit
		
var unitsTargeted:Array[Unit]
var cellsTargeted:Array[Vector3i]
