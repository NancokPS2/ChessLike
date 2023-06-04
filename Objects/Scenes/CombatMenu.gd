extends NestedMenu

#const ACTION_TYPES:Array[String] = []
#const MOVEMENT_TYPES:Array =[]
#
#@onready var board = Ref.board
#
#func _init() -> void:
#	Events.UPDATE_UNIT_INFO.connect(refresh_ui)
#
#func refresh_ui():
#	if board.actingUnit.attributes.stats.actions <=0:
#		for element in get_all_elements():
#
#			pass
