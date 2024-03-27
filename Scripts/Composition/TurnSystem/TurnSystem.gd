extends Node
class_name TurnSystem

signal turn_taken(user:TurnSystemUser)
signal time_passed(time:float)

const COMP_TURN_USER:StringName = "_TurnSystem_USER"

var refCompTurnUsers:Array[TurnSystemUser]
var currentTurnTaker:TurnSystemUser

func _enter_tree() -> void:
	get_tree().node_added.connect(on_node_entered)	

func on_node_entered(node:Node) -> void:
	if node is TurnSystemUser:
		user_add(node)
	
		
func pass_turn():
	#Get delay
	var currDelay:float = 0
	if currentTurnTaker: currDelay = currentTurnTaker.turnCurrentDelay
	
	#Apply it to everyone
	for user in user_get_all(false):
		user_advance_time(user, currDelay)
	time_passed.emit(currDelay)
	
	#Select a turn taker and reset their time
	currentTurnTaker = user_get_with_lowest_delay()
	user_reset_time(currentTurnTaker)
	turn_taken.emit(currentTurnTaker)
	
func user_get_all(fromGroup:bool)->Array[TurnSystemUser]:
	if fromGroup:
		var users:Array[TurnSystemUser]
		users.assign(get_tree().get_nodes_in_group(COMP_TURN_USER))
		return users
	else:
		return refCompTurnUsers

func user_add(user:TurnSystemUser):
	refCompTurnUsers.append(user)

func user_remove(user:TurnSystemUser):
	refCompTurnUsers.erase(user)

func user_get_sorted_by_delay()->Array[TurnSystemUser]:
	var userArr:Array[TurnSystemUser] = user_get_all(false)
	userArr.sort_custom( func(a:TurnSystemUser,b:TurnSystemUser): return a.turnCurrentDelay < b.turnCurrentDelay )
	return userArr

func user_get_with_lowest_delay()->TurnSystemUser:
	return user_get_sorted_by_delay().front()
	
func user_advance_time(user:TurnSystemUser, amount:float):
	#Take the delay from the actingUnit
	user.turnCurrentDelay -= amount

func user_reset_time(user:TurnSystemUser):
	user.turnCurrentDelay = user.turnDelayMax

	
