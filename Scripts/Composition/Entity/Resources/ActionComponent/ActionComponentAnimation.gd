extends Resource
class_name ComponentActionResourceAnim

var action_log_cache: ComponentActionLog

func start(action_log: ComponentActionLog):
	if action_log_cache:
		push_warning("The cache wasn't empty!")
	action_log_cache = action_log
	_start()
	
	
func _start():
	pass


func run(delta: float):
	_run(delta)
	
	
func _run(delta: float):
	pass
	
	
func finish():
	_finish()
	action_log_cache = null
	
	
func _finish():
	pass